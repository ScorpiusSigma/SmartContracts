//SPDX-License-Identifier: Unlicense.
pragma solidity ^0.8.10;

import "./NFT.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTFactory is Ownable, ReentrancyGuard {
    mapping(address => NFT[]) contracts; // Maps sender to contract address they created.
    uint256 public creationPrice = 5000000000000000; // In Ethers 0.005ETH.

    // To count the number of contracts created.
    using Counters for Counters.Counter;
    Counters.Counter private _creationCount;

    event Create(address sender, string contractName, string contractSymbol);
    function create(
        string memory contractName,
        string memory contractSymbol,
        uint256 nftQuantity
    ) 
        public
        payable
    {
        require(msg.value >= creationPrice, "Not enough ETH!");
        // Instantiate NFT contract.
        NFT nftContract = new NFT(msg.sender, contractName, contractSymbol, nftQuantity);
        contracts[msg.sender].push(nftContract); 

        _creationCount.increment();
        emit Create(msg.sender, contractName, contractSymbol);
    }

    // function getAddress() public view returns (NFT[]) {
    //     return contracts[msg.sender];
    // }

    function setPrice(uint256 _price) public onlyOwner {
        creationPrice = _price;
    }

    function withdraw() public onlyOwner nonReentrant{
        (bool success, bytes memory data) = msg
                                            .sender
                                            .call{
                                                value: address(this).balance
                                            }("");

        require(success, "Withdrawal Failed!");
    }

}