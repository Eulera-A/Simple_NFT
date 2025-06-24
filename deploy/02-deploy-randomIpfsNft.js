const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat.config");
const { verify } = require("../utils/verify");
const { networkConfig } = require("../helper-hardhat-config");
const {
  storeImages,
  storeTokenUriMetadata,
} = require("../utils/uploadToPinata");
const imagesLocation = "../utils/imgaes/randomNft";

const metadataTemplate = {
  name: "",
  description: "",
  image: ("".attributes = [
    {
      trait_type: "Cuteness",
      value: 100,
    },
  ]),
};

let tokenUris = ["", "", ""]; // input pinata's uris

const FUND_AMOUNT = "10000000000";

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const { chainId } = network.config.chainId;

  if (process.env.UPLOAD_TO_PINATA == "true ") {
    tokenUris = await handleTokenUris();
  }

  let vrfCoordinatorV2Address, subscriptionId;

  if (developmentChains.includes(network.name)) {
    const vrfCoordinatorV2Mock = await ethers.getContract(
      "VRFCoordinatorV2Mock"
    );
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
    const tx = await vrfCoordinatorV2Mock.createSubscription();
    const txReceipt = await tx.wait();
    subscriptionId = txReceipt.events[0].args.subId;
    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId);
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
    subscriptionId = networkConfig[chainId].subscriptionId;
  }

  log("--------------------------------------------------------");
  await storeImages(imagesLocation);
  const arguments = [
    vrfCoordinatorV2Address,
    subscriptionId, // the vrf subscription id you have from chainink!
    networkConfig[chainId]["gasLane"],
    networkConfig[chainId]["mintFee"],
    networkConfig[chainId]["callbackGasLimit"],
    tokenUris,
  ];
  const randomIpfsNft = await deploy("RandomIpfsNft", {
    from: deployer,
    args: arguments,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,

    // 21:58:19
  });

  log("---------------------------");

  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("Verifying...");
    await verify(randomIpfsNft.address, arguments);
  }
};

// helpers outside of the main stuff!

async function handleTokenUris() {
  tokenUris = [];
  //store image in ipfs
  //and store metadata in ipfs
  const { responses: imageUploadResponses, files } =
    await storeImages(imagesLocation);

  for (imageUploadResponseIndex in imageUploadResponses) {
    // create meta data and upload
    let tokenUriMetadata = { ...metadataTemplate };
    tokenUriMetadata.name = files[imageUploadResponseIndex].replace(".png", "");
    tokenUriMetadata.description = `An adorable ${tokenUriMetadata.name} pup!`;
    tokenUriMetadata.image = `ipsf://${imageUploadResponses[imageUploadResponseIndex].IpsfHash}`;
    console.log(`Uploading ${tokenUriMetadata.name}...`);
    // call function to upload metadata in uploadToPinata.js
    const metadataUploadResponse =
      await storeTokenUriMetadata(tokenUriMetadata);
    tokenUris.push(`ipfs://${metadataUploadResponse}.IpfsHash`);
  }

  return tokenUris;
}

module.exports.tags = ["all", "randomipfs", "main"];
// adding these tags, so when you deploy, it deploys this script
// yarn hardhat deploy --tags randomipfs, mocks, etc...

// youtube: 21:41:10
