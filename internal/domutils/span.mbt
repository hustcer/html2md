///|
fn is_fake_span(node : @dom.Node) -> Bool {
  if !(@domext.node_name(node) is "span") {
    return false
  }
  fn contains_block(current : @dom.Node) -> Bool {
    if @domext.is_block_name(@domext.node_name(current)) {
      return true
    }
    for child in current.children {
      if contains_block(child) {
        return true
      }
    }
    false
  }

  contains_block(node)
}

///|
/// Rename `span` elements containing block elements to `div` (port of
/// `domutils.RenameFakeSpans`).
pub fn rename_fake_spans(doc : @dom.Node) -> Unit {
  fn finder(node : @dom.Node) {
    let current = if is_fake_span(node) {
      @domext.rename(node, "div")
    } else {
      node
    }
    for child in current.children.copy() {
      finder(child)
    }
  }

  finder(doc)
}
