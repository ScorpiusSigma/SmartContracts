const { compileProject } = require("@ethereum-waffle/compiler");

const main = async () => {
  const [owner, signer1, signer2] = await hre.ethers.getSigners();

  const NFTFactoryContratFactory = await hre.ethers.getContractFactory(
    "NFTFactory"
  );
  const NFTFactoryContract = await NFTFactoryContratFactory.deploy();
  await NFTFactoryContract.deployed();
  console.log("Contract deployed to:", NFTFactoryContract.address);

  // Creation of NFT Contract
  const NFT1 = await NFTFactoryContract.create("MintedByte", "MB");
  const NFT2 = await NFTFactoryContract.connect(signer1).create(
    "Justin Leng",
    "JL"
  );

  console.log(await NFTFactoryContract.getAddress());
  console.log(await NFTFactoryContract.connect(signer1).getAddress());
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(0);
  }
};

runMain();
