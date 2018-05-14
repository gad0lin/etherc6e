const web3 = require('web3')

for (let i=0; i < 1000000000; i++) {
	let hex =  web3.utils.toHex(i);
	let hash = web3.utils.sha3(hex, {encoding: 'hex'});
  	// console.log(hex + ":" + hash);
	if (hash === "0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365") {
		console.log("Found match " + i)
		break;
	}

}
