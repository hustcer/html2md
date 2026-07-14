///|
/// Insert escape markers into text content, honoring the escape mode (wraps
/// `@escape.escape_content`).
fn escape(ctx : RenderCtx, content : String) -> String {
  @escape.escape_content(content, enabled=ctx.options.escape_mode is Smart)
}

///|
/// Prefix used to encode literal occurrences of the two internal marker
/// characters. A literal prefix is doubled, making the encoding reversible.
const MARKER_LITERAL_PREFIX : Char = '\u{F000}'

///|
fn protect_internal_marker_literals(content : String) -> String {
  let out = StringBuilder(size_hint=content.length())
  for ch in content {
    match ch {
      MARKER_LITERAL_PREFIX => {
        out.write_char(MARKER_LITERAL_PREFIX)
        out.write_char(MARKER_LITERAL_PREFIX)
      }
      @escape.MARKER_ESCAPING => {
        out.write_char(MARKER_LITERAL_PREFIX)
        out.write_char('E')
      }
      @escape.MARKER_CODE_BLOCK_NEWLINE => {
        out.write_char(MARKER_LITERAL_PREFIX)
        out.write_char('N')
      }
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn restore_internal_marker_literals(content : String) -> String {
  let chars = content.to_array()
  let out = StringBuilder(size_hint=content.length())
  let mut i = 0
  while i < chars.length() {
    if chars[i] == MARKER_LITERAL_PREFIX && i + 1 < chars.length() {
      match chars[i + 1] {
        MARKER_LITERAL_PREFIX => out.write_char(MARKER_LITERAL_PREFIX)
        'E' => out.write_char(@escape.MARKER_ESCAPING)
        'N' => out.write_char(@escape.MARKER_CODE_BLOCK_NEWLINE)
        _ => {
          out.write_char(MARKER_LITERAL_PREFIX)
          i += 1
          continue
        }
      }
      i += 2
    } else {
      out.write_char(chars[i])
      i += 1
    }
  }
  out.to_string()
}

///|
/// Resolve escape markers using the commonmark un-escaper rule set, honoring
/// the escape mode (wraps `@escape.unescape_content`).
fn unescape(ctx : RenderCtx, content : String) -> String {
  @escape.unescape_content(
    content,
    commonmark_unescapers(),
    enabled=ctx.options.escape_mode is Smart,
  )
}

///|
/// The commonmark un-escaper handlers, in the same registration order as the
/// Go commonmark plugin.
fn commonmark_unescapers() -> Array[@escape.UnEscaper] {
  [
    @escape.is_italic_or_bold, @escape.is_strikethrough, @escape.is_block_quote,
    @escape.is_atx_header, @escape.is_setext_header, @escape.is_divider, @escape.is_ordered_list,
    @escape.is_unordered_list, @escape.is_image_or_link, @escape.is_fenced_code,
    @escape.is_inline_code, @escape.is_backslash,
  ]
}
