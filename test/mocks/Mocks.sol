// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Gaussian} from "src/Gaussian.sol";
import {CDF as Philogy} from "gud-cdf/CDF.sol";
import {Gaussian as Solstat} from "solstat/Gaussian.sol";
import {GaussianYul as Fiveoutofnine} from "solidity-cdf/GaussianYul.sol";

// Own

contract MockCdf {
    function cdf(int256 x, int256 u, uint256 o) public pure returns (uint256) {
        return Gaussian.cdf(x, u, o);
    }
}

contract MockErfc {
    function erfc(int256 x) public pure returns (uint256) {
        return Gaussian.erfc(x);
    }
}

contract MockErfinv {
    function erfinv(int256 x) public pure returns (int256) {
        return Gaussian.erfinv(x);
    }
}

contract MockErfcinv {
    function erfcinv(int256 x) public pure returns (int256) {
        return Gaussian.erfcinv(x);
    }
}

contract MockPpf {
    function ppf(int256 x, int256 u, int256 o) public pure returns (int256) {
        return Gaussian.ppf(x, u, o);
    }
}

// Philogy

contract MockPhilogyErfc {
    function erfc(int256 x) public pure returns (uint256) {
        return Philogy._innerErfc(x);
    }
}

contract MockPhilogyCdf {
    function cdf(int256 x, int256 u, uint256 o) public pure returns (uint256) {
        return Philogy.cdf(x, u, o);
    }
}

// 5/9

contract MockFiveoutofnineCdf {
    function cdf(int256 x, int256 u, uint256 o) public pure returns (uint256) {
        return Fiveoutofnine.cdf(x, u, o);
    }
}

// Solstat

contract MockSolstatErfc {
    function erfc(int256 x) public pure returns (int256) {
        return Solstat.erfc(x);
    }
}

contract MockSolstatCdf {
    function cdf(int256 x) public pure returns (int256) {
        return Solstat.cdf(x);
    }
}
