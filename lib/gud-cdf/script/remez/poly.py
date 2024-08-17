from typing import Callable
from mpmath import mpf, diff, polyval, fabs, sign, exp
from .utils import find_extrema, solve_lin


def show_poly(coeffs: list[mpf], d: int = 4) -> str:
    l = [
        f'{"+" if c > 0 else ""}{float(c):.{d}f}\\cdot x^{{{i}}}'
        for i, c in enumerate(coeffs)
        if c
    ]

    return ' '.join(l)


def poly_remez(
    n: int,
    start: mpf,
    end: mpf,
    f: Callable[[mpf], mpf],
    tol: mpf,
    rounds: int = 10,
    sample_multiple: int = 30,
):
    assert start < end
    # dumb slicing
    w = n + 2
    ref = [
        start + (end - start) * i / (w + 1)
        for i in range(1, w + 1)
    ]

    signs = [(-1, 1)[i % 2] for i in range(w)]

    for _ in range(rounds):
        ys = list(map(f, ref))
        matrix = [
            [
                x**i
                for i in range(n + 1)
            ] + [s]
            for x, s in zip(ref, signs)
        ]

        params = solve_lin(matrix, ys)
        ps = params[:-1]
        show_poly(ps, d=20)

        def approx(x):
            return polyval(ps[::-1], x)

        def err(x):
            return f(x) - approx(x)

        total_samples = w * sample_multiple

        sample_xs = [
            start + (end - start) * i / (total_samples - 1)
            for i in range(total_samples)
        ]
        dirs = [
            sign(diff(err, x))
            for x in sample_xs
        ]

        extrema = [start] + [
            find_extrema(err, a, b, tol)
            for a, sa, b, sb in zip(sample_xs[:-1], dirs[:-1], sample_xs[1:], dirs[1:])
            if sa != sb
        ] + [end]

        peak_err = max([fabs(err(x)) for x in extrema])
        print(f'peak_err: {peak_err}')

        for a, b in zip(extrema[:-1], extrema[1:]):
            assert sign(err(a)) != sign(err(b))

        assert len(extrema) == w
        ref = extrema
