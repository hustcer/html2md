// End-to-end cases ported from testdata/GoldenFiles/heading.{in.html,out.md}.

///|
test "golden heading: simple h1-h7" {
  inspect(
    @html2md.convert(
      "<h1>Heading 1</h1><h2>Heading 2</h2><h3>Heading 3</h3><h4>Heading 4</h4><h5>Heading 5</h5><h6>Heading 6</h6><h7>Heading 7</h7>",
    ),
    content=(
      #|# Heading 1
      #|
      #|## Heading 2
      #|
      #|### Heading 3
      #|
      #|#### Heading 4
      #|
      #|##### Heading 5
      #|
      #|###### Heading 6
      #|
      #|Heading 7
    ),
  )
}

///|
test "golden heading: whitespace-only are dropped, content trimmed" {
  inspect(
    @html2md.convert(
      "<h1></h1><h1> </h1><h1>  </h1><h1>a</h1><h1> a </h1><h1>  a  </h1><h1> <br/> </h1>",
    ),
    content=(
      #|# a
      #|
      #|# a
      #|
      #|# a
    ),
  )
}

///|
test "golden heading: spaces/tabs/newlines/breaks collapse" {
  inspect(
    @html2md.convert("<h2>  heading with spaces  </h2>"),
    content=(
      #|## heading with spaces
    ),
  )
  inspect(
    @html2md.convert("<h2>  heading   with    spaces\t\tand\t\ttabs  </h2>"),
    content=(
      #|## heading with spaces and tabs
    ),
  )
  inspect(
    @html2md.convert("<h2>\n\n    heading\n    with\n    newlines\n\n</h2>"),
    content=(
      #|## heading with newlines
    ),
  )
  inspect(
    @html2md.convert("<h2>heading<br /><br />with<br />breaks</h2>"),
    content=(
      #|## heading with breaks
    ),
  )
  inspect(
    @html2md.convert("<h2><br /><br />heading with breaks<br /><br /></h2>"),
    content=(
      #|## heading with breaks
    ),
  )
}

///|
test "golden heading: pound signs" {
  inspect(
    @html2md.convert("<h1>#hashtag</h1>"),
    content=(
      #|# #hashtag
    ),
  )
  inspect(
    @html2md.convert("<h1># Heading</h1>"),
    content=(
      #|# # Heading
    ),
  )
  inspect(
    @html2md.convert("<h1>#</h1>"),
    content=(
      #|# \#
    ),
  )
  inspect(
    @html2md.convert("<h1>  #  </h1>"),
    content=(
      #|# \#
    ),
  )
  inspect(
    @html2md.convert("<h1># Heading #</h1>"),
    content=(
      #|# # Heading \#
    ),
  )
  inspect(
    @html2md.convert("<h1>Heading #</h1>"),
    content=(
      #|# Heading \#
    ),
  )
  inspect(
    @html2md.convert("<h1>Heading ##</h1>"),
    content=(
      #|# Heading #\#
    ),
  )
  inspect(
    @html2md.convert("<h1>Heading \\#</h1>"),
    content=(
      #|# Heading \\#
    ),
  )
}

///|
test "golden heading: not recognized as headings in paragraphs" {
  inspect(
    @html2md.convert("<p>not title<br/>===</p>"),
    content=(
      #|not title  
      #|\===
    ),
  )
  inspect(
    @html2md.convert("<p>not title<br/>=</p>"),
    content=(
      #|not title  
      #|\=
    ),
  )
  inspect(
    @html2md.convert("<p>not title<br/>---</p>"),
    content=(
      #|not title  
      #|\---
    ),
  )
  inspect(
    @html2md.convert("<p>not title<br/>-</p>"),
    content=(
      #|not title  
      #|\-
    ),
  )
  inspect(
    @html2md.convert("<p>#not title</p>"),
    content=(
      #|#not title
    ),
  )
  inspect(
    @html2md.convert("<p># not title</p>"),
    content=(
      #|\# not title
    ),
  )
  inspect(
    @html2md.convert("<p>## not title</p>"),
    content=(
      #|\## not title
    ),
  )
}

///|
test "golden heading: inline elements allowed" {
  inspect(
    @html2md.convert(
      "<h2><strong>important</strong> <code>h2</code> <em>heading</em></h2>",
    ),
    content=(
      #|## **important** `h2` *heading*
    ),
  )
}

///|
test "golden heading: heading inside link inside blockquote" {
  inspect(
    @html2md.convert(
      "<blockquote><a href=\"/page.html\"><h2>Heading 2</h2></a></blockquote>",
    ),
    content=(
      #|> ## [Heading 2](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<blockquote><a href=\"/page.html\"><h2>Heading 2</h2><h5>Heading 5</h5></a></blockquote>",
    ),
    content=(
      #|> [**Heading 2**  
      #|> **Heading 5**](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<blockquote><a href=\"/page.html\"><h2>Heading 2</h2><p>Description Line 1<br/>Description Line 2<br/>Description Line 3<br/></p><blockquote>Some quote</blockquote></a></blockquote>",
    ),
    content=(
      #|> [**Heading 2**  
      #|> \
      #|> Description Line 1  
      #|> Description Line 2  
      #|> Description Line 3  
      #|> \
      #|> "Some quote"](/page.html)
    ),
  )
}

///|
test "golden heading: divider inside heading" {
  inspect(
    @html2md.convert("<h4><hr>More posts from around the site:</h4>"),
    content=(
      #|#### More posts from around the site:
    ),
  )
}

///|
test "golden heading: heading inside inline element" {
  inspect(
    @html2md.convert(
      "<div><span><div><span><h3><b>Heading</b></h3></span></div></span></div>",
    ),
    content=(
      #|### **Heading**
    ),
  )
}
