// End-to-end cases ported from testdata/GoldenFiles/metadata.{in.html,out.md}.
// Each independent fragment is converted on its own (the Go golden runs the
// whole file with comments kept as raw HTML; our default convert removes
// comments, so per-fragment is the faithful unit).

///|
test "golden metadata: heading" {
  inspect(@html2md.convert("<h4>Heading A</h4>"), content="#### Heading A")
}

///|
test "golden metadata: backslashes escaped" {
  inspect(
    @html2md.convert("<p>\\a \\* \\\\</p>"),
    content="\\\\a \\\\* \\\\\\\\",
  )
}

///|
test "golden metadata: angle-bracket entities in spans" {
  inspect(
    @html2md.convert(
      "<p><span> .&lt;name&gt; </span><span> .< name >. </span><span> <</span><span>name</span><span>> </span></p>",
    ),
    content=".&lt;name&gt; .&lt; name &gt;. &lt;name&gt;",
  )
}

///|
test "golden metadata: ampersands and angle brackets with breaks" {
  inspect(
    @html2md.convert(
      "<p>2 > 1 <br/>\n1 < 2 <br/>\n\nA & B <br/>\nA &amp; B <br/>\n&amp;ouml;</p>",
    ),
    content=(
      #|2 &gt; 1  
      #|1 &lt; 2  
      #|A & B  
      #|A & B  
      #|&ouml;
    ),
  )
}

///|
test "golden metadata: fake markdown escaped line-by-line" {
  inspect(
    @html2md.convert(
      "<p>*not emphasized* <br/>\n&lt;br/&gt; not a tag <br/>\n[not a link](/foo) <br/>\n`not code` <br/>\n1. not a list <br/>\n* not a list <br/>\n# not a heading <br/>\n[foo]: /url &quot;not a reference&quot; <br/>\n&amp;ouml; not a character entity</p>",
    ),
    content=(
      #|\*not emphasized*  
      #|&lt;br/&gt; not a tag  
      #|\[not a link](/foo)  
      #|\`not code\`  
      #|1\. not a list  
      #|\* not a list  
      #|\# not a heading  
      #|\[foo]: /url "not a reference"  
      #|&ouml; not a character entity
    ),
  )
}

///|
test "golden metadata: many breaks collapse" {
  inspect(
    @html2md.convert(
      "<p>\n      Start Line\n      <br /><br /><br />\n      <span> </span>\n      <br /><br /><br />\n      End Line\n    </p>",
    ),
    content=(
      #|Start Line
      #|
      #|End Line
    ),
  )
}
