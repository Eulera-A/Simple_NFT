First: write the solidity contracts:
    > if need to import super class contract -> do import
    > Constructor, + super class Constructor (if apply)
    > your main functions, in execution order


Second:
Deploy scripts
> choose the network your contract is deploying on
> for all big "class-like" functions, create a separate json script, export the function using module.export,
> and then import in the main deploy script as a object
e.x. function verify() in the verify.js,
    and in deploy: import from ../utils/verfiy.js


> the key deploy lines:

const arguments = [];
  const sol-contract = await deploy("SOLIDITY-CONTRACT-NAME", {
    from: deployer,
    args: arguments,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("Verifying...");
    await verify(basicNft.address, arguments);
  }


module.exports.tags = ["all", "basicnft", "main"];


Second: Tests


!!! notes:
using abi.encodePacked() converts input to binary abi in packed version,
where saves lot of gas compared to non-packed version.
or , use bytes(...), also return packed binary abi


call functions:

> call: call functions to change state of the blockchain
> static call: like pure/view types, just retrieve info,
no state change

ex:
function withdraw(address recentWinner) public {

  (bool success,) 
  = 
  recentWinner.call{value: address(this).balance} ("this is the data section you send onto blockcahin, includes any function calls!!!")
}


3. Mocks vs chain net:
Mocks version of the contract deployed on local host for testing purposes.
VRF mock contract: to generate random variable on local host
MockV3aggregator contract mocks the real-time priceFeed to get conversion rates on your local host

testNet or mainNet:
you need the VRF to generate randomness type variable
you need the priceFeed contracts to get conversion rate