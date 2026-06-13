///|
fn get_heading_level(name : String) -> Int {
  match name {
    "h1" => 1
    "h2" => 2
    "h3" => 3
    "h4" => 4
    "h5" => 5
    _ => 6
  }
}

///|
/// Width of the widest line in chars, not counting escape markers; setext
/// underlines below 3 chars could be ambiguous (port of
/// `commonmark.getUnderlineWidth`).
fn get_underline_width(content : String, min_val : Int) -> Int {
  let mut width = 0
  for part in content.split("\n") {
    let mut w = 0
    for ch in part {
      if ch != @escape.MARKER_ESCAPING {
        w += 1
      }
    }
    if w > width {
      width = w
    }
  }
  if width < min_val {
    min_val
  } else {
    width
  }
}

///|
/// Collapse runs of 2+ spaces to a single space (Go regex `  +`).
fn collapse_multiple_spaces(content : String) -> String {
  let out = StringBuilder(size_hint=content.length())
  let mut spaces = 0
  for ch in content {
    if ch == ' ' {
      spaces += 1
    } else {
      if spaces == 1 {
        out.write_char(' ')
      } else if spaces > 1 {
        out.write_char(' ')
      }
      spaces = 0
      out.write_char(ch)
    }
  }
  if spaces > 0 {
    out.write_char(' ')
  }
  out.to_string()
}

///|
/// An ATX heading would lose a trailing "#", so force-escape it by turning
/// its escape marker into a backslash (port of
/// `commonmark.escapePoundSignAtEnd`).
fn escape_pound_sign_at_end(content : String) -> String {
  let len = content.length()
  if len == 0 || content[len - 1] != '#' {
    return content
  }
  if len >= 3 && content[len - 3] == '\\' {
    // Already escaped.
    return content
  }
  if len >= 2 && content[len - 2] == '\u{0007}' {
    // Override the placeholder with a real backslash.
    content[:len - 2].to_owned() + "\\#"
  } else {
    // No marker (escaping disabled): leave the content untouched.
    content
  }
}

///|
/// Render h1..h6 in ATX or setext style (port of
/// `commonmark.renderHeading`).
fn render_heading(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let level = get_heading_level(@domext.node_name(node))
  let buf = StringBuilder()
  render_children(ctx, buf, node)
  let content = buf.to_string()
  if @textutils.trim_space(content) is "" {
    return
  }
  if ctx.options.heading_style is Setext && level < 3 {
    // EscapeMultiLine takes care of remaining newlines.
    let content = @textutils.trim_consecutive_newlines(content)
    let content = @textutils.escape_multiline(content)
    let width = get_underline_width(content, 3)
    let underline_char = if level == 1 { "=" } else { "-" }
    out.write_string("\n\n")
    out.write_string(content)
    out.write_char('\n')
    out.write_string(underline_char.repeat(width))
    out.write_string("\n\n")
  } else {
    let content = content
      .replace_all(old="\n", new=" ")
      .replace_all(old="\r", new=" ")
      |> collapse_multiple_spaces
      |> @textutils.trim_space
      |> escape_pound_sign_at_end
    out.write_string("\n\n")
    out.write_string("#".repeat(level))
    out.write_char(' ')
    out.write_string(content)
    out.write_string("\n\n")
  }
}
