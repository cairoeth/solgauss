from mpmath import erf, mp, mpf, fabs, floor, sqrt
import sys

mp.dps = 60
mp.pretty = True


def cdf(x):
    return (mpf(1) + erf(x / sqrt(2))) / mpf(2)


x = mpf(sys.argv[1])
y = cdf(x)

as_int = int(floor(fabs(y) * 10**18))

print(f'0x{as_int:064x}')
