from mpmath import floor, erfinv
import sys


if __name__ == "__main__":
    x = int(sys.argv[1]) / 10**18
    try:
        _erfcinv = int(floor(erfinv(1 - x) * 10**18))
    except:
        _erfcinv = 0
    if _erfcinv < 0:
        # For negative values, use two's complement representation
        _erfcinv = (1 << 256) + _erfcinv
    print(f'0x{_erfcinv:064x}')
