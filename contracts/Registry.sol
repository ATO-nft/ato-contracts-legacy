// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

/// @title contract for registry all ERC721 NFT create by Ato.sol
/// @author Olivier Fernandez / Frédéric Le Coidic
/// @notice registry ERC721 token

contract Registry {
	
	struct Artwork {
		address addr;
		uint256 price;
		uint256 max;
		bool verified;
		uint256 current;
	}

	Artwork[] public artworks;
	mapping(address => uint256) public addressToIndexArtwork;

	mapping(address => bool) public existAuthor;
	address[] public authorList;
	mapping(address => address[]) public contractsListByAuthor;

	address[] public contracts;
	address public lastContractAddress;
	
	modifier onlyNFTContract(address _ATOContract)
	{
		require(msg.sender == _ATOContract, "Only contract NFT");
		_;
	}

	/// @notice addNFT add NFT ATO contract
	/// @param _author author of ERC721 token
	/// @param _ATOContract contract address of ERC721 token
	function addNFT(
		address _author,
		address _ATOContract,
		uint _maxNFT)
		public onlyNFTContract(_ATOContract)
	{
		contracts.push(_ATOContract);
		lastContractAddress = _ATOContract;
		if (!existAuthor[_author]) {
			existAuthor[_author] = true;
			authorList.push(_author);
		}
		contractsListByAuthor[_author].push(_ATOContract);
		artworks.push(
			Artwork({
				addr: _ATOContract,
				price: 0,
				max: _maxNFT,
				verified: true,
				current: 0
			})
		);
		addressToIndexArtwork[_ATOContract] = artworks.length - 1;
	}

	/// @notice return the total Artworks
	function getCountArtworks() public view returns (uint)
	{
		return artworks.length;
	}

	/// @notice return list of Artworks
	function getArtworks() public view returns (Artwork[] memory)
	{
		return artworks;
	}

	/// @notice return the total Artworks by Author
	/// @param _author author of ERC721 token
	function getCountArtworksByAuthor(address _author) public view returns (uint)
	{
		if (!existAuthor[_author])
			return 0;
		return contractsListByAuthor[_author].length;
	}

	/// @notice return list of Artworks by Author
	/// @param _author author of ERC721 token
	function getArtworksByAuthor(address _author) public view returns (Artwork[] memory)
	{
		uint y = contractsListByAuthor[_author].length;
		Artwork[] memory artworksAuthor = new Artwork[](y);
		uint z = 0;
		address artWorkAddress;
		for (uint i = 0; i < y; i++) {
			artWorkAddress = contractsListByAuthor[_author][i];
			z = addressToIndexArtwork[artWorkAddress];
			artworksAuthor[i] = artworks[z];
		}
		return artworksAuthor;
	}

	/// @notice return Artwork id of NFT contract
	/// @param _ATOContract address of NFT contract
	function getArtworkId(address _ATOContract) public view returns (uint256 i)
	{
		return addressToIndexArtwork[_ATOContract];
	}

	/// @notice return NFT contract address of Artwork
	/// @param _id Artwork id
	function getArtworkAddress(uint256 _id) public view returns (address)
	{
		return artworks[_id].addr;
	}

}
