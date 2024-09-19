// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {CDF} from "src/CDF.sol";
import {CDF as CDFPhilogy} from "gud-cdf/CDF.sol";
import {Gaussian} from "solstat/Gaussian.sol";
import {GaussianYul as Gaussian2} from "solidity-cdf/GaussianYul.sol";

contract Mock {
    function erfc(int256 x) public pure returns (uint256) {
        return CDF.erfc(x);
    }

    function erfinv(int256 x) public pure returns (int256) {
        return CDF.erfinv(x);
    }

    function erfcinv(int256 x) public pure returns (int256) {
        return CDF.erfcinv(x);
    }

    function ppf(int256 _x, int72 _u, int256 _o) public pure returns (int256) {
        return CDF.ppf(_x, _u, _o);
    }

    function cdf(int256 _x, int256 _u, uint256 _o) public pure returns (uint256) {
        return CDF.cdf(_x, _u, _o);
    }
}

contract MockPhilogy {
    function erfc(int256 x) public pure returns (uint256) {
        return CDFPhilogy._innerErfc(x);
    }

    function cdf(int256 x, int72 u, uint256 o) public pure returns (uint256) {
        return CDFPhilogy.cdf(x, u, o);
    }
}

contract MockFiveoutofnine {
    function cdf(int256 x, int72 u, uint256 o) public pure returns (uint256) {
        return Gaussian2.cdf(x, u, o);
    }
}

contract MockSolstat {
    function erfc(int256 x) public pure returns (int256) {
        return Gaussian.erfc(x);
    }

    function cdf(int256 x) public pure returns (int256) {
        return Gaussian.cdf(x);
    }
}

contract CDFTest is Test {
    uint256 internal constant POW = 96;
    uint256 internal constant ONE = 1 ether;

    int72 internal constant MEAN_UPPER = 1e20;
    int72 internal constant MEAN_LOWER = -MEAN_UPPER;

    int256 constant INPUT_UPPER = 1e23;
    int256 constant INPUT_LOWER = -INPUT_UPPER;

    uint256 constant O_UPPER = 1e19;

    int256 internal constant ERFC_DOMAIN_UPPER = 6.24 ether;
    int256 internal constant ERFC_DOMAIN_LOWER = -ERFC_DOMAIN_UPPER;

    Mock mock;
    MockPhilogy philogy;
    MockFiveoutofnine fiveoutofnine;
    MockSolstat solstat;

    function setUp() public {
        mock = new Mock();
        philogy = new MockPhilogy();
        fiveoutofnine = new MockFiveoutofnine();
        solstat = new MockSolstat();
    }

    /// forge-config: default.fuzz.runs = 500
    function testDifferentialErfc(int256 x) public {
        vm.assume(x != 0);
        vm.assume(ERFC_DOMAIN_LOWER <= x && x <= ERFC_DOMAIN_UPPER);

        uint256 actual = mock.erfc(getx96(x));

        // error must be less than 1e-8
        uint256 expected = getErfcPython(x);
        assertApproxEqAbs(actual, expected, 1e-8 ether);

        // error must be less than 1e-8
        // uint256 expected2 = getErfcJavascript(x);
        // assertApproxEqAbs(actual, expected2, 1e-8 ether);

        // benchmarks
        philogy.erfc(getx96(x));
        solstat.erfc(x);
    }

    /// forge-config: default.fuzz.runs = 500
    function testDifferentialErfinv(int256 x) public {
        x = bound(x, -0.999999999e18, 0.999999999e18);

        int256 actual = mock.erfinv(getx96(x));

        // error must be less than 1e-8
        int256 expected = getErfinvPython(x);

        assertApproxEqAbs(stdMath.abs(actual), stdMath.abs(expected), 1e-8 ether);
    }

    /// forge-config: default.fuzz.runs = 500
    function testDifferentialErfcinv(int256 x) public {
        x = bound(x, 0.999999999e18, 1.999999999e18);

        int256 actual = mock.erfcinv(x);

        // error must be less than 1e-8
        int256 expected = getErfcinvPython(x);

        assertApproxEqAbs(stdMath.abs(actual), stdMath.abs(expected), 1e-8 ether);
    }

    /// forge-config: default.fuzz.runs = 500
    function testDifferentialPpf(int64 x, int72 u, int256 o) public {
        vm.assume(2e9 <= x && x < 1e18);
        vm.assume(u < x);
        // Can't use bound because it's limited to uint.
        // -1e20 ≤ μ ≤ 1e20
        vm.assume(MEAN_LOWER <= u && u <= MEAN_UPPER);
        // 0 < σ ≤ 1e19
        vm.assume(0 < o && o <= 1e19);
        // interval [-1e23, 1e23]
        vm.assume(INPUT_LOWER <= x && x <= INPUT_UPPER);

        int256 actual = mock.ppf(x, u, o);

        // error must be less than 1e-8
        int256 expected = getPpfPython(x, u, o);

        assertApproxEqAbs(stdMath.abs(actual), stdMath.abs(expected), 1e-8 ether);
    }

    /// forge-config: default.fuzz.runs = 500
    function testDifferentialCdf(int256 x, int72 u, uint64 o) public {
        vm.assume(x != 0 && x > u);
        // Can't use bound because it's limited to uint.
        // -1e20 ≤ μ ≤ 1e20
        vm.assume(MEAN_LOWER <= u && u <= MEAN_UPPER);
        // 0 < σ ≤ 1e19
        vm.assume(0 < o && o <= O_UPPER);
        // interval [-1e23, 1e23]
        vm.assume(INPUT_LOWER <= x && x <= INPUT_UPPER);

        uint256 actual = mock.cdf(x, u, o);

        // error must be less than 1e-8
        uint256 expected = getCdfPython(x, u, o);
        assertApproxEqAbs(actual, expected, 1e-8 ether);

        // error must be less than 1e-8
        // uint256 expected2 = getCdfJavascript(x, u, o);
        // assertApproxEqAbs(actual, expected2, 1e-8 ether);

        // benchmarks
        philogy.cdf(x, u, o);
        fiveoutofnine.cdf(x, u, o);
        solstat.cdf(x);
    }

    function getx96(int256 x) internal pure returns (int256 x96) {
        assembly ("memory-safe") {
            x96 := sdiv(shl(POW, x), ONE)
        }
    }

    function getErfcPython(int256 x) internal returns (uint256) {
        string[] memory cmd = new string[](3);
        cmd[0] = "venv/bin/python";
        cmd[1] = "differential/erfc.py";
        cmd[2] = vm.toString(x);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (uint256));
    }

    function getErfinvPython(int256 x) internal returns (int256) {
        string[] memory cmd = new string[](3);
        cmd[0] = "venv/bin/python";
        cmd[1] = "differential/erfinv.py";
        cmd[2] = vm.toString(x);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (int256));
    }

    function getErfcinvPython(int256 x) internal returns (int256) {
        string[] memory cmd = new string[](3);
        cmd[0] = "venv/bin/python";
        cmd[1] = "differential/erfcinv.py";
        cmd[2] = vm.toString(x);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (int256));
    }

    function getPpfPython(int256 x, int72 u, int256 o) internal returns (int256) {
        string[] memory cmd = new string[](5);
        cmd[0] = "venv/bin/python";
        cmd[1] = "differential/ppf.py";
        cmd[2] = vm.toString(x);
        cmd[3] = vm.toString(u);
        cmd[4] = vm.toString(o);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (int256));
    }

    function getErfcJavascript(int256 x) public returns (uint256) {
        string[] memory cmd = new string[](7);
        cmd[0] = "yarn";
        cmd[1] = "--cwd";
        cmd[2] = "differential/";
        cmd[3] = "--silent";
        cmd[4] = "run";
        cmd[5] = "erfc";
        cmd[6] = vm.toString(x);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (uint256));
    }

    function getCdfPython(int256 x, int72 u, uint64 o) internal returns (uint256) {
        string[] memory cmd = new string[](5);
        cmd[0] = "venv/bin/python";
        cmd[1] = "differential/cdf.py";
        cmd[2] = vm.toString(x);
        cmd[3] = vm.toString(u);
        cmd[4] = vm.toString(o);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (uint256));
    }

    function getCdfJavascript(int256 x, int72 u, uint64 o) public returns (uint256) {
        string[] memory cmd = new string[](9);
        cmd[0] = "yarn";
        cmd[1] = "--cwd";
        cmd[2] = "differential/";
        cmd[3] = "--silent";
        cmd[4] = "run";
        cmd[5] = "cdf";
        cmd[6] = vm.toString(x);
        cmd[7] = vm.toString(u);
        cmd[8] = vm.toString(o);

        bytes memory result = vm.ffi(cmd);
        return abi.decode(result, (uint256));
    }
}
