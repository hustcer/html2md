///|
/// Comment text inserted between two adjacent lists so they are not parsed
/// as one (matches `domutils.ListEndCommentData`).
pub const LIST_END_COMMENT_DATA : String = "THE END"

///|
/// Insert `<!--THE END-->` between adjacent lists (port of
/// `domutils.AddListEndComments`; runs after whitespace collapsing).
pub fn add_list_end_comments(doc : @dom.Node) -> Unit {
  let mut cursor : @dom.Node? = Some(doc)
  while cursor is Some(node) {
    if name_is_list(node) && next_name_is_list(node) {
      @domext.insert_after(node, @dom.comment(LIST_END_COMMENT_DATA))
    }
    cursor = @domext.next_neighbor_element(node)
  }
}

///|
fn name_is_list(node : @dom.Node) -> Bool {
  @domext.node_name(node) is ("ul" | "ol")
}

///|
fn next_name_is_list(start : @dom.Node) -> Bool {
  let mut cursor = @domext.next_neighbor_node_excluding_own_child(start)
  while cursor is Some(node) {
    let name = @domext.node_name(node)
    if name is ("ul" | "ol") {
      return true
    }
    if name is "li" {
      return false
    }
    if name is "#comment" && node.data == LIST_END_COMMENT_DATA {
      return false
    }
    // If there is any text between two lists they are automatically
    // not connected anymore.
    if node.kind is Text {
      return false
    }
    if name is "hr" {
      // A divider already separates two lists...
      return false
    }
    cursor = @domext.next_neighbor_node(node)
  }
  false
}
