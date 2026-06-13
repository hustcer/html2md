///|
/// Make sure `ol`/`ul` elements only contain `li` children: stray content is
/// moved into the previous `li` or wrapped in a fresh one (port of
/// `domutils.MoveListItems`).
pub fn move_list_items(node : @dom.Node) -> Unit {
  if node.kind is Element && @domext.node_name(node) is ("ol" | "ul") {
    let mut previous_li : @dom.Node? = None
    for child in node.children.copy() {
      if child.kind is Element && @domext.node_name(child) is "li" {
        previous_li = Some(child)
      } else if child.kind is Text && @textutils.trim_space(child.data) is "" {
        // Skip the node, probably just formatting of code
      } else {
        match previous_li {
          Some(li) => {
            // Move this stray content into the previous "li" node.
            @domext.remove_node(child)
            li.append_child(child)
          }
          None =>
            // Wrap this node with its own "li" node.
            previous_li = Some(@domext.wrap_node(child, @dom.element("li")))
        }
      }
    }
  }
  for child in node.children.copy() {
    move_list_items(child)
  }
}
