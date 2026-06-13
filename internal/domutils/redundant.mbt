///|
/// Unwrap nodes that have an ancestor of the same "type" (port of
/// `domutils.RemoveRedundant`). `match_fn(n, p)` decides whether `p` is the
/// same type as `n`; a node is redundant when `match_fn(n, n)` holds and some
/// ancestor matches.
pub fn remove_redundant(
  doc : @dom.Node,
  match_fn : (@dom.Node, @dom.Node) -> Bool,
) -> Unit {
  for node in @domext.all_nodes(doc) {
    if has_same_type_ancestor(node, match_fn) {
      @domext.unwrap_node(node)
    }
  }
}

///|
fn has_same_type_ancestor(
  n : @dom.Node,
  match_fn : (@dom.Node, @dom.Node) -> Bool,
) -> Bool {
  if !match_fn(n, n) {
    return false
  }
  let mut current = n.parent
  while current is Some(p) {
    if match_fn(n, p) {
      return true
    }
    current = p.parent
  }
  false
}
