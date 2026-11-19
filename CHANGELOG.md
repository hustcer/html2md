# Changelog

Notable changes to `hustcer/html2md` are documented here.

## 0.3.0 — 2026-11-19

### Changed

- **Breaking:** `convert_dom` now accepts `hustcer/html2md/dom.Node`. Use the
  new `parse_dom` entry point to parse HTML into a compatible node, or import
  the local DOM package to construct nodes directly.
- Embed the HTML parser, DOM support and compact entity tables (from
  `html_parser` commit `53978cf`) and remove the external `html_parser`
  dependency. Upstream attribution is retained.

### Performance

- The stripped macOS arm64 consumer binary is 306.4 KiB (26.9%) smaller.
- Markdown output is unchanged across 1,576 HTML fixtures.

### Internal

- Add a GitHub CI workflow.

## 0.2.0 — 2026-11-18

### Changed

- Upgrade `bobzhang/html_parser` to 0.2.4.
- Fix `moon check` warnings for newer MoonBit toolchains.

## 0.1.3 — 2026-10-12

### Changed

- Upgrade `bobzhang/html_parser` from 0.1.7 to 0.2.0.
- Fix compiler warnings and reformat code for newer MoonBit toolchains.

## 0.1.2 — 2026-09-08

### Fixed

- Merge adjacent bold/italic elements only within the same style (`b`/`strong`
  or `i`/`em`), preserving distinct bold and italic runs.
- Insert invisible inline comments (`<!-- -->`) where needed to separate
  generated emphasis delimiters at adjacent runs, punctuation boundaries and
  intraword underscore boundaries, including through transparent inline
  containers, without adding visible spaces.
- Preserve literal backslashes and entity spellings remaining after HTML
  attribute parsing in link and image titles.
- Escape image alt text so backslashes, brackets, Markdown delimiters, HTML-like
  text and entity spellings retain their literal meaning.
- Extend existing LF-to-space normalization in link/image titles and image alt
  text to CR and CRLF, treating CRLF as a single line ending.
- Resolve directory URLs without duplicating trailing slashes, while preserving
  intentional empty path segments, including those left by final dot segments.
- Resolve MoonBit compiler warnings and replace deprecated API usage.

### Performance

- Merge adjacent text nodes in linear time relative to node count and combined
  text length, avoiding repeated string copies and child-array removals.
- Add reproducible merge and conversion benchmarks. Isolated Apple M1 native
  release measurements of this optimization showed 21.6× faster merging for
  1,000 text nodes and 96.7× for 4,000 nodes; full conversion of 1,000
  comment-separated text chunks took 27.0% less time. These are synthetic
  workloads, not guarantees for all documents or measurements of the final
  release tree. See [PERFORMANCE.md](PERFORMANCE.md) for methodology and limits.

### Compatibility

- Public API signatures and configuration options are unchanged.
- Generated Markdown may contain additional `<!-- -->` separators and different
  escaping as a result of correctness fixes. Consumers comparing exact output
  strings may need to update their snapshots.

## 0.1.1 — 2026-07-14

### Fixed

- Preserve literal internal marker characters across rendering.
- Handle negative ordered-list start values without aborting.
- Bound table spans and validate code language metadata.
- Apply empty-link behavior before resolving URLs against a domain.

## 0.1.0 — 2026-06-13

### Added

- Initial release with HTML-to-Markdown conversion through `convert` and
  `convert_dom`.
- Configurable CommonMark rendering, smart escaping and relative URL resolution.
- Image rendering, GFM tables and strikethrough support.
