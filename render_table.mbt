///|
priv struct TableCell {
  content : String
  align : String
}

///|
priv struct TableRow {
  cells : Array[TableCell]
}

///|
priv struct PendingTableCell {
  row : Int
  col : Int
  cell : TableCell
}

///|
fn render_table(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Bool {
  if ctx.is_inside_link {
    return false
  }
  if @domext.attr_or(node, "role", "").to_lower() is "presentation" {
    render_presentation_table(ctx, out, node)
    return true
  }
  let rows : Array[TableRow] = []
  let row_nodes : Array[@dom.Node] = []
  collect_table_row_nodes(row_nodes, node)
  build_table_rows(ctx, rows, row_nodes)
  if rows.length() == 0 {
    return false
  }
  let column_count = table_column_count(rows)
  if column_count == 0 {
    return false
  }
  out.write_string("\n\n")
  write_table_row(out, rows[0], column_count)
  write_table_delimiter(out, rows[0], column_count)
  for i in 1..<rows.length() {
    write_table_row(out, rows[i], column_count)
  }
  out.write_string("\n\n")
  true
}

///|
fn render_presentation_table(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let row_nodes : Array[@dom.Node] = []
  collect_table_row_nodes(row_nodes, node)
  let rows : Array[String] = []
  for row_node in row_nodes {
    let cells : Array[String] = []
    for child in row_node.children.copy() {
      match @domext.node_name(child) {
        "th" | "td" => cells.push(render_table_cell(ctx, child))
        _ => ()
      }
    }
    let row = @textutils.trim_space(cells.join(" "))
    if row != "" {
      rows.push(row)
    }
  }
  if rows.length() > 0 {
    out.write_string("\n\n")
    out.write_string(rows.join("\n\n"))
    out.write_string("\n\n")
  }
}

///|
fn collect_table_row_nodes(rows : Array[@dom.Node], node : @dom.Node) -> Unit {
  match @domext.node_name(node) {
    "tr" => rows.push(node)
    "table" | "thead" | "tbody" | "tfoot" =>
      for child in node.children.copy() {
        collect_table_row_nodes(rows, child)
      }
    _ => ()
  }
}

///|
fn build_table_rows(
  ctx : RenderCtx,
  rows : Array[TableRow],
  row_nodes : Array[@dom.Node],
) -> Unit {
  let pending : Array[PendingTableCell] = []
  for row_index, row_node in row_nodes {
    match build_table_row(ctx, row_node, row_index, pending) {
      Some(row) => rows.push(row)
      None => ()
    }
  }
}

///|
fn build_table_row(
  ctx : RenderCtx,
  row_node : @dom.Node,
  row_index : Int,
  pending : Array[PendingTableCell],
) -> TableRow? {
  let cells : Array[TableCell] = []
  let mut col_index = 0
  for child in row_node.children.copy() {
    match @domext.node_name(child) {
      "th" | "td" => {
        drain_pending_table_cells(cells, pending, row_index, col_index)
        col_index = cells.length()
        let cell = {
          content: render_table_cell(ctx, child),
          align: normalize_table_align(@domext.attr_or(child, "align", "")),
        }
        let col_span = parse_table_span(@domext.attr_or(child, "colspan", ""))
        let row_span = parse_table_span(@domext.attr_or(child, "rowspan", ""))
        cells.push(cell)
        for offset in 1..<col_span {
          cells.push(empty_table_cell(cell.align))
          for row_offset in 1..<row_span {
            pending.push({
              row: row_index + row_offset,
              col: col_index + offset,
              cell: empty_table_cell(cell.align),
            })
          }
        }
        for row_offset in 1..<row_span {
          pending.push({
            row: row_index + row_offset,
            col: col_index,
            cell: empty_table_cell(cell.align),
          })
        }
        col_index = cells.length()
      }
      _ => ()
    }
  }
  drain_pending_table_cells(cells, pending, row_index, col_index)
  if cells.length() == 0 {
    None
  } else {
    Some({ cells, })
  }
}

///|
fn drain_pending_table_cells(
  cells : Array[TableCell],
  pending : Array[PendingTableCell],
  row_index : Int,
  start_col : Int,
) -> Unit {
  let mut col_index = start_col
  let mut keep_going = true
  while keep_going {
    match pop_pending_table_cell(pending, row_index, col_index) {
      Some(cell) => {
        cells.push(cell)
        col_index += 1
      }
      None => keep_going = false
    }
  }
}

///|
fn pop_pending_table_cell(
  pending : Array[PendingTableCell],
  row_index : Int,
  col_index : Int,
) -> TableCell? {
  for i in 0..<pending.length() {
    let item = pending[i]
    if item.row == row_index && item.col == col_index {
      return Some(pending.remove(i).cell)
    }
  }
  None
}

///|
fn empty_table_cell(align : String) -> TableCell {
  { content: "", align }
}

///|
fn normalize_table_align(value : String) -> String {
  match value.to_lower() {
    "left" => "left"
    "center" => "center"
    "right" => "right"
    _ => ""
  }
}

///|
fn parse_table_span(value : String) -> Int {
  let mut span = 0
  for ch in value {
    if ch < '0' || ch > '9' {
      return 1
    }
    span = span * 10 + ch.to_int() - '0'.to_int()
  }
  if span < 1 {
    1
  } else {
    span
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
fn table_align_at(row : TableRow, index : Int) -> String {
  match row.cells.get(index) {
    Some(cell) => cell.align
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
fn write_table_delimiter(
  out : StringBuilder,
  header : TableRow,
  column_count : Int,
) -> Unit {
  out.write_char('|')
  for i in 0..<column_count {
    match table_align_at(header, i) {
      "left" => out.write_string(" :--- |")
      "center" => out.write_string(" :---: |")
      "right" => out.write_string(" ---: |")
      _ => out.write_string(" --- |")
    }
  }
  out.write_char('\n')
}
