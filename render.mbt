///|
/// Render a node into `out` (port of `Converter.handleRenderNode`):
/// text nodes go through the text pipeline, elements through the static
/// renderer dispatch, everything unhandled through the fallback.
fn render_node(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Unit {
  if node.kind is Text {
    render_text(ctx, out, node)
    return
  }
  if render_element(ctx, out, node) {
    return
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
) -> Unit {
  for child in node.children.copy() {
    render_node(ctx, out, child)
  }
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
    "strong" | "b" | "em" | "i" => {
      render_bold_italic(ctx, out, node)
      true
    }
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
) -> Unit {
  let is_block = @domext.is_block_tag_type(@domext.node_name(node))
  if is_block {
    out.write_string("\n\n")
  }
  render_children(ctx, out, node)
  if is_block {
    out.write_string("\n\n")
  }
}

///|
/// Text pipeline (port of `base.handleTextTransform` +
/// `commonmark.handleTextTransform`): entity-escape angle brackets, insert
/// escape markers, then (inside links) force-escape "]".
fn render_text(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Unit {
  let content = node.data
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
