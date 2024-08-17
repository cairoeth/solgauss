// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { Gaussian } from "src/Gaussian.sol";
import { GaussianYul } from "src/GaussianYul.sol";

contract GaussianTest is Test {
    // -------------------------------------------------------------------------
    // {Gaussian}
    // -------------------------------------------------------------------------

    /// @notice Tests the gas cost of {Gaussian.cdf} with hard-coded parameters.
    function testGas_cdf() public pure {
        Gaussian.cdf({ _x: 1e18, _mu: 0, _sigma: 1e18 });
    }

    /// @notice Tests the gas cost of {Gaussian.cdf} with fuzzed inputs with the
    /// following bounds: `_x` ∈ [-1e23, 1e23], `_mu` ∈ [-1e20, 1e20], `_sigma`
    /// ∈ (0, 1e19].
    /// @param _x The value to evaluate the CDF at, as an 18-decimal fixed-point
    /// number.
    /// @param _mu The mean of the distribution, as an 18-decimal fixed-point
    /// number.
    /// @param _sigma The standard deviation of the distribution, as an
    /// 18-decimal fixed-point number.
    function testGas_cdf_fuzz(int256 _x, int256 _mu, uint256 _sigma) public pure {
        _x = bound(_x, -1e23, 1e23);
        _mu = bound(_mu, -1e20, 1e20);
        _sigma = bound(_sigma, 1, 1e19);
        Gaussian.cdf({ _x: _x, _mu: _mu, _sigma: _sigma });
    }

    // -------------------------------------------------------------------------
    // {GaussianYul}
    // -------------------------------------------------------------------------

    /// @notice Tests the gas cost of {GaussianYul.cdf} with hard-coded
    /// parameters.
    function testGas_cdf_yul() public pure {
        GaussianYul.cdf({ _x: 1e18, _mu: 0, _sigma: 1e18 });
    }

    /// @notice Tests the gas cost of {GaussianYul.cdf} with fuzzed inputs with
    /// the following bounds: `_x` ∈ [-1e23, 1e23], `_mu` ∈ [-1e20, 1e20],
    /// `_sigma` ∈ (0, 1e19].
    /// @param _x The value to evaluate the CDF at, as an 18-decimal fixed-point
    /// number.
    /// @param _mu The mean of the distribution, as an 18-decimal fixed-point
    /// number.
    /// @param _sigma The standard deviation of the distribution, as an
    /// 18-decimal fixed-point number.
    function testGas_cdf_yul_fuzz(int256 _x, int256 _mu, uint256 _sigma) public pure {
        _x = bound(_x, -1e23, 1e23);
        _mu = bound(_mu, -1e20, 1e20);
        _sigma = bound(_sigma, 1, 1e19);
        GaussianYul.cdf({ _x: _x, _mu: _mu, _sigma: _sigma });
    }
}
