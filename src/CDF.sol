// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";
import {console2 as console} from "forge-std/console2.sol";

library CDF {
    using FixedPointMathLib for uint256;

    uint256 internal constant ONE = 1e18;
    uint256 internal constant ONE_2 = 1e15;
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
        // 0 - 0.99 range
        assembly {
            // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
            let z := xor(sar(255, _x), add(sar(255, _x), _x))

            for {} 1 {} {
                if lt(z, 0xf5c28f5c28f5c28f5c28f5c2) {
                    let num := add(z, 0xfffffffffffffffffffffffffffffffffffffffbd156a4dc207899e2ab98b3ab)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffffcbd9a8d0ed0981f0ddbb667dd)
                    num := add(sar(POW, mul(num, z)), 0x1f69b01a95fc46bbab505f7876)
                    num :=
                        add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffffdd6f2336207ace4f468f290c9f)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffff413e33d087ff2f6b29f1f174c)
                    num := add(sar(POW, mul(num, z)), 0x24557d6a5386815359e9da9552)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffff12ec63ba934b3a974e645c055)
                    num := add(sar(POW, mul(num, z)), 0x44266f1dd31a336ee)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffc05d4b83f43643780e63fa31f)
                    denom := add(sar(POW, mul(denom, z)), 0x11b628e24001f98eb0d2d0e49)
                    denom := add(sar(POW, mul(denom, z)), 0xd2f794b85e1989ff37bf3cfd7)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffefb41be778336df3585c1114e1)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffffd06cbc0aa3ad7b8c573c7494d)
                    denom := add(sar(POW, mul(denom, z)), 0xd6ebe115934fd955caead076b)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffffa85a6c945287f53296c9e773f)
                    _y := sdiv(mul(0x48bff9f3dffa2d1, num), denom)
                    break
                }
                if lt(z, 0xfd70a3d70a3d70a3d70a3d70) {
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffff9331c52ee2de921fc08d4082)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffffafa7bb86e60fb6718b0e075e3)
                    num := add(sar(POW, mul(num, z)), 0x7526f84f82ebfdcd3718752ff)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffffd1fe28adc8b1add12ca5016d2)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffb7ae0ed4cfc8f118fcb0a300f)
                    denom := add(sar(POW, mul(denom, z)), 0x796e148d2a115e78c328b216e)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffffa6186bfb4d25c5bc472803388)
                    denom := add(sar(POW, mul(denom, z)), 0x18cb71166d99fa8a0a64822e2)
                    _y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffdc4ccbd2fab6ca0, num), denom)
                    break
                }
                break
            }

            if slt(_x, 0) { _y := sub(0, _y) }
        }

        // 0.99 - 1 range
        if (_y == 0) {
            // turn POW-scaled back to WAD for now
            assembly {
                _x := sdiv(mul(_x, ONE), shl(POW, 1))
            }

            // sqrt(log(2) - log(1.0 - _x)) - 1.6
            int256 r =
                int256(FixedPointMathLib.sqrtWad(uint256(693147180559945309 - FixedPointMathLib.lnWad(1e18 - _x))));

            assembly {
                r := sub(r, 1600000000000000000)

                let z1 := add(sdiv(mul(774545014278341407, r), ONE), 22723844989269184583)
                z1 := add(sdiv(mul(z1, r), ONE), 241780725177450611770)
                z1 := add(sdiv(mul(z1, r), ONE), 1270458252452368382580)
                z1 := add(sdiv(mul(z1, r), ONE), 3647848324763204605040)
                z1 := add(sdiv(mul(z1, r), ONE), 5769497221460691405500)
                z1 := add(sdiv(mul(z1, r), ONE), 4630337846156545295900)
                z1 := add(sdiv(mul(z1, r), ONE), 1423437110749683577340)

                let z2 := add(sdiv(mul(1485985001, r), ONE), 774414590651577)
                z2 := add(sdiv(mul(z2, r), ONE), 21494160384252876)
                z2 := add(sdiv(mul(z2, r), ONE), 209450652105127491)
                z2 := add(sdiv(mul(z2, r), ONE), 975478320017874271)
                z2 := add(sdiv(mul(z2, r), ONE), 2370766162602453236)
                z2 := add(sdiv(mul(z2, r), ONE), 2903651444541994617)
                z2 := add(sdiv(mul(z2, r), ONE), 1414213562373095048)

                _y := sdiv(mul(z1, ONE_2), z2)
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
    function ppf(int256 _x, int72 _u, int256 _o) internal pure returns (int256 _y) {
        // u - o * sqrt(2) * ercfinv(2 * x)
        unchecked {
            _y = _u - (_o * ((1414213562373095048 * erfcinv((2e18 * _x) / 1e18)) / 1e18)) / 1e18;
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
