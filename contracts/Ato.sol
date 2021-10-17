// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import './ERC2981ContractWideRoyalties.sol';

import "./Registry.sol";

import "hardhat/console.sol";

/// @title contract for ATO
/// @author Olivier Fernandez / Frédéric Le Coidic
/// @notice create ERC721 token with IEP2981

contract Ato is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ERC2981ContractWideRoyalties {

using Counters for Counters.Counter;

	Counters.Counter private _tokenIdCounter;

	address public author; // The address of the author
	string public metadata; // The URI of the metadata
	uint public max; // The maximum number of copies
	bool public set; // True if the tokenURI is set
	address public RegistryAddress; // The address of the registry contract

	modifier onlyAuthor()
	{
		require(author == msg.sender, "ONLY_AUTHOR");
		_;
	}

	event Minted(
		uint256 indexed nftId,
		address indexed author
	);

	/// @notice constructor
	/// @param _name name of ERC721 token
	/// @param _symbol symbol of ERC721 token
	/// @param _metadata metadata of NFT
	/// @param _max maximum mint of NFT
	/// @param _royalties percentage (using 2 decimals - 10000 = 100, 0 = 0)
	/// @param _Registry addresse of Registry contract
	constructor(
		string memory _name,
		string memory _symbol,
		string memory _metadata,
		uint _max,
		uint _mintNumber,
		uint _royalties,
		address _Registry)
		ERC721(_name, _symbol)
	{
		author = msg.sender;
		max = _max;
		setMetadata(_metadata);
		RegistryAddress = _Registry;

		if (bytes(metadata).length > 0) {
			set = true;
			if (_mintNumber > _max) {
				_mintNumber = _max;
			}
			mintBatch(_mintNumber);
		}
		_setRoyalties(_royalties);

		// add author and contract to Registry
		Registry registry = Registry(RegistryAddress);
		registry.addNFT(author, address(this), _max);
	}

	/// @notice set Metadata of Token
	/// @param _metadata metadata of NFT
	function setMetadata(string memory _metadata) public onlyAuthor
	{
		require(!set,"Metadata already set");
		metadata = _metadata;
		set = true;
	}

	/// @notice get mint counter value
	function getTokenIdCounter() public view returns (uint)
	{
		return _tokenIdCounter.current();
	}

	/// @notice mint NFT by batch
	/// @param _number number of NFT to mint
	function mintBatch(uint _number) public onlyAuthor
	{
		require(set,"Metadata not set");
		uint current = _tokenIdCounter.current();
		uint last = current + _number;
		require(last <= max, "Maximum NFT already create");

		for (uint i = current; i < last; i++) {
			_mintNFT();
		}
	}

	/// @notice mint NFT and assigns them to `author`.
	/// @notice Emits a {Mint} event.
	function _mintNFT() private
	{
		_tokenIdCounter.increment();
		_safeMint(author, _tokenIdCounter.current());
		_setTokenURI(_tokenIdCounter.current(), metadata);
		emit Minted(_tokenIdCounter.current(), author);
	}

	/// @dev Sets token royalties
	/// @param value percentage (using 2 decimals - 10000 = 100, 0 = 0)
	function _setRoyalties(uint256 value) private onlyAuthor
	{
		require(value <= 10000, 'ERC2981Royalties: Too high');
		super._setRoyalties(author, value);
	}

	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal
		override(ERC721, ERC721Enumerable)
	{
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
	{
		super._burn(tokenId);
	}

	function tokenURI(uint256 tokenId)
		public
		view
		override(ERC721, ERC721URIStorage)
		returns (string memory)
	{
		return super.tokenURI(tokenId);
	}

    function owner() public view override returns (address) {
        return super.owner();
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable, ERC2981ContractWideRoyalties)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}
