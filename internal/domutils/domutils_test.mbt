///|
fn parse_body(html : String) -> @dom.Node raise {
  // Return the <body> element so the dumps stay focused.
  let doc = @parser.parse(html, sanitize=false)
  guard @domext.find_first_node(doc.root, n => @domext.node_name(n) is "body")
    is Some(body)
  body
}

///|
test "merge_adjacent_text_nodes" {
  let p = @dom.element("p", children=[
    @dom.text("a"),
    @dom.text("b"),
    @dom.element("br"),
    @dom.text("c"),
  ])
  @domutils.merge_adjacent_text_nodes(p)
  inspect(
    @domext.dump(p),
    content=(
      #|p
      #|  #text "ab"
      #|  br
      #|  #text "c"
      #|
    ),
  )
}

///|
test "remove_redundant unwraps nested same-type" {
  let body = parse_body("<p><strong><strong>x</strong></strong></p>")
  @domutils.remove_redundant(body, (a, b) => {
    @domext.node_name(a) is "strong" && @domext.node_name(b) is "strong"
  })
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  p
      #|    strong
      #|      #text "x"
      #|
    ),
  )
}

///|
test "merge_adjacent combines siblings" {
  let body = parse_body("<p><strong>a</strong><strong>b</strong></p>")
  @domutils.merge_adjacent(body, n => @domext.node_name(n) is "strong")
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  p
      #|    strong
      #|      #text "a"
      #|      #text "b"
      #|
    ),
  )
}

///|
test "remove_empty_code drops empty code" {
  let body = parse_body("<p><code></code><code>x</code></p>")
  @domutils.remove_empty_code(body)
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  p
      #|    code
      #|      #text "x"
      #|
    ),
  )
}

///|
test "swap_tags swaps code/pre nesting" {
  let body = parse_body("<code><pre>x</pre></code>")
  @domutils.swap_tags(body, n => @domext.node_name(n) is "code", n => {
    @domext.node_name(n) is "pre"
  })
  // After swap the outer becomes pre and the inner code.
  inspect(
    @domext.find_first_node(body, n => @domext.node_name(n) is "pre") is Some(_),
    content="true",
  )
}

///|
test "rename_fake_spans renames span-with-block to div" {
  let body = parse_body("<span><p>x</p></span>")
  @domutils.rename_fake_spans(body)
  inspect(
    @domext.find_first_node(body, n => @domext.node_name(n) is "div") is Some(_),
    content="true",
  )
}

///|
test "move_list_items wraps stray content" {
  let ul = @dom.element("ul", children=[
    @dom.element("li", children=[@dom.text("a")]),
    @dom.text("stray"),
  ])
  @domutils.move_list_items(ul)
  // The stray text gets moved into the previous li.
  inspect(
    @domext.dump(ul),
    content=(
      #|ul
      #|  li
      #|    #text "a"
      #|    #text "stray"
      #|
    ),
  )
}

///|
test "add_list_end_comments between two lists" {
  let body = @dom.element("body", children=[
    @dom.element("ul", children=[@dom.element("li", children=[@dom.text("a")])]),
    @dom.element("ul", children=[@dom.element("li", children=[@dom.text("b")])]),
  ])
  @domutils.add_list_end_comments(body)
  inspect(
    @domext.find_first_node(body, n => n.kind is Comment) is Some(_),
    content="true",
  )
}
