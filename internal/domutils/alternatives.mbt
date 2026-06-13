///|
priv enum MarkdownStructure {
  ContainerBlock
  LeafBlock
  Inline
  Uncategorized
} derive(Eq)

///|
fn get_markdown_structure(name : String) -> MarkdownStructure {
  match name {
    "#document"
    | "html"
    | "head"
    | "body"
    | "blockquote"
    | "ul"
    | "ol"
    | "li" =>
      // A container block can also contain other blocks.
      ContainerBlock
    "hr" | "pre" | "h1" | "h2" | "h3" | "h4" | "h5" | "h6" =>
      // Leaf blocks can contain inline content but NOT other blocks.
      LeafBlock
    "#text"
    | "span"
    | "code"
    | "b"
    | "strong"
    | "i"
    | "em"
    | "a"
    | "img"
    | "br" => Inline
    // "div"/"p" just place newlines, so they are not categorized.
    _ => Uncategorized
  }
}

///|
/// Replace block elements that ended up inside leaf blocks or inline content
/// (invalid markdown) with sensible alternatives (port of
/// `domutils.LeafBlockAlternatives`): headings become bold + line break,
/// blockquotes become quoted spans, pre becomes code, hr disappears,
/// everything else degrades to a span.
pub fn leaf_block_alternatives(doc : @dom.Node) -> Unit {
  fn finder(node : @dom.Node, inside_leaf : Bool, inside_inline : Bool) {
    let name = @domext.node_name(node)
    let structure = get_markdown_structure(name)
    let mut current = node
    if structure is (ContainerBlock | LeafBlock) &&
      (inside_leaf || inside_inline) {
      match name {
        "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => {
          current = @domext.rename(node, "strong")
          @domext.insert_after(current, @dom.element("br"))
        }
        "blockquote" => {
          guard node.parent is Some(parent) else { return }
          parent.insert_before(@dom.text(" \""), Some(node))
          current = @domext.rename(node, "span")
          @domext.insert_after(current, @dom.text("\" "))
        }
        "pre" => current = @domext.rename(node, "code")
        "hr" => {
          @domext.remove_node(node)
          return
        }
        _ => current = @domext.rename(node, "span")
      }
    }
    let inside_leaf = inside_leaf || structure is LeafBlock
    let inside_inline = inside_inline || structure is Inline
    for child in current.children.copy() {
      finder(child, inside_leaf, inside_inline)
    }
  }

  finder(doc, false, false)
}
