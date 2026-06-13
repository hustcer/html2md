///|
test "node_name and tag_type" {
  let el = @dom.element("div")
  inspect(@domext.node_name(el), content="div")
  inspect(@domext.node_name(@dom.text("x")), content="#text")
  inspect(@domext.node_name(@dom.comment("c")), content="#comment")
  inspect(@domext.node_name(@dom.document()), content="#document")
  debug_inspect(@domext.tag_type("p"), content="Some(Block)")
  debug_inspect(@domext.tag_type("span"), content="Some(Inline)")
  debug_inspect(@domext.tag_type("script"), content="Some(Remove)")
  debug_inspect(@domext.tag_type("noscript"), content="Some(Remove)")
  debug_inspect(@domext.tag_type("body"), content="None")
  inspect(@domext.is_block_tag_type("blockquote"), content="true")
  inspect(@domext.is_block_tag_type("b"), content="false")
}

///|
test "sibling cursors" {
  let a = @dom.text("a")
  let b = @dom.element("b")
  let c = @dom.text("c")
  let parent = @dom.element("p", children=[a, b, c])
  inspect(@domext.index_in_parent(b), content="1")
  guard @domext.next_sibling(a) is Some(n1) && physical_equal(n1, b)
  guard @domext.next_sibling(c) is None
  guard @domext.prev_sibling(b) is Some(p1) && physical_equal(p1, a)
  guard @domext.prev_sibling(a) is None
  guard @domext.first_child(parent) is Some(f) && physical_equal(f, a)
  guard @domext.last_child(parent) is Some(l) && physical_equal(l, c)
  inspect(@domext.index_in_parent(parent), content="-1")
}

///|
test "remove / insert_after / replace" {
  let a = @dom.text("a")
  let b = @dom.text("b")
  let parent = @dom.element("p", children=[a, b])
  @domext.remove_node(a)
  inspect(parent.children.length(), content="1")
  guard a.parent is None
  let x = @dom.text("x")
  @domext.insert_after(b, x)
  inspect(
    @domext.dump(parent),
    content=(
      #|p
      #|  #text "b"
      #|  #text "x"
      #|
    ),
  )
  let y = @dom.element("em")
  @domext.replace_node(b, y)
  guard physical_equal(parent.children[0], y)
  guard b.parent is None
}

///|
test "rename keeps attrs and children" {
  let child = @dom.text("hi")
  let div = @dom.element("div", attrs={ "class": Some("x") }, children=[child])
  let parent = @dom.element("section", children=[div])
  let span = @domext.rename(div, "span")
  inspect(
    @domext.dump(parent),
    content=(
      #|section
      #|  span class="x"
      #|    #text "hi"
      #|
    ),
  )
  guard physical_equal(span.children[0], child)
}

///|
test "set_text replaces node content" {
  let t = @dom.text("old")
  let parent = @dom.element("p", children=[t])
  let nt = @domext.set_text(t, "new")
  inspect(nt.data, content="new")
  inspect(parent.children[0].data, content="new")
}

///|
test "attr_or semantics" {
  let el = @dom.element("a", attrs={ "href": Some("/x"), "disabled": None })
  inspect(@domext.attr_or(el, "href", "fallback"), content="/x")
  inspect(@domext.attr_or(el, "disabled", "fallback"), content="")
  inspect(@domext.attr_or(el, "missing", "fallback"), content="fallback")
}
