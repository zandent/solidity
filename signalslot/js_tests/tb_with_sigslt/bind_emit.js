/* eslint-disable */

const { Conflux } = require('js-conflux-sdk');

const PRIVATE_KEY_A = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const PRIVATE_KEY_B = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde0';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 100,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000
  // ================================ Contract ================================
  // create contract instance
  const contractB = cfx.Contract({
    abi: require('./contract/B-abi.json'),
    // code is unnecessary
    address: '0x817aac2df68097e4f6991beb34d6146ad7497039',
  });
  // create contract instance
  const contractA = cfx.Contract({
    abi: require('./contract/A-abi.json'),
    // code is unnecessary
    address: '0x89dd68bbca1a76a1c86570361879301a8e131e96',
  });
  //await cfx.getCode(contractB.address);
  await contractB.bindfunc(contractA.address);
  //await cfx.getCode(contractA.address);
  await contractA.emitfunc([0x11,0x22,0x33]);
}

main().catch(e => console.error(e));
