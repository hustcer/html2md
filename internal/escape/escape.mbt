///|
/// Characters that have special meaning in markdown and therefore get an
/// escape marker inserted before them (registered via `EscapedChar` in the
/// Go commonmark plugin).
fn is_markdown_char(ch : Char) -> Bool {
  match ch {
    '\\'
    | '*'
    | '_'
    | '-'
    | '+'
    | '.'
    | '>'
    | '|'
    | '$'
    | '#'
    | '='
    | '['
    | ']'
    | '('
    | ')'
    | '!'
    | '~'
    | '`'
    | '"'
    | '\'' => true
    _ => false
  }
}

///|
/// Insert an escape marker before each markdown-special character (port of
/// `converter.escapeContent`). `U+0000` is replaced with the replacement
/// character for security. A no-op when escaping is disabled.
pub fn escape_content(content : String, enabled? : Bool = true) -> String {
  if !enabled {
    return content
  }
  let out = StringBuilder(size_hint=content.length())
  for ch in content {
    if ch == '\u{0000}' {
      out.write_char('\u{FFFD}')
    } else if is_markdown_char(ch) {
      out.write_char(MARKER_ESCAPING)
      out.write_char(ch)
    } else {
      out.write_char(ch)
    }
  }
  out.to_string()
}
