from typing import Callable
from mpmath import mpf, sign, diff, fabs


def muls(x: mpf, v: list[mpf]) -> list[mpf]:
    return [u * x for u in v]


def mulv(a: list[mpf], b: list[mpf]) -> list[mpf]:
    assert len(a) == len(b)
    return [x * y for x, y in zip(a, b)]


def addv(a: list[mpf], b: list[mpf]) -> list[mpf]:
    assert len(a) == len(b)
    return [x + y for x, y in zip(a, b)]


def subv(a: list[mpf], b: list[mpf]) -> list[mpf]:
    assert len(a) == len(b)
    return [x - y for x, y in zip(a, b)]


def solve_lin(matrix: list[list[mpf]], out: list[mpf]) -> list[mpf]:
    # O(n^3) algo but who cares, it works
    # Transforms matrix into identity matrix via valid operations on the individual rows.
    # - Can multiply any row by a factor
    # - Can add/subtract rows to each other

    out = out.copy()

    n = len(matrix)
    assert n > 0
    assert n == len(out)
    assert all(len(row) == n for row in matrix)

    for i in range(n):
        row = matrix[i]

        # Number we want to equal 1 in our end-matrix
        x = row[i]

        # Multiply row by inverse to get the target cell to 1
        f = mpf(1) / x
        out[i] *= f
        matrix[i] = row = muls(f, row)

        # Subtract our row from all others to get their values in the target column to be 0
        for j, alt_row in enumerate(matrix):
            if i == j:
                continue
            u = alt_row[i]
            matrix[j] = subv(alt_row, muls(u, row))
            out[j] = out[j] - u * out[i]

    return out


def find_extrema(f: Callable[[mpf], mpf], a: mpf, b: mpf, tol: mpf) -> mpf:
    sa = sign(diff(f, a))
    sb = sign(diff(f, b))
    assert sa != sb and sa != 0 and sb != 0
    mid = (a + b) / 2

    while fabs(a - b) > tol:
        ma = sign(diff(f, mid))

        if ma == 0:
            return mid
        if ma == sa:
            a = mid
        else:
            b = mid

        sa = sign(diff(f, a))
        sb = sign(diff(f, b))
        mid = (a + b) / 2

    return mid


def full_range(start: mpf, end: mpf, count: int) -> list[mpf]:
    assert start < end
    return [
        start + (end - start) * i / (count - 1)
        for i in range(count)
    ]


def find_extremas(f: Callable[[mpf], mpf], start: mpf, end: mpf, tol: mpf, samples: int) -> list[mpf]:
    sample_xs = full_range(start, end, samples)
    signs = [
        sign(diff(f, x))
        for x in sample_xs
    ]
    return [start] + [
        find_extrema(f, a, b, tol)
        for a, sa, b, sb in zip(sample_xs[:-1], signs[:-1], sample_xs[1:], signs[1:])
        if sa != sb
    ] + [end]


class InsufficientExtremaError(Exception):
    pass


def select_extremas(xs: list[mpf], errors: list[mpf], n: int) -> list[mpf]:
    assert len(xs) == len(errors)

    new_xs = []
    new_errs = []

    for x, err in zip(xs, errors):
        last_err = None
        last_sign = None
        if new_errs:
            last_err = new_errs[-1]
            last_sign = sign(last_err)

        if sign(err) != last_sign:
            new_xs.append(x)
            new_errs.append(err)
            continue

        assert last_err is not None
        if fabs(err) > fabs(last_err):
            new_xs[-1] = x
            new_errs[-1] = err

    # for x, err in zip(new_xs, new_errs):
    #     print(f'{float(x):.4f}   {float(err):.4f}')

    signs = list(map(sign, new_errs))
    assert all(a != b for a, b in zip(signs[:-1], signs[1:]))
    # print(f'new_errs: {new_errs}')

    if len(new_xs) < n:
        raise InsufficientExtremaError(
            f'Insufficient values ({len(new_xs)} < {n})')

    offset = max(
        range(len(xs) - n + 1),
        key=lambda o: sum(map(fabs, new_errs[o:]))
    )

    return new_xs[offset:]


def get_signs(n: int) -> list[int]:
    return [(1, -1)[i % 2] for i in range(n)]
