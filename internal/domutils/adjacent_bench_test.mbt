///|
/// Include DOM construction and cycle cleanup in every measured iteration.
fn bench_text_merge(it : @bench.T, count : Int) -> Unit {
  let text = "abcdefghij".repeat(8)
  it.bench(fn() {
    let node = @dom.element(
      "p",
      children=Array::makei(count, _ => @dom.text(text)),
    )
    @domutils.merge_adjacent_text_nodes(node)
    it.keep(node.children[0].data)
    // Break parent/child cycles so repeated native measurements remain bounded.
    for child in node.children {
      child.parent = None
    }
  })
}

///|
test "merge adjacent text: 1 node" (it : @bench.T) {
  bench_text_merge(it, 1)
}

///|
test "merge adjacent text: 1000 nodes" (it : @bench.T) {
  bench_text_merge(it, 1000)
}

///|
test "merge adjacent text: 4000 nodes" (it : @bench.T) {
  bench_text_merge(it, 4000)
}
