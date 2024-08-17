from mpmath import mpf, fabs, floor, sqrt
import sys
from erfc import erfc


def cdf(x, u, o):
    z = -(x-u) / (o * sqrt(2))
    _cdf = erfc(z) / mpf(2)
    return _cdf


if __name__ == "__main__":
    x = mpf(sys.argv[1]) / 10**18
    u = mpf(sys.argv[2]) / 10**18
    o = mpf(sys.argv[3]) / 10**18

    _cdf = int(floor(fabs(cdf(x, u, o)) * 10**18))
    print(f'0x{_cdf:064x}')
