// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console } from "forge-std/Test.sol";
import { Script } from "forge-std/Script.sol";

import { Gaussian } from "src/Gaussian.sol";
import { GaussianYul } from "src/GaussianYul.sol";

/// @notice A helper script to log values of {Gaussian.cdf} to console for
/// testing.
contract PrintGaussianScript is Script {
    /// @notice Computes the CDF values for a few test cases and logs them to
    /// console.
    function run() public pure {
        console.log(Gaussian.cdf({ _x: 2e18, _mu: 0.75e18, _sigma: 2e18 }));
        console.log(GaussianYul.cdf({ _x: 2e18, _mu: 0.75e18, _sigma: 2e18 }));
        console.log(Gaussian.cdf({ _x: -2e18, _mu: 0.75e18, _sigma: 2e18 }));
        console.log(GaussianYul.cdf({ _x: -2e18, _mu: 0.75e18, _sigma: 2e18 }));
        console.log(Gaussian.cdf({ _x: 0, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: 0, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: 1e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: 1e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: 2e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: 2e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: 5.342e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: 5.342e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: 10e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: 10e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: -1e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: -1e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: -2e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: -2e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: -5.342e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: -5.342e18, _mu: 0, _sigma: 1e18 }));
        console.log(Gaussian.cdf({ _x: -10e18, _mu: 0, _sigma: 1e18 }));
        console.log(GaussianYul.cdf({ _x: -10e18, _mu: 0, _sigma: 1e18 }));
    }
}
