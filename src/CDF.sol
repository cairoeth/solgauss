// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library CDF {
    uint256 internal constant TWO = 2e18;
    uint256 internal constant POW = 96;

    /// @param x The value at which to evaluate the complementary error function.
    /// @return y The complementary error function output scaled by WAD.
    function erfc(int256 x) internal pure returns (uint256 y) {
        assembly {
            // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
            let z := xor(sar(255, x), add(sar(255, x), x))

            // (11,4) rational polynomial
            // 0x40d63886594af3ffffdf1498c = 4.0523 (scaled), returning 0 gives an error of 9.995e−9 (less than 1e-8)
            if lt(z, 0x40d63886594af3ffffdf1498c) {
                let num := add(z, 0xffffffffffffffffffffffffffffffffffffffe1d359833912c23153f6a4c7ca)
                num := add(sar(POW, mul(num, z)), 0x184bd769e81acc2bc5117dd4340)
                num := add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffff54cf2e464e3cc01292026c6f381)
                num := add(sar(POW, mul(num, z)), 0x2b07e7304c56d586e1e76c5dda61)
                num := add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffa8b97d4a044b852c4e02f6ccf289)
                num := add(sar(POW, mul(num, z)), 0x183fbd9d4b19bec7d03c92fd6fed)
                num := add(sar(POW, mul(num, z)), 0x918a41378612a830bb75cdba3b5c)
                num := add(sar(POW, mul(num, z)), 0x20f66687946b34c1344a6efeb90b4)
                num := add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff324c2812bd16658f088daf442c20a)
                num := add(sar(POW, mul(num, z)), 0x16bfee604912b1849eaf46aaea35da)
                num := add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff1a154cab1f55955bd800aeef21b27)
                let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffd0f1cb792d6c582e52079878b)
                denom := add(sar(POW, mul(denom, z)), 0xca25958180aaa1c8b1b525ae4)
                denom :=
                    add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff0f0473c6ea8e169426cb0736f)
                denom := add(sar(POW, mul(denom, z)), 0x211e2a69d8e1c99ad5fb3491e7)
                y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffe0041ef0b43e, num), denom)
            }

            if slt(x, 0) { y := sub(TWO, y) }
        }
    }

    /// @param _x The value at which to evaluate the cdf.
    /// @param _u The mean of the distribution (-1e20 ≤ μ ≤ 1e20).
    /// @param _o The standard deviation (sigma) of the distribution (0 < σ ≤ 1e19).
    /// @param _y The cumulative distribution function output scaled by WAD.
    function cdf(int256 _x, int72 _u, uint256 _o) internal pure returns (uint256 _y) {
        assembly {
            function erfc(x) -> y {
                // https://github.com/Vectorized/solady/blob/be5200bdc2533875b4da6aef5da4dab53191c104/src/utils/FixedPointMathLib.sol#L932-L937
                let z := xor(sar(255, x), add(sar(255, x), x))

                // (11,4) rational polynomial
                // 0x40d63886594af3ffffdf1498c = 4.0523 (scaled), returning 0 gives an error of 9.995e−9 (less than 1e-8)
                if lt(z, 0x40d63886594af3ffffdf1498c) {
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffe1d359833912c23153f6a4c7ca)
                    num := add(sar(POW, mul(num, z)), 0x184bd769e81acc2bc5117dd4340)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffff54cf2e464e3cc01292026c6f381)
                    num := add(sar(POW, mul(num, z)), 0x2b07e7304c56d586e1e76c5dda61)
                    num :=
                        add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffa8b97d4a044b852c4e02f6ccf289)
                    num := add(sar(POW, mul(num, z)), 0x183fbd9d4b19bec7d03c92fd6fed)
                    num := add(sar(POW, mul(num, z)), 0x918a41378612a830bb75cdba3b5c)
                    num := add(sar(POW, mul(num, z)), 0x20f66687946b34c1344a6efeb90b4)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff324c2812bd16658f088daf442c20a)
                    num := add(sar(POW, mul(num, z)), 0x16bfee604912b1849eaf46aaea35da)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffff1a154cab1f55955bd800aeef21b27)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffd0f1cb792d6c582e52079878b)
                    denom := add(sar(POW, mul(denom, z)), 0xca25958180aaa1c8b1b525ae4)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff0f0473c6ea8e169426cb0736f)
                    denom := add(sar(POW, mul(denom, z)), 0x211e2a69d8e1c99ad5fb3491e7)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffe0041ef0b43e, num), denom)
                }

                if slt(x, 0) { y := sub(TWO, y) }
            }

            _y := shr(1, erfc(sdiv(mul(sub(_u, _x), 0xb504f333f9de6484597d89b3), _o)))
        }
    }
}
