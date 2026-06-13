///|
priv struct TableCell {
  content : String
}

///|
priv struct TableRow {
  cells : Array[TableCell]
}

///|
fn render_table(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Bool {
  if ctx.is_inside_link {
    return false
  }
  let rows : Array[TableRow] = []
  collect_table_rows(ctx, rows, node)
  if rows.length() == 0 {
    return false
  }
  let column_count = table_column_count(rows)
  if column_count == 0 {
    return false
  }
  out.write_string("\n\n")
  write_table_row(out, rows[0], column_count)
  write_table_delimiter(out, column_count)
  for i in 1..<rows.length() {
    write_table_row(out, rows[i], column_count)
  }
  out.write_string("\n\n")
  true
}

///|
fn collect_table_rows(
  ctx : RenderCtx,
  rows : Array[TableRow],
  node : @dom.Node,
) -> Unit {
  match @domext.node_name(node) {
    "tr" =>
      match build_table_row(ctx, node) {
        Some(row) => rows.push(row)
        None => ()
      }
    "table" | "thead" | "tbody" | "tfoot" =>
      for child in node.children.copy() {
        collect_table_rows(ctx, rows, child)
      }
    _ => ()
  }
}

///|
fn build_table_row(ctx : RenderCtx, row_node : @dom.Node) -> TableRow? {
  let cells : Array[TableCell] = []
  for child in row_node.children.copy() {
    match @domext.node_name(child) {
      "th" | "td" => cells.push({ content: render_table_cell(ctx, child) })
      _ => ()
    }
  }
  if cells.length() == 0 {
    None
  } else {
    Some({ cells, })
  }
}

///|
fn render_table_cell(ctx : RenderCtx, node : @dom.Node) -> String {
  let buf = StringBuilder()
  render_children(ctx, buf, node)
  let content = @textutils.trim_space(buf.to_string())
  let content = @textutils.trim_consecutive_newlines(content)
  let content = @textutils.trim_unnecessary_hard_line_breaks(content)
  let content = content.replace_all(
    old=@escape.marker_code_block_newline,
    new=" ",
  )
  let content = @textutils.collapse_inline_code_content(content)
  escape_table_pipes(content)
}

///|
fn escape_table_pipes(content : String) -> String {
  let chars = content.to_array()
  let out = StringBuilder(size_hint=content.length())
  let mut i = 0
  while i < chars.length() {
    if chars[i] == @escape.MARKER_ESCAPING &&
      i + 1 < chars.length() &&
      chars[i + 1] == '|' {
      out.write_string("\\|")
      i += 2
      continue
    }
    if chars[i] == '|' {
      out.write_string("\\|")
    } else {
      out.write_char(chars[i])
    }
    i += 1
  }
  out.to_string()
}

///|
fn table_column_count(rows : Array[TableRow]) -> Int {
  let mut count = 0
  for row in rows {
    if row.cells.length() > count {
      count = row.cells.length()
    }
  }
  count
}

///|
fn table_cell_at(row : TableRow, index : Int) -> String {
  match row.cells.get(index) {
    Some(cell) => cell.content
    None => ""
  }
}

///|
fn write_table_row(
  out : StringBuilder,
  row : TableRow,
  column_count : Int,
) -> Unit {
  out.write_char('|')
  for i in 0..<column_count {
    out.write_char(' ')
    out.write_string(table_cell_at(row, i))
    out.write_string(" |")
  }
  out.write_char('\n')
}

///|
fn write_table_delimiter(out : StringBuilder, column_count : Int) -> Unit {
  out.write_char('|')
  for _ in 0..<column_count {
    out.write_string(" --- |")
  }
  out.write_char('\n')
}
