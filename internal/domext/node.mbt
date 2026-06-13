///|
/// Node name following the goquery convention used by JohannesKaufmann/dom:
/// `#text`, `#comment`, `#document`, or the element tag name.
pub fn node_name(node : @dom.Node) -> String {
  match node.kind {
    Text => "#text"
    Comment => "#comment"
    Document => "#document"
    Fragment => "#document-fragment"
    Doctype => "#doctype"
    Element => node.name
  }
}

///|
pub fn is_text(node : @dom.Node) -> Bool {
  node.kind is Text
}

///|
pub fn is_element(node : @dom.Node) -> Bool {
  node.kind is Element
}

///|
/// Index of `node` in its parent's child list (identity comparison), or -1
/// when detached.
pub fn index_in_parent(node : @dom.Node) -> Int {
  guard node.parent is Some(parent) else { return -1 }
  for i, child in parent.children {
    if physical_equal(child, node) {
      return i
    }
  }
  -1
}

///|
/// Next sibling in document order, if any.
pub fn next_sibling(node : @dom.Node) -> @dom.Node? {
  guard node.parent is Some(parent) else { return None }
  let index = index_in_parent(node)
  if index >= 0 && index + 1 < parent.children.length() {
    Some(parent.children[index + 1])
  } else {
    None
  }
}

///|
/// Previous sibling in document order, if any.
pub fn prev_sibling(node : @dom.Node) -> @dom.Node? {
  guard node.parent is Some(parent) else { return None }
  let index = index_in_parent(node)
  if index > 0 {
    Some(parent.children[index - 1])
  } else {
    None
  }
}

///|
pub fn first_child(node : @dom.Node) -> @dom.Node? {
  node.children.get(0)
}

///|
pub fn last_child(node : @dom.Node) -> @dom.Node? {
  node.children.get(node.children.length() - 1)
}

///|
/// Detach `node` from its parent (no-op when already detached).
pub fn remove_node(node : @dom.Node) -> Unit {
  if node.parent is Some(parent) {
    parent.remove_child(node)
  }
}

///|
/// Insert `new_node` right after `reference` under the same parent.
pub fn insert_after(reference : @dom.Node, new_node : @dom.Node) -> Unit {
  guard reference.parent is Some(parent) else { return }
  match next_sibling(reference) {
    Some(next) => parent.insert_before(new_node, Some(next))
    None => parent.append_child(new_node)
  }
}

///|
/// Replace `old_node` with `new_node` in the parent's child list.
pub fn replace_node(old_node : @dom.Node, new_node : @dom.Node) -> Unit {
  if old_node.parent is Some(parent) {
    ignore(parent.replace_child(new_node, old_node))
  }
}

///|
/// "Rename" an element by replacing it with a new element of the same
/// attributes and children (the dependency's `name` field is immutable).
/// Returns the replacement node.
pub fn rename(node : @dom.Node, new_name : String) -> @dom.Node {
  let replacement = @dom.element(new_name, attrs=node.attrs)
  for child in node.children.copy() {
    replacement.append_child(child)
  }
  replace_node(node, replacement)
  replacement
}

///|
/// Replace a text/comment node's content by swapping in a fresh node (the
/// dependency's `data` field is immutable). Returns the replacement node.
pub fn set_text(node : @dom.Node, data : String) -> @dom.Node {
  let replacement = match node.kind {
    Comment => @dom.comment(data)
    _ => @dom.text(data)
  }
  replace_node(node, replacement)
  replacement
}

///|
/// Attribute value lookup mirroring `dom.GetAttributeOr`: a present attribute
/// without value yields "", a missing attribute yields `fallback`.
pub fn attr_or(node : @dom.Node, name : String, fallback : String) -> String {
  match node.attrs.get(name) {
    Some(Some(value)) => value
    Some(None) => ""
    None => fallback
  }
}

///|
/// Escape control characters for single-line display in `dump`.
fn escape_data(data : String) -> String {
  data
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\t", new="\\t")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\"", new="\\\"")
}

///|
/// Debug representation of a DOM subtree for snapshot tests.
pub fn dump(node : @dom.Node) -> String {
  let out = StringBuilder()
  fn walk(current : @dom.Node, depth : Int) {
    out.write_string("  ".repeat(depth))
    match current.kind {
      Text => out.write_string("#text \"\{escape_data(current.data)}\"")
      Comment => out.write_string("#comment \"\{escape_data(current.data)}\"")
      _ => {
        out.write_string(node_name(current))
        if current.kind is Element && !current.attrs.is_empty() {
          for key, value in current.attrs {
            match value {
              Some(v) => out.write_string(" \{key}=\"\{v}\"")
              None => out.write_string(" \{key}")
            }
          }
        }
      }
    }
    out.write_char('\n')
    for child in current.children {
      walk(child, depth + 1)
    }
  }

  walk(node, 0)
  out.to_string()
}
