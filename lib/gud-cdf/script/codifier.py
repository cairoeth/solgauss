import json
from typing import Any
from mpmath import mp, mpf, floor, fabs, erf, sqrt
from remez.rational import Rational
import sys

mp.dps = 60
mp.pretty = True

WAD = 10**18
POW = 96
X128_ONE = 1 << POW


def le_func(x):
    return erf(x / sqrt(2))


def to_int(x: str | mpf, one: int) -> int:
    if isinstance(x, str):
        x = mpf(x)

    assert not isinstance(x, str)

    z = fabs(x)

    whole = int(floor(z * one))
    assert whole < (1 << 255)

    return whole if x >= 0 else (1 << 256) - whole


def to_x128(x: str | mpf) -> int:
    return to_int(x, X128_ONE)


def to_wad(x: str | mpf) -> int:
    return to_int(x, WAD)


def make_poly(coeffs: list[int], var_in: str, var_out: str) -> str:
    assert coeffs[0] == X128_ONE, f'Other coeff: {coeffs[0]}'
    s = ''
    if len(coeffs) > 1:
        s += f'let {var_out} := add({var_in}, {hex(coeffs[1])})\n'
    else:
        s += f'let {var_out} := {var_in}\n'

    for c in coeffs[2:]:
        # if c == 0:
        #     s += f'{var_out} := sar(128, mul({var_out}, {var_in})), {hex(c)}\n'
        # else:
        s += f'{var_out} := add(sar(POW, mul({var_out}, {var_in})), {hex(c)})\n'
    return s


def normalize(coeffs: list[mpf]) -> tuple[list[mpf], mpf]:
    x = coeffs[0]
    return [c / x for c in coeffs], x


class Func:
    def __init__(self, start: mpf, end: mpf, inner_fn: Rational, err: mpf) -> None:
        self.start = start
        self.end = end
        self.inner_fn = inner_fn
        self.err = err

    @classmethod
    def from_json(cls, obj: dict[str, Any]) -> 'Func':
        return cls(
            mpf(obj['start']),
            mpf(obj['end']),
            Rational(
                list(map(mpf, obj['fn']['ps'])),
                list(map(mpf, obj['fn']['qs'])),
            ),
            mpf(obj['err'])
        )

    def codify(self, var_in: str, var_out: str) -> str:
        s = ''
        ps, p = normalize(self.inner_fn.ps.copy())
        qs, q = normalize(self.inner_fn.qs.copy())

        first = p / q

        s += make_poly(list(map(to_x128, ps)), var_in, 'num')
        s += make_poly(list(map(to_x128, qs)), var_in, 'denom')
        s += f'{var_out} := sdiv(mul({hex(to_wad(first))}, num), denom)\n'

        return s


if_count = []


def codify_ranges(
    var_in: str,
    var_out: str,
    fns: list[Func],
    has_end: bool,
    ifs: int = 0
) -> str:
    s = ''
    total_len = len(fns) + has_end
    if total_len <= 3:
        for i, fn in enumerate(fns, start=1):
            needs_if = i < total_len
            if_count.append(ifs + i + needs_if - 1)
            if needs_if:
                s += f'if lt({var_in}, {hex(to_x128(fn.end))}) {{\n'  # }}
            s += fn.codify(var_in, var_out)
            s += f'break\n'
            if needs_if:
                s += '}\n'
        if has_end:
            if_count.append(ifs + len(fns))
            s += f'{var_out} := 0\n'
            s += f'break\n'
        return s

    half = total_len // 2
    h1 = fns[:half]
    h2 = fns[half:]
    s += f'if lt({var_in}, {hex(to_x128(h2[0].start))}) {{\n'  # }}
    s += codify_ranges(var_in, var_out, h1, False, ifs=ifs+1)
    s += '}\n'
    s += codify_ranges(var_in, var_out, h2, has_end, ifs=ifs+1)

    return s


path = 'result.json' if len(sys.argv) < 2 else sys.argv[1]

# ifs: [3, 4, 4, 3, 3, 3, 4, 4, 3, 3] (34)
# ifs: [3, 3, 3, 4, 4, 3, 3, 3, 4, 4] (34)

with open(path, 'r') as f:
    funcs = list(map(Func.from_json, json.load(f)))


delta = min(
    fn.end - fn.start
    for fn in funcs
)


print(codify_ranges('z', 'y', funcs, True))
