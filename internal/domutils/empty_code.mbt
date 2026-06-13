///|
fn has_text_child_nodes(start : @dom.Node) -> Bool {
  fn finder(node : @dom.Node) -> Bool {
    if node.kind is Text && node.data != "" {
      return true
    }
    for child in node.children {
      if finder(child) {
        return true
      }
    }
    false
  }

  finder(start)
}

///|
/// Remove `code` elements that contain no text at all (port of
/// `domutils.RemoveEmptyCode`).
pub fn remove_empty_code(doc : @dom.Node) -> Unit {
  let mut cursor : @dom.Node? = Some(doc)
  while cursor is Some(node) {
    if @domext.node_name(node) is "code" && !has_text_child_nodes(node) {
      let next = @domext.next_neighbor_node_excluding_own_child(node)
      @domext.remove_node(node)
      cursor = next
      continue
    }
    cursor = @domext.next_neighbor_node(node)
  }
}
