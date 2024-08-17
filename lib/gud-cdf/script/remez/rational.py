from typing import Callable
from mpmath import mpf, polyval, findroot, fabs
from .utils import solve_lin, get_signs, full_range, find_extremas, select_extremas
from .poly import show_poly


class Rational:
    ps: list[mpf]
    qs: list[mpf]

    def __init__(self, ps: list[mpf], qs: list[mpf]) -> None:
        self.ps = ps
        self.qs = qs

    def p(self, x: mpf) -> mpf:
        return polyval(self.ps, x)

    def q(self, x: mpf) -> mpf:
        return polyval(self.qs, x)

    def show(self, d: int = 20) -> str:
        return f'\\frac{{{show_poly(self.ps[::-1], d=d)}}}{{{show_poly(self.qs[::-1], d=d)}}}'

    def __call__(self, x: mpf) -> mpf:
        return self.p(x) / self.q(x)


def _solve_with_assumed_error(
    n: int, m: int,
    guessed_err: mpf,
    ref: list[mpf],
    ys: list[mpf]
) -> tuple[list[mpf], list[mpf], mpf]:
    signs = get_signs(len(ref))

    matrix = [
        [
            xi ** j
            for j in range(0, n + 1)

        ] + [
            (s * guessed_err - yi) * xi ** j
            for j in range(1, m + 1)
        ] + [s]
        for xi, yi, s in zip(ref, ys, signs)
    ]

    params = solve_lin(matrix, ys)

    ps = params[:n+1]
    qs = params[n+1:n+1+m]
    solved_err = params[-1]

    return ps, qs, solved_err


def _solve_rational(
    n: int, m: int,
    ref: list[mpf],
    ys: list[mpf]
) -> tuple[list[mpf], list[mpf], mpf]:
    def error_error(guessed_err: mpf) -> mpf:
        _, _, err = _solve_with_assumed_error(n, m, guessed_err, ref, ys)
        return err - guessed_err

    found_err = findroot(error_error, mpf(0))
    return _solve_with_assumed_error(n, m, found_err, ref, ys)


def rational_remez(
    n: int,
    m: int,
    start: mpf,
    end: mpf,
    f: Callable[[mpf], mpf],
    tol: mpf,
    rounds: int = 10,
    sample_scale: int = 80,
    verbose: bool = False
) -> tuple[Rational, mpf]:
    assert rounds >= 1
    assert start < end

    # From [Remco's Approximation blog post](https://xn--2-umb.com/22/approximation/)

    # width
    w = n + m + 2

    ref = full_range(start, end, w)

    peak_err = None
    approx = Rational([], [])

    for _ in range(rounds):
        ys = list(map(f, ref))

        ps, qs, _ = _solve_rational(n, m, ref, ys)
        qs = [mpf(1)] + qs

        approx = Rational(ps[::-1], qs[::-1])

        def err(x):
            return f(x) - approx(x)

        extremas = find_extremas(err, start, end, tol, w * sample_scale)
        errors = list(map(err, extremas))

        ref = select_extremas(extremas, errors, w)

        def rel_err(x):
            return fabs(mpf(1) - f(x) / approx(x))

        new_peak_err = max(map(rel_err, ref))

        if new_peak_err == peak_err:
            break
        peak_err = new_peak_err

        if verbose:
            print(approx.show())
            print(f'peak_err: {peak_err}')

    assert peak_err is not None

    return approx, peak_err
