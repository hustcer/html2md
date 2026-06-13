// Ported from plugin/commonmark/commonmark_test.go (TestOptionFunc and
// TestOptionFunc_ValidationError) and validation_test.go.

///|
test "option: em / strong delimiter" {
  inspect(
    @html2md.convert("<em>italic</em>", em_delimiter="_"),
    content="_italic_",
  )
  inspect(
    @html2md.convert("<b>bold</b>", strong_delimiter="__"),
    content="__bold__",
  )
}

///|
test "option: horizontal rule variants" {
  inspect(@html2md.convert("<hr />", horizontal_rule="***"), content="***")
  inspect(
    @html2md.convert("<hr />", horizontal_rule="******"),
    content="******",
  )
  inspect(@html2md.convert("<hr />", horizontal_rule="---"), content="---")
  inspect(@html2md.convert("<hr />", horizontal_rule="___"), content="___")
}

///|
test "option: bullet list marker and list end comment" {
  inspect(
    @html2md.convert("<ul><li>list item</li></ul>", bullet_list_marker="+"),
    content="+ list item",
  )
  inspect(
    @html2md.convert(
      "<ul><li>list a</li></ul>  <ul><li>list b</li></ul>",
      bullet_list_marker="*",
    ),
    content=(
      #|* list a
      #|
      #|<!--THE END-->
      #|
      #|* list b
    ),
  )
  inspect(
    @html2md.convert(
      "<ul><li>list a</li></ul>  <ul><li>list b</li></ul>",
      bullet_list_marker="*",
      list_end_comment=false,
    ),
    content=(
      #|* list a
      #|
      #|* list b
    ),
  )
}

///|
test "option: code block fence" {
  inspect(
    @html2md.convert(
      "<pre><code>hello world</code></pre>",
      code_block_fence="~~~",
    ),
    content=(
      #|~~~
      #|hello world
      #|~~~
    ),
  )
}

///|
test "option: heading style" {
  inspect(
    @html2md.convert("<h1>important<br/>heading</h1>", heading_style=Atx),
    content="# important heading",
  )
  inspect(
    @html2md.convert("<h1>important<br/>heading</h1>", heading_style=Setext),
    content=(
      #|important  
      #|heading
      #|===========
    ),
  )
}

///|
test "option: link empty href / content behavior" {
  inspect(
    @html2md.convert(
      "<a href=\"\">the link content</a>",
      link_empty_href_behavior=Render,
    ),
    content="[the link content]()",
  )
  inspect(
    @html2md.convert(
      "<a href=\"\">the link content</a>",
      link_empty_href_behavior=Skip,
    ),
    content="the link content",
  )
  inspect(
    @html2md.convert(
      "<a href=\"/page\"></a>",
      link_empty_content_behavior=Render,
    ),
    content="[](/page)",
  )
  inspect(
    @html2md.convert("<a href=\"/page\"></a>", link_empty_content_behavior=Skip),
    content="",
  )
}

///|
/// Mirrors validation_test.go: default config is valid, setext is valid,
/// invalid values raise InvalidConfig.
test "validation: defaults and valid values pass" {
  inspect(@html2md.convert("<b>x</b>"), content="**x**")
  inspect(
    @html2md.convert("<h1>x</h1>", heading_style=Setext),
    content=(
      #|x
      #|===
    ),
  )
}

///|
fn expect_invalid(f : () -> String raise) -> String {
  try f() catch {
    @html2md.InvalidConfig(msg) => msg
    _ => "WRONG ERROR KIND"
  } noraise {
    _ => "NO ERROR"
  }
}

///|
test "validation: invalid option values raise InvalidConfig" {
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", em_delimiter="__")),
    content="invalid em_delimiter \"__\": must be exactly 1 character of \"*\" or \"_\"",
  )
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", strong_delimiter="_")),
    content="invalid strong_delimiter \"_\": must be exactly 2 characters of \"**\" or \"__\"",
  )
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", horizontal_rule="* *")),
    content="invalid horizontal_rule \"* *\": must be at least 3 characters of \"*\", \"_\" or \"-\"",
  )
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", horizontal_rule="+++")),
    content="invalid horizontal_rule \"+++\": must be at least 3 characters of \"*\", \"_\" or \"-\"",
  )
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", bullet_list_marker="_")),
    content="invalid bullet_list_marker \"_\": must be one of \"-\", \"+\" or \"*\"",
  )
  inspect(
    expect_invalid(() => @html2md.convert("<b>x</b>", code_block_fence="~~")),
    content="invalid code_block_fence \"~~\": must be one of \"```\" or \"~~~\"",
  )
}
