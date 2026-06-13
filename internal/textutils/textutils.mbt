///|
/// Collapse runs of 3+ newlines down to exactly two, dropping the spaces that
/// only surround the removed newlines (port of
/// `textutils.TrimConsecutiveNewlines`).
pub fn trim_consecutive_newlines(input : String) -> String {
  let result = StringBuilder(size_hint=input.length())
  let space_buffer = StringBuilder()
  let mut newline_count = 0
  for ch in input {
    if ch == '\n' {
      newline_count += 1
      if newline_count <= 2 {
        // Preserve up to 2 newlines, including preceding spaces
        result.write_string(space_buffer.to_string())
        result.write_char('\n')
      }
      space_buffer.reset()
    } else if ch == ' ' {
      space_buffer.write_char(' ')
    } else {
      newline_count = 0
      result.write_string(space_buffer.to_string())
      result.write_char(ch)
      space_buffer.reset()
    }
  }
  result.write_string(space_buffer.to_string())
  result.to_string()
}

///|
/// Remove hard line breaks ("  \n") that directly precede a blank line — they
/// have no effect there (port of `textutils.TrimUnnecessaryHardLineBreaks`).
pub fn trim_unnecessary_hard_line_breaks(content : String) -> String {
  content
  .replace_all(old="  \n\n", new="\n\n")
  .replace_all(old="  \n  \n", new="\n\n")
  .replace_all(old="  \n \n", new="\n\n")
}

///|
/// Split `content` into (leading whitespace, trimmed content, trailing
/// whitespace), port of `textutils.SurroundingSpaces`.
pub fn surrounding_spaces(content : String) -> (String, String, String) {
  let mut end = content.length()
  while end > 0 {
    match content.get_char(end - 1) {
      Some(ch) if ch.is_whitespace() => end -= ch.utf16_len()
      _ => break
    }
  }
  let mut start = 0
  while start < end {
    match content.get_char(start) {
      Some(ch) if ch.is_whitespace() => start += ch.utf16_len()
      _ => break
    }
  }
  let left = content[0:start].to_owned()
  let trimmed = content[start:end].to_owned()
  let right = content[end:].to_owned()
  (left, trimmed, right)
}

///|
/// Trim leading and trailing unicode whitespace (Go `bytes.TrimSpace`).
pub fn trim_space(content : String) -> String {
  let (_, trimmed, _) = surrounding_spaces(content)
  trimmed
}

///|
/// Put the delimiter around the content of every non-empty line, so that
/// bold/italic markers survive multi-line content (port of
/// `textutils.DelimiterForEveryLine`).
pub fn delimiter_for_every_line(text : String, delimiter : String) -> String {
  let out = StringBuilder(size_hint=text.length())
  let lines = text.split("\n").collect()
  for i, line in lines {
    let (left, trimmed, right) = surrounding_spaces(line.to_string())
    if trimmed is "" {
      // For empty lines, we don't need a delimiter
      out.write_string(left)
      out.write_string(right)
    } else {
      out.write_string(left)
      out.write_string(delimiter)
      out.write_string(trimmed)
      out.write_string(delimiter)
      out.write_string(right)
    }
    if i < lines.length() - 1 {
      out.write_char('\n')
    }
  }
  out.to_string()
}

///|
/// Deal with multiline content inside a link or heading: blank lines become
/// "\\\n", other line endings become hard line breaks (port of
/// `textutils.EscapeMultiLine`).
pub fn escape_multiline(content : String) -> String {
  let lines = content.split("\n").collect()
  if lines.length() == 1 {
    return content
  }
  let output = StringBuilder(size_hint=content.length())
  for i, line in lines {
    let mut start = 0
    let line = line.to_string()
    while start < line.length() {
      match line.get_char(start) {
        Some(ch) if ch.is_whitespace() => start += ch.utf16_len()
        _ => break
      }
    }
    let trimmed_left = line[start:].to_owned()
    if trimmed_left is "" {
      // A blank line would interrupt the link, so escape it.
      output.write_string("\\\n")
      continue
    }
    if i == lines.length() - 1 {
      output.write_string(trimmed_left)
      continue
    }
    if trimmed_left.has_suffix("  ") {
      // We already have "  " so adding a "\n" is enough
      output.write_string(trimmed_left)
      output.write_char('\n')
    } else {
      // We *prefer* having a hard-line-break "  \n"
      output.write_string(trimmed_left)
      output.write_string("  \n")
    }
  }
  output.to_string()
}

///|
/// Prefix the first line and every line after a "\n" with `repl` (port of
/// `textutils.PrefixLines`; note a trailing newline also gets the prefix).
pub fn prefix_lines(source : String, repl : String) -> String {
  let out = StringBuilder(size_hint=source.length())
  out.write_string(repl)
  for ch in source {
    out.write_char(ch)
    if ch == '\n' {
      out.write_string(repl)
    }
  }
  out.to_string()
}

///|
/// Normalize the content of an inline code span: newlines/tabs become spaces,
/// the result is trimmed and runs of spaces are collapsed (port of
/// `textutils.CollapseInlineCodeContent`).
pub fn collapse_inline_code_content(content : String) -> String {
  let replaced = trim_space(
    content.replace_all(old="\n", new=" ").replace_all(old="\t", new=" "),
  )
  let out = StringBuilder(size_hint=replaced.length())
  let mut count = 0
  for ch in replaced {
    if ch == ' ' {
      count += 1
    } else {
      count = 0
    }
    if count > 1 {
      continue
    }
    out.write_char(ch)
  }
  out.to_string()
}

///|
/// Longest run of `fence_char` inside `content` (port of
/// `textutils.CalculateCodeFenceOccurrences`).
pub fn calculate_code_fence_occurrences(
  fence_char : Char,
  content : String,
) -> Int {
  let mut max = 0
  let mut together = 0
  for ch in content {
    if ch == fence_char {
      together += 1
      if together > max {
        max = together
      }
    } else {
      together = 0
    }
  }
  max
}

///|
/// A fence that is guaranteed not to collide with the content: one longer
/// than the longest run, at least three (port of
/// `textutils.CalculateCodeFence`).
pub fn calculate_code_fence(fence_char : Char, content : String) -> String {
  let mut repeat = calculate_code_fence_occurrences(fence_char, content) + 1
  if repeat < 3 {
    repeat = 3
  }
  fence_char.to_string().repeat(repeat)
}

///|
/// Surround a link/image title with quotes, choosing the quote character so
/// that escaping is rarely needed (port of `textutils.SurroundByQuotes`).
pub fn surround_by_quotes(content : String) -> String {
  if content is "" {
    return ""
  }
  let has_double = content.contains("\"")
  let has_single = content.contains("'")
  if has_double && has_single {
    let escaped = content.replace_all(old="\"", new="\\\"")
    "\"" + escaped + "\""
  } else if has_double {
    "'" + content + "'"
  } else {
    "\"" + content + "\""
  }
}
