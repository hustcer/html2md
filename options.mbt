///|
/// Resolved conversion options (filled from the labeled parameters of
/// `convert` / `convert_dom`, then validated).
priv struct Options {
  domain : String
  heading_style : HeadingStyle
  em_delimiter : String
  strong_delimiter : String
  horizontal_rule : String
  bullet_list_marker : String
  code_block_fence : String
  escape_mode : EscapeMode
  link_empty_href_behavior : LinkBehavior
  link_empty_content_behavior : LinkBehavior
  list_end_comment : Bool
}

///|
/// True when `s` is a thematic break line: at least three matching `*`, `_`,
/// or `-` marker chars, with optional spaces between them.
fn is_horizontal_rule(s : String) -> Bool {
  let mut n = 0
  let mut marker : Char? = None
  for ch in s {
    if ch is ' ' {
      continue
    }
    if !(ch is ('*' | '_' | '-')) {
      return false
    }
    match marker {
      None => marker = Some(ch)
      Some(prev) if prev == ch => ()
      Some(_) => return false
    }
    n += 1
  }
  n >= 3
}

///|
/// Validate option values, mirroring `plugin/commonmark/validation.go`.
fn Options::build(
  domain~ : String,
  heading_style~ : HeadingStyle,
  em_delimiter~ : String,
  strong_delimiter~ : String,
  horizontal_rule~ : String,
  bullet_list_marker~ : String,
  code_block_fence~ : String,
  escape_mode~ : EscapeMode,
  link_empty_href_behavior~ : LinkBehavior,
  link_empty_content_behavior~ : LinkBehavior,
  list_end_comment~ : Bool,
) -> Options raise ConvertError {
  // em: exactly one "*" or one "_"
  if !(em_delimiter is ("*" | "_")) {
    raise InvalidConfig(
      "invalid em_delimiter \"\{em_delimiter}\": must be exactly 1 character of \"*\" or \"_\"",
    )
  }
  // strong: exactly two "*" or two "_"
  if !(strong_delimiter is ("**" | "__")) {
    raise InvalidConfig(
      "invalid strong_delimiter \"\{strong_delimiter}\": must be exactly 2 characters of \"**\" or \"__\"",
    )
  }
  // horizontal rule: at least 3 of "*", "_" or "-"
  if !is_horizontal_rule(horizontal_rule) {
    raise InvalidConfig(
      "invalid horizontal_rule \"\{horizontal_rule}\": must be at least 3 characters of \"*\", \"_\" or \"-\"",
    )
  }
  if !(bullet_list_marker is ("-" | "+" | "*")) {
    raise InvalidConfig(
      "invalid bullet_list_marker \"\{bullet_list_marker}\": must be one of \"-\", \"+\" or \"*\"",
    )
  }
  if !(code_block_fence is ("```" | "~~~")) {
    raise InvalidConfig(
      "invalid code_block_fence \"\{code_block_fence}\": must be one of \"```\" or \"~~~\"",
    )
  }
  {
    domain,
    heading_style,
    em_delimiter,
    strong_delimiter,
    horizontal_rule,
    bullet_list_marker,
    code_block_fence,
    escape_mode,
    link_empty_href_behavior,
    link_empty_content_behavior,
    list_end_comment,
  }
}
