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
/// Static dispatch to the commonmark renderers (filled in P4). Returns false
/// when no renderer handled the node, like `RenderTryNext`.
fn render_element(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Bool {
  ignore(ctx)
  ignore(out)
  ignore(node)
  false
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
/// `commonmark.handleTextTransform`): entity-escape angle brackets, then
/// insert escape markers (P5).
fn render_text(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Unit {
  ignore(ctx)
  let content = node.data
    .replace_all(old="<", new="&lt;")
    .replace_all(old=">", new="&gt;")
  out.write_string(content)
}
