// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Gaussian {
    /// @notice Computes the cumulative distribution function (CDF) for an
    /// 18-decimal fixed-point numbers `_x`, `_mu`, and `_sigma` with 1e-8
    /// precision.
    /// @dev The function doesn't check for overflows and underflows and assumes
    /// the following bounds: `_x` ∈ [-1e23, 1e23], `_mu` ∈ [-1e20, 1e20],
    /// `_sigma` ∈ (0, 1e19].
    /// @param _x The value to evaluate the CDF at, as an 18-decimal fixed-point
    /// number.
    /// @param _mu The mean of the distribution, as an 18-decimal fixed-point
    /// number.
    /// @param _sigma The standard deviation of the distribution, as an
    /// 18-decimal fixed-point number.
    /// @return The CDF value at `_x`, `_mu`, and `_sigma`, as an 18-decimal
    /// fixed-point number.
    function cdf(int256 _x, int256 _mu, uint256 _sigma) internal pure returns (uint256) {
        unchecked {
            _x -= _mu;

            int256 x;
            assembly {
                // Compute `_x / (_sigma * sqrt(2))` and scale it to 2**96 base.
                // ```
                // (2**96 / WAD) * (_x * WAD / (_sigma * sqrt(2) * WAD / WAD))
                // = _x * 2**96 / (_sigma * sqrt(2))
                // = _x * 0xb504f333f9de6484597d89b3 / _sigma.
                // ```
                x := sdiv(mul(_x, 0xb504f333f9de6484597d89b3), _sigma)
            }

            // Divide result by 2.
            return erfc(x) >> 1;
        }
    }

    /// @notice Computes the complementary error function (erfc) for an
    /// 18-decimal fixed-point number `_x` scaled to 2**96 base with 2e-8
    /// precision.
    /// @dev Unlike {Gaussian.cdf}, this function doesn't assume any bounds on
    /// `_x`. Note that the function returns 0 early if |`_x`| is greater than
    /// 5.342 because the result is accurate within 2e-8. The result from this
    /// function is halved when computing the CDF value, so 2e-8 is sufficient
    /// for the desired 1e-8 precision in the CDF.
    /// @param _x The value to evaluate the erfc at, as an 18-decimal
    /// fixed-point number scaled to 2**96 base.
    /// @return r The erfc value at `_x`, as an 18-decimal fixed-point number.
    function erfc(int256 _x) internal pure returns (uint256 r) {
        int256 x;
        assembly {
            // Compute the absolute value of `_x` (credit to [Solady](https://github.com/Vectorized/solady/blob/2cead9a403ef788b5467e16fc5a166497be4f820/src/utils/FixedPointMathLib.sol#L935)
            // for the `abs` implementation).
            x := xor(sar(255, _x), add(sar(255, _x), _x))
        }

        // If `x` is greater than 5.342, return 0 because the absolute error of
        // the rational approximation in the domain [0, 5.342] is ~1.343e-8`,
        // which is less than the necessary 2e-8.
        // `floor(5.342e18 / 2**96) = 0x5578d4fdf27cb98715bb60000`.
        if (x > 0x5578d4fdf27cb98715bb60000) {
            return 0;
        }

        // Compute the value using a (14, 5)-term rational approximation.
        // The polynomials `p` and `q` are evaluated using Horner's method.
        unchecked {
            // The first iteration of Horner's method is removed by scaling each
            // of the coefficients by `floor(2**96 / a_{n}) = 350643517`, where
            // `a_{n}` is the highest degree term's coefficient and scaling the
            // result back down at the end of the computation. Note that
            // `log(350643517) ≈ 8.54 > 8`, so we retain the desired 2e-8
            // precision.
            int256 p = 0x53f03f07e018b5e437ebc00000 - x;
            p = ((p * x) >> 96) - 0x9426c0da0db0196f4c940000000;
            p = ((p * x) >> 96) + 0x87ce3464514f9f2a96a900000000;
            p = ((p * x) >> 96) - 0x4aa878b19f5e1da7849da00000000;
            p = ((p * x) >> 96) + 0x19c6271833e59e7293644000000000;
            p = ((p * x) >> 96) - 0x57250cb5cfe1a6b98e584000000000;
            p = ((p * x) >> 96) + 0x986c8bb677c010a3ace48000000000;
            p = ((p * x) >> 96) - 0x13d63a9a5da47428a1670000000000;
            p = ((p * x) >> 96) - 0xf4d1deada9d68c8918f10000000000;
            p = ((p * x) >> 96) - 0x379fa110f89b0b537e2e20000000000;
            p = ((p * x) >> 96) + 0x14001c78d75852359284580000000000;
            p = ((p * x) >> 96) - 0x220176c16cc7b9b6d30dd00000000000;
            p = (p * x) + 0x14e66541b58fa8fa0dc2600000000000000000000000000000000000;

            // Unlike `p`, `q` can't be made monic because the scaling factor
            // results in too much precision loss: `log(2**96 / a_{n}) ≈ 1.52`.
            int256 q = 0x7bfa42098491b8000000000;
            q = ((q * x) >> 96) - 0x18e69e267814200000000000;
            q = ((q * x) >> 96) + 0x64ead0991554bc0000000000;
            q = ((q * x) >> 96) - 0x7faa085414fe440000000000;
            q = ((q * x) >> 96) + 0x1000000000000000000000000;

            assembly {
                // Convert the result back to 1e18 base and multiply by the
                // inverse of the scaling factor used to make `p` monic.
                // `floor(350643517 * 2**96 / 1e18) = 0x18189603334553000`.
                r := div(sdiv(p, q), 0x18189603334553000)

                // Subtract from 2 if `_x` is positive;
                // `2e18 = 0x1bc16d674ec80000`.
                if sgt(_x, 0) { r := sub(0x1bc16d674ec80000, r) }
            }
        }
    }
}
