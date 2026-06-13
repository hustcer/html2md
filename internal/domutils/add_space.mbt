///|
fn get_first_child_node(
  start : @dom.Node,
  match_fn : (@dom.Node) -> Bool,
) -> @dom.Node? {
  let mut cursor = @domext.first_child(start)
  while cursor is Some(node) {
    if @domext.node_name(node) is "span" {
      // A span has no special meaning. So we just skip it...
      cursor = @domext.next_neighbor_node(node)
    } else if match_fn(node) {
      return Some(node)
    } else {
      return None
    }
  }
  None
}

///|
fn get_last_child_node(
  start : @dom.Node,
  match_fn : (@dom.Node) -> Bool,
) -> @dom.Node? {
  let mut cursor = @domext.last_child(start)
  while cursor is Some(node) {
    if @domext.node_name(node) is "span" {
      cursor = @domext.prev_neighbor_node(node)
    } else if match_fn(node) {
      return Some(node)
    } else {
      return None
    }
  }
  None
}

///|
fn get_next_text_node(start : @dom.Node) -> @dom.Node? {
  let mut cursor = @domext.next_neighbor_node_excluding_own_child(start)
  while cursor is Some(node) {
    if node.kind is Text {
      return Some(node)
    }
    if @domext.node_name(node) is "span" {
      cursor = @domext.next_neighbor_node(node)
      continue
    }
    return None
  }
  None
}

///|
fn get_prev_text_node(start : @dom.Node) -> @dom.Node? {
  let mut cursor = @domext.prev_neighbor_node_excluding_own_child(start)
  while cursor is Some(node) {
    if node.kind is Text {
      return Some(node)
    }
    if @domext.node_name(node) is "span" {
      cursor = @domext.prev_neighbor_node(node)
      continue
    }
    return None
  }
  None
}

///|
/// When an outer element (e.g. `<strong>`) directly touches surrounding text
/// and starts/ends with an inner element (e.g. `<code>`), add a space to the
/// neighboring text so the markdown delimiters stay recognizable (port of
/// `domutils.AddSpace`).
pub fn add_space(
  doc : @dom.Node,
  is_outer : (@dom.Node) -> Bool,
  is_inner : (@dom.Node) -> Bool,
) -> Unit {
  let mut cursor : @dom.Node? = Some(doc)
  while cursor is Some(node) {
    if is_outer(node) {
      if get_first_child_node(node, is_inner) is Some(_) {
        match get_prev_text_node(node) {
          Some(prev) => ignore(@domext.set_text(prev, prev.data + " "))
          None => ()
        }
      }
      if get_last_child_node(node, is_inner) is Some(_) {
        match get_next_text_node(node) {
          Some(next) => ignore(@domext.set_text(next, " " + next.data))
          None => ()
        }
      }
    }
    cursor = @domext.next_neighbor_element(node)
  }
}
