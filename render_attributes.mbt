///|
/// Attribute character references can contain CR even after HTML parsing.
/// Keep link/image descriptions on one line, treating CRLF as one line ending.
fn inline_attribute(node : @dom.Node, name : String) -> String {
  @domext.attr_or(node, name, "")
  .replace_all(old="\r\n", new=" ")
  .replace_all(old="\r", new=" ")
  .replace_all(old="\n", new=" ")
}
