const main = async () => {
  const [owner, signer1, signer2] = await hre.ethers.getSigners();

  const NFTFactoryContratFactory = await hre.ethers.getContractFactory(
    "NFTFactory"
  );
  const NFTFactoryContract = await NFTFactoryContratFactory.deploy();
  await NFTFactoryContract.deployed();
  console.log("Contract deployed to:", NFTFactoryContract.address);

  // Creation of NFT Contract
  const NFT1 = await NFTFactoryContract.create(
    {
      owner: "0x0000000000000000000000000000000000000000",
      mintPrice: ethers.utils.parseEther("0.05"),
      maxMint: 1,
      contractName: "MintedByte",
      contractSymbol: "MB",
      maxSupply: 10,
      isMintEnabled: true,
      baseURI: "ipfs://",
    },
    {
      value: ethers.utils.parseEther("0.05"), // Pays Ether
    }
  );

  const NFT2 = await NFTFactoryContract.connect(signer1).create(
    {
      owner: "0x0000000000000000000000000000000000000000",
      mintPrice: ethers.utils.parseEther("2"),
      maxMint: 1,
      contractName: "Justin Leng",
      contractSymbol: "JL",
      maxSupply: 10,
      isMintEnabled: false,
      baseURI: "ipfs://",
    },
    {
      value: ethers.utils.parseEther("1.0"),
    }
  );

  const NFT3 = await NFTFactoryContract.connect(signer1).create(
    {
      owner: "0x0000000000000000000000000000000000000000",
      mintPrice: ethers.utils.parseEther("5"),
      maxMint: 1,
      contractName: "Justin Leng",
      contractSymbol: "JL",
      maxSupply: 10,
      isMintEnabled: true,
      baseURI: "ipfs://",
    },
    {
      value: ethers.utils.parseEther("1.0"),
    }
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
