# Adjacent text node merging

Measured on 2026-09-08 with an Apple M1 (arm64), macOS 15.7.9 and
`moon 0.1.20260827 (d0aaa07 2026-08-27)`, native release builds.
Baseline: commit `91f2ee9`, with the same benchmark files and test imports
copied into a separate worktree. The optimized version changes
`internal/domutils/adjacent.mbt` only in production code.

The old implementation repeatedly copied an expanding text prefix, searched
the parent array and removed individual children. The new implementation
builds each consecutive text run once and compacts the child array in place.
Its work is linear in the node count plus the combined text length.

## Results

Each value is the median of three independent benchmark means. Runs were
interleaved baseline/optimized three times, with no concurrent benchmark or
test processes. Each invocation used MoonBit's default 10 timed batches,
with automatically calibrated iteration counts.

| Workload | Before | After | Change in time |
| --- | ---: | ---: | ---: |
| Merge 1 text node | 252.82 ns | 227.03 ns | -10.2% |
| Merge 1,000 text nodes | 2.73 ms | 126.28 µs | -95.4% (21.6× faster) |
| Merge 4,000 text nodes | 47.31 ms | 489.01 µs | -99.0% (96.7× faster) |
| Full conversion, 1,000 comment-separated text chunks | 10.23 ms | 7.47 ms | -27.0% (1.37× faster) |
| Full conversion, short mixed document | 36.57 µs | 37.59 µs | +2.8% |

The merge benchmarks use 80-character text nodes and include DOM creation
and cleanup. Full conversion includes HTML parsing, `convert_dom` and DOM
cleanup. Parent links are cleared after every iteration to avoid retaining
DOM cycles during native benchmarks. The short mixed document contains a
heading, emphasis, a link, inline code and a list.

These synthetic workloads isolate fragmentation cost; they do not establish
a speedup for every HTML document. The short-document control was slightly
slower, and several samples had substantial noise: the second optimized
short-document run had an 8.34 µs standard deviation; the first optimized
single-node run had a 153.31 ns standard deviation. No improvement is claimed
for short mixed documents.

## Individual means

| Workload (unit) | Before 1 | After 1 | Before 2 | After 2 | Before 3 | After 3 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Merge 1 node (ns) | 252.82 | 281.20 | 253.80 | 219.73 | 247.63 | 227.03 |
| Merge 1,000 nodes (µs) | 2730 | 126.28 | 2850 | 124.68 | 2610 | 129.66 |
| Merge 4,000 nodes (µs) | 47310 | 486.95 | 46440 | 494.35 | 47390 | 489.01 |
| Full conversion, fragmented (ms) | 10.23 | 7.34 | 10.41 | 7.47 | 9.87 | 7.49 |
| Full conversion, short (µs) | 36.57 | 37.07 | 38.06 | 40.40 | 35.78 | 37.59 |

## Reproduce

Run in the optimized checkout:

```sh
moon bench internal/domutils/adjacent_bench_test.mbt convert_bench_wbtest.mbt --target native --release --no-parallelize
```

Prepare a baseline checkout at a new, unused directory:

```sh
git worktree add --detach ../html2md-perf-baseline 91f2ee9
cp internal/domutils/adjacent_bench_test.mbt internal/domutils/moon.pkg ../html2md-perf-baseline/internal/domutils/
cp convert_bench_wbtest.mbt moon.pkg ../html2md-perf-baseline/
moon -C ../html2md-perf-baseline bench internal/domutils/adjacent_bench_test.mbt convert_bench_wbtest.mbt --target native --release --no-parallelize
```

Alternate the command in both checkouts three times. Keep fixture files and
compiler versions identical and compare medians of the reported means.

## Correctness

`moon check --target all` reports no warnings or errors. All 257 tests pass
on wasm, wasm-gc, JavaScript and native. Tests verify text content (including
Unicode and empty runs), comment/element boundaries, recursive merging,
detached original nodes, parent links, retained node/array identities and
idempotence. The added semantic tests also passed on the baseline algorithm.
`moon fmt` and `moon info` complete without public API changes.
