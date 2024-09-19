# 🔎 solgauss

[![CI][ci-badge]][ci-url]

Solidity library for statistical functions rationally approximated with an error of less than 1 × 10<sup>-8</sup>, including `erfc`, `erfinv`, `erfcinv`, `ppf`, and `cdf`.

## ⚙️ Installation

To install with [**Foundry**](https://github.com/foundry-rs/foundry):

```sh
forge install cairoeth/solcdf
```

## ⛽ Gas Benchmarks

To run the gas benchmark: `forge t --gas-report --fuzz-seed 0x123`

### `cdf`

| Function           |  min |  avg | median |  max |
|--------------------|------|------|--------|------|
| cdf (solcdf)       |  519 |  610 |    519 |  833 |
| cdf (solidity-cdf) |  492 |  617 |    492 |  914 |
| cdf (gud-cdf)      |  704 |  736 |    704 |  841 |
| cdf (solstat)      |  916 | 4258 |   5137 | 5137 |

### `erfc`

| Function        |  min |  avg | median |  max |
|-----------------|------|------|--------|------|
| erfc (solcdf)   |  687 |  688 |    687 |  693 |
| erfc (gud-cdf)  |  569 |  570 |    569 |  603 |
| erfc (solstat)  | 4436 | 4453 |   4436 | 4543 |

### `erfcinv`

| Function |  min |  avg | median |  max |
|----------|------|------|--------|------|
| erfcinv  |  669 |  828 |    783 | 1847 |

### `erfinv`

| Function |  min |  avg | median |  max |
|----------|------|------|--------|------|
| erfinv   |  604 |  749 |    718 | 1796 |

### `ppf`

| Function |  min |  avg | median |  max |
|----------|------|------|--------|------|
| ppf      |  856 | 1687 |   2034 | 2034 |

## ✅ Tests

Run the following for the dependencies used in the (differential) tests:

1. `python -m venv venv && source venv/bin/activate`
2. `pip install mpmath`

To run the tests: `forge t`

## 👇 Acknowledgements

This repository is inspired by or directly modified from many sources, primarily:

- [gud-cdf](https://github.com/Philogy/gud-cdf): codification script

[ci-badge]: https://github.com/cairoeth/solgauss/actions/workflows/test.yml/badge.svg
[ci-url]: https://github.com/cairoeth/solgauss/actions/workflows/test.yml