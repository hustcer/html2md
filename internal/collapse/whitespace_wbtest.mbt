// White-box test for the private replaceAnyWhitespaceWithSpace, ported from
// collapse/whitespace_test.go. The Go test also re-runs each case with spaces
// swapped for newlines, so we do the same here.

///|
fn ws_both(input : String, expected : String) -> Unit raise {
  assert_eq(replace_any_whitespace_with_space(input), expected)
  // Same expectation when every space is a newline instead.
  assert_eq(
    replace_any_whitespace_with_space(input.replace_all(old=" ", new="\n")),
    expected,
  )
}

///|
test "replace_any_whitespace_with_space (full table)" {
  ws_both("", "")
  ws_both(" ", " ")
  ws_both("  ", " ")
  ws_both("     ", " ")
  // newline variants are covered by ws_both's second assertion
  ws_both("\n a \nb  \nc\n", " a b c ")
  // special en-dash is not whitespace
  assert_eq(replace_any_whitespace_with_space(" \u{2013} "), " \u{2013} ")
  ws_both("abcdef", "abcdef")
  ws_both("abc def", "abc def")
  ws_both("abc  def", "abc def")
  ws_both(" abcdef", " abcdef")
  ws_both("  abcdef", " abcdef")
  ws_both("abcdef ", "abcdef ")
  ws_both("abcdef  ", "abcdef ")
  ws_both("   or ", " or ")
  ws_both("   or   ", " or ")
  ws_both(" or   ", " or ")
}
