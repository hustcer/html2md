///|
test "trim_consecutive_newlines" {
  inspect(
    @textutils.trim_consecutive_newlines("normal\n\ntext"),
    content="normal\n\ntext",
  )
  inspect(
    @textutils.trim_consecutive_newlines("1\n\n\n2\n\n\n\n3"),
    content="1\n\n2\n\n3",
  )
  // spaces around *dropped* newlines are dropped; spaces between kept newlines stay
  inspect(
    @textutils.trim_consecutive_newlines("a \n \n \n b"),
    content="a \n \n b",
  )
  inspect(
    @textutils.trim_consecutive_newlines("trailing  "),
    content="trailing  ",
  )
  inspect(@textutils.trim_consecutive_newlines(""), content="")
}

///|
test "trim_unnecessary_hard_line_breaks" {
  inspect(
    @textutils.trim_unnecessary_hard_line_breaks("a  \n\nb"),
    content="a\n\nb",
  )
  inspect(
    @textutils.trim_unnecessary_hard_line_breaks("a  \n  \nb"),
    content="a\n\nb",
  )
  inspect(
    @textutils.trim_unnecessary_hard_line_breaks("a  \n \nb"),
    content="a\n\nb",
  )
  inspect(
    @textutils.trim_unnecessary_hard_line_breaks("a  \nb"),
    content="a  \nb",
  )
}

///|
test "surrounding_spaces" {
  debug_inspect(
    @textutils.surrounding_spaces(" bold text "),
    content="(\" \", \"bold text\", \" \")",
  )
  debug_inspect(
    @textutils.surrounding_spaces("no extra"),
    content="(\"\", \"no extra\", \"\")",
  )
  debug_inspect(
    @textutils.surrounding_spaces("   "),
    content="(\"\", \"\", \"   \")",
  )
  // non-breaking space counts as whitespace (unicode.IsSpace)
  let (l, t, r) = @textutils.surrounding_spaces("\u{a0}x\u{a0}\u{a0}")
  inspect(l.length(), content="1")
  inspect(t, content="x")
  inspect(r.length(), content="2")
}

///|
test "delimiter_for_every_line" {
  inspect(
    @textutils.delimiter_for_every_line("bold text", "**"),
    content="**bold text**",
  )
  inspect(
    @textutils.delimiter_for_every_line(" bold text ", "**"),
    content=" **bold text** ",
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
    @textutils.delimiter_for_every_line("\u{a0}bold text\u{a0}\u{a0}", "**"),
    content="\u{a0}**bold text**\u{a0}\u{a0}",
  )
  inspect(
    @textutils.delimiter_for_every_line("bold\u{a0}\ntext\u{a0}", "**"),
    content="**bold**\u{a0}\n**text**\u{a0}",
  )
  inspect(
    @textutils.delimiter_for_every_line("\nline 1\n\nline 2\nline 3\n", "__"),
    content="\n__line 1__\n\n__line 2__\n__line 3__\n",
  )
}

///|
test "escape_multiline (after trim_consecutive_newlines, as in Go tests)" {
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

///|
test "prefix_lines" {
  inspect(@textutils.prefix_lines("a\nb", "> "), content="> a\n> b")
  inspect(@textutils.prefix_lines("a\n", "> "), content="> a\n> ")
  inspect(@textutils.prefix_lines("", "> "), content="> ")
}

///|
test "collapse_inline_code_content" {
  inspect(@textutils.collapse_inline_code_content(""), content="")
  inspect(@textutils.collapse_inline_code_content("a\nb"), content="a b")
  inspect(@textutils.collapse_inline_code_content("a\t \n b"), content="a b")
  inspect(@textutils.collapse_inline_code_content("  a    b  "), content="a b")
}

///|
test "calculate_code_fence" {
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
}

///|
test "surround_by_quotes" {
  inspect(@textutils.surround_by_quotes(""), content="")
  inspect(@textutils.surround_by_quotes("title"), content="\"title\"")
  inspect(
    @textutils.surround_by_quotes("with \"double\""),
    content="'with \"double\"'",
  )
  inspect(
    @textutils.surround_by_quotes("it's single"),
    content="\"it's single\"",
  )
  inspect(
    @textutils.surround_by_quotes("\"both\" and 'single'"),
    content="\"\\\"both\\\" and 'single'\"",
  )
}
