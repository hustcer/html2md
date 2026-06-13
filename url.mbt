///|
/// Percent-encode the characters that would break markdown link/image syntax
/// (port of `converter.percentEncodingReplacer`).
fn percent_encode_url_chars(url : String) -> String {
  let out = StringBuilder(size_hint=url.length())
  for ch in url {
    match ch {
      ' ' => out.write_string("%20")
      '[' => out.write_string("%5B")
      ']' => out.write_string("%5D")
      '(' => out.write_string("%28")
      ')' => out.write_string("%29")
      '<' => out.write_string("%3C")
      '>' => out.write_string("%3E")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// Assemble an absolute URL, mirroring `converter.defaultAssembleAbsoluteURL`
/// closely enough for the common cases:
///   - "#" is returned unchanged
///   - newlines/tabs are pre-encoded
///   - "data:" URIs are only percent-encoded
///   - a relative URL is joined onto `domain` when one is provided
///   - query components are normalized with RFC 3986 percent-encoding
///   - special characters are percent-encoded
fn assemble_absolute_url(
  tag_name : String,
  raw_url : String,
  domain : String,
) -> String {
  ignore(tag_name)
  let raw = @textutils.trim_space(raw_url)
  if raw is "#" {
    return raw
  }
  // Increase the chance the url stays usable.
  let raw = raw
    .replace_all(old="\n", new="%0A")
    .replace_all(old="\t", new="%09")
  let scheme = url_scheme(raw)
  if scheme is Some("data") {
    return percent_encode_url_chars(raw)
  }
  let resolved = if domain != "" && is_relative_url(raw, scheme) {
    join_url(domain, raw)
  } else {
    raw
  }
  percent_encode_url_chars(normalize_query_component(resolved))
}

///|
/// Normalize the query component of a URI reference according to RFC 3986:
/// query = *( pchar / "/" / "?" ), where pchar allows unreserved,
/// pct-encoded, sub-delims, ":" and "@".
fn normalize_query_component(url : String) -> String {
  let (before_fragment, fragment) = split_fragment_suffix(url)
  match find_char(before_fragment, '?') {
    Some(query_start) => {
      let before_query = before_fragment[0:query_start + 1].to_owned()
      let query = before_fragment[query_start + 1:].to_owned()
      before_query + percent_encode_query(query) + fragment
    }
    None => url
  }
}

///|
fn split_fragment_suffix(s : String) -> (String, String) {
  match find_char(s, '#') {
    Some(idx) => (s[0:idx].to_owned(), s[idx:].to_owned())
    None => (s, "")
  }
}

///|
fn percent_encode_query(query : String) -> String {
  let out = StringBuilder(size_hint=query.length())
  let mut i = 0
  while i < query.length() {
    match query.get_char(i) {
      Some('%') if has_pct_encoded_triplet(query, i) => {
        out.write_char('%')
        out.write_char(uppercase_hex_char(query.get_char(i + 1).unwrap()))
        out.write_char(uppercase_hex_char(query.get_char(i + 2).unwrap()))
        i += 3
      }
      Some(ch) if is_rfc3986_query_char(ch) => {
        out.write_char(ch)
        i += ch.to_string().length()
      }
      Some(ch) => {
        write_percent_encoded_utf8(out, ch)
        i += ch.to_string().length()
      }
      None => i += 1
    }
  }
  out.to_string()
}

///|
fn has_pct_encoded_triplet(s : String, idx : Int) -> Bool {
  match (s.get_char(idx + 1), s.get_char(idx + 2)) {
    (Some(a), Some(b)) => is_ascii_hex_digit(a) && is_ascii_hex_digit(b)
    _ => false
  }
}

///|
fn is_rfc3986_query_char(ch : Char) -> Bool {
  is_ascii_alpha(ch) ||
  is_ascii_digit(ch) ||
  ch is ('-' | '.' | '_' | '~') ||
  ch is ('!' | '$' | '&' | '\'' | '(' | ')' | '*' | '+' | ',' | ';' | '=') ||
  ch is (':' | '@' | '/' | '?')
}

///|
fn is_ascii_hex_digit(ch : Char) -> Bool {
  is_ascii_digit(ch) || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')
}

///|
fn uppercase_hex_char(ch : Char) -> Char {
  match ch {
    'a' => 'A'
    'b' => 'B'
    'c' => 'C'
    'd' => 'D'
    'e' => 'E'
    'f' => 'F'
    _ => ch
  }
}

///|
fn write_percent_encoded_utf8(out : StringBuilder, ch : Char) -> Unit {
  for byte in @utf8.encode(ch.to_string()) {
    write_percent_encoded_byte(out, byte.to_int())
  }
}

///|
fn write_percent_encoded_byte(out : StringBuilder, byte : Int) -> Unit {
  out.write_char('%')
  out.write_char(hex_digit(byte / 16))
  out.write_char(hex_digit(byte % 16))
}

///|
fn hex_digit(n : Int) -> Char {
  if n < 10 {
    ('0'.to_int() + n).unsafe_to_char()
  } else {
    ('A'.to_int() + n - 10).unsafe_to_char()
  }
}

///|
/// Extract the URL scheme (lowercased) if the string starts with
/// `scheme:` where scheme is `ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )`.
fn url_scheme(url : String) -> String? {
  let mut i = 0
  let len = url.length()
  guard len > 0 else { return None }
  // First char must be a letter.
  match url.get_char(0) {
    Some(ch) if is_ascii_alpha(ch) => i = 1
    _ => return None
  }
  while i < len {
    match url.get_char(i) {
      Some(ch) =>
        if is_ascii_alpha(ch) || is_ascii_digit(ch) || ch is ('+' | '-' | '.') {
          i += 1
        } else if ch is ':' {
          return Some(url[0:i].to_owned().to_lower())
        } else {
          return None
        }
      None => return None
    }
  }
  None
}

///|
fn is_ascii_alpha(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')
}

///|
fn is_ascii_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
/// A URL is relative (joinable onto a domain) when it has no scheme and is
/// not a protocol-relative (`//host`) or fragment-only (`#x`) URL.
fn is_relative_url(url : String, scheme : String?) -> Bool {
  if scheme is Some(_) {
    return false
  }
  if url.has_prefix("//") {
    return false
  }
  true
}

///|
/// Join a relative URL onto a base domain (which may or may not carry a
/// scheme). Mirrors RFC 3986 relative reference resolution for path, query,
/// and fragment handling.
fn join_url(domain : String, raw : String) -> String {
  let (scheme_prefix, host_and_path) = split_scheme(domain)
  let scheme_prefix = if scheme_prefix is "" {
    "http://"
  } else {
    scheme_prefix
  }
  let (host, base_ref) = split_authority_ref(host_and_path)
  let base_without_fragment = strip_fragment(base_ref)
  let base_path = strip_query(base_without_fragment)
  if raw is "" {
    return scheme_prefix + host + base_without_fragment
  }
  if raw.has_prefix("#") {
    return scheme_prefix + host + base_without_fragment + raw
  }
  if raw.has_prefix("?") {
    return scheme_prefix + host + base_path + raw
  }
  let (raw_path, raw_suffix) = split_path_suffix(raw)
  if raw.has_prefix("/") {
    scheme_prefix + host + remove_dot_segments(raw_path) + raw_suffix
  } else {
    let merged = merge_relative_path(base_path, raw_path)
    scheme_prefix + host + remove_dot_segments(merged) + raw_suffix
  }
}

///|
/// Separate authority from the path/query/fragment reference.
fn split_authority_ref(s : String) -> (String, String) {
  for i, ch in s {
    if ch is ('/' | '?' | '#') {
      return (s[0:i].to_owned(), s[i:].to_owned())
    }
  }
  (s, "")
}

///|
fn strip_fragment(s : String) -> String {
  match find_char(s, '#') {
    Some(idx) => s[0:idx].to_owned()
    None => s
  }
}

///|
fn strip_query(s : String) -> String {
  match find_char(s, '?') {
    Some(idx) => s[0:idx].to_owned()
    None => s
  }
}

///|
/// Split a relative reference into path and query/fragment suffix.
fn split_path_suffix(s : String) -> (String, String) {
  for i, ch in s {
    if ch is ('?' | '#') {
      return (s[0:i].to_owned(), s[i:].to_owned())
    }
  }
  (s, "")
}

///|
/// Merge a relative reference path against the base path's directory.
fn merge_relative_path(base_path : String, raw_path : String) -> String {
  let dir = if base_path is "" {
    "/"
  } else {
    match last_index_char(base_path, '/') {
      Some(idx) => base_path[0:idx + 1].to_owned()
      None => "/"
    }
  }
  dir + raw_path
}

///|
/// Remove "." and ".." path segments after RFC 3986 section 5.2.4.
fn remove_dot_segments(path : String) -> String {
  let leading_slash = path.has_prefix("/")
  let trailing_slash = path.has_suffix("/") ||
    path.has_suffix("/.") ||
    path.has_suffix("/..")
  let segments : Array[String] = []
  let mut first = true
  for part_view in path.split("/") {
    let part = part_view.to_owned()
    if first && leading_slash && part is "" {
      first = false
      continue
    }
    first = false
    match part {
      "." => ()
      ".." => ignore(segments.pop())
      _ => segments.push(part)
    }
  }
  let joined = segments.join("/")
  let normalized = if leading_slash { "/" + joined } else { joined }
  if trailing_slash && normalized != "/" {
    normalized + "/"
  } else {
    normalized
  }
}

///|
/// Split off a leading `scheme://` (returns the prefix incl. "//" and the
/// remainder), or ("", domain) when there is none.
fn split_scheme(domain : String) -> (String, String) {
  match url_scheme(domain) {
    Some(scheme) => {
      let prefix_len = scheme.length() + 1 // scheme + ':'
      let rest = domain[prefix_len:].to_owned()
      if rest.has_prefix("//") {
        (domain[0:prefix_len + 2].to_owned(), rest[2:].to_owned())
      } else {
        (domain[0:prefix_len].to_owned(), rest)
      }
    }
    None =>
      if domain.has_prefix("//") {
        ("//", domain[2:].to_owned())
      } else {
        ("", domain)
      }
  }
}

///|
fn find_char(s : String, target : Char) -> Int? {
  for i, ch in s {
    if ch == target {
      return Some(i)
    }
  }
  None
}

///|
fn last_index_char(s : String, target : Char) -> Int? {
  let mut found : Int? = None
  for i, ch in s {
    if ch == target {
      found = Some(i)
    }
  }
  found
}
