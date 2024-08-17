# 🔎 solcdf

Approximation of the cumulative distribution function (cdf) for arbitrary 18 decimal fixed point parameters `x`, `μ`, `σ` and a target absolute error of 1e-8.

## 🧪 Methodology

The complementary error function (`erfc`) is approximated rationally using a variant from the algorithm presented in [this](https://eprint.iacr.org/2020/552.pdf) paper. The rational polynomial is composed of a polynomial of degree 11 as numerator, and a polynomial of degree 4 as denominator.

The coefficients of the rational polynomial are scaled by a factor of 2^96 and then codified as part of the `erfc` function. This scaling allows for the use of cheaper `sar` (shift arithmetic right) operations instead of more expensive `sdiv` (signed division) operations (former costs 3 gas, while latter 5). Additionally, this function always returns 0 when the input is more than `4.0523` as the maximum absolute error would not surpass the target error.

The `erfc` and `cdf` functions are differentially fuzzed against Python and Javascript implementations to ensure that they provide an absolute error of less than 1e-8. These functions are also benchmarked against [`solstat`](https://github.com/primitivefinance/solstat), [`gud-cdf`](https://github.com/Philogy/gud-cdf), and [`solidity-cdf`](https://github.com/fiveoutofnine/solidity-cdf). It's important to note that the benchmark does not verify the precision of these external libraries, such as `solidity-cdf`, which has an error of more than 1e-8.

## ⛽ Gas Benchmarks

| Function             | min  | avg  | median | max  | calls |
|----------------------|------|------|--------|------|-------|
| cdf (solcdf)         | 562  | 657  | 562    | 876  | 256   |
| cdf (solidity-cdf)   | 540  | 671  | 540    | 962  | 256   |
| cdf (gud-cdf)        | 781  | 815  | 781    | 917  | 256   |
| cdf (solstat)        | 938  | 4279 | 5159   | 5159 | 256   |

To run the gas benchmark: `forge t --gas-report`

## ✅ Tests

Run the following for the dependencies used in the (differential) tests:

### Python
1. `python -m venv venv && source venv/bin/activate`
2. `pip install mpmath`

### Javascript
1. `(cd differential && yarn)`

To run the tests: `forge t`

## 👇 Acknowledgements

This repository is inspired by or directly modified from many sources, primarily:

- [High-Precision Bootstrapping of RNS-CKKS Homomorphic Encryption Using Optimal Minimax Polynomial Approximation and Inverse Sine Function](https://eprint.iacr.org/2020/552): paper for algorithm variant
- [gud-cdf](https://github.com/Philogy/gud-cdf): codification script
- [gaussian](https://github.com/errcw/gaussian): javascript differential scripts