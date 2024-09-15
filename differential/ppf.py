from mpmath import floor, sqrt
import sys
from scipy.special import erfcinv, erfinv


if __name__ == "__main__":
    x = int(sys.argv[1]) / 10**18
    u = int(sys.argv[2]) / 10**18
    o = int(sys.argv[3]) / 10**18

    _ppf = int(floor((u-o*sqrt(2)*erfcinv(2*x))*10**18))
    print(f'0x{_ppf:064x}')
