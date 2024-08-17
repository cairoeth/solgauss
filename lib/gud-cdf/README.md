# Gud CDF

This repo contains code to generate as well as a specific instance of a normal distribution CDF
(cumulative distribution function) implemented in Solidity.

The `CDF.cdf` function operates on WAD numbers (fixed point numbers with scale 10^18) and achieves
8-digit accuracy (max relative error $|1 - \frac{f(x)}{f'(x)}| \lt 10^{-8}$) while being 8x more gas
efficient than comparable libraries like [solstat's Gaussian](https://github.com/primitivefinance/solstat/blob/main/src/Gaussian.sol).

## Project Setup

1. Setup virtual environment: `uv venv .venv`
2. Install mpmath: `uv pip install mpmath`
3. Run tests: `forge t -vvv --ffi`

## Methodology

The core objective was to approximate either $\text{erf} (z)$ or $\text{erfc} (z)$ (which is just
$1 - \text{erf} (z) $). Libraries like solstat or [errcw/gaussian](https://github.com/errcw/gaussian/blob/master/lib/gaussian.js) do this by finding a polynomial $p$ such that $e^p(x)$ approximates the desired error function. This approach is sub-optimal in the EVM as $e^x$ is itself an approximation.

I therefore opted to approximate the error function itself using a rational approximation, finding
tow polynomials $p$ and $q$ such that $\frac{p(x)}{q(x)}$ give the desired accuracy. This was done
via the remez rational algorithm as detailed in [Remco's amazing blog post on approximation
theory](https://xn--2-umb.com/22/approximation/).

This algorithm was implemented in Python using the arbitrary precision library `mpmath`:
[`script/remez/rational.py`](./script/remez/rational.py).

Initially despite correct implementation the algorithm did not work as I was attempting to
approximate to large of a range. I then discovered that not only did the algorithm work well once
you started applying it to smaller ranges, you needed a smaller function to achieve the same
precision. This is how I came to implementing the final algorithm in
[`script/bounds.py`](./script/bounds.py). It takes a set target accuracy and parameter size and
continuously bisects the target range until the desired accuracy is achieved, it then stores the
result in a json file.

The last step of the process is the [`codifier`](./script/codifier.py) which takes the list of
functions and produces solidity assembly code to be inserted into the implementation.

While the code was applied to the Normal Distribution CDF with very simple tweaks it could be
applied to other functions.

### Optimizations

**Base-2 Fixed Point Numbers**

For the sake of accuracy and getting access to cheaper "division" in the form of bit-shifting
opcodes the input to the function is converted to a base-2 fixed point number when computing
$-\frac{x - \mu}{\sigma}$. The number is converted back to WAD when the result of the two
polynomials $p$ and $q$ are divided.


**Arithmetic Overflow/Underflow Checks**

Thanks to the bounds of the polynomial and the range checks the core erfc function cannot overflow.
However when $x$, $\mu$ and $\sigma$ are first accepted as inputs and $-\frac{x - \mu}{\sigma}$ is
computed the overflow checks are branchlessly combined into just one check.
