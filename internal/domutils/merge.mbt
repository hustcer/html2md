///|
fn collect_adjacent_nodes(
  start : @dom.Node,
  match_fn : (@dom.Node) -> Bool,
) -> Array[@dom.Node] {
  let collected : Array[@dom.Node] = []
  let mut cursor = @domext.next_sibling(start)
  while cursor is Some(node) {
    if @domext.node_name(node) is "span" {
      // A span has no special meaning. So we just skip it...
      cursor = @domext.next_neighbor_node(node)
    } else if match_fn(node) {
      collected.push(node)
      cursor = @domext.next_neighbor_node_excluding_own_child(node)
    } else {
      return collected
    }
  }
  collected
}

///|
fn merge_children(destination : @dom.Node, nodes : Array[@dom.Node]) -> Unit {
  for node in nodes {
    for child in node.children.copy() {
      @domext.remove_node(child)
      destination.append_child(child)
    }
    @domext.remove_node(node)
  }
}

///|
/// Merge directly adjacent matching elements into the first one (port of
/// `domutils.MergeAdjacent`), e.g. `<b>a</b><b>b</b>` -> `<b>ab</b>`.
pub fn merge_adjacent(doc : @dom.Node, match_fn : (@dom.Node) -> Bool) -> Unit {
  let mut cursor : @dom.Node? = Some(doc)
  while cursor is Some(node) {
    if match_fn(node) {
      let next_nodes = collect_adjacent_nodes(node, match_fn)
      merge_children(node, next_nodes)
    }
    cursor = @domext.next_neighbor_element(node)
  }
}
