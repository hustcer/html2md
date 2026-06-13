///|
/// Render strong/em with the configured delimiter on every content line
/// (port of `commonmark.renderBoldItalic`).
fn render_bold_italic(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let delimiter = match @domext.node_name(node) {
    "strong" | "b" => ctx.options.strong_delimiter
    _ => ctx.options.em_delimiter
  }
  let buf = StringBuilder()
  render_children(ctx, buf, node)
  out.write_string(
    @textutils.delimiter_for_every_line(buf.to_string(), delimiter),
  )
}
