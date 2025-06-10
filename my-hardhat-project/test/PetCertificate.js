const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PetCertificate", function () {
  let contract;
  let shelter, user1;

  beforeEach(async () => {
    [shelter, user1] = await ethers.getSigners();
    const PetCertificate = await ethers.getContractFactory("PetCertificate");
    contract = await PetCertificate.connect(shelter).deploy();
  });

  it("Should mint a new pet NFT", async () => {
    await contract.mint("Fluffy", "Cat", "ipfs://cat1");
    const pet = await contract.getPet(0);

    expect(pet.name).to.equal("Fluffy");
    expect(pet.species).to.equal("Cat");
    expect(pet.owner).to.equal(shelter.address);
  });

  it("Should add vaccine record", async () => {
    await contract.mint("Max", "Dog", "ipfs://dog1");
    await expect(contract.addVaccine(0, "Rabies"))
      .to.emit(contract, "VaccineAdded")
      .withArgs(0, "Rabies");
  });

  it("Should add health record", async () => {
    await contract.mint("Bunny", "Rabbit", "ipfs://rabbit1");
    await expect(contract.addHealth(0, "Healthy"))
      .to.emit(contract, "HealthRecordAdded")
      .withArgs(0, "Healthy");
  });

  it("Should add achievement by owner", async () => {
    await contract.mint("Leo", "Lion", "ipfs://lion1");
    await expect(contract.addAchievement(0, "Bravest Pet"))
      .to.emit(contract, "AchievementAdded")
      .withArgs(0, "Bravest Pet");
  });

  it("Should request and approve adoption", async () => {
    await contract.mint("Nemo", "Fish", "ipfs://fish1");

    await contract.connect(user1).requestAdoption(0);
    await expect(contract.connect(shelter).approveAdoption(0))
      .to.emit(contract, "AdoptionApproved")
      .withArgs(0, user1.address);

    const pet = await contract.getPet(0);
    expect(pet.owner).to.equal(user1.address);
  });

  it("Should revert if non-shelter tries to mint", async () => {
    await expect(
      contract.connect(user1).mint("Rocky", "Dog", "ipfs://rocky")
    ).to.be.revertedWith("Only shelter can mint");
  });

  it("Should revert if non-owner adds achievement", async () => {
    await contract.mint("Rocky", "Dog", "ipfs://rocky");
    await expect(
      contract.connect(user1).addAchievement(0, "Cutest Dog")
    ).to.be.revertedWith("Only pet owner can add achievement");
  });
});
