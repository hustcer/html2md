///|
/// Whitespace per Go's `escape.IsSpace`: tab, LF, VT, FF, CR, space, NEL,
/// NBSP.
fn is_space_char(ch : Char) -> Bool {
  match ch {
    '\t' | '\n' | '\u{0B}' | '\u{0C}' | '\r' | ' ' | '\u{85}' | '\u{A0}' => true
    _ => false
  }
}

///|
fn is_digit_char(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
/// Previous non-marker char, or NUL when none (port of `escape.getPrev` /
/// `getPrevAsRune`, which coincide in char space).
fn get_prev(chars : Array[Char], index : Int) -> Char {
  for i = index - 1; i >= 0; i = i - 1 {
    if chars[i] != MARKER_ESCAPING {
      return chars[i]
    }
  }
  '\u{0000}'
}

///|
/// Next non-marker char, or NUL when none (port of `escape.getNext` /
/// `getNextAsRune`).
fn get_next(chars : Array[Char], index : Int) -> Char {
  for i = index + 1; i < chars.length(); i = i + 1 {
    if chars[i] != MARKER_ESCAPING {
      return chars[i]
    }
  }
  '\u{0000}'
}

///|
/// `*`/`_` is emphasis only when not followed by whitespace (port of
/// `escape.IsItalicOrBold`).
pub fn is_italic_or_bold(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('*' | '_')) {
    return -1
  }
  let next = get_next(chars, index)
  if is_space_char(next) || next == '\u{0000}' {
    return -1
  }
  1
}

///|
/// `~~` starts or ends GFM strikethrough when the second tilde is adjacent
/// modulo escape markers.
pub fn is_strikethrough(chars : Array[Char], index : Int) -> Int {
  if chars[index] != '~' {
    return -1
  }
  if get_next(chars, index) == '~' {
    1
  } else {
    -1
  }
}

///|
/// `>` is a block quote only at the (whitespace-only) start of a line (port
/// of `escape.IsBlockQuote`).
pub fn is_block_quote(chars : Array[Char], index : Int) -> Int {
  if chars[index] != '>' {
    return -1
  }
  if !only_space_before_line_start(chars, index) {
    return -1
  }
  1
}

///|
/// Scan backwards from `index`; true when everything until the line start (or
/// buffer start) is space or marker.
fn only_space_before_line_start(chars : Array[Char], index : Int) -> Bool {
  for i = index - 1; i >= 0; i = i - 1 {
    if chars[i] == '\n' {
      break
    }
    if chars[i] == MARKER_ESCAPING || chars[i] == ' ' {
      continue
    }
    return false
  }
  true
}

///|
/// `#` is an ATX heading marker at line start, with 1..6 signs followed by
/// whitespace/EOL (port of `escape.IsAtxHeader`).
pub fn is_atx_header(chars : Array[Char], index : Int) -> Int {
  if chars[index] != '#' {
    return -1
  }
  if !only_space_before_line_start(chars, index) {
    return -1
  }
  let mut pound_signs = 1
  for i = index + 1; i < chars.length(); i = i + 1 {
    let ch = chars[i]
    if ch == '#' {
      pound_signs += 1
      if pound_signs > 6 {
        return -1
      }
      continue
    }
    if ch == MARKER_ESCAPING {
      continue
    }
    if ch is (' ' | '\t' | '\n' | '\r') {
      return i - index
    }
    return -1
  }
  1
}

///|
/// `=`/`-` underlines a setext heading when the previous non-empty line holds
/// the heading content (port of `escape.IsSetextHeader`).
pub fn is_setext_header(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('=' | '-')) {
    return -1
  }
  let mut newline_count = 0
  for i = index - 1; i >= 0; i = i - 1 {
    let ch = chars[i]
    if ch == MARKER_ESCAPING || ch == ' ' {
      continue
    }
    if ch == '\n' {
      newline_count += 1
      continue
    }
    if newline_count == 0 {
      return -1
    } else if newline_count == 1 {
      return 1
    } else {
      return -1
    }
  }
  -1
}

///|
/// `-`/`_`/`*` repeated 3+ times on an otherwise blank line is a thematic
/// break (port of `escape.IsDivider`).
pub fn is_divider(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('-' | '_' | '*')) {
    return -1
  }
  if !only_space_before_line_start(chars, index) {
    return -1
  }
  let marker_char = chars[index]
  let mut count = 1
  let mut last_char = chars.length()
  for i = index + 1; i < chars.length(); i = i + 1 {
    let ch = chars[i]
    if ch == MARKER_ESCAPING || ch == ' ' {
      continue
    }
    if ch == marker_char {
      count += 1
      continue
    }
    if ch == '\n' {
      last_char = i
      break
    }
    return -1
  }
  if count >= 3 {
    last_char - index
  } else {
    -1
  }
}

///|
/// `.`/`)` after digits at line start is an ordered-list marker (port of
/// `escape.IsOrderedList`).
pub fn is_ordered_list(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('.' | ')')) {
    return -1
  }
  // Directly before the dot needs to be a digit.
  if !is_digit_char(get_prev(chars, index)) {
    return -1
  }
  for i = index - 1; i >= 0; i = i - 1 {
    let ch = chars[i]
    if ch == '\n' {
      break
    }
    if ch == ' ' || ch == MARKER_ESCAPING || is_digit_char(ch) {
      continue
    }
    return -1
  }
  let next = get_next(chars, index)
  if is_space_char(next) || next == '\u{0000}' {
    1
  } else {
    -1
  }
}

///|
/// `-`/`*`/`+` at line start followed by whitespace is an unordered-list
/// marker (port of `escape.IsUnorderedList`).
pub fn is_unordered_list(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('-' | '*' | '+')) {
    return -1
  }
  if !only_space_before_line_start(chars, index) {
    return -1
  }
  let next = get_next(chars, index)
  if is_space_char(next) || next == '\u{0000}' {
    1
  } else {
    -1
  }
}

///|
/// `![` starts an image, `[...]` an inline link (port of
/// `escape.IsImageOrLink`).
pub fn is_image_or_link(chars : Array[Char], index : Int) -> Int {
  if chars[index] == '!' {
    let next_index = index + 1
    if next_index < chars.length() && chars[next_index] == '[' {
      return 1
    }
    return -1
  }
  if chars[index] == '[' {
    for i = index + 1; i < chars.length(); i = i + 1 {
      if chars[i] == '\n' {
        return -1
      }
      if chars[i] == ']' {
        return 1
      }
    }
    return -1
  }
  -1
}

///|
/// `` ` ``/`~` repeated 3+ times at line start is a fenced code block (port
/// of `escape.IsFencedCode`).
pub fn is_fenced_code(chars : Array[Char], index : Int) -> Int {
  if !(chars[index] is ('`' | '~')) {
    return -1
  }
  for i = index - 1; i >= 0; i = i - 1 {
    if chars[i] == ' ' || chars[i] == MARKER_ESCAPING {
      continue
    }
    if chars[i] == '\n' {
      break
    }
    return -1
  }
  let mut count = 1
  let mut i = index + 1
  while i < chars.length() {
    let ch = chars[i]
    if ch == MARKER_ESCAPING {
      i += 1
      continue
    }
    if ch is ('`' | '~') {
      count += 1
      i += 1
      continue
    }
    break
  }
  if count < 3 {
    -1
  } else {
    i - index
  }
}

///|
/// A backtick always needs escaping in case it starts inline code (port of
/// `escape.IsInlineCode`).
pub fn is_inline_code(chars : Array[Char], index : Int) -> Int {
  if chars[index] != '`' {
    -1
  } else {
    1
  }
}

///|
/// A backslash escapes the following character (port of `escape.IsBackslash`).
pub fn is_backslash(chars : Array[Char], index : Int) -> Int {
  if chars[index] != '\\' {
    -1
  } else {
    1
  }
}
