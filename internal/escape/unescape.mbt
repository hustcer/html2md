///|
/// An un-escaper inspects the characters that follow an escape marker and
/// returns how many characters the markdown construct spans (so the marker
/// becomes a backslash), or -1 when it does not apply.
///
/// `chars` is the full content as a char array; `index` is the position right
/// after the marker.
pub type UnEscaper = (Array[Char], Int) -> Int

///|
/// Resolve escape markers (port of `converter.unEscapeContent`): for each
/// marker, run the registered un-escapers; if any matches, the marker becomes
/// a backslash, otherwise it is dropped. A no-op when escaping is disabled.
///
/// `handlers` are supplied by the caller (the commonmark rule set in P5); with
/// an empty list every marker is simply removed.
pub fn unescape_content(
  content : String,
  handlers : Array[UnEscaper],
  enabled? : Bool = true,
) -> String {
  if !enabled {
    return content
  }
  let chars = content.to_array()
  let n = chars.length()
  // Mark which markers should turn into a backslash.
  let escape_at = Array::make(n, false)
  let mut index = 0
  while index < n {
    if chars[index] != MARKER_ESCAPING {
      index += 1
      continue
    }
    if index + 1 >= n {
      break
    }
    let mut skip = -1
    for handler in handlers {
      let s = handler(chars, index + 1)
      if s != -1 {
        skip = s
        break
      }
    }
    if skip == -1 {
      index += 1
      continue
    }
    escape_at[index] = true
    index += skip // marker (1) + (skip-1) consumed chars
  }
  let out = StringBuilder(size_hint=n)
  for i in 0..<n {
    let ch = chars[i]
    if ch != MARKER_ESCAPING {
      out.write_char(ch)
    } else if escape_at[i] {
      out.write_char('\\')
    }
    // otherwise: drop the marker
  }
  out.to_string()
}
