// Exhaustive port of the internal/textutils/*_test.go sub-cases.

///|
/// Go runs TrimUnnecessaryHardLineBreaks(TrimConsecutiveNewlines(x)) together
/// in consecutive_newlines_test.go.
fn trim_both(input : String) -> String {
  @textutils.trim_unnecessary_hard_line_breaks(
    @textutils.trim_consecutive_newlines(input),
  )
}

///|
test "trim_consecutive_newlines + hard breaks (full table)" {
  inspect(trim_both(""), content="")
  inspect(trim_both("a"), content="a")
  inspect(trim_both("hello"), content="hello")
  inspect(
    trim_both("hello  this is a   normal text"),
    content="hello  this is a   normal text",
  )
  // single newline
  inspect(trim_both("a\nb"), content="a\nb")
  inspect(trim_both("a  \nb"), content="a  \nb")
  inspect(trim_both("a\n  b"), content="a\n  b")
  // double newline
  inspect(trim_both("a\n\nb"), content="a\n\nb")
  inspect(trim_both("a  \n\nb"), content="a\n\nb")
  inspect(trim_both("a\n  \nb"), content="a\n  \nb")
  inspect(trim_both("a\n\n  b"), content="a\n\n  b")
  // triple+
  inspect(trim_both("a\n\n\nb"), content="a\n\nb")
  inspect(trim_both("a\n\n\n\nb"), content="a\n\nb")
  inspect(trim_both("a  \n\n\nb"), content="a\n\nb")
  // multiple segments
  inspect(trim_both("a\n\nb\n\nc"), content="a\n\nb\n\nc")
  inspect(trim_both("a  \n\nb  \n\nc"), content="a\n\nb\n\nc")
  // hard line break
  inspect(trim_both("a  \nb"), content="a  \nb")
  inspect(trim_both("a  \n\nb"), content="a\n\nb")
  // edge cases
  inspect(trim_both("\n\n\n"), content="\n\n")
  inspect(trim_both("   "), content="   ")
  inspect(trim_both("\n\n\ntext\n\n\n"), content="\n\ntext\n\n")
  inspect(trim_both("  \n  \n  \n  \n  "), content="\n\n  ")
  inspect(trim_both("a  \n  \nb"), content="a\n\nb")
  inspect(trim_both("a  \n \nb"), content="a\n\nb")
  inspect(trim_both("   a"), content="   a")
  inspect(trim_both("\na"), content="\na")
  inspect(trim_both("\n\na"), content="\n\na")
  inspect(trim_both("\n\n\na"), content="\n\na")
  inspect(trim_both("a   "), content="a   ")
  inspect(trim_both("a\n"), content="a\n")
  inspect(trim_both("a\n\n"), content="a\n\n")
  inspect(trim_both("a\n\n\n"), content="a\n\n")
  // UTF-8
  inspect(trim_both("äöü\n\n\näöü"), content="äöü\n\näöü")
  inspect(trim_both("🌟\n\n\n🌟\n\n\n🌟"), content="🌟\n\n🌟\n\n🌟")
  // markdown indented sublist
  inspect(
    trim_both("- The main list\n  \n  - The sublist"),
    content="- The main list\n  \n  - The sublist",
  )
}

///|
test "collapse_inline_code_content (full table)" {
  inspect(@textutils.collapse_inline_code_content(""), content="")
  inspect(@textutils.collapse_inline_code_content("a b"), content="a b")
  inspect(@textutils.collapse_inline_code_content("a\nb"), content="a b")
  inspect(@textutils.collapse_inline_code_content("a\nb\n\nc"), content="a b c")
  inspect(@textutils.collapse_inline_code_content(" a b "), content="a b")
  inspect(
    @textutils.collapse_inline_code_content(
      "\n\t\t\tbody {\n\t\t\t\tcolor: yellow;\n\t\t\t\tfont-size: 16px;\n\t\t\t}\n\t\t\t",
    ),
    content="body { color: yellow; font-size: 16px; }",
  )
}

///|
test "prefix_lines (full table)" {
  inspect(@textutils.prefix_lines("abc", "> "), content="> abc")
  inspect(
    @textutils.prefix_lines("line 1\nline 2", "> "),
    content="> line 1\n> line 2",
  )
  inspect(
    @textutils.prefix_lines("line 1\n\nline 2", "> "),
    content="> line 1\n> \n> line 2",
  )
  inspect(@textutils.prefix_lines("abc\n", "> "), content="> abc\n> ")
}

///|
test "surround_by_quotes (full table)" {
  inspect(@textutils.surround_by_quotes(""), content="")
  inspect(
    @textutils.surround_by_quotes("no quotes are here"),
    content="\"no quotes are here\"",
  )
  inspect(
    @textutils.surround_by_quotes("double \"quotes\" are here"),
    content="'double \"quotes\" are here'",
  )
  inspect(
    @textutils.surround_by_quotes("single 'quotes' are here"),
    content="\"single 'quotes' are here\"",
  )
  inspect(
    @textutils.surround_by_quotes("double \" AND single ' quotes '\" are here"),
    content="\"double \\\" AND single ' quotes '\\\" are here\"",
  )
}

///|
test "surrounding_spaces (full table)" {
  debug_inspect(@textutils.surrounding_spaces(""), content="(\"\", \"\", \"\")")
  debug_inspect(
    @textutils.surrounding_spaces(" "),
    content="(\"\", \"\", \" \")",
  )
  debug_inspect(
    @textutils.surrounding_spaces("some text"),
    content="(\"\", \"some text\", \"\")",
  )
  debug_inspect(
    @textutils.surrounding_spaces("  text    "),
    content="(\"  \", \"text\", \"    \")",
  )
  debug_inspect(
    @textutils.surrounding_spaces("\n\n text  \n\n"),
    content="(\"\\n\\n \", \"text\", \"  \\n\\n\")",
  )
}

///|
test "calculate_code_fence (full table)" {
  inspect(
    @textutils.calculate_code_fence('`', "normal ~~~ code block"),
    content="```",
  )
  inspect(
    @textutils.calculate_code_fence('~', "normal ``` code block"),
    content="~~~",
  )
  inspect(@textutils.calculate_code_fence('`', "```"), content="````")
  inspect(
    @textutils.calculate_code_fence('`', "normal ``` code block"),
    content="````",
  )
  inspect(
    @textutils.calculate_code_fence('`', "normal ````` code block"),
    content="``````",
  )
  inspect(
    @textutils.calculate_code_fence('`', "normal ``` code `````` block"),
    content="```````",
  )
  inspect(
    @textutils.calculate_code_fence('~', "normal ~~~ code ~~~~~~~~~~~~ block"),
    content="~~~~~~~~~~~~~",
  )
  inspect(
    @textutils.calculate_code_fence(
      '~', "\nnormal\n\t~~~\ncode ~~~~~~~~~~~~ block\n\t\t\t\t",
    ),
    content="~~~~~~~~~~~~~",
  )
}

///|
test "delimiter_for_every_line (full table)" {
  inspect(
    @textutils.delimiter_for_every_line("bold text", "**"),
    content="**bold text**",
  )
  inspect(
    @textutils.delimiter_for_every_line(" bold text ", "**"),
    content=" **bold text** ",
  )
  inspect(
    @textutils.delimiter_for_every_line("\u{a0}bold text\u{a0}\u{a0}", "**"),
    content="\u{a0}**bold text**\u{a0}\u{a0}",
  )
  inspect(
    @textutils.delimiter_for_every_line("bold\u{a0}\ntext\u{a0}", "**"),
    content="**bold**\u{a0}\n**text**\u{a0}",
  )
  inspect(
    @textutils.delimiter_for_every_line("line 1\nline 2", "**"),
    content="**line 1**\n**line 2**",
  )
  inspect(
    @textutils.delimiter_for_every_line("line 1\n\n\nline 2", "_"),
    content="_line 1_\n\n\n_line 2_",
  )
  inspect(
    @textutils.delimiter_for_every_line("\nline 1\n\nline 2\nline 3\n", "__"),
    content="\n__line 1__\n\n__line 2__\n__line 3__\n",
  )
}

///|
test "escape_multiline (full table, after trim_consecutive_newlines)" {
  fn go_case(text : String) -> String {
    @textutils.escape_multiline(@textutils.trim_consecutive_newlines(text))
  }

  inspect(go_case(""), content="")
  inspect(
    go_case("some longer text that is on one line"),
    content="some longer text that is on one line",
  )
  inspect(go_case("A\nB"), content="A  \nB")
  inspect(go_case("A\n\nB"), content="A  \n\\\nB")
  inspect(go_case("line 1\n\n\n\nline 2"), content="line 1  \n\\\nline 2")
  inspect(
    go_case("line1\nline2\n\nline3\n\n\n\n\nline4"),
    content="line1  \nline2  \n\\\nline3  \n\\\nline4",
  )
  inspect(go_case("line 1\n  \nline 2"), content="line 1  \n\\\nline 2")
  inspect(go_case("a\n\n b"), content="a  \n\\\nb")
  inspect(
    go_case("line 1\n  line 2\n\tline 3"),
    content="line 1  \nline 2  \nline 3",
  )
}
