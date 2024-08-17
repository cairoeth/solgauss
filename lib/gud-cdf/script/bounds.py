from typing import Callable
from mpmath import mp, mpf, erf, erfinv, sqrt
from remez.rational import rational_remez, Rational
from remez.utils import InsufficientExtremaError
import sys
import json

mp.dps = 60
mp.pretty = True

TOLERANCE = mpf('1.0e-30')
TARGET_ERROR = mpf('1.0e-8')

N = 4
M = 4
START = mpf(0)
END = erfinv(mpf('1.0') - mpf('1.0e-18'))
DEFAULT_ROUNDS = 20


def erfc(x):
    return mpf(1) - erf(x / sqrt(2))


def safe_run_remez(start: mpf, end: mpf, fn: Callable[[mpf], mpf]) -> tuple[Rational, None | mpf]:
    try:
        return rational_remez(
            N, M,
            start, end,
            fn,
            TOLERANCE,
            rounds=DEFAULT_ROUNDS
        )
    except InsufficientExtremaError:
        print(f'  (extrema fail)')
        return Rational([], []), None


def build_tree_fn(start: mpf, end: mpf, fn: Callable[[mpf], mpf]) -> list[tuple[mpf, mpf, Rational, mpf]]:
    print(f'Trying [{float(start):.8f}; {float(end):.8f}]')
    res_fn, peak_err = safe_run_remez(start, end, fn)
    if peak_err is None or peak_err > TARGET_ERROR:
        print(f'  failed, peak_err: {peak_err}')
        mid = (end + start) / 2
        return build_tree_fn(start, mid, fn) + build_tree_fn(mid, end, fn)
    print(f'  success, peak_err: {peak_err}')

    return [(start, end, res_fn, peak_err)]


funcs = build_tree_fn(START, END, erfc)

print(f'len(funcs): {len(funcs)}')
print(f'done')

path = 'result.json' if len(sys.argv) < 2 else sys.argv[1]


print(f'saving to {path}')
with open(path, 'w') as f:
    json.dump([
        {
            'start': str(start),
            'end': str(end),
            'fn': {
                'ps': list(map(str, fn.ps)),
                'qs': list(map(str, fn.qs)),
            },
            'err': str(err)
        }
        for start, end, fn, err in funcs
    ], f, indent=2)
