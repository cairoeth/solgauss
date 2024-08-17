// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "forge-std/console2.sol";
import {FormatLib} from "./FormatLib.sol";
import {LibString} from "solady/src/utils/LibString.sol";

/// @author philogy <https://github.com/philogy>
library CDF {
    using FormatLib for *;
    using LibString for *;

    uint256 internal constant POW = 96;
    uint256 internal constant TWO = 2e18;

    error CDFArithmeticError();

    /**
     * @dev Approximation of the complementary error function "erfc" where the input is divided by
     * sqrt(2) (`1 - erf(x)`).
     * @param x Base-2 fixed point number with scale 2^POW.
     * @param y Number in WAD (fixed point number with scale 10^18).
     */
    function _innerErfc(int256 x) internal pure returns (uint256 y) {
        assembly {
            for {} 1 {} {
                // Compute absolute value of `x` (credit to
                // [Solady](https://github.com/Vectorized/solady/blob/8200a70e8dc2a77ecb074fc2e99a2a0d36547522/src/utils/FixedPointMathLib.sol#L932-L937)).
                // Exploits symmetry of `erfc` (2 - erfc(-x) = erfc(x)) and just approximates positive section,
                // flipping based on the sign at the end.
                let z := xor(sar(255, x), add(sar(255, x), x))

                // Find which of the 26 ranges `z` lies in to compute the approximation for the
                // specific range.
                if lt(z, 0x3e7941cf7851d637c3343f1d7) {
                    if lt(z, 0x257bf44948311a21751f5911a) {
                        if lt(z, 0x12bdfa24a4188d10ba8fac88d) {
                            if lt(z, 0x63f53618c082f0593853982f) {
                                let num := add(z, 0xfffffffffffffffffffffffffffffffffffffffd5b9db0c63ceb616249e160d2)
                                num :=
                                    add(
                                        sar(POW, mul(num, z)),
                                        0xfffffffffffffffffffffffffffffffffffffffd7d33745dfe3dc692724366e3
                                    )
                                num := add(sar(POW, mul(num, z)), 0x972876544bcdf0af5bde315ec)
                                let denom := add(z, 0x1a35c4a3c55bfed60e7d705dd)
                                denom := add(sar(POW, mul(denom, z)), 0x60412a301b225f7f185a16479)
                                denom := add(sar(POW, mul(denom, z)), 0xb4e4f7929d746aa17539db842)
                                y := sdiv(mul(0x109b9db6fc0bee23, num), denom)
                                break
                            }
                            if lt(z, 0xc7ea6c318105e0b270a7305e) {
                                let num := add(z, 0xfffffffffffffffffffffffffffffffffffffffa1262e64b4be6a68511604041)
                                num := add(sar(POW, mul(num, z)), 0xc04fe6d28f305c95f6e7ccd3c)
                                num :=
                                    add(
                                        sar(POW, mul(num, z)),
                                        0xfffffffffffffffffffffffffffffffffffffff7eef8c036dc49b1124094731b
                                    )
                                let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffe540db7707856a86e85033c2d)
                                denom := add(sar(POW, mul(denom, z)), 0x65ed222e7ac7c600bab4b3b6d)
                                denom :=
                                    add(
                                        sar(POW, mul(denom, z)),
                                        0xfffffffffffffffffffffffffffffffffffffff6cb274dc1d8cb1e79970ad6db
                                    )
                                y := sdiv(mul(0xfd6d7f47435c154, num), denom)
                                break
                            }
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff86d590afd6f543110dcb1bdaa)
                            num := add(sar(POW, mul(num, z)), 0x14202da4573e97aa33065d5bf0)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffed4766b1477ac16ddc6d0573ed
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffa7317507e0958737926f85540)
                            denom := add(sar(POW, mul(denom, z)), 0x89df33f370acb82b21486aabf)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xffffffffffffffffffffffffffffffffffffffe0a0a829d6d91a4490ffc279bd
                                )
                            y := sdiv(mul(0x174407a7886b5518, num), denom)
                            break
                        }
                        if lt(z, 0x18fd4d863020bc164e14e60bc) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff755384bee352a645d6760b9c0)
                            num := add(sar(POW, mul(num, z)), 0x1a1334f87896dcbe2bb519c403)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffe4cafa887900331fee6efb8746
                                )
                            let denom := add(z, 0x2267e2d30cf9cc880589bfab92)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xffffffffffffffffffffffffffffffffffffffe19a3a865a2a63448264a6a9c7
                                )
                            denom := add(sar(POW, mul(denom, z)), 0xd3fdeb3f125889c6a4fa0f0d0e)
                            y :=
                                sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffff9366e6f1d3aeb331, num), denom)
                            break
                        }
                        if lt(z, 0x1f3ca0e7bc28eb1be19a1f8eb) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff676806c1f3fd3ad38f192eb99)
                            num := add(sar(POW, mul(num, z)), 0x1f434fcbba4e31f45a7727a3ff)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffdcc692754a0669b77a5832e3ae
                                )
                            let denom := add(z, 0x179b255378d16f9cad611959e)
                            denom := add(sar(POW, mul(denom, z)), 0x389dd3b37fcea39300cb8a0b)
                            denom := add(sar(POW, mul(denom, z)), 0x1115162e8ab7cb12a003b0e737)
                            y :=
                                sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffff90792b6e24bf48c, num), denom)
                            break
                        }
                        let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff5a359e0326e72e8e56a35e825)
                        num := add(sar(POW, mul(num, z)), 0x24a161625625ae7670d07e7efc)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffffd3ce1e51c60f3f7ee59e29c2a4)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffe837e1091a194ecdb40163e34)
                        denom := add(sar(POW, mul(denom, z)), 0x30b435be1647b9a61572eff23)
                        denom := add(sar(POW, mul(denom, z)), 0x44109a1f9fea9af62234f152f)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffe36aa51e50e0705, num), denom)
                        break
                    }
                    if lt(z, 0x31fa9b0c6041782c9c29cc179) {
                        if lt(z, 0x2bbb47aad439492708a49294a) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff4cbafe2b5100d36a11277b57c)
                            num := add(sar(POW, mul(num, z)), 0x2a96b9c7b77ea49ac3653251ee)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffc90dbfd07ab80201f6a4eefe73
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffca4ecfe7797f20b0b3deaf926)
                            denom := add(sar(POW, mul(denom, z)), 0x5f3b3fd91dc2c6a75e0d6e2b4)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xfffffffffffffffffffffffffffffffffffffffe99bbf9a5ff25c9ab154695be
                                )
                            y :=
                                sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffff8344319be367f5, num), denom)
                            break
                        }
                        if lt(z, 0x2edaf15b9a3d60a9d2672f561) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff424fbff97d0a26f0d554e30a8)
                            num := add(sar(POW, mul(num, z)), 0x2f881288a95a8c5275c7bb3dfe)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffbf86a10efb68ac6e149d43bcb4
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffb62fc6d4b57d521dff37082a6)
                            denom := add(sar(POW, mul(denom, z)), 0x8fbddb10a43dd10c9c2716a8c)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xfffffffffffffffffffffffffffffffffffffffae8a83b9bbca9444a7a85c139
                                )
                            y :=
                                sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffd36b4134ccf80f, num), denom)
                            break
                        }
                        let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff3b2a48953c2f297d49c7bab81)
                        num := add(sar(POW, mul(num, z)), 0x331637dca399dc652a3708a323)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffffb85b79a4009cacfa9022bfe1e6)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffffa9a4b5524430951d76848a776)
                        denom := add(sar(POW, mul(denom, z)), 0xb63c9e3d3c16d80e918328e96)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff8363311a0fa1e51d06ea21bea)
                        y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffea122837b875b3, num), denom)
                        break
                    }
                    if lt(z, 0x3839ee6dec49a7322faf059a8) {
                        if lt(z, 0x351a44bd26458faf65ec68d90) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff33e313284d4da0d796075d9b3)
                            num := add(sar(POW, mul(num, z)), 0x36d8fe4e89ea83bfd96ea267af)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffffb07e83b44dd10bbb3fc50297f9
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff9d67819f6fb93ddec0c198ca3)
                            denom := add(sar(POW, mul(denom, z)), 0xe253973dea93a638f28acea68)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xfffffffffffffffffffffffffffffffffffffff5105d753ef7448a0c671aee94
                                )
                            y :=
                                sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffff57f69ca4fa400, num), denom)
                            break
                        }
                        let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff2c7bafb6ea7199b1f76093d7c)
                        num := add(sar(POW, mul(num, z)), 0x3ad170881be20460f98cdda52c)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffffa7e4244490b7b5ae7bd55cae29)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff9167ee7ae633ac391a3ff2e22)
                        denom := add(sar(POW, mul(denom, z)), 0x113e6df490bf3ddf37aafc71a9)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xfffffffffffffffffffffffffffffffffffffff154495e730264eaaa2f735950)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffb1c2e6bf8086c, num), denom)
                        break
                    }
                    if lt(z, 0x3b59981eb24dbeb4f971a25c0) {
                        let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff24f5e1066d1528e9845ba1bb7)
                        num := add(sar(POW, mul(num, z)), 0x3f0063f981ca4350fad80b95b8)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff9e80d99a5797e0164e88456978)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff859cb11cf88286abe4d9491c2)
                        denom := add(sar(POW, mul(denom, z)), 0x14ac8d1cd2c72f8e7ea6f6086c)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffece6d13e8f23e7bfeac37ae51a)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffdc9fa6f4ad372, num), denom)
                        break
                    }
                    let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff1d53796d18d110274752c9e68)
                    num := add(sar(POW, mul(num, z)), 0x436687f3620b7734aa4d483d58)
                    num :=
                        add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff94492b23fab70b03c53131a1de)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff79ffc5d265bd1efc008563f7d)
                    denom := add(sar(POW, mul(denom, z)), 0x186c61b567d4ac81d5f776765c)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffe7b216bd826e25d9909c01b224)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffff07ae76a73145, num), denom)
                    break
                }
                if lt(z, 0x51373bf41c6a63487dc3eba65) {
                    if lt(z, 0x47d83ee1ca5e1cc0207c1561e) {
                        if lt(z, 0x4198eb803e55edba8cf6dbdef) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff15964895f45b30f0780119030)
                            num := add(sar(POW, mul(num, z)), 0x48046e4c7935e08e674bbf2bc5)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffff8931a338e126208d60ba00ba1f
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff6e8cb9c8818a9fe4009f7e21e)
                            denom := add(sar(POW, mul(denom, z)), 0x1c7ac58208ad48f281e81d4a94)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xffffffffffffffffffffffffffffffffffffffe1a3d647b88c0f6c344bbb1fb7
                                )
                            y :=
                                sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffff9662034943fa, num), denom)
                            break
                        }
                        if lt(z, 0x44b89531045a053d56b978a06) {
                            let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff0dc011a262424079db4f2db3a)
                            num := add(sar(POW, mul(num, z)), 0x4cda90e1755c8246407e8fbdc6)
                            num :=
                                add(
                                    sar(POW, mul(num, z)),
                                    0xffffffffffffffffffffffffffffffffffffff7d2ecd4deeea7673838e007ded
                                )
                            let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff633fe316b178985af495d3aca)
                            denom := add(sar(POW, mul(denom, z)), 0x20d4d517695f5068d2dd373b5d)
                            denom :=
                                add(
                                    sar(POW, mul(denom, z)),
                                    0xffffffffffffffffffffffffffffffffffffffdaac3ec732f932b8aa8872bf94
                                )
                            y :=
                                sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffd47a42c6ea20, num), denom)
                            break
                        }
                        let num := add(z, 0xfffffffffffffffffffffffffffffffffffffff05d285962b46905d428909b87)
                        num := add(sar(POW, mul(num, z)), 0x51e9558687ad50971e42522892)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff703535ea118e8a0851c5fbe19c)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff58160898ccf7f8a58c9eeeb47)
                        denom := add(sar(POW, mul(denom, z)), 0x2578040aa3021a7fc2dde1c6cf)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffd2bd257114ee08f63fbca996ae)
                        y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffeea281ebce83, num), denom)
                        break
                    }
                    if lt(z, 0x4af7e89290623442ea3eb2235) {
                        let num := add(z, 0xffffffffffffffffffffffffffffffffffffffefdcf402299acd63c01a689858)
                        num := add(sar(POW, mul(num, z)), 0x5731112597326c1a1316ee9dcb)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff62396b196ce14457e5d9e2a29f)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff4d0c3ccfba057b5062c97aeee)
                        denom := add(sar(POW, mul(denom, z)), 0x2a621fd51799b84312d1d707d7)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffc9c979f6a91fd8f1f1c5c937c4)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffff94b8732807e, num), denom)
                        break
                    }
                    if lt(z, 0x4e17924356664bc5b4014ee4d) {
                        let num := add(z, 0xffffffffffffffffffffffffffffffffffffffef5b7c5e3dc64ce40c0fe9f699)
                        num := add(sar(POW, mul(num, z)), 0x5cb20a5b0e53079fcf6e4e9b82)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff532ffcdab5ae5ac3006c21b603)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff421fcef59f5cbd7a9dabdfbb6)
                        denom := add(sar(POW, mul(denom, z)), 0x2f914a1bcee170734fe4b4933b)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffbfc4e768bc5b31df1759941996)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffd7ef44903db, num), denom)
                        break
                    }
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffeed8d83962a7f5773ed900847e)
                    num := add(sar(POW, mul(num, z)), 0x626c7bb45cbaeb7af8251266e1)
                    num :=
                        add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff430d7d5c9e298f378e87c53b90)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff374e44f8d86806590bc03f4c4)
                    denom := add(sar(POW, mul(denom, z)), 0x3503ef551055501f6ff1a62e4e)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffb4a393dad1081ebafe955f6019)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffff188919aeb3, num), denom)
                    break
                }
                if lt(z, 0x5a9639066e76a9d0db0bc1eab) {
                    if lt(z, 0x5456e5a4e26e7acb47868867c) {
                        let num := add(z, 0xffffffffffffffffffffffffffffffffffffffee551cdfafb22043f682e7be45)
                        num := add(sar(POW, mul(num, z)), 0x686095a00bbb92844a5b953ebd)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff31c68108660517c337f6f496a4)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff2c95587ff8d00c604ed2801f8)
                        denom := add(sar(POW, mul(denom, z)), 0x3ab8bc7e5e34967408dbd4e8a7)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffffa859f5055a8e14924724df502c)
                        y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffaf3ae50ac1, num), denom)
                        break
                    }
                    if lt(z, 0x57768f55a872924e114925294) {
                        let num := add(z, 0xffffffffffffffffffffffffffffffffffffffedd05e23e26144cc76d6f4b790)
                        num := add(sar(POW, mul(num, z)), 0x6e8e801854cad10821b0b2757d)
                        num :=
                            add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff1f4f9e64bc923d307bb8640f6c)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff21f2f4931390b436cc93d63d9)
                        denom := add(sar(POW, mul(denom, z)), 0x40ae953d05eb9627f35b06455d)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffff9adcb32a8620a7f8ddc0e72776)
                        y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffe4c56419a8, num), denom)
                        break
                    }
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffed4aae6b6f7f73473ab472f797)
                    num := add(sar(POW, mul(num, z)), 0x74f65c0f2faf64d85a35a2c575)
                    num :=
                        add(sar(POW, mul(num, z)), 0xffffffffffffffffffffffffffffffffffffff0b9d6ddee0fc1851921b8703a0)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff17653316df4ff25d4011e1e84)
                    denom := add(sar(POW, mul(denom, z)), 0x46e48b01b1a3eb2de51d466d9c)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffff8c2095a1cbd0bb388985855e8c)
                    y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffff72281d9fa, num), denom)
                    break
                }
                if lt(z, 0x60d58c67fa7ed8d66e90fb6db) {
                    if lt(z, 0x5db5e2b7347ac153a4ce5eac3) {
                        let num := add(z, 0xffffffffffffffffffffffffffffffffffffffecc41ebe8f4bafef2502dcbe9a)
                        num := add(sar(POW, mul(num, z)), 0x7b9844a27c1fcd8108d606b764)
                        num :=
                            add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffef6a489862734b03b188c1dd359)
                        let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff0cea59ef01b292acd067b9252)
                        denom := add(sar(POW, mul(denom, z)), 0x4d59d55f451b5521c94e2ed046)
                        denom :=
                            add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffff7c1a75e84f843ac638ce22f7a6)
                        y := sdiv(mul(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffd36969e24, num), denom)
                        break
                    }
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffec3cbedadcb487053185ee5ca5)
                    num := add(sar(POW, mul(num, z)), 0x8274501ee9a0971236ca2a6d7c)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffee0598cc2f8f62d5a6590337421)
                    let denom := add(z, 0xfffffffffffffffffffffffffffffffffffffff0280d7db34f844aa58942a0a4)
                    denom := add(sar(POW, mul(denom, z)), 0x540dcb90d119f016c5f28184b0)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffff6abf3716f8f22e18bc4972becf)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff27882153, num), denom)
                    break
                }
                if lt(z, 0x63f53618c082f0593853982f2) {
                    let num := add(z, 0xffffffffffffffffffffffffffffffffffffffebb49d476c8b544ab85b38b474)
                    num := add(sar(POW, mul(num, z)), 0x898a90d81c92c2610989467f99)
                    num :=
                        add(sar(POW, mul(num, z)), 0xfffffffffffffffffffffffffffffffffffffec8b1140f70f4d7ba00d5d298de)
                    let denom := add(z, 0xffffffffffffffffffffffffffffffffffffffef82741331e241e6ea96979455)
                    denom := add(sar(POW, mul(denom, z)), 0x5affdf12a5dff4ab5149f553cb)
                    denom :=
                        add(sar(POW, mul(denom, z)), 0xffffffffffffffffffffffffffffffffffffff5803c04f22bcd2769ed77a19f7)
                    y := sdiv(mul(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffc09d3eb8, num), denom)
                    break
                }
                y := 0
                break
            }

            if slt(x, 0) { y := sub(TWO, y) }
        }
    }

    function cdf(int256 x, int256 mu, uint256 sigma) internal pure returns (uint256) {
        // cdf(x) = erfc(-x) / 2
        int256 base2X;
        assembly ("memory-safe") {
            let num := sub(mu, x)
            // Signed subtraction overflow/underflow check.
            let noError := eq(slt(num, mu), sgt(x, 0))
            let z := shl(POW, num)
            // Check shift overflow.
            noError := and(noError, eq(sar(POW, z), num))
            // Check that sigma is positive when interpreted as a two's complement number.
            noError := and(noError, sgt(sigma, 0))
            if iszero(noError) {
                mstore(0x00, 0xb8f629c0 /*CDFArithmeticError()*/ )
                revert(0x1c, 0x04)
            }
            // Complete final division.
            base2X := sdiv(z, sigma)
        }
        return _innerErfc(base2X) >> 1;
    }
}
