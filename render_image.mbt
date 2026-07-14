///|
/// The alt description sits between square brackets, so escape those (port
/// of `commonmark.escapeAlt`).
fn escape_alt(alt : String) -> String {
  let out = StringBuilder(size_hint=alt.length())
  let mut prev : Char = ' '
  for i, ch in alt {
    if (ch == '[' || ch == ']') && (i == 0 || prev != '\\') {
      out.write_char('\\')
    }
    out.write_char(ch)
    prev = ch
  }
  out.to_string()
}

///|
/// Render `<img>` as `![alt](src "title")` (port of
/// `commonmark.renderImage`). Returns false when there is no src.
fn render_image(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Bool {
  let src = @textutils.trim_space(@domext.attr_or(node, "src", ""))
  if src is "" {
    return false
  }
  let src = assemble_absolute_url("img", src, ctx.options.domain)
  let title = @domext.attr_or(node, "title", "").replace_all(old="\n", new=" ")
  let alt = @domext.attr_or(node, "alt", "").replace_all(old="\n", new=" ")
  let alt = escape_alt(alt)
  out.write_string("![")
  out.write_string(protect_internal_marker_literals(alt))
  out.write_string("](")
  out.write_string(protect_internal_marker_literals(src))
  if title != "" {
    // The destination and title must be separated by a space
    out.write_char(' ')
    out.write_string(
      @textutils.surround_by_quotes(protect_internal_marker_literals(title)),
    )
  }
  out.write_char(')')
  true
}
