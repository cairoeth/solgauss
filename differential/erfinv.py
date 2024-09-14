from mpmath import erfinv, mpf, floor
import sys


if __name__ == "__main__":
    x = mpf(sys.argv[1]) / 10**18
    try:
        _erfinv = int(floor(erfinv(x) * 10**18))
    except:
        _erfinv = 0
    if _erfinv < 0:
        # For negative values, use two's complement representation
        _erfinv = (1 << 256) + _erfinv
    print(f'0x{_erfinv:064x}')