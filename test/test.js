const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Āto: Tests", function () {

  let Ato;
  let ato;
  let metadata;
  let author, alice;
  let maxNFT;
  let mintNumber;
  let royalties;
  let Registry;
  let registry;

  beforeEach(async function () {

    [author, alice] = await ethers.getSigners();
    metadata = "https://bafkreigicogtnm6fb3opxfqoecvkuzdp6jzq2ns5sssycc3q3zuoxbattq.ipfs.dweb.link"

    Registry = await ethers.getContractFactory("Registry");
    registry = await Registry.deploy();

    await registry.deployed();

    maxNFT = 150;
    mintNumber = 1;
    royalties = 10 * 100;
    Ato = await ethers.getContractFactory("Ato");
    ato = await Ato.deploy("Fred", "FLC", metadata, maxNFT, mintNumber, royalties, registry.address);
    
    await ato.deployed();

  });
  
  describe("Unit tests", function () {
    it("Should return the name", async function () {
      expect(await ato.name()).to.equal("Fred");
    });

    it("Should return the symbol", async function () {
      expect(await ato.symbol()).to.equal("FLC");
    });

    it("Should return the author", async function () {
      expect(await ato.author()).to.equal(author.address);
      expect(await ato.author()).to.not.equal(alice.address);
    });

    it("Verify max NFT", async function () {
      expect(await ato.max()).to.equal(maxNFT);
    });

    it("Verify Royalties", async function () {
      const Royalties = await ato.royaltyInfo(0,10000);
      //console.log("Adresse Author : " + Royalties[0]);
      //console.log("Royalties Author : " + Royalties[1]);
      expect(Royalties[1]).to.equal(royalties);
    });

    it("Should return the metadata", async function () {
      expect(await ato.metadata()).to.equal(metadata);
    });

    it("Verify mintNumber", async function () {
      expect(await ato.getTokenIdCounter()).to.equal(mintNumber);
    });

    it("Verify mintBatch", async function () {
      let addMint = 30;
      await ato.connect(author).mintBatch(addMint);
      expect(await ato.getTokenIdCounter()).to.equal(mintNumber + addMint);
    });

    it("Verify Author", async function () {
      await expect(ato.connect(alice).setMetadata("Toto")).to.be.reverted;
      await expect(ato.connect(alice).mintBatch(1)).to.be.reverted;
    });
  });
  
  describe("Integration tests", function () {
    it("Check if Author and contract exist", async function () {
      expect(await registry.existAuthor(author.address)).to.be.true;
      expect(await registry.contractsListByAuthor(author.address, 0)).to.equal(ato.address);
    });
  });
});
