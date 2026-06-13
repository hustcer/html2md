///|
test "render: emphasis" {
  inspect(
    @html2md.convert("<em>italic</em>"),
    content=(
      #|*italic*
    ),
  )
  inspect(
    @html2md.convert("<b>bold</b>"),
    content=(
      #|**bold**
    ),
  )
  inspect(
    @html2md.convert("<em>italic</em>", em_delimiter="_"),
    content=(
      #|_italic_
    ),
  )
  inspect(
    @html2md.convert("<b>bold</b>", strong_delimiter="__"),
    content=(
      #|__bold__
    ),
  )
  inspect(
    @html2md.convert("<p>a <strong>b</strong> c</p>"),
    content=(
      #|a **b** c
    ),
  )
}

///|
test "render: headings atx and setext" {
  inspect(
    @html2md.convert("<h1>Title</h1>"),
    content=(
      #|# Title
    ),
  )
  inspect(
    @html2md.convert("<h3>Sub</h3>"),
    content=(
      #|### Sub
    ),
  )
  inspect(
    @html2md.convert("<h1>Title</h1>", heading_style=Setext),
    content=(
      #|Title
      #|=====
    ),
  )
  inspect(
    @html2md.convert("<h2>Two</h2>", heading_style=Setext),
    content=(
      #|Two
      #|---
    ),
  )
  inspect(
    @html2md.convert("<h3>Three</h3>", heading_style=Setext),
    content=(
      #|### Three
    ),
  )
}

///|
test "render: hr and br" {
  inspect(
    @html2md.convert("<hr/>"),
    content=(
      #|* * *
    ),
  )
  inspect(
    @html2md.convert("<hr/>", horizontal_rule="---"),
    content=(
      #|---
    ),
  )
  inspect(
    @html2md.convert("<p>a<br/>b</p>"),
    content=(
      #|a  
      #|b
    ),
  )
}

///|
test "render: links" {
  inspect(
    @html2md.convert("<a href=\"https://example.com\">link</a>"),
    content=(
      #|[link](https://example.com)
    ),
  )
  inspect(
    @html2md.convert(
      "<a href=\"/page\" title=\"the title\">link</a>",
      domain="https://example.com",
    ),
    content=(
      #|[link](https://example.com/page "the title")
    ),
  )
  inspect(
    @html2md.convert("<a href=\"\">empty</a>"),
    content=(
      #|[empty]()
    ),
  )
  inspect(
    @html2md.convert("<a href=\"\">empty</a>", link_empty_href_behavior=Skip),
    content=(
      #|empty
    ),
  )
}

///|
test "render: images" {
  inspect(
    @html2md.convert("<img src=\"/img.png\" alt=\"alt text\"/>"),
    content=(
      #|![alt text](/img.png)
    ),
  )
  inspect(
    @html2md.convert(
      "<img src=\"/img.png\" alt=\"a\" title=\"t\"/>",
      domain="https://example.com",
    ),
    content=(
      #|![a](https://example.com/img.png "t")
    ),
  )
  inspect(@html2md.convert("<img alt=\"no src\"/>"), content="")
}

///|
test "render: inline code" {
  inspect(
    @html2md.convert("<p>use <code>foo()</code> here</p>"),
    content=(
      #|use `foo()` here
    ),
  )
  inspect(
    @html2md.convert("<code>a `b` c</code>"),
    content=(
      #|``a `b` c``
    ),
  )
}

///|
test "render: block code" {
  inspect(
    @html2md.convert("<pre><code>line1\nline2</code></pre>"),
    content=(
      #|```
      #|line1
      #|line2
      #|```
    ),
  )
  inspect(
    @html2md.convert("<pre><code class=\"language-go\">x := 1</code></pre>"),
    content=(
      #|```go
      #|x := 1
      #|```
    ),
  )
  inspect(
    @html2md.convert("<pre><code>a\nb</code></pre>", code_block_fence="~~~"),
    content=(
      #|~~~
      #|a
      #|b
      #|~~~
    ),
  )
}

///|
test "render: blockquote" {
  inspect(
    @html2md.convert("<blockquote>quoted</blockquote>"),
    content=(
      #|> quoted
    ),
  )
  inspect(
    @html2md.convert("<blockquote><p>a</p><p>b</p></blockquote>"),
    content=(
      #|> a
      #|> 
      #|> b
    ),
  )
}

///|
test "render: unordered list" {
  inspect(
    @html2md.convert("<ul><li>a</li><li>b</li></ul>"),
    content=(
      #|- a
      #|- b
    ),
  )
  inspect(
    @html2md.convert("<ul><li>a</li></ul>", bullet_list_marker="+"),
    content=(
      #|+ a
    ),
  )
}

///|
test "render: ordered list with start and padding" {
  inspect(
    @html2md.convert("<ol><li>a</li><li>b</li></ol>"),
    content=(
      #|1. a
      #|2. b
    ),
  )
  inspect(
    @html2md.convert("<ol start=\"9\"><li>a</li><li>b</li></ol>"),
    content=(
      #|09. a
      #|10. b
    ),
  )
}

///|
test "render: nested list" {
  inspect(
    @html2md.convert("<ul><li>a<ul><li>b</li></ul></li></ul>"),
    content=(
      #|- a
      #|  
      #|  - b
    ),
  )
}

///|
test "render: two adjacent lists get end comment" {
  inspect(
    @html2md.convert("<ul><li>a</li></ul><ul><li>b</li></ul>"),
    content=(
      #|- a
      #|
      #|<!--THE END-->
      #|
      #|- b
    ),
  )
  inspect(
    @html2md.convert(
      "<ul><li>a</li></ul><ul><li>b</li></ul>",
      list_end_comment=false,
    ),
    content=(
      #|- a
      #|
      #|- b
    ),
  )
}
