// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

library Gaussian {
    uint256 internal constant ONE = 1e18;
    int256 internal constant ONE_SQUARED = 1e36;
    uint256 internal constant TWO = 2e18;
    uint256 internal constant POW = 96;

    /// @param _x The value at which to evaluate the complementary error function.
    /// @return _y The complementary error function output scaled by WAD.
    function erfc(int256 _x) internal pure returns (uint256 _y) {
        assembly {
            // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
            let z := xor(sar(255, _x), add(sar(255, _x), _x))

            // (11,4) rational polynomial
            // 0x40d63886594af3ffffdf1498c = 4.0523 (scaled), returning 0 gives an error of 9.995e−9 (less than 1e-8)
            if lt(z, 0x40d63886594af3ffffdf1498c) {
                let pow := POW
                let num := add(z, 0xffffffffffffffffffffffffffffffffffffffe1d359833912c23153f6a4c7ca)
                num := add(sar(pow, mul(num, z)), 0x184bd769e81acc2bc5117dd4340)
                num := add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffff54cf2e464e3cc01292026c6f381)
                num := add(sar(pow, mul(num, z)), 0x2b07e7304c56d586e1e76c5dda61)
                num := add(sar(pow, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffa8b97d4a044b852c4e02f6ccf289)
                num := add(sar(pow, mul(num, z)), 0x183fbd9d4b19bec7d03c92fd6fed)
                num := add(sar(pow, mul(num, z)), 0x918a41378612a830bb75cdba3b5c)
                num := add(sar(pow, mul(num, z)), 0x20f66687946b34c1344a6efeb90b4)
                num := add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff324c2812bd16658f088daf442c20a)
                num := add(sar(pow, mul(num, z)), 0x16bfee604912b1849eaf46aaea35da)
                num := add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff1a154cab1f55955bd800aeef21b27)
                let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffd0f1cb792d6c582e52079878b)
                denom := add(sar(pow, mul(denom, z)), 0xca25958180aaa1c8b1b525ae4)
                denom :=
                    add(sar(pow, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff0f0473c6ea8e169426cb0736f)
                denom := add(sar(pow, mul(denom, z)), 0x211e2a69d8e1c99ad5fb3491e7)
                _y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffe0041ef0b43e, num), denom)
            }

            if slt(_x, 0) { _y := sub(TWO, _y) }
        }
    }

    /// @notice Calculates the inverse error function (erf^-1)
    /// @param _x The value at which to evaluate the inverse error function (-1 < x < 1).
    /// @return _y The inverse error function output scaled by WAD.
    function erfinv(int256 _x) internal pure returns (int256 _y) {
        unchecked {
            int256 z;

            // 0 - 0.99 range
            assembly {
                // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
                z := xor(sar(255, _x), add(sar(255, _x), _x))

                for {} 1 {} {
                    let pow := POW
                    if lt(z, 0xf5c28f5c28f5c28f5c28f5c2) {
                        let num := sub(z, 0x42ea95b23df87661d54674c55)
                        num := sub(sar(pow, mul(num, z)), 0x3426572f12f67e0f224499823)
                        num := add(sar(pow, mul(num, z)), 0x1f69b01a95fc46bbab505f7876)
                        num := sub(sar(pow, mul(num, z)), 0x2290dcc9df8531b0b970d6f361)
                        num := sub(sar(pow, mul(num, z)), 0xbec1cc2f7800d094d60e0e8b4)
                        num := add(sar(pow, mul(num, z)), 0x24557d6a5386815359e9da9552)
                        num := sub(sar(pow, mul(num, z)), 0xed139c456cb4c568b19ba3fab)
                        num := add(sar(pow, mul(num, z)), 0x44266f1dd31a336ee)
                        let denom := sub(z, 0x3fa2b47c0bc9bc87f19c05ce1)
                        denom := add(sar(pow, mul(denom, z)), 0x11b628e24001f98eb0d2d0e49)
                        denom := add(sar(pow, mul(denom, z)), 0xd2f794b85e1989ff37bf3cfd7)
                        denom := sub(sar(pow, mul(denom, z)), 0x104be41887cc920ca7a3eeeb1f)
                        denom := sub(sar(pow, mul(denom, z)), 0x2f9343f55c528473a8c38b6b3)
                        denom := add(sar(pow, mul(denom, z)), 0xd6ebe115934fd955caead076b)
                        denom := sub(sar(pow, mul(denom, z)), 0x57a5936bad780acd6936188c1)
                        _y := sdiv(mul(0x48bff9f3dffa2d1, num), denom)
                        break
                    }
                    if lt(z, 0xfd70a3d70a3d70a3d70a3d70) {
                        let num := sub(z, 0x6cce3ad11d216de03f72bf7e)
                        num := sub(sar(pow, mul(num, z)), 0x5058447919f0498e74f1f8a1d)
                        num := add(sar(pow, mul(num, z)), 0x7526f84f82ebfdcd3718752ff)
                        num := sub(sar(pow, mul(num, z)), 0x2e01d752374e522ed35afe92e)
                        let denom := sub(z, 0x4851f12b30370ee7034f5cff1)
                        denom := add(sar(pow, mul(denom, z)), 0x796e148d2a115e78c328b216e)
                        denom := sub(sar(pow, mul(denom, z)), 0x59e79404b2da3a43b8d7fcc78)
                        denom := add(sar(pow, mul(denom, z)), 0x18cb71166d99fa8a0a64822e2)

                        _y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffdc4ccbd2fab6ca0, num), denom)
                        break
                    }
                    // (z * ONE) / shl(pow, 1)
                    z := sdiv(mul(z, ONE), 0x1000000000000000000000000)
                    break
                }
            }

            // 0.99 - 1 range
            if (_y == 0) {
                // sqrt(log(2) - log(1.0 - _x)) - 1.6
                int256 r = int256(
                    FixedPointMathLib.sqrt(uint256(693147180559945309 - FixedPointMathLib.lnWad(1e18 - z)) * 10 ** 18)
                );

                assembly {
                    let one := ONE
                    r := sub(r, 0x16345785d8a00000)

                    let num := add(sdiv(mul(0xabfbc96369c431f, r), one), 0x13b5b509f246e1047)
                    num := add(sdiv(mul(num, r), one), 0xd1b61b08a2a49c43a)
                    num := add(sdiv(mul(num, r), one), 0x44df26696ddaf67a74)
                    num := add(sdiv(mul(num, r), one), 0xc5c010a43e4e965470)
                    num := add(sdiv(mul(num, r), one), 0x138c3dbb2cfe7ba4abc)
                    num := add(sdiv(mul(num, r), one), 0xfb02d89a7f8035061c)
                    num := add(sdiv(mul(num, r), one), 0x4d2a287e88a740f1fc)
                    let denom := add(sdiv(mul(0x589254e9, r), one), 0x2c0537295acb9)
                    denom := add(sdiv(mul(denom, r), one), 0x4c5cd33272dbcc)
                    denom := add(sdiv(mul(denom, r), one), 0x2e81e4224b33643)
                    denom := add(sdiv(mul(denom, r), one), 0xd89985d1ec29d5f)
                    denom := add(sdiv(mul(denom, r), one), 0x20e6a743976f68f4)
                    denom := add(sdiv(mul(denom, r), one), 0x284bd79ac779b679)
                    denom := add(sdiv(mul(denom, r), one), 0x13a04bbdfdc9be88)

                    _y := sdiv(mul(num, 0x38d7ea4c68000), denom)
                }
            }

            assembly {
                if slt(_x, 0) { _y := sub(0, _y) }
            }
        }
    }

    /// @notice Calculates the inverse complementary error function (erfc^-1)
    /// @param _x The value at which to evaluate the inverse complementary error function (0 < x < 2)
    /// @return _y The inverse complementary error function output scaled by WAD
    function erfcinv(int256 _x) internal pure returns (int256 _y) {
        assembly {
            _x := sdiv(shl(POW, sub(ONE, _x)), ONE)
        }
        return erfinv(_x);
    }

    /// @param _x The value at which to evaluate the ppf.
    /// @param _u The mean of the distribution (-1e20 ≤ μ ≤ 1e20).
    /// @param _o The standard deviation (sigma) of the distribution (0 < σ ≤ 1e19).
    function ppf(int256 _x, int256 _u, int256 _o) internal pure returns (int256) {
        // u - o * sqrt(2) * ercfinv(2 * x)
        unchecked {
            return _u - (_o * 0x13a04bbdfdc9be88 * erfcinv(2 * _x) / ONE_SQUARED);
        }
    }

    /// @param _x The value at which to evaluate the cdf.
    /// @param _u The mean of the distribution (-1e20 ≤ μ ≤ 1e20).
    /// @param _o The standard deviation (sigma) of the distribution (0 < σ ≤ 1e19).
    /// @param _y The cumulative distribution function output scaled by WAD.
    function cdf(int256 _x, int256 _u, uint256 _o) internal pure returns (uint256 _y) {
        assembly {
            function erfc(x) -> y {
                // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
                let z := xor(sar(255, x), add(sar(255, x), x))

                // (11,4) rational polynomial
                // 0x40d63886594af3ffffdf1498c = 4.0523 (scaled), returning 0 gives an error of 9.995e−9 (less than 1e-8)
                if lt(z, 0x40d63886594af3ffffdf1498c) {
                    let pow := POW
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffe1d359833912c23153f6a4c7ca)
                    num := add(sar(pow, mul(num, z)), 0x184bd769e81acc2bc5117dd4340)
                    num :=
                        add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffff54cf2e464e3cc01292026c6f381)
                    num := add(sar(pow, mul(num, z)), 0x2b07e7304c56d586e1e76c5dda61)
                    num :=
                        add(sar(pow, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffa8b97d4a044b852c4e02f6ccf289)
                    num := add(sar(pow, mul(num, z)), 0x183fbd9d4b19bec7d03c92fd6fed)
                    num := add(sar(pow, mul(num, z)), 0x918a41378612a830bb75cdba3b5c)
                    num := add(sar(pow, mul(num, z)), 0x20f66687946b34c1344a6efeb90b4)
                    num :=
                        add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff324c2812bd16658f088daf442c20a)
                    num := add(sar(pow, mul(num, z)), 0x16bfee604912b1849eaf46aaea35da)
                    num :=
                        add(sar(pow, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff1a154cab1f55955bd800aeef21b27)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffd0f1cb792d6c582e52079878b)
                    denom := add(sar(pow, mul(denom, z)), 0xca25958180aaa1c8b1b525ae4)
                    denom :=
                        add(sar(pow, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff0f0473c6ea8e169426cb0736f)
                    denom := add(sar(pow, mul(denom, z)), 0x211e2a69d8e1c99ad5fb3491e7)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffe0041ef0b43e, num), denom)
                }

                if slt(x, 0) { y := sub(TWO, y) }
            }

            _y := shr(1, erfc(sdiv(mul(sub(_u, _x), 0xb504f333f9de6484597d89b3), _o)))
        }
    }
}
