///|
/// Render strong/em with the configured delimiter on every content line
/// (port of `commonmark.renderBoldItalic`).
fn render_bold_italic(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> EmphasisEdges {
  let delimiter = match @domext.node_name(node) {
    "strong" | "b" => ctx.options.strong_delimiter
    _ => ctx.options.em_delimiter
  }
  let buf = StringBuilder()
  ignore(render_children(ctx, buf, node))
  out.write_string(
    @textutils.delimiter_for_every_line(buf.to_string(), delimiter),
  )
  { start: Some(delimiter), end: Some(delimiter), }
}

///|
/// Only generated emphasis delimiters count as edges. Literal Markdown text
/// (including EscapeMode::Disabled) must not be mistaken for an HTML style.
priv struct EmphasisEdges {
  start : String?
  end : String?
}

///|
fn EmphasisEdges::none() -> EmphasisEdges {
  { start: None, end: None, }
}

///|
/// Separate distinct emphasis runs without inserting visible whitespace.
/// Inline containers propagate their edges, so transparent spans cannot hide
/// a collision. Whitespace already separates runs and needs no comment.
fn emphasis_needs_separator(
  left : String,
  closing : String?,
  right : String,
  opening : String?,
) -> Bool {
  guard left.rev_iter().next() is Some(before) &&
    right.iter().next() is Some(after) &&
    !before.is_whitespace() &&
    !after.is_whitespace() else {
    return false
  }
  let closing = closing.filter(delimiter => left.has_suffix(delimiter))
  let opening = opening.filter(delimiter => right.has_prefix(delimiter))
  if closing is Some(_) && opening is Some(_) {
    return true
  }
  if opening is Some(delimiter) {
    let first = right[delimiter.length():]
      .iter()
      .filter(ch => ch != @escape.MARKER_ESCAPING)
      .next()
    if delimiter.has_prefix("_") ||
      (
        !before.is_ascii_punctuation() &&
        emphasis_edge_may_be_punctuation(first)
      ) {
      return true
    }
  }
  if closing is Some(delimiter) {
    let last = left[:left.length() - delimiter.length()]
      .rev_iter()
      .filter(ch => ch != @escape.MARKER_ESCAPING)
      .next()
    if delimiter.has_prefix("_") ||
      (!after.is_ascii_punctuation() && emphasis_edge_may_be_punctuation(last)) {
      return true
    }
  }
  false
}

///|
/// ASCII letters and digits are known non-punctuation. Conservatively protect
/// other boundary characters, including Unicode punctuation, without a Unicode
/// category table or a new dependency.
fn emphasis_edge_may_be_punctuation(ch : Char?) -> Bool {
  match ch {
    Some(ch) => !(ch.is_ascii_alphabetic() || ch.is_ascii_digit())
    None => false
  }
}
