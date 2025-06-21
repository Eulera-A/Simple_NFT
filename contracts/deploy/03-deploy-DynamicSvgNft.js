const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat.config");
const { verify } = require("../utils/verify");
// since we are deploying in on 100% block chain this time,
// make sure to update the chain address that we will deploy
// it on to in the helper.configs!!!

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  // call the contract , fill in constructor
  if (developmentChains.includes.network.name) {
    const EthUsdAggregator = await ethers.getContract("MockAggregatorV3");
    EthUsdPriceFeedAddress = EthUsdAggregator.address;
  } else {
    EthUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
  }
  const lowSVG = await fs.readFileSync("./image/dynamicNFT/frown.svg", {
    encoding: "uft8",
  });
  const highSVG = await fs.readFileSync("./image/dynamicNFT/happy.svg", {
    encoding: "uft8",
  });
  // deploy contract:
  args = [EthUsdPriceFeedAddress, lowSVG, highSVG];
  const dynamicSvgNft = await deploy("DynamicSvgNft", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  if (!developmentChains.includes(network.name)) && process.env.ETHERSCAN_API_KEY {
    console.log("verifying...");
    await verify(dynamicSvgNft.address,args);
  };
};
module.exports.tags = ["all","dynamicsvg","main"];
