# Third-party notices

## Embedded HTML parser

The DOM and parser code in `dom/` and `internal/html_parser/`, and the
named character reference generator in `scripts/generate_named_entities.mbtx`,
are adapted from [bobzhang/html_parser](https://github.com/bobzhang/html_parser)
at commit [53978cf4a9cd04b78519ad124c30e2cc162aebf4](https://github.com/hustcer/html_parser/commit/53978cf4a9cd04b78519ad124c30e2cc162aebf4),
licensed under the [Apache License 2.0](LICENSE).

The MoonBit parser is a port of [JustHTML](https://github.com/EmilStenstrom/justhtml).
The following notice is included upstream as `tests/fixtures/justhtml/LICENSE.justhtml`.

```
MIT License

Copyright (c) 2025 Emil Stenström (JustHTML)
Copyright (c) 2014-2017, The html5ever Project Developers (html5ever inspiration)
Copyright (c) 2006-2013 James Graham, Sam Sneddon, and
other contributors (html5lib-tests)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
