// Exhaustive port of internal/domutils/*_test.go. Each case parses an HTML
// fragment, runs the transform on <body>, and snapshots the resulting tree via
// @domext.dump (a different layout than the Go tester's representation, but
// structurally equivalent). Generated with `moon test --update` and verified
// against the Go expected trees.

///|
fn parse_body(html : String) -> @dom.Node raise {
  let doc = @parser.parse(html, sanitize=false)
  guard @domext.find_first_node(doc.root, n => @domext.node_name(n) is "body")
    is Some(body)
  body
}

///|
fn name_is_bold_or_italic(n : @dom.Node) -> Bool {
  @domext.node_name(n) is ("strong" | "b" | "em" | "i")
}

///|
fn dump_merge_adjacent(
  html : String,
  match_fn : (@dom.Node) -> Bool,
) -> String raise {
  let body = parse_body(html)
  @domutils.merge_adjacent(body, match_fn)
  @domext.dump(body)
}

///|
fn name_is_strong_or_em(n : @dom.Node) -> Bool {
  @domext.node_name(n) is ("strong" | "em")
}

// - - - - - - - - - - merge_adjacent_text_nodes - - - - - - - - - - //

///|
test "merge_adjacent_text_nodes: three text nodes" {
  let div = @dom.element("div", children=[
    @dom.text("one"),
    @dom.text("two"),
    @dom.text("three"),
  ])
  @domutils.merge_adjacent_text_nodes(div)
  inspect(
    @domext.dump(div),
    content=(
      #|div
      #|  #text "onetwothree"
      #|
    ),
  )
}

// - - - - - - - - - - merge_adjacent - - - - - - - - - - //

///|
test "merge_adjacent: don't change other tags" {
  inspect(
    dump_merge_adjacent("<span>a</span> <span>b</span>", name_is_strong_or_em),
    content=(
      #|body
      #|  span
      #|    #text "a"
      #|  #text " "
      #|  span
      #|    #text "b"
      #|
    ),
  )
}

///|
test "merge_adjacent: simple strong unchanged" {
  inspect(
    dump_merge_adjacent("<strong>a</strong>", name_is_strong_or_em),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|
    ),
  )
}

///|
test "merge_adjacent: don't merge with space between" {
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong> <strong>b</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|  #text " "
      #|  strong
      #|    #text "b"
      #|
    ),
  )
}

///|
test "merge_adjacent: merge two/three/four without space" {
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong><strong>b</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|    #text "b"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong><strong>b</strong><strong>c</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|    #text "b"
      #|    #text "c"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent("<em>a</em><em>b</em><em>c</em>", name_is_strong_or_em),
    content=(
      #|body
      #|  em
      #|    #text "a"
      #|    #text "b"
      #|    #text "c"
      #|
    ),
  )
}

///|
test "merge_adjacent: don't merge across tag/text/break between" {
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong><p>between</p><strong>b</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|  p
      #|    #text "between"
      #|  strong
      #|    #text "b"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong> between <strong>b</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|  #text " between "
      #|  strong
      #|    #text "b"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent(
      "<strong>a</strong><br/><strong>b</strong>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|  br
      #|  strong
      #|    #text "b"
      #|
    ),
  )
}

///|
test "merge_adjacent: merge next strong nested in span" {
  inspect(
    dump_merge_adjacent(
      "<p><strong>a</strong><span><strong>b</strong></span>other text</p>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  p
      #|    strong
      #|      #text "a"
      #|      #text "b"
      #|    span
      #|    #text "other text"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent(
      "<p><strong>a</strong><span>other text</span></p>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  p
      #|    strong
      #|      #text "a"
      #|    span
      #|      #text "other text"
      #|
    ),
  )
  inspect(
    dump_merge_adjacent(
      "<p><strong>a</strong><span> <strong>b</strong></span></p>", name_is_strong_or_em,
    ),
    content=(
      #|body
      #|  p
      #|    strong
      #|      #text "a"
      #|    span
      #|      #text " "
      #|      strong
      #|        #text "b"
      #|
    ),
  )
}

// - - - - - - - - - - remove_redundant - - - - - - - - - - //

///|
fn dump_remove_redundant(html : String) -> String raise {
  let body = parse_body(html)
  @domutils.remove_redundant(body, (a, b) => {
    let ia = @domext.node_name(a) is ("em" | "i")
    let ib = @domext.node_name(b) is ("em" | "i")
    let ba = @domext.node_name(a) is ("strong" | "b")
    let bb = @domext.node_name(b) is ("strong" | "b")
    (ia && ib) || (ba && bb)
  })
  @domext.dump(body)
}

///|
test "remove_redundant: don't change other tags / simple strong" {
  inspect(
    dump_remove_redundant("<strong>a</strong>"),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|
    ),
  )
}

///|
test "remove_redundant: double strong" {
  inspect(
    dump_remove_redundant("<strong><strong>a</strong></strong>"),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|
    ),
  )
}

///|
test "remove_redundant: more complicated double strong" {
  inspect(
    dump_remove_redundant(
      "<strong><strong>a</strong> b <strong><strong>c</strong></strong></strong>",
    ),
    content=(
      #|body
      #|  strong
      #|    #text "a"
      #|    #text " b "
      #|    #text "c"
      #|
    ),
  )
}

///|
test "remove_redundant: leave italic inside bold, but not italic in italic" {
  inspect(
    dump_remove_redundant("<strong>A<em>B</em>C</strong>"),
    content=(
      #|body
      #|  strong
      #|    #text "A"
      #|    em
      #|      #text "B"
      #|    #text "C"
      #|
    ),
  )
  inspect(
    dump_remove_redundant("<i>A<em>B</em>C</i>"),
    content=(
      #|body
      #|  i
      #|    #text "A"
      #|    #text "B"
      #|    #text "C"
      #|
    ),
  )
}

// - - - - - - - - - - remove_empty_code - - - - - - - - - - //

///|
test "remove_empty_code: two empty code nodes" {
  let body = parse_body("<p><code></code></p>between<p><code></code></p>")
  @domutils.remove_empty_code(body)
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  p
      #|  #text "between"
      #|  p
      #|
    ),
  )
}

// - - - - - - - - - - swap_tags - - - - - - - - - - //

///|
fn dump_swap(
  html : String,
  is_outer : (@dom.Node) -> Bool,
  is_inner : (@dom.Node) -> Bool,
) -> String raise {
  let body = parse_body(html)
  @domutils.swap_tags(body, is_outer, is_inner)
  @domext.dump(body)
}

///|
test "swap_tags: pre/code wrong order gets swapped" {
  inspect(
    dump_swap(
      "<div><code><pre>content</pre></code></div>",
      n => @domext.node_name(n) is "code",
      n => @domext.node_name(n) is "pre",
    ),
    content=(
      #|body
      #|  div
      #|    pre
      #|      code
      #|        #text "content"
      #|
    ),
  )
}

///|
test "swap_tags: correct code block kept" {
  inspect(
    dump_swap(
      "<div><pre><code>content</code></pre></div>",
      n => @domext.node_name(n) is "code",
      n => @domext.node_name(n) is "pre",
    ),
    content=(
      #|body
      #|  div
      #|    pre
      #|      code
      #|        #text "content"
      #|
    ),
  )
}

///|
test "swap_tags: strong/link swap" {
  inspect(
    dump_swap(
      "<p>before<strong><a href=\"/\">middle</a></strong>after</p>",
      name_is_bold_or_italic,
      n => @domext.node_name(n) is "a",
    ),
    content=(
      #|body
      #|  p
      #|    #text "before"
      #|    a href="/"
      #|      strong
      #|        #text "middle"
      #|    #text "after"
      #|
    ),
  )
}

///|
test "swap_tags: strong/link with empty spans" {
  inspect(
    dump_swap(
      "<p>before<strong><span></span><a href=\"/\">x</a><span></span></strong>after</p>",
      name_is_bold_or_italic,
      n => @domext.node_name(n) is "a",
    ),
    content=(
      #|body
      #|  p
      #|    #text "before"
      #|    strong
      #|      span
      #|      a href="/"
      #|        #text "x"
      #|      span
      #|    #text "after"
      #|
    ),
  )
}

// - - - - - - - - - - add_space - - - - - - - - - - //

///|
test "add_space: space before & after" {
  let body = parse_body("before<strong><code>inline code</code></strong>after")
  @domutils.add_space(body, name_is_bold_or_italic, n => {
    @domext.node_name(n) is "code"
  })
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  #text "before "
      #|  strong
      #|    code
      #|      #text "inline code"
      #|  #text " after"
      #|
    ),
  )
}

///|
test "add_space: no surrounding text" {
  let body = parse_body("<strong><code>inline code</code></strong>")
  @domutils.add_space(body, name_is_bold_or_italic, n => {
    @domext.node_name(n) is "code"
  })
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  strong
      #|    code
      #|      #text "inline code"
      #|
    ),
  )
}

// - - - - - - - - - - rename_fake_spans - - - - - - - - - - //

///|
fn dump_rename_spans(html : String) -> String raise {
  let body = parse_body(html)
  @domutils.rename_fake_spans(body)
  @domext.dump(body)
}

///|
test "rename_fake_spans: simple span and inline span unchanged" {
  inspect(
    dump_rename_spans("<span>a</span>"),
    content=(
      #|body
      #|  span
      #|    #text "a"
      #|
    ),
  )
  inspect(
    dump_rename_spans("<span><a>link content</a></span>"),
    content=(
      #|body
      #|  span
      #|    a
      #|      #text "link content"
      #|
    ),
  )
}

///|
test "rename_fake_spans: span with block becomes div" {
  inspect(
    dump_rename_spans("<span><p>paragraph content</p></span>"),
    content=(
      #|body
      #|  div
      #|    p
      #|      #text "paragraph content"
      #|
    ),
  )
  inspect(
    dump_rename_spans("<span><span><p>paragraph content</p></span></span>"),
    content=(
      #|body
      #|  div
      #|    div
      #|      p
      #|        #text "paragraph content"
      #|
    ),
  )
}

// - - - - - - - - - - move_list_items - - - - - - - - - - //

///|
fn dump_move_list_items(html : String) -> String raise {
  let body = parse_body(html)
  @domutils.move_list_items(body)
  @domext.dump(body)
}

///|
test "move_list_items: normal list unchanged" {
  inspect(
    dump_move_list_items("<div><ul><li>A</li><li>B</li></ul></div>"),
    content=(
      #|body
      #|  div
      #|    ul
      #|      li
      #|        #text "A"
      #|      li
      #|        #text "B"
      #|
    ),
  )
}

///|
test "move_list_items: stray text/div/ol move into previous li" {
  inspect(
    dump_move_list_items("<ul><li>A</li>B</ul>"),
    content=(
      #|body
      #|  ul
      #|    li
      #|      #text "A"
      #|      #text "B"
      #|
    ),
  )
  inspect(
    dump_move_list_items("<ul><li>A</li><div>B</div></ul>"),
    content=(
      #|body
      #|  ul
      #|    li
      #|      #text "A"
      #|      div
      #|        #text "B"
      #|
    ),
  )
}

///|
test "move_list_items: no existing li wraps stray content" {
  inspect(
    dump_move_list_items("<ul><span>A</span><span>B</span></ul>"),
    content=(
      #|body
      #|  ul
      #|    li
      #|      span
      #|        #text "A"
      #|      span
      #|        #text "B"
      #|
    ),
  )
}

// - - - - - - - - - - leaf_block_alternatives - - - - - - - - - - //

///|
fn dump_leaf_alts(html : String) -> String raise {
  let body = parse_body(html)
  @domutils.leaf_block_alternatives(body)
  @domext.dump(body)
}

///|
test "leaf_block_alternatives: divider in heading removed" {
  inspect(
    dump_leaf_alts("<h3>Heading<hr /></h3>"),
    content=(
      #|body
      #|  h3
      #|    #text "Heading"
      #|
    ),
  )
}

///|
test "leaf_block_alternatives: heading inside link becomes strong+br" {
  inspect(
    dump_leaf_alts("<a href=\"/page.html\"><h3>Heading</h3></a>"),
    content=(
      #|body
      #|  a href="/page.html"
      #|    strong
      #|      #text "Heading"
      #|    br
      #|
    ),
  )
}

///|
test "leaf_block_alternatives: two headings inside link" {
  inspect(
    dump_leaf_alts(
      "<a href=\"/page.html\"><h4>Heading A</h4><h3>Heading B</h3></a>",
    ),
    content=(
      #|body
      #|  a href="/page.html"
      #|    strong
      #|      #text "Heading A"
      #|    br
      #|    strong
      #|      #text "Heading B"
      #|    br
      #|
    ),
  )
}
