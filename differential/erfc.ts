import { ethers } from 'ethers'

// from errcw/gaussian
var erfc = function(x) {
  var z = Math.abs(x);
  var t = 1 / (1 + z / 2);
  var r = t * Math.exp(-z * z - 1.26551223 + t * (1.00002368 +
          t * (0.37409196 + t * (0.09678418 + t * (-0.18628806 +
          t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 +
          t * (-0.82215223 + t * 0.17087277)))))))))
  return x >= 0 ? r : 2 - r;
};

const x = Number(process.argv[2]) / 10 ** 18;

console.log(ethers.utils.defaultAbiCoder.encode(["uint256"], [Math.round(erfc(x) * 10 ** 18).toString()]));