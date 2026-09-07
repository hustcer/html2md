///|
/// Merge directly adjacent text nodes into one (port of
/// `domutils.MergeAdjacentTextNodes`). Needed after node removal, which can
/// leave two #text nodes next to each other and would confuse the
/// whitespace-collapse pass.
pub fn merge_adjacent_text_nodes(node : @dom.Node) -> Unit {
  let children = node.children
  let mut read = 0
  let mut write = 0
  while read < children.length() {
    let child = children[read]
    let mut end = read + 1
    if child.kind is Text {
      while end < children.length() && children[end].kind is Text {
        end += 1
      }
    }
    if end > read + 1 {
      // Assemble each text run once, avoiding repeated prefix copies and
      // per-node searches/removals from the parent's child array.
      let content = StringBuilder()
      for i in read..<end {
        content.write_string(children[i].data)
        children[i].parent = None
      }
      let merged = @dom.text(content.to_string())
      merged.parent = Some(node)
      children[write] = merged
    } else {
      merge_adjacent_text_nodes(child)
      if write != read {
        children[write] = child
      }
    }
    read = end
    write += 1
  }
  // Compact in place to retain the array identity and untouched node objects.
  children.truncate(write)
}
