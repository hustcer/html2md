///|
/// HTML alt text is literal text. Escape inline Markdown syntax and entities
/// so the rendered image description retains its original characters.
fn escape_alt(alt : String) -> String {
  let out = StringBuilder(size_hint=alt.length())
  for ch in alt {
    match ch {
      '\\' | '[' | ']' | '*' | '_' | '`' | '~' => {
        out.write_char('\\')
        out.write_char(ch)
      }
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '&' => out.write_string("&amp;")
      _ => out.write_char(ch)
    }
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
  let title = inline_attribute(node, "title")
  let alt = inline_attribute(node, "alt")
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
