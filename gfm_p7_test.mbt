///|
test "gfm strikethrough: s del strike tags" {
  inspect(
    @html2md.convert(
      "<p>before <s>old</s> <del>gone</del> <strike>legacy</strike> after</p>",
    ),
    content="before ~~old~~ ~~gone~~ ~~legacy~~ after",
  )
}

///|
test "gfm strikethrough: multiline and fake text marker" {
  inspect(
    @html2md.convert("<del>line 1<br>line 2</del>"),
    content=(
      #|~~line 1~~  
      #|~~line 2~~
    ),
  )
  inspect(
    @html2md.convert("<p>fake ~~strike~~ and real <del>strike</del></p>"),
    content="fake \\~~strike\\~~ and real ~~strike~~",
  )
}

///|
test "gfm table: thead tbody" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <thead><tr><th>Name</th><th>Value</th></tr></thead>
        #|  <tbody><tr><td>A</td><td>1</td></tr><tr><td>B</td><td>2</td></tr></tbody>
        #|</table>
      ),
    ),
    content=(
      #|| Name | Value |
      #|| --- | --- |
      #|| A | 1 |
      #|| B | 2 |
    ),
  )
}

///|
test "gfm table: tbody-only uses first row as header" {
  inspect(
    @html2md.convert(
      "<table><tr><td>Name</td><td>Value</td></tr><tr><td>A</td><td>1</td></tr></table>",
    ),
    content=(
      #|| Name | Value |
      #|| --- | --- |
      #|| A | 1 |
    ),
  )
}

///|
test "gfm table: inline content and pipe escaping" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><th>Item</th><th>Desc</th></tr>
        #|  <tr><td><strong>A</strong></td><td>a | b and <a href="/x">link</a></td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| Item | Desc |
      #|| --- | --- |
      #|| **A** | a \| b and [link](/x) |
    ),
  )
}
