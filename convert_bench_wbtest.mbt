///|
/// Parse HTML, convert it, and release DOM cycles on every iteration.
fn bench_conversion(it : @bench.T, html : String) -> Unit {
  it.bench(fn() {
    let doc = try! @parser.parse(html, sanitize=false)
    it.keep(try! convert_dom(doc.root))
    for node in @domext.all_nodes(doc.root) {
      node.parent = None
    }
  })
}

///|
test "convert: text separated by 1000 comments" (it : @bench.T) {
  let text = "abcdefghij".repeat(8)
  let html = "<p>" + (text + "<!-- split -->").repeat(1000) + "</p>"
  bench_conversion(it, html)
}

///|
test "convert: short mixed document" (it : @bench.T) {
  bench_conversion(
    it,
    "<h1>Title</h1><p>A <strong>bold</strong> and <em>italic</em> paragraph " +
    "with a <a href=\"/page\">link</a> and <code>code</code>.</p>" +
    "<ul><li>First</li><li>Second</li></ul>",
  )
}
