//SPDX-License-Identifier: Unlicense.
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFT is ERC721URIStorage, Ownable, ReentrancyGuard {
    address private factoryAddress;
    uint256 private royaltiesPctToFactory = 5; // 5% royalties
    string public baseURI;
    uint256 public mintPrice;
    uint256 public maxSupply;
    bool public isMintEnabled;
    mapping(address => bool) whiteListWallets;
    mapping(address => uint256) public mintedWallets;

    // Keep count of NFT ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Init {
        address owner;
        uint256 mintPrice;
        string contractName;
        string contractSymbol;
        uint256 maxSupply;
        bool isMintEnabled;
        string baseURI;
    }

    constructor(Init memory config) ERC721(
        config.contractName,
        config.contractSymbol
    ) {
        // Transfer ownership to client
        transferOwnership(config.owner);
        // Set base URI
        baseURI = config.baseURI;
        // Sets factory address for royalties
        factoryAddress = msg.sender;
        // Sets max supply
        maxSupply = config.maxSupply;
        // Sets is mint enabled
        isMintEnabled = config.isMintEnabled;
        // Sets mint prices
        mintPrice = config.mintPrice;

        // Let token ID count start from 1.
        _tokenIds.increment();
    }
    
    // internal
    function _baseURI()
        internal
        view
        virtual
        override
        returns (string memory)
    {
        return baseURI;
    }

    // Public
    function mint() public payable {
        require(isMintEnabled, "Minting not enabled!");
        require(maxSupply > _tokenIds.current(), "Sold out");
        require(
            mintedWallets[msg.sender] < 1,
            "Exceeded max minted per wallet"
        );
        require(msg.value >= mintPrice, "Insufficient ETH!");

        // Sends 5% royalties to Mintedbyte.
        (bool success, ) = payable(factoryAddress).call{
            value: msg.value * (royaltiesPctToFactory / 100)
        }("");
        require(success);

        uint256 tokenID = _tokenIds.current();
        _safeMint(msg.sender, tokenID);
        _tokenIds.increment();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(
                currentBaseURI,
                tokenId,
                ".json"
            )) : "";
    }

    // Owner
    function toggleIsMintEnabled() external onlyOwner {
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        maxSupply = maxSupply_;
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = owner().call{
            value: address(this).balance
        }("");

        require(success, "Withdrawal Failed!");
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function burn(uint256 quantity_) external onlyOwner {
        // Checks if the quantity given is less than or equal
        // to the unminted supply
        bool condition = quantity_ <= (maxSupply - _tokenIds.current());

        if (condition)
            maxSupply -= quantity_; // Burns off set supply
        else
            maxSupply = _tokenIds.current(); // Burns off all remaining supply
    }

    function addWhitelist(address[] memory whitelisters_) external onlyOwner {
        for (uint256 i=0; i<whitelisters_.length; i++) {
            address whitelister = whitelisters_[i];
            whiteListWallets[whitelister] = true;
        }
    }

    // Overloading
    function addWhitelist(address whitelister_) external onlyOwner {
        whiteListWallets[whitelister_] = true;
    }

    function removeWhitelist(address[] memory whitelisters_) 
        external
        onlyOwner
    {
        for (uint256 i=0; i<whitelisters_.length; i++) {
            address whitelister = whitelisters_[i];
            whiteListWallets[whitelister] = false;
        }
    }

    // Overloading
    function removeWhitelist(address whitelister_) external onlyOwner {
        whiteListWallets[whitelister_] = false;
    }
}