///|
fn is_empty_text(node : @dom.Node) -> Bool {
  node.kind is Text && @textutils.trim_space(node.data) is ""
}

///|
/// Swap the tag names (and attributes) of an outer/inner element pair when
/// the outer node's only meaningful child is the inner one (port of
/// `domutils.SwapTags`), e.g. `<code><pre>x</pre></code>` ->
/// `<pre><code>x</code></pre>`.
pub fn swap_tags(
  doc : @dom.Node,
  is_outer : (@dom.Node) -> Bool,
  is_inner : (@dom.Node) -> Bool,
) -> Unit {
  fn finder(node : @dom.Node) {
    if is_outer(node) {
      let children = node.children.filter(child => !is_empty_text(child))
      if children.length() == 1 && is_inner(children[0]) {
        let inner = children[0]
        // Swap names + attributes; both fields are immutable in the
        // dependency's Node, so swap via replacement (inner first, since the
        // outer rename rebuilds the child list).
        let outer_name = @domext.node_name(node)
        let outer_attrs = node.attrs
        let inner_name = @domext.node_name(inner)
        let inner_attrs = inner.attrs
        ignore(@domext.rename(inner, outer_name, attrs=outer_attrs))
        ignore(@domext.rename(node, inner_name, attrs=inner_attrs))
        return
      }
    }
    for child in node.children.copy() {
      finder(child)
    }
  }

  finder(doc)
}
