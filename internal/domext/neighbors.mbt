///|
/// Depth-first successor over all nodes: first child, else next sibling,
/// else climb up taking the first available next sibling (port of
/// `dom.GetNextNeighborNode`).
pub fn next_neighbor_node(node : @dom.Node) -> @dom.Node? {
  match first_child(node) {
    Some(child) => return Some(child)
    None => ()
  }
  next_neighbor_node_excluding_own_child(node)
}

///|
/// Like `next_neighbor_node` but never descends into the node's own children
/// (port of `dom.GetNextNeighborNodeExcludingOwnChild`).
pub fn next_neighbor_node_excluding_own_child(node : @dom.Node) -> @dom.Node? {
  match next_sibling(node) {
    Some(sibling) => return Some(sibling)
    None => ()
  }
  let mut current = node.parent
  while current is Some(parent) {
    match next_sibling(parent) {
      Some(sibling) => return Some(sibling)
      None => current = parent.parent
    }
  }
  None
}

///|
/// Mirror of `next_neighbor_node` walking backwards. Note the Go original
/// also tries the first child first (port of `dom.GetPrevNeighborNode`).
pub fn prev_neighbor_node(node : @dom.Node) -> @dom.Node? {
  match first_child(node) {
    Some(child) => return Some(child)
    None => ()
  }
  prev_neighbor_node_excluding_own_child(node)
}

///|
/// Port of `dom.GetPrevNeighborNodeExcludingOwnChild`.
pub fn prev_neighbor_node_excluding_own_child(node : @dom.Node) -> @dom.Node? {
  match prev_sibling(node) {
    Some(sibling) => return Some(sibling)
    None => ()
  }
  let mut current = node.parent
  while current is Some(parent) {
    match prev_sibling(parent) {
      Some(sibling) => return Some(sibling)
      None => current = parent.parent
    }
  }
  None
}

///|
fn first_child_element(node : @dom.Node) -> @dom.Node? {
  for child in node.children {
    if child.kind is Element {
      return Some(child)
    }
  }
  None
}

///|
fn next_sibling_element(node : @dom.Node) -> @dom.Node? {
  let mut current = next_sibling(node)
  while current is Some(sibling) {
    if sibling.kind is Element {
      return Some(sibling)
    }
    current = next_sibling(sibling)
  }
  None
}

///|
/// Depth-first successor over element nodes only (port of
/// `dom.GetNextNeighborElement`).
pub fn next_neighbor_element(node : @dom.Node) -> @dom.Node? {
  match first_child_element(node) {
    Some(child) => return Some(child)
    None => ()
  }
  match next_sibling_element(node) {
    Some(sibling) => return Some(sibling)
    None => ()
  }
  let mut current = node.parent
  while current is Some(parent) {
    match next_sibling_element(parent) {
      Some(sibling) => return Some(sibling)
      None => current = parent.parent
    }
  }
  None
}

///|
/// First node in the subtree (excluding `start`) matching `pred`, bounded by
/// `start` (port of `dom.FindFirstNode`).
pub fn find_first_node(
  start : @dom.Node,
  pred : (@dom.Node) -> Bool,
) -> @dom.Node? {
  fn walk(node : @dom.Node) -> @dom.Node? {
    for child in node.children {
      if pred(child) {
        return Some(child)
      }
      match walk(child) {
        Some(found) => return Some(found)
        None => ()
      }
    }
    None
  }

  walk(start)
}

///|
/// Whether any descendant of `start` matches `pred` (port of
/// `dom.ContainsNode`).
pub fn contains_node(start : @dom.Node, pred : (@dom.Node) -> Bool) -> Bool {
  find_first_node(start, pred) is Some(_)
}

///|
/// All nodes of the subtree in depth-first order, including `start`
/// (port of `dom.AllNodes`).
pub fn all_nodes(start : @dom.Node) -> Array[@dom.Node] {
  let nodes : Array[@dom.Node] = []
  fn walk(node : @dom.Node) {
    nodes.push(node)
    for child in node.children {
      walk(child)
    }
  }

  walk(start)
  nodes
}

///|
/// Replace `node` with its own children (port of `dom.UnwrapNode`).
pub fn unwrap_node(node : @dom.Node) -> Unit {
  guard node.parent is Some(parent) else { return }
  for child in node.children.copy() {
    parent.insert_before(child, Some(node))
  }
  parent.remove_child(node)
}

///|
/// Wrap `wrapper` around `existing`, returning the wrapper (port of
/// `dom.WrapNode`).
pub fn wrap_node(existing : @dom.Node, wrapper : @dom.Node) -> @dom.Node {
  guard existing.parent is Some(parent) else { return existing }
  parent.insert_before(wrapper, Some(existing))
  parent.remove_child(existing)
  wrapper.append_child(existing)
  wrapper
}
