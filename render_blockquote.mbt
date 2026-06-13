///|
/// Render a blockquote: trim, normalize newlines, prefix every line with
/// "> " (port of `commonmark.renderBlockquote`).
fn render_blockquote(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let buf = StringBuilder()
  render_children(ctx, buf, node)
  let content = @textutils.trim_space(buf.to_string())
  if content is "" {
    return
  }
  let content = @textutils.trim_consecutive_newlines(content)
  let content = @textutils.trim_unnecessary_hard_line_breaks(content)
  let content = @textutils.prefix_lines(content, "> ")
  out.write_string("\n\n")
  out.write_string(content)
  out.write_string("\n\n")
}
