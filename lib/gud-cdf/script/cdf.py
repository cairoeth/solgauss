from mpmath import erf, mp, mpf, fabs, sqrt
from codifier import Func
import sys
import json

mp.dps = 60
mp.pretty = True


def cdf(x):
    return (mpf(1) + erf(x / sqrt(2))) / mpf(2)


print(cdf(mpf('1.2')))

path = 'result.json' if len(sys.argv) < 2 else sys.argv[1]

with open(path, 'r') as f:
    funcs = list(map(Func.from_json, json.load(f)))


def approx_erf(x: mpf) -> mpf:
    z = fabs(x)
    for fn in funcs:
        if z <= fn.end:
            y = fn.inner_fn(z)
            break
    y = mpf(1)
    if x < 0:
        y = -y
    return y


def approx_cdf(x: mpf) -> mpf:
    return (mpf(1) + approx_erf(x)) / mpf(2)


xs = [
    mpf('-6.121045594144430842'),
    mpf('-6.019023504161353321'),
    mpf('-6.219761545359106298')
]

for x in xs:
    y = cdf(x)
    approx_y = approx_cdf(x)
    err = fabs(approx_y - y)
    print(f'cdf({float(x):.8f}) = {float(y):.8f}; {
          float(approx_y):.8f} [{err}]')
