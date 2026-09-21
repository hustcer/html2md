///|
/// Heading rendering style.
///
/// - `Atx`: `## Heading` (default)
/// - `Setext`: underline style for h1/h2, e.g. `Heading\n-------`
pub(all) enum HeadingStyle {
  Atx
  Setext
} derive(Eq, Debug)

///|
pub extend HeadingStyle with Eq::{equal, not_equal}

///|
pub extend HeadingStyle with Debug::{to_repr}

///|
/// Controls the escaping of characters that have a special meaning in markdown.
///
/// - `Smart` (default): only escape a character when it would otherwise be
///   parsed as markdown syntax in its surrounding context.
/// - `Disabled`: never escape.
pub(all) enum EscapeMode {
  Smart
  Disabled
} derive(Eq, Debug)

///|
pub extend EscapeMode with Eq::{equal, not_equal}

///|
pub extend EscapeMode with Debug::{to_repr}

///|
/// Controls how links with an empty href / empty content are rendered.
///
/// - `Render`: still render as a link, e.g. `[content]()` (default)
/// - `Skip`: fall back to rendering the content without link syntax
pub(all) enum LinkBehavior {
  Render
  Skip
} derive(Eq, Debug)

///|
pub extend LinkBehavior with Eq::{equal, not_equal}

///|
pub extend LinkBehavior with Debug::{to_repr}

///|
/// Error raised by `convert` / `convert_dom`.
pub(all) suberror ConvertError {
  /// An option value is invalid (e.g. an unsupported delimiter).
  InvalidConfig(String)
  /// The HTML input could not be parsed.
  ParseFailed(String)
} derive(Debug)

///|
pub extend ConvertError with Debug::{to_repr}
