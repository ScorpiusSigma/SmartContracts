//SPDX-License-Identifier: Unlicense.
pragma solidity ^0.8.10;

import "./NFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTFactory is Ownable {
    event Create(address sender, string contractName, string contractSymbol);

    // Maps sender to contract address they created.
    mapping(address => NFT[]) contracts;
    uint256 public creationPrice = 0.05 ether; // In Ethers 0.005ETH.
    bool public isCreationEnabled = true;
        
    // To count the number of contracts created.
    using Counters for Counters.Counter;
    Counters.Counter private _creationCount;

    // Public
    /** Factory method for NFT Creation
     */
    function create(NFT.Init memory config) public payable {
        require(isCreationEnabled, "Creation of contract paused!");
        require(msg.value >= creationPrice, "Insufficient ETH!");

        // Set owner in config to contract caller
        config.owner = msg.sender;

        // Instantiate NFT contract.
        NFT nftContract = new NFT(config);
        contracts[msg.sender].push(nftContract); 

        _creationCount.increment();
        emit Create(msg.sender, config.contractName, config.contractSymbol);
    }

    function getAddress() public view returns (NFT[] memory) {
        return contracts[msg.sender];
    }

    // Owner
    function setPrice(uint256 price) external onlyOwner {
        creationPrice = price;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner()
                            .call{
                                value: address(this).balance
                            }("");

        require(success, "Withdrawal Failed!");
    }

    function toggleIsCreationEnabled() external onlyOwner {
        isCreationEnabled = !isCreationEnabled;
    }
}