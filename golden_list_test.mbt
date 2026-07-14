// End-to-end cases ported from testdata/GoldenFiles/list.{in.html,out.md}.
// Fragments are split at the source <hr/> boundaries (each renders
// independently). Adjacent-list fragments keep their <!--THE END--> comments.

///|
test "golden list: big mixed nested list" {
  inspect(
    @html2md.convert(
      (
        #|<div>
        #|  <p>A paragraph</p>
        #|  <ul>
        #|    <li>1</li>
        #|    <li></li>
        #|    <li><p>2</p></li>
        #|    <li><ul><li>3.1</li><li>3.2</li></ul></li>
        #|    <li><span>4 Before</span><ul><li>4.1</li><li><p>4.2</p></li></ul></li>
        #|    <li><ul><li>5.1</li></ul><p>5 After</p></li>
        #|    <li><span>6 Before <br />6 also Before</span><ul><li>6A.1</li></ul><span>6 Between</span><ul><li>6B.1</li></ul><p>6 After</p><p>6 also After</p></li>
        #|    <li>7</li>
        #|  </ul>
        #|</div>
      ),
    ),
    content=(
      #|A paragraph
      #|
      #|- 1
      #|- 2
      #|- - 3.1
      #|  - 3.2
      #|- 4 Before
      #|  
      #|  - 4.1
      #|  - 4.2
      #|- - 5.1
      #|  
      #|  5 After
      #|- 6 Before  
      #|  6 also Before
      #|  
      #|  - 6A.1
      #|  
      #|  6 Between
      #|  
      #|  - 6B.1
      #|  
      #|  6 After
      #|  
      #|  6 also After
      #|- 7
    ),
  )
}

///|
test "golden list: ul then ol(start=9) then stray li" {
  inspect(
    @html2md.convert(
      (
        #|<div>
        #|  <p>And also other lists...</p>
        #|  <ul>
        #|    <li>First</li>
        #|    <li><p>Someone once said:</p><blockquote>My famous quote</blockquote><span>- someone</span></li>
        #|  </ul>
        #|  <ol start="9">
        #|    <li>Nine</li>
        #|    <li>Ten</li>
        #|    <li><ol start="111"><li>Eleven.A</li><li>Eleven.B</li></ol></li>
        #|    <li><p>Someone once said:</p><blockquote>My famous quote</blockquote><span>- someone</span></li>
        #|    <li>Thirteen</li>
        #|  </ol>
        #|  <li>List Item without Container</li>
        #|</div>
      ),
    ),
    content=(
      #|And also other lists...
      #|
      #|- First
      #|- Someone once said:
      #|  
      #|  > My famous quote
      #|  
      #|  \- someone
      #|
      #|<!--THE END-->
      #|
      #|09. Nine
      #|10. Ten
      #|11. 111. Eleven.A
      #|    112. Eleven.B
      #|12. Someone once said:
      #|    
      #|    > My famous quote
      #|    
      #|    \- someone
      #|13. Thirteen
      #|
      #|List Item without Container
    ),
  )
}

///|
test "golden list: blockquote with break inside item" {
  inspect(
    @html2md.convert(
      "<ol><li><blockquote>Line A<br />Line B</blockquote></li></ol>",
    ),
    content=(
      #|1. > Line A  
      #|   > Line B
    ),
  )
}

///|
test "golden list: ol with non-numeric start" {
  inspect(
    @html2md.convert("<ol start=\"text\"><li>one</li><li>two</li></ol>"),
    content=(
      #|1. one
      #|2. two
    ),
  )
}

///|
test "golden list: ordinal width padding" {
  inspect(
    @html2md.convert("<ol start=\"8\"><li>a</li><li>b</li></ol>"),
    content=(
      #|8. a
      #|9. b
    ),
  )
  inspect(
    @html2md.convert("<ol start=\"9\"><li>a</li><li>b</li></ol>"),
    content=(
      #|09. a
      #|10. b
    ),
  )
  inspect(
    @html2md.convert("<ol start=\"-1\"><li>a</li><li>b</li></ol>"),
    content=(
      #|-1. a
      #|00. b
    ),
  )
  inspect(
    @html2md.convert("<ol start=\"-10\"><li>a</li><li>b</li></ol>"),
    content=(
      #|-10. a
      #|-09. b
    ),
  )
}

///|
test "golden list: soft line break and link in item" {
  inspect(
    @html2md.convert(
      "<ul><li>Before\n      text after</li><li>Before\n      <a href=\"/page\">text</a> after</li></ul>",
    ),
    content=(
      #|- Before text after
      #|- Before [text](/page) after
    ),
  )
}

///|
test "golden list: code and link in item" {
  inspect(
    @html2md.convert(
      "<ul><li>A double <code>**</code> <a href=\"/page\">can open strong emphasis</a></li></ul>",
    ),
    content=(
      #|- A double `**` [can open strong emphasis](/page)
    ),
  )
}

///|
test "golden list: nested list containers collapse to one item" {
  inspect(
    @html2md.convert(
      "<ol><ol><ol><ol><ol><li>lots of list containers</li></ol></ol></ol></ol></ol>",
    ),
    content=(
      #|1. 1. 1. 1. 1. lots of list containers
    ),
  )
  inspect(
    @html2md.convert(
      "<ol><li><ol><li><ol><li>lots of list items</li></ol></li></ol></li></ol>",
    ),
    content=(
      #|1. 1. 1. lots of list items
    ),
  )
}

///|
test "golden list: with breaks in items" {
  inspect(
    @html2md.convert(
      "<ul><li><p>Start Line</p><br /><br /><br /><span> </span><br /><br /><br /><p>End Line</p></li><li><p>Start Line<br /><br /><br /><span> </span><br /><br /><br />End Line</p></li></ul>",
    ),
    content=(
      #|- Start Line
      #|  
      #|  End Line
      #|- Start Line
      #|  
      #|  End Line
    ),
  )
}

///|
test "golden list: code block in item" {
  inspect(
    @html2md.convert(
      "<ul><li>item:<pre>line 1\nline 2</pre></li><li>item 2</li></ul>",
    ),
    content=(
      #|- item:
      #|  
      #|  ```
      #|  line 1
      #|  line 2
      #|  ```
      #|- item 2
    ),
  )
}

///|
test "golden list: code block in nested item" {
  inspect(
    @html2md.convert(
      "<ul><li>item 1:<ul><li>nested item 1:<pre>line 1\nline 2</pre></li><li>nested item 2</li></ul></li><li>item 2</li></ul>",
    ),
    content=(
      #|- item 1:
      #|  
      #|  - nested item 1:
      #|    
      #|    ```
      #|    line 1
      #|    line 2
      #|    ```
      #|  - nested item 2
      #|- item 2
    ),
  )
}

///|
test "golden list: special characters escaped" {
  inspect(
    @html2md.convert("<p>1.</p>"),
    content=(
      #|1\.
    ),
  )
  inspect(
    @html2md.convert("<p>-</p>"),
    content=(
      #|\-
    ),
  )
  inspect(
    @html2md.convert("<p>+</p>"),
    content=(
      #|\+
    ),
  )
  inspect(
    @html2md.convert("<p>*</p>"),
    content=(
      #|\*
    ),
  )
  inspect(
    @html2md.convert("<p>1. not a list</p>"),
    content=(
      #|1\. not a list
    ),
  )
  inspect(
    @html2md.convert("<p>- not a list</p>"),
    content=(
      #|\- not a list
    ),
  )
  inspect(
    @html2md.convert("<p>+ not a list</p>"),
    content=(
      #|\+ not a list
    ),
  )
  inspect(
    @html2md.convert("<p>* not a list</p>"),
    content=(
      #|\* not a list
    ),
  )
}

///|
test "golden list: adjacent lists get end comments" {
  inspect(
    @html2md.convert(
      "<div><ul><li>List 1</li></ul><ul><li>List 2</li></ul><ul></ul><ul><li>List 3</li></ul></div>",
    ),
    content=(
      #|- List 1
      #|
      #|<!--THE END-->
      #|
      #|- List 2
      #|
      #|<!--THE END-->
      #|
      #|<!--THE END-->
      #|
      #|- List 3
    ),
  )
}
