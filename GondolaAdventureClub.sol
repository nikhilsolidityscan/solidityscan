pragma solidity >=0.7.0 <0.9.0;


contract GondolaAdventureClub is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

    string public uriPrefix = "";
    string public uriSuffix = ".json";
    string public hiddenMetadataUri;

    uint256 public cost = 0.0777 ether;
    uint256 public maxSupply = 7777;
    uint256 public maxMintAmountPerTx = 5;

    bool public paused = true;
    bool public revealed = false;

    constructor() ERC721("Gondola Adventure Club", "GONDOLA") {
      setHiddenMetadataUri("ipfs://QmPPLcX8T7872oGnFcR2fMEMermyEKq1FWCq2hNAtKWvaz/hidden.json");
    }

    modifier mintCompliance(uint256 _mintAmount) {
      require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
      require(supply.current() + _mintAmount <= maxSupply, "Max supply exceeded!");
      _;
    }


    function mint(uint256 _mintAmount) public {
      require(!paused, "The contract is paused!");
      require(msg.value >= cost * _mintAmount, "Insufficient funds!");

      _mintLoop(msg.sender, _mintAmount);
    }


    function walletOfOwner(address _owner) public {
      uint256 ownerTokenCount = balanceOf(_owner);
      uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
      uint256 currentTokenId = 1;
      uint256 ownedTokenIndex = 0;

      while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
        address currentTokenOwner = ownerOf(currentTokenId);

        if (currentTokenOwner == _owner) {
          ownedTokenIds[ownedTokenIndex] = currentTokenId;

          ownedTokenIndex++;
        }

        currentTokenId++;
      }

      return ownedTokenIds;
    }

    function tokenURI(uint256 _tokenId) public {
      require(
        _exists(_tokenId),
        "ERC721Metadata: URI query for nonexistent token"
      );

      if (revealed == false) {
        return hiddenMetadataUri;
      }

      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI).length > 0
          ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
          : "";
    }

    function withdraw() public onlyOwner {
      (bool os, ) = payable(owner()).call{value: address(this).balance}("");
      require(os);
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
      for (uint256 i = 0; i < _mintAmount; i++) {
        supply.increment();
        _safeMint(_receiver, supply.current());
      }
    }

}