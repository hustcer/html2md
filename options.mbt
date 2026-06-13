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
  if !(em_delimiter is ("*" | "_")) {
    raise ConvertError::InvalidConfig(
      "invalid em_delimiter \"\{em_delimiter}\": must be \"*\" or \"_\"",
    )
  }
  if !(strong_delimiter is ("**" | "__")) {
    raise ConvertError::InvalidConfig(
      "invalid strong_delimiter \"\{strong_delimiter}\": must be \"**\" or \"__\"",
    )
  }
  if !(bullet_list_marker is ("-" | "+" | "*")) {
    raise ConvertError::InvalidConfig(
      "invalid bullet_list_marker \"\{bullet_list_marker}\": must be \"-\", \"+\" or \"*\"",
    )
  }
  if !(code_block_fence is ("```" | "~~~")) {
    raise ConvertError::InvalidConfig(
      "invalid code_block_fence \"\{code_block_fence}\": must be \"```\" or \"~~~\"",
    )
  }
  if horizontal_rule is "" {
    raise ConvertError::InvalidConfig("horizontal_rule must not be empty")
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
