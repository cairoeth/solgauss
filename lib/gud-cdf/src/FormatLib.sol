// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibString} from "solady/src/utils/LibString.sol";

import {console2 as console} from "forge-std/console2.sol";

library FormatLib {
    using FormatLib for *;

    using LibString for uint256;
    using LibString for int256;

    function formatDecimals(int256 value) internal pure returns (string memory) {
        return formatDecimals(value, 6, 18);
    }

    function formatDecimals(int256 value, uint8 roundTo) internal pure returns (string memory) {
        return formatDecimals(value, roundTo, 18);
    }

    function formatDecimals(int256 value, uint8 roundTo, uint8 decimals) internal pure returns (string memory) {
        roundTo = roundTo > decimals ? decimals : roundTo;
        int256 roundedUnit = int256(10 ** uint256(decimals - roundTo));
        int256 decimalValue = (value + roundedUnit / 2) / roundedUnit;
        assert(roundedUnit > 0);

        uint256 one = 10 ** roundTo;

        uint256 aboveDecimal = uint256(abs(decimalValue)) / one;
        uint256 belowDecimal = uint256(abs(decimalValue)) % one;

        string memory decimalRepr = belowDecimal.toString();
        while (bytes(decimalRepr).length < roundTo) {
            decimalRepr = string.concat("0", decimalRepr);
        }

        return string.concat(value < 0 ? "-" : "", aboveDecimal.toString(), ".", decimalRepr);
    }

    function formatDecimals(uint256 value) internal pure returns (string memory) {
        return formatDecimals(value, 6, 18);
    }

    function formatDecimals(uint256 value, uint8 roundTo) internal pure returns (string memory) {
        return formatDecimals(value, roundTo, 18);
    }

    function formatDecimals(uint256 value, uint8 roundTo, uint8 decimals) internal pure returns (string memory) {
        roundTo = roundTo > decimals ? decimals : roundTo;
        uint256 roundedUnit = 10 ** uint256(decimals - roundTo);
        uint256 decimalValue = (value + roundedUnit / 2) / roundedUnit;

        uint256 one = 10 ** roundTo;
        uint256 aboveDecimal = decimalValue / one;
        uint256 belowDecimal = decimalValue % one;

        string memory decimalRepr = belowDecimal.toString();
        while (bytes(decimalRepr).length < roundTo) {
            decimalRepr = string.concat("0", decimalRepr);
        }

        return string.concat(aboveDecimal.toString(), ".", decimalRepr);
    }

    function toString(uint256[] memory values) internal pure returns (string memory) {
        if (values.length == 0) return "[]";
        string memory str = string.concat("[", values[0].toString());
        for (uint256 i = 1; i < values.length; i++) {
            str = string.concat(str, ", ", values[i].toString());
        }
        return string.concat(str, "]");
    }

    function toString(bool b) internal pure returns (string memory) {
        return b ? "true" : "false";
    }

    function toString(bool[] memory values) internal pure returns (string memory) {
        if (values.length == 0) return "[]";
        string memory str = string.concat("[", values[0].toString());
        for (uint256 i = 1; i < values.length; i++) {
            str = string.concat(str, ", ", values[i].toString());
        }
        return string.concat(str, "]");
    }

    function abs(int256 x) private pure returns (int256) {
        return x < 0 ? -x : x;
    }
}
