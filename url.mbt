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
///   - special characters are percent-encoded
///
/// Note: we keep query strings as-is (the Go version re-encodes them); this
/// matches the behavior for the vast majority of inputs and avoids pulling in
/// a full URL parser.
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
  percent_encode_url_chars(resolved)
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
/// scheme). Mirrors the practical outcome of Go's `ResolveReference` for the
/// common cases of absolute-path / relative-path references.
fn join_url(domain : String, raw : String) -> String {
  let (scheme_prefix, host_and_path) = split_scheme(domain)
  let scheme_prefix = if scheme_prefix is "" {
    "http://"
  } else {
    scheme_prefix
  }
  // Separate host from any path on the base.
  let slash = find_char(host_and_path, '/')
  let host = match slash {
    Some(idx) => host_and_path[0:idx].to_owned()
    None => host_and_path
  }
  let base_path = match slash {
    Some(idx) => host_and_path[idx:].to_owned()
    None => "/"
  }
  if raw.has_prefix("#") || raw.has_prefix("?") {
    return scheme_prefix + host + base_path + raw
  }
  if raw.has_prefix("/") {
    scheme_prefix + host + raw
  } else {
    // Relative to the base path's directory.
    let dir = match last_index_char(base_path, '/') {
      Some(idx) => base_path[0:idx + 1].to_owned()
      None => "/"
    }
    scheme_prefix + host + dir + raw
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
