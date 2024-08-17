// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CDF} from "../src/CDF.sol";
import {console2 as console} from "forge-std/console2.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {FormatLib} from "../src/FormatLib.sol";
import {Gaussian} from "solstat/Gaussian.sol";
import {PRNG} from "../src/PRNG.sol";

/// @author philogy <https://github.com/philogy>
contract CDFTest is Test {
    using FormatLib for *;
    using LibString for *;

    uint256 internal constant POW = 80;

    function setUp() public {}

    function test_gas_erf() public view {
        int256 start = -5.25e18;
        int256 end = 5.25e18;
        uint256 count = 200;
        uint256 totalGas;
        for (uint256 i = 0; i < count; i++) {
            int256 x = (end - start) * int256(i) / int256(count - 1) + start;
            uint256 before = gasleft();
            CDF.cdf(x, 0, 1e18);
            totalGas += before - gasleft();
        }
        console.log("totalGas: %s", totalGas);
    }

    function test_gas_waylon() public view {
        int256 start = -5.25e18;
        int256 end = 5.25e18;
        uint256 count = 200;
        uint256 totalGas;
        for (uint256 i = 0; i < count; i++) {
            int256 x = (end - start) * int256(i) / int256(count - 1) + start;
            uint256 before = gasleft();
            Gaussian.cdf(x);
            totalGas += before - gasleft();
        }
        console.log("totalGas: %s", totalGas);
    }

    struct ErrorTracker {
        uint256 max;
        uint256 total;
        uint256 n;
    }

    function test_avg_error() public {
        PRNG memory rng = PRNG(123);
        uint256 samples = 1000;

        ErrorTracker memory waylon;
        ErrorTracker memory philogy;

        for (uint256 i = 0; i < samples; i++) {
            int256 x = rng.randint(-7e18, 7e18);
            uint256 y = _fullCdf(x);
            _update(waylon, y, uint256(Gaussian.cdf(x)));
            uint256 myY = CDF.cdf(x, 0, 1e18);
            uint256 err = _update(philogy, y, myY);
            if (err > 0.1e18) {
                console.log("cdf(%s) = %s (%s)", x.formatDecimals(18), y.formatDecimals(18), myY.formatDecimals(18));
                console.log("  error: %s", err.formatDecimals());
            }
        }

        console.log("waylon:");
        _show(waylon);
        console.log("philogy:");
        _show(philogy);
    }

    function _powFmt(int256 x) internal pure returns (string memory) {
        return ((x * 1e18) >> CDF.POW).formatDecimals(18);
    }

    function _update(ErrorTracker memory tracker, uint256 y, uint256 out) internal returns (uint256 error) {
        if (out == 0) return 0;
        uint256 relError = y * 1e18 / out;
        error = relError < 1e18 ? 1e18 - relError : relError - 1e18;
        tracker.total += error;
        tracker.max = tracker.max < error ? error : tracker.max;
        tracker.n++;
    }

    function _show(ErrorTracker memory tracker) internal pure {
        console.log("  max error: %s", tracker.max.formatDecimals(18));
        console.log("  avg error: %s", (tracker.total / tracker.n).formatDecimals(18));
    }

    function _fullCdf(int256 x) internal returns (uint256) {
        string[] memory args = new string[](3);
        args[0] = ".venv/bin/python3";
        args[1] = "script/erf.py";
        args[2] = x.formatDecimals(18);
        bytes memory ret = vm.ffi(args);
        return abi.decode(ret, (uint256));
    }
}
