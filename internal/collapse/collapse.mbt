///|
/// Collapse runs of HTML whitespace (space, \r, \n, \t) into a single space
/// (port of `collapse.replaceAnyWhitespaceWithSpace`).
fn replace_any_whitespace_with_space(source : String) -> String {
  let out = StringBuilder(size_hint=source.length())
  let mut in_run = false
  for ch in source {
    if ch is (' ' | '\r' | '\n' | '\t') {
      if !in_run {
        out.write_char(' ')
        in_run = true
      }
    } else {
      out.write_char(ch)
      in_run = false
    }
  }
  out.to_string()
}

///|
fn is_pre(node : @dom.Node) -> Bool {
  @domext.is_preformatted_name(@domext.node_name(node))
}

///|
fn is_void(node : @dom.Node) -> Bool {
  @domext.is_void_name(@domext.node_name(node))
}

///|
/// Block check used during collapsing: matches the Go `base` plugin override
/// (tag type resolution; only resolved Block counts).
fn is_block(node : @dom.Node) -> Bool {
  @domext.is_block_tag_type(@domext.node_name(node))
}

///|
/// Depth-first cursor (port of `collapse.nextNode`): don't descend when we
/// just came up from `current`'s children or when `current` is preformatted.
fn next_node(prev : @dom.Node?, current : @dom.Node) -> @dom.Node? {
  let came_up = prev is Some(p) &&
    p.parent is Some(par) &&
    physical_equal(par, current)
  if came_up || is_pre(current) {
    match @domext.next_sibling(current) {
      Some(sibling) => Some(sibling)
      None => current.parent
    }
  } else {
    match @domext.first_child(current) {
      Some(child) => Some(child)
      None =>
        match @domext.next_sibling(current) {
          Some(sibling) => Some(sibling)
          None => current.parent
        }
    }
  }
}

///|
/// Remove `node` and return the node the traversal continues with
/// (port of `collapse.removeNode`).
fn remove_and_next(node : @dom.Node) -> @dom.Node? {
  let next = match @domext.next_sibling(node) {
    Some(sibling) => Some(sibling)
    None => node.parent
  }
  @domext.remove_node(node)
  next
}

///|
/// Collapse whitespace in the subtree rooted at `element` (port of
/// `collapse.Collapse`, originally from turndown / collapse-whitespace).
pub fn collapse(element : @dom.Node) -> Unit {
  if @domext.first_child(element) is None || is_pre(element) {
    return
  }
  let mut prev_text : @dom.Node? = None
  let mut keep_leading_ws = false
  let mut prev : @dom.Node? = None
  let mut cursor = next_node(prev, element)
  while cursor is Some(node) && !physical_equal(node, element) {
    match node.kind {
      Text => {
        let mut text = replace_any_whitespace_with_space(node.data)
        let prev_ends_with_space = match prev_text {
          None => true
          Some(pt) => pt.data.has_suffix(" ")
        }
        if prev_ends_with_space &&
          !keep_leading_ws &&
          text != "" &&
          text[0] == ' ' {
          text = text[1:].to_owned()
        }
        if text is "" {
          cursor = remove_and_next(node)
          continue
        }
        let current = if text == node.data {
          node
        } else {
          @domext.set_text(node, text)
        }
        prev_text = Some(current)
        cursor = next_node(prev, current)
        prev = Some(current)
      }
      Element => {
        let name = @domext.node_name(node)
        if is_block(node) || name is "br" {
          if prev_text is Some(pt) {
            match trim_text_suffix_space(pt) {
              Some(updated) =>
                // keep the traversal pointer valid when it aliased prev_text
                if prev is Some(p) && physical_equal(p, pt) {
                  prev = Some(updated)
                }
              None => ()
            }
          }
          prev_text = None
          keep_leading_ws = false
        } else if is_void(node) || is_pre(node) || name is "code" {
          // Avoid trimming space around non-block, non-BR void elements
          // and inline PRE.
          prev_text = None
          keep_leading_ws = true
        } else if !(prev_text is None) {
          // Drop protection if set previously.
          keep_leading_ws = false
        }
        cursor = next_node(prev, node)
        prev = Some(node)
      }
      Comment => {
        // Comments are kept as-is.
        cursor = next_node(prev, node)
        prev = Some(node)
      }
      _ =>
        // E.g. a doctype node: remove it.
        cursor = remove_and_next(node)
    }
  }
  if prev_text is Some(pt) {
    let trimmed = if pt.data.has_suffix(" ") {
      pt.data[:pt.data.length() - 1].to_owned()
    } else {
      pt.data
    }
    if trimmed is "" {
      @domext.remove_node(pt)
    } else if trimmed != pt.data {
      ignore(@domext.set_text(pt, trimmed))
    }
  }
}

///|
/// Trim one trailing space off a text node (replacement-based). Returns the
/// replacement node when the content changed.
fn trim_text_suffix_space(pt : @dom.Node) -> @dom.Node? {
  if pt.data.has_suffix(" ") {
    let trimmed = pt.data[:pt.data.length() - 1].to_owned()
    Some(@domext.set_text(pt, trimmed))
  } else {
    None
  }
}
