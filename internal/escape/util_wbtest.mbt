// White-box tests for the private prev/next helpers, ported from
// internal/escape/util_test.go (TestGetPrev / TestGetNext / TestGetNextAsRune).
// In char space get_prev/get_next subsume the byte and rune variants.

///|
let nul : Char = '\u{0000}'

///|
test "get_prev skips marker, NUL at start" {
  let input = ['a', MARKER_ESCAPING, 'b', 'c']
  inspect(get_prev(input, 3), content="b")
  inspect(get_prev(input, 2), content="a")
  inspect(get_prev(input, 1), content="a")
  inspect(get_prev(input, 0) == nul, content="true")
}

///|
test "get_next skips marker, NUL at end" {
  let input = ['a', MARKER_ESCAPING, 'b', 'c']
  inspect(get_next(input, 0), content="b")
  inspect(get_next(input, 1), content="b")
  inspect(get_next(input, 2), content="c")
  inspect(get_next(input, 3) == nul, content="true")
}

///|
test "get_next/get_prev across a multibyte char with markers" {
  // Port of TestGetNextAsRune: "a\a⌘\ab" — in char space the marker is one
  // code unit and ⌘ is one char, so prev/next return the char directly.
  let input = ['a', MARKER_ESCAPING, '⌘', MARKER_ESCAPING, 'b']
  inspect(get_next(input, 0), content="⌘")
  inspect(get_next(input, 4) == nul, content="true")
  inspect(get_prev(input, 4), content="⌘")
  inspect(get_prev(input, 0) == nul, content="true")
}

///|
test "is_space_char matches Go IsSpace" {
  inspect(is_space_char(nul), content="false")
  inspect(is_space_char('a'), content="false")
  inspect(is_space_char('ä'), content="false")
  inspect(is_space_char('字'), content="false")
  inspect(is_space_char(' '), content="true")
  inspect(is_space_char('\t'), content="true")
}
