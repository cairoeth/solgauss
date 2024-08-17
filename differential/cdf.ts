import { ethers } from 'ethers'
import gaussian from 'gaussian'

const x = Number(process.argv[2] ? process.argv[2] : 0);
const mean = Number(process.argv[3] ? process.argv[3] : 0);
const std = Number(process.argv[4] ? process.argv[4] : 1);

var distribution = gaussian(mean / 10 ** 18, (std / 10 ** 18) ** 2);
const cdf = distribution.cdf(x / 10 ** 18);
console.log(ethers.utils.defaultAbiCoder.encode(["uint256"], [Math.round(cdf * 10 ** 18).toString()]));