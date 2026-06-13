///|
fn get_start_at(node : @dom.Node) -> Int {
  let raw = @domext.attr_or(node, "start", "1")
  match (try? @strconv.parse_int(raw)) {
    Ok(value) => value
    Err(_) => 1
  }
}

///|
/// Build the prefix function for a list (port of `commonmark.getPrefixFunc`):
/// bullet marker for `ul`, zero-padded "N. " for `ol`.
fn make_prefix(
  ctx : RenderCtx,
  node : @dom.Node,
  slice_length : Int,
) -> (Int) -> String {
  let start_at = get_start_at(node)
  let is_ul = @domext.node_name(node) is "ul"
  fn prefix(slice_index : Int) -> String {
    if is_ul {
      ctx.options.bullet_list_marker + " "
    } else {
      let current_index = start_at + slice_index
      let last_index = start_at + slice_length - 1
      let max_length = last_index.to_string().length()
      let num = current_index.to_string()
      // Pad numbers so every prefix lines up, e.g. "01. ".
      let padded = "0".repeat(max_length - num.length()) + num
      padded + ". "
    }
  }

  prefix
}

///|
/// Render a multi-line list item with the right indentation, including the
/// indent applied after code-block newline markers (port of
/// `commonmark.renderMultiLineListItem`).
fn render_multi_line_list_item(
  out : StringBuilder,
  content : String,
  indent_count : Int,
) -> Unit {
  let indent = " ".repeat(indent_count)
  let indented_code_newline = @escape.marker_code_block_newline + indent
  let lines = content.split("\n").collect()
  for i, line in lines {
    let line = line
      .to_string()
      .replace_all(
        old=@escape.marker_code_block_newline,
        new=indented_code_newline,
      )
    if i != 0 {
      // The first line is already indented through the prefix.
      out.write_string(indent)
    }
    out.write_string(line)
    if i < lines.length() - 1 {
      out.write_char('\n')
    }
  }
}

///|
/// Render a `ul`/`ol` list container (port of
/// `commonmark.renderListContainer`).
fn render_list_container(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let items : Array[String] = []
  for child in node.children.copy() {
    let buf = StringBuilder()
    render_node(ctx, buf, child)
    let content = @textutils.trim_space(buf.to_string())
    if content != "" {
      items.push(content)
    }
  }
  if items.length() == 0 {
    return
  }
  let prefix = make_prefix(ctx, node, items.length())
  let indent_count = prefix(0).length()
  out.write_string("\n\n")
  for i, item in items {
    out.write_string(prefix(i))
    let item = @textutils.trim_consecutive_newlines(item)
    let item = @textutils.trim_unnecessary_hard_line_breaks(item)
    let item = unescape(ctx, item)
    render_multi_line_list_item(out, item, indent_count)
    if i < items.length() - 1 {
      out.write_char('\n')
    }
  }
  out.write_string("\n\n")
}
