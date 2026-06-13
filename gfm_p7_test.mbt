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
test "gfm strikethrough: plugin basic cases from Go" {
  inspect(@html2md.convert("<p><s>  Text  </s></p>"), content="~~Text~~")
  inspect(
    @html2md.convert("<p><s>~~A~~B~~</s></p>"),
    content="~~\\~~A\\~~B\\~\\~~~",
  )
  inspect(@html2md.convert("<p><s>A <s>B</s> C</s></p>"), content="~~A B C~~")
  inspect(
    @html2md.convert("<p><s>A</s><s>B</s> <s>C</s></p>"),
    content="~~AB~~ ~~C~~",
  )
}

///|
test "gfm strikethrough: golden file cases from Go" {
  inspect(
    @html2md.convert("<del>strikethrough content</del>"),
    content="~~strikethrough content~~",
  )
  inspect(@html2md.convert("<p>~ </p>"), content="~")
  inspect(@html2md.convert("<p>* </p>"), content="\\*")
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
test "gfm table: empty cells and caption fallback from Go basics" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <caption>The caption text of the empty table</caption>
        #|  <thead></thead>
        #|  <tbody></tbody>
        #|</table>
      ),
    ),
    content="The caption text of the empty table",
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tbody>
        #|    <tr><td></td><td></td></tr>
        #|    <tr><td></td><td></td></tr>
        #|  </tbody>
        #|</table>
      ),
    ),
    content=(
      #||  |  |
      #|| --- | --- |
      #||  |  |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td></td><td>B1</td></tr>
        #|  <tr><td></td><td></td></tr>
        #|  <tr><td>A3</td><td></td></tr>
        #|</table>
      ),
    ),
    content=(
      #||  | B1 |
      #|| --- | --- |
      #||  |  |
      #|| A3 |  |
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

///|
test "gfm table: content cases from Go golden" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td><strong>A1</strong></td><td><i>B1</i></td></tr>
        #|  <tr><td><code>A2</code></td><td><a href="/">B2</a></td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| **A1** | *B1* |
      #|| --- | --- |
      #|| `A2` | [B2](/) |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td>with break after<br /></td></tr>
        #|  <tr><td><br />with break before</td></tr>
        #|  <tr><td><br /><br /><br />with break around<br /><br /><br /></td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| with break after |
      #|| --- |
      #|| with break before |
      #|| with break around |
    ),
  )
  inspect(
    @html2md.convert(
      "<table><tr><td><p>Some normal content</p></td></tr></table>",
    ),
    content=(
      #|| Some normal content |
      #|| --- |
    ),
  )
}

///|
test "gfm table: align attributes from Go golden" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <thead>
        #|    <tr>
        #|      <th align="left">Left</th>
        #|      <th align="center">Center</th>
        #|      <th align="right">Right</th>
        #|    </tr>
        #|  </thead>
        #|  <tbody><tr><td>A</td><td>B</td><td>C</td></tr></tbody>
        #|</table>
      ),
    ),
    content=(
      #|| Left | Center | Right |
      #|| :--- | :---: | ---: |
      #|| A | B | C |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr>
        #|    <td align="left">Left</td>
        #|    <td align="center">Center</td>
        #|    <td align="right">Right</td>
        #|  </tr>
        #|  <tr><td>A</td><td>B</td><td>C</td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| Left | Center | Right |
      #|| :--- | :---: | ---: |
      #|| A | B | C |
    ),
  )
}

///|
test "gfm table: simple colspans and rowspans from Go golden" {
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr>
        #|    <td colspan="">A1</td>
        #|    <td colspan="x">B1</td>
        #|    <td colspan="-5">C1</td>
        #|  </tr>
        #|</table>
      ),
    ),
    content=(
      #|| A1 | B1 | C1 |
      #|| --- | --- | --- |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td colspan="2">wide cell</td><td>B1</td></tr>
        #|  <tr><td>A2</td><td>B2</td><td>C2</td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| wide cell |  | B1 |
      #|| --- | --- | --- |
      #|| A2 | B2 | C2 |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td rowspan="2">tall cell</td><td>B1</td><td>C1</td></tr>
        #|  <tr><td>A2</td><td>B2</td></tr>
        #|  <tr><td>A3</td><td>B3</td><td>C3</td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| tall cell | B1 | C1 |
      #|| --- | --- | --- |
      #||  | A2 | B2 |
      #|| A3 | B3 | C3 |
    ),
  )
  inspect(
    @html2md.convert(
      (
        #|<table>
        #|  <tr><td rowspan="2" colspan="2">big cell</td><td>B1</td></tr>
        #|  <tr><td>A2</td></tr>
        #|  <tr><td>A3</td><td>B3</td><td>C3</td></tr>
        #|</table>
      ),
    ),
    content=(
      #|| big cell |  | B1 |
      #|| --- | --- | --- |
      #||  |  | A2 |
      #|| A3 | B3 | C3 |
    ),
  )
}

///|
test "gfm table: presentation table falls back to child content" {
  inspect(
    @html2md.convert(
      (
        #|<table role="presentation">
        #|  <tr><td>A1</td><td>A2</td></tr>
        #|  <tr><td>B1</td><td>B2</td></tr>
        #|</table>
      ),
    ),
    content=(
      #|A1 A2
      #|
      #|B1 B2
    ),
  )
}

///|
test "gfm table: parent containers from Go golden" {
  inspect(
    @html2md.convert(
      (
        #|<blockquote>
        #|  The blockquote content:
        #|  <table><tr><td>A1</td><td>A2</td></tr></table>
        #|</blockquote>
      ),
    ),
    content="> The blockquote content:\n> \n> | A1 | A2 |\n> | --- | --- |",
  )
  inspect(
    @html2md.convert(
      (
        #|<button>
        #|  button content before
        #|  <table><tr><td>A1</td><td>A2</td></tr></table>
        #|  button content after
        #|</button>
      ),
    ),
    content=(
      #|button content before
      #|
      #|| A1 | A2 |
      #|| --- | --- |
      #|
      #|button content after
    ),
  )
}
