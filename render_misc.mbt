///|
/// Render hr, br and comments (port of `render_divider`, `render_break`,
/// `render_comment`).
fn render_divider(
  ctx : RenderCtx,
  out : StringBuilder,
  _node : @dom.Node,
) -> Unit {
  out.write_string("\n\n")
  out.write_string(ctx.options.horizontal_rule)
  out.write_string("\n\n")
}

///|
fn render_break(
  _ctx : RenderCtx,
  out : StringBuilder,
  _node : @dom.Node,
) -> Unit {
  // Render a "hard line break".
  out.write_string("  \n")
}

///|
/// Only the list-end comments we inserted ourselves are rendered; all other
/// comments fall through (port of `commonmark.renderComment`).
fn render_comment(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Bool {
  ignore(ctx)
  if node.data == @domutils.LIST_END_COMMENT_DATA {
    out.write_string("\n\n<!--")
    out.write_string(node.data)
    out.write_string("-->\n\n")
    true
  } else {
    false
  }
}
