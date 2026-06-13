// End-to-end cases ported from testdata/GoldenFiles/code.{in.html,out.md}.

///|
test "golden code: different inline code tags" {
  inspect(
    @html2md.convert("<div><code>inline code</code></div>"),
    content=(
      #|`inline code`
    ),
  )
  inspect(
    @html2md.convert("<div><var>variable</var></div>"),
    content=(
      #|`variable`
    ),
  )
  inspect(
    @html2md.convert("<div><samp>sample output</samp></div>"),
    content=(
      #|`sample output`
    ),
  )
  inspect(
    @html2md.convert("<div><kbd>keyboard input</kbd></div>"),
    content=(
      #|`keyboard input`
    ),
  )
  inspect(
    @html2md.convert("<div><tt>teletype text</tt></div>"),
    content=(
      #|`teletype text`
    ),
  )
}

///|
test "golden code: inline in text" {
  inspect(
    @html2md.convert(
      "<div>When <code>x = 3</code>, that means <code>x + 2 = 5</code></div>",
    ),
    content=(
      #|When `x = 3`, that means `x + 2 = 5`
    ),
  )
  inspect(
    @html2md.convert(
      "<div>A simple equation: <var>x</var> = <var>y</var> + 2 </div>",
    ),
    content=(
      #|A simple equation: `x` = `y` + 2
    ),
  )
}

///|
test "golden code: adjacent" {
  inspect(
    @html2md.convert(
      "<div>before <code>A</code> middle <code>B</code> after</div>",
    ),
    content=(
      #|before `A` middle `B` after
    ),
  )
  inspect(
    @html2md.convert("<div>before<code>A</code>middle<code>B</code>after</div>"),
    content=(
      #|before`A`middle`B`after
    ),
  )
  inspect(
    @html2md.convert("<div>before <code>A</code> <code>B</code> after</div>"),
    content=(
      #|before `A` `B` after
    ),
  )
  inspect(
    @html2md.convert("<div>before<code>A</code><code>B</code>after</div>"),
    content=(
      #|before`AB`after
    ),
  )
  inspect(
    @html2md.convert(
      "<div><code>A</code><var>B</var><samp>C</samp><kbd>D</kbd><tt>E</tt></div>",
    ),
    content=(
      #|`ABCDE`
    ),
  )
}

///|
test "golden code: with bold/italic outside" {
  inspect(
    @html2md.convert(
      "<div>before<strong><code>inline code</code></strong>after</div>",
    ),
    content=(
      #|before **`inline code`** after
    ),
  )
  inspect(
    @html2md.convert("<div>before<em><code>inline code</code></em>after</div>"),
    content=(
      #|before *`inline code`* after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before<strong>a<code>inline code</code>b</strong>after</div>",
    ),
    content=(
      #|before**a`inline code`b**after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before<strong><span></span><code>inline code</code><span></span></strong>after</div>",
    ),
    content=(
      #|before **`inline code`** after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before <strong><code>&lt;pre&gt;</code></strong> after</div>",
    ),
    content=(
      #|before **`<pre>`** after
    ),
  )
}

///|
test "golden code: other tags inside" {
  inspect(
    @html2md.convert("<div>before <code>&lt;img&gt;</code> after</div>"),
    content=(
      #|before `<img>` after
    ),
  )
  inspect(
    @html2md.convert("<div>before <code><img /></code> after</div>"),
    content=(
      #|before after
    ),
  )
  inspect(
    @html2md.convert("<div>before <samp>A <em>middle</em> B</samp> after</div>"),
    content=(
      #|before `A middle B` after
    ),
  )
}

///|
test "golden code: pre/code with tags inside" {
  inspect(
    @html2md.convert(
      "<pre><code>\nThe &lt;img&gt; tag is used to embed an image.\n\nThe <img> tag is used to embed an image.\n</code></pre>",
    ),
    content=(
      #|```
      #|
      #|The <img> tag is used to embed an image.
      #|
      #|The  tag is used to embed an image.
      #|```
    ),
  )
  inspect(
    @html2md.convert(
      "<pre><code>\n    <ul>\n        <li>List Item One</li>\n        <li>List Item Two</li>\n    </ul>\n</code></pre>",
    ),
    content=(
      #|```
      #|
      #|    
      #|        List Item One
      #|        List Item Two
      #|    
      #|```
    ),
  )
}

///|
test "golden code: empty inline code spacing" {
  inspect(
    @html2md.convert("<div>before<code></code>after</div>"),
    content=(
      #|beforeafter
    ),
  )
  inspect(
    @html2md.convert("<div>before <code></code> after</div>"),
    content=(
      #|before after
    ),
  )
  inspect(
    @html2md.convert("<div>before<code> </code>after</div>"),
    content=(
      #|before` `after
    ),
  )
  inspect(
    @html2md.convert("<div>before <code> </code> after</div>"),
    content=(
      #|before ` ` after
    ),
  )
  inspect(
    @html2md.convert("<div>before<code>  </code>after</div>"),
    content=(
      #|before`  `after
    ),
  )
}

///|
test "golden code: empty pre code blocks" {
  inspect(
    @html2md.convert("<pre><code></code></pre>"),
    content=(
      #|```
      #|
      #|```
    ),
  )
  inspect(
    @html2md.convert("<pre><code> </code></pre>"),
    content=(
      #|```
      #| 
      #|```
    ),
  )
  inspect(
    @html2md.convert("<pre><code>\n  \n</code></pre>"),
    content=(
      #|```
      #|
      #|  
      #|```
    ),
  )
}

///|
test "golden code: pre preserves internal blank lines" {
  inspect(
    @html2md.convert(
      "<pre><code>Beginning of code\n \n  \n  \n\n\nEnd of code</code></pre>",
    ),
    content=(
      #|```
      #|Beginning of code
      #| 
      #|  
      #|  
      #|
      #|
      #|End of code
      #|```
    ),
  )
  inspect(
    @html2md.convert(
      "<pre><code>Start of many newlines\n\n\n\n\n\nEnd of many newlines</code></pre>",
    ),
    content=(
      #|```
      #|Start of many newlines
      #|
      #|
      #|
      #|
      #|
      #|End of many newlines
      #|```
    ),
  )
}

///|
test "golden code: whitespace at edges is trimmed for inline" {
  inspect(
    @html2md.convert("<div><code> inline code</code></div>"),
    content=(
      #|`inline code`
    ),
  )
  inspect(
    @html2md.convert("<div><code>inline code </code></div>"),
    content=(
      #|`inline code`
    ),
  )
  inspect(
    @html2md.convert("<div><code> inline code </code></div>"),
    content=(
      #|`inline code`
    ),
  )
  inspect(
    @html2md.convert("<div><code>  inline code  </code></div>"),
    content=(
      #|`inline code`
    ),
  )
}

///|
test "golden code: backticks in content get larger fence" {
  inspect(
    @html2md.convert("<div><code>with ` backtick</code></div>"),
    content=(
      #|``with ` backtick``
    ),
  )
  inspect(
    @html2md.convert("<div><code>with `` backticks</code></div>"),
    content=(
      #|```with `` backticks```
    ),
  )
  inspect(
    @html2md.convert("<div><code>a ``` b ```` c ` d</code></div>"),
    content=(
      #|`````a ``` b ```` c ` d`````
    ),
  )
  inspect(
    @html2md.convert(
      "<div><code>`starting & ending with a backtick`</code></div>",
    ),
    content=(
      #|`` `starting & ending with a backtick` ``
    ),
  )
}

///|
test "golden code: content that is just backticks" {
  inspect(
    @html2md.convert("<div>before<code>``</code>after</div>"),
    content=(
      #|before``` `` ```after
    ),
  )
  inspect(
    @html2md.convert("<div>before <code>``</code> after</div>"),
    content=(
      #|before ``` `` ``` after
    ),
  )
}

///|
test "golden code: fence characters in pre block" {
  inspect(
    @html2md.convert("<pre><code>```</code></pre>"),
    content=(
      #|````
      #|```
      #|````
    ),
  )
  inspect(
    @html2md.convert("<pre><code>~~~</code></pre>"),
    content=(
      #|```
      #|~~~
      #|```
    ),
  )
  inspect(
    @html2md.convert(
      "<pre><code>\nSome ```\ntotally `````` normal\n` code\n</code></pre>",
    ),
    content=(
      #|```````
      #|
      #|Some ```
      #|totally `````` normal
      #|` code
      #|```````
    ),
  )
}

///|
test "golden code: code vs pre combinations" {
  inspect(
    @html2md.convert("<div>before <code>just code</code> after</div>"),
    content=(
      #|before `just code` after
    ),
  )
  inspect(
    @html2md.convert("<div>before <pre>just pre</pre> after</div>"),
    content=(
      #|before
      #|
      #|```
      #|just pre
      #|```
      #|
      #|after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before <code><pre>code inside pre</pre></code> after</div>",
    ),
    content=(
      #|before
      #|
      #|```
      #|code inside pre
      #|```
      #|
      #|after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before <pre><code>pre inside code</code></pre> after</div>",
    ),
    content=(
      #|before
      #|
      #|```
      #|pre inside code
      #|```
      #|
      #|after
    ),
  )
}

///|
test "golden code: multiline code vs pre" {
  inspect(
    @html2md.convert(
      "<div>before <code>\n// just code\n// another line\n</code> after</div>",
    ),
    content=(
      #|before `// just code // another line` after
    ),
  )
  inspect(
    @html2md.convert(
      "<div>before <pre>\n// just pre\n// another line\n</pre> after</div>",
    ),
    content=(
      #|before
      #|
      #|```
      #|// just pre
      #|// another line
      #|```
      #|
      #|after
    ),
  )
}

///|
test "golden code: language classes" {
  inspect(
    @html2md.convert(
      "<div><pre class=\"language-one\"><code class=\"language-two\">content</code></pre></div>",
    ),
    content=(
      #|```one
      #|content
      #|```
    ),
  )
  inspect(
    @html2md.convert(
      "<div><code class=\"language-one\"><pre class=\"language-two\">content</pre></code></div>",
    ),
    content=(
      #|```two
      #|content
      #|```
    ),
  )
}

///|
test "golden code: highlighting spans are stripped" {
  inspect(
    @html2md.convert(
      "<div><pre><code>Line 0\n    Line 1 <span>A</span><span>B</span> <span>C</span>\n    Line 2 <span>A</span><span>B</span> <span>C</span>\nLine 3</code></pre></div>",
    ),
    content=(
      #|```
      #|Line 0
      #|    Line 1 AB C
      #|    Line 2 AB C
      #|Line 3
      #|```
    ),
  )
}
