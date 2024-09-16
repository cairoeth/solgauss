from mpmath import floor, sqrt, erfinv
import sys


if __name__ == "__main__":
    x = int(sys.argv[1]) / 10**18
    u = int(sys.argv[2]) / 10**18
    o = int(sys.argv[3]) / 10**18

    try:
        _ppf = int(floor((u-o*sqrt(2)*erfinv(1-(2*x)))*10**18))
    except:
        _ppf = 0
    if _ppf < 0:
        # For negative values, use two's complement representation
        _ppf = (1 << 256) + _ppf
    print(f'0x{_ppf:064x}')
