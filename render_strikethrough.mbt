///|
/// Render GFM strikethrough tags using `~~` on every content line.
fn render_strikethrough(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let buf = StringBuilder()
  render_children(ctx, buf, node)
  out.write_string(@textutils.delimiter_for_every_line(buf.to_string(), "~~"))
}
