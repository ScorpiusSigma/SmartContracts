//SPDX-License-Identifier: Unlicense.
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFT is ERC721URIStorage, Ownable, ReentrancyGuard {
    address public contractOwner;
    bool public allowMint;
    uint256 public mintPrice = 5000000000000000; // In Ethers 0.005ETH.
    uint public nftLimit;
    mapping(address => bool) whiteList;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(
        address owner,
        string memory contractName,
        string memory contractSymbol,
        uint nftQuantity
    )
        ERC721(
            contractName,
            contractSymbol
        ) 
    {
        contractOwner = owner;
        nftLimit = nftQuantity;

        // Let token ID count start from 1.
        _tokenIds.increment();
    }

    function mint() public payable {
        if (_tokenIds >= nftLimit) {
            revert("NFT is sold out.");
        }

        require(msg.value >= mintPrice,"Not enough ETH!");
        _safeMint(msg.sender, _tokenIds.current());
        _tokenIds.increment();
    }
}