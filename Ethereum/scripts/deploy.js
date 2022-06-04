// 0x00Db65AD756648A094316187771eD8573aA55628

const main = async () => {
  const [owner, signer1, signer2] = await hre.ethers.getSigners();

  const NFTFactoryContratFactory = await hre.ethers.getContractFactory(
    "NFTFactory"
  );
  const NFTFactoryContract = await NFTFactoryContratFactory.deploy();
  await NFTFactoryContract.deployed();
  console.log("Contract deployed to:", NFTFactoryContract.address);
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
