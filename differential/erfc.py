from mpmath import erf, erfc, mpf, floor
import sys


def erfc(x):
    return mpf(1) - erf(x)


if __name__ == "__main__":
    x = mpf(sys.argv[1]) / 10**18

    _erfc = int(floor(erfc(x) * 10**18))
    print(f'0x{_erfc:064x}')
