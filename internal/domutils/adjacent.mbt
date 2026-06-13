///|
/// Merge directly adjacent text nodes into one (port of
/// `domutils.MergeAdjacentTextNodes`). Needed after node removal, which can
/// leave two #text nodes next to each other and would confuse the
/// whitespace-collapse pass.
pub fn merge_adjacent_text_nodes(node : @dom.Node) -> Unit {
  let mut prev : @dom.Node? = None
  for child in node.children.copy() {
    if child.kind is Text && prev is Some(p) && p.kind is Text {
      let merged = @domext.set_text(p, p.data + child.data)
      @domext.remove_node(child)
      prev = Some(merged)
    } else {
      merge_adjacent_text_nodes(child)
      prev = Some(child)
    }
  }
}
