// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct PRNG {
    uint256 __state;
}

using PRNGLib for PRNG global;

/// @author philogy <https://github.com/philogy>
library PRNGLib {
    error InvalidBounds();

    function randbool(PRNG memory self) internal pure returns (bool) {
        return self.next() % 2 == 0;
    }

    function randchoice(PRNG memory self, uint256 p, uint256 x, uint256 y) internal pure returns (uint256) {
        return self.randuint(1e18) <= p ? x : y;
    }

    function randint(PRNG memory self, int256 lowerBound, int256 upperBound) internal pure returns (int256 num) {
        if (lowerBound >= upperBound) revert InvalidBounds();
        uint256 rangeSize;
        unchecked {
            rangeSize = uint256(upperBound) - uint256(lowerBound);
            num = int256(self.randuint(rangeSize) + uint256(lowerBound));
        }
    }

    function randuint(PRNG memory self, uint256 lowerBound, uint256 upperBound) internal pure returns (uint256 num) {
        if (lowerBound >= upperBound) revert InvalidBounds();
        num = self.randuint(upperBound - lowerBound) + lowerBound;
    }

    function randuint(PRNG memory self, uint256 upperBound) internal pure returns (uint256 num) {
        if (upperBound == 1) return 0;
        uint256 maxValue = (type(uint256).max / upperBound) * upperBound;
        assembly ("memory-safe") {
            let preState := mload(self)
            let value
            mstore(0x20, preState)
            for { let i := 0 } 1 { i := add(i, 1) } {
                mstore(0x00, i)
                value := keccak256(0x00, 0x40)
                if lt(value, maxValue) { break }
            }
            num := mod(value, upperBound)

            mstore8(0x1f, 3)
            mstore(self, keccak256(31, 33))
        }
    }

    function next(PRNG memory self) internal pure returns (uint256 value) {
        assembly ("memory-safe") {
            mstore(1, mload(self))

            mstore8(0, 1)
            value := keccak256(0, 33)

            mstore8(0, 2)
            mstore(self, keccak256(0, 33))
        }
    }
}
