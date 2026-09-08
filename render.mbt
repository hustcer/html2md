///|
/// Render a node into `out` (port of `Converter.handleRenderNode`):
/// text nodes go through the text pipeline, elements through the static
/// renderer dispatch, everything unhandled through the fallback.
fn render_node(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> EmphasisEdges {
  if node.kind is Text {
    render_text(ctx, out, node)
    return EmphasisEdges::none()
  }
  if name_is_bold_or_italic(node) {
    return render_bold_italic(ctx, out, node)
  }
  if render_element(ctx, out, node) {
    return EmphasisEdges::none()
  }
  render_fallback(ctx, out, node)
}

///|
/// Render all children of `node` (iterates over a copy, mirroring
/// `dom.AllChildNodes`).
fn render_children(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> EmphasisEdges {
  let children = node.children.copy()
  if children.length() == 1 {
    return render_node(ctx, out, children[0])
  }
  let buf = StringBuilder()
  let mut previous = ""
  let mut edges = EmphasisEdges::none()
  for child in children {
    buf.reset()
    let child_edges = render_node(ctx, buf, child)
    let content = buf.to_string()
    if content.is_empty() {
      continue
    }
    if emphasis_needs_separator(previous, edges.end, content, child_edges.start) {
      out.write_string("<!-- -->")
    }
    out.write_string(content)
    edges = {
      start: if previous.is_empty() {
        child_edges.start
      } else {
        edges.start
      },
      end: child_edges.end,
    }
    previous = content
  }
  edges
}

///|
/// Static dispatch to the commonmark renderers (port of
/// `commonmark.handleRender`). Returns false when no renderer handled the
/// node, like `RenderTryNext`.
fn render_element(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Bool {
  match @domext.node_name(node) {
    "s" | "del" | "strike" => {
      render_strikethrough(ctx, out, node)
      true
    }
    "table" => render_table(ctx, out, node)
    "hr" => {
      render_divider(ctx, out, node)
      true
    }
    "br" => {
      render_break(ctx, out, node)
      true
    }
    "ul" | "ol" => {
      render_list_container(ctx, out, node)
      true
    }
    "pre" => {
      render_block_code(ctx, out, node)
      true
    }
    "code" | "var" | "samp" | "kbd" | "tt" => {
      render_inline_code(ctx, out, node)
      true
    }
    "blockquote" => {
      render_blockquote(ctx, out, node)
      true
    }
    "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => {
      render_heading(ctx, out, node)
      true
    }
    "img" => render_image(ctx, out, node)
    "a" => render_link(ctx, out, node)
    "#comment" => render_comment(ctx, out, node)
    _ => false
  }
}

///|
/// Fallback renderer (port of `handleRenderFallback`): block tags get blank
/// lines around their children, everything else renders children in place.
fn render_fallback(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> EmphasisEdges {
  let is_block = @domext.is_block_tag_type(@domext.node_name(node))
  if is_block {
    out.write_string("\n\n")
  }
  let edges = render_children(ctx, out, node)
  if is_block {
    out.write_string("\n\n")
    EmphasisEdges::none()
  } else {
    edges
  }
}

///|
/// Text pipeline (port of `base.handleTextTransform` +
/// `commonmark.handleTextTransform`): entity-escape angle brackets, insert
/// escape markers, then (inside links) force-escape "]".
fn render_text(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Unit {
  let content = protect_internal_marker_literals(node.data)
    .replace_all(old="<", new="&lt;")
    .replace_all(old=">", new="&gt;")
  let content = escape(ctx, content)
  let content = if ctx.is_inside_link {
    // The "]" would prematurely close the link text.
    content.replace_all(old=@escape.marker_escaping + "]", new="\\]")
  } else {
    content
  }
  out.write_string(content)
}
