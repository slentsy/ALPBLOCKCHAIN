// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PetCertificate {
    address public shelter;
    uint256 public petCounter;

    // struct certificate untuk simpan data certificate
    struct Certificate {
        string ipfsHash;
        string description;
        uint256 timestamp;
    }

    struct Pet {
        string name;
        string species;
        string tokenURI;
        address currentOwner;
        Certificate[] vaccineRecords;
        string[] healthRecords;
        Certificate[] achievements;
        bool adoptionRequested;
        address adoptionCandidate;
    }

    mapping(uint => Pet) public pets;

    event PetMinted(uint petId, address owner);
    event VaccineAdded(uint petId, string vaccine);
    event HealthRecordAdded(uint petId, string record);
    event AchievementAdded(uint petId, string achievement);
    event AdoptionRequested(uint petId, address by);
    event AdoptionApproved(uint petId, address newOwner);

    constructor() {
        shelter = msg.sender;
    }

    function mint(string memory _name, string memory _species, string memory _uri) public {
        require(msg.sender == shelter, "Only shelter can mint");

        Pet storage newPet = pets[petCounter];
        newPet.name = _name;
        newPet.species = _species;
        newPet.tokenURI = _uri;
        newPet.currentOwner = shelter;
        newPet.adoptionRequested = false;
        newPet.adoptionCandidate = address(0);

        emit PetMinted(petCounter, shelter);
        petCounter++;
    }

    function addVaccine(uint _id, string memory _ipfsHash, string memory _description) public {
        require(msg.sender == shelter, "Only shelter can add");
        pets[_id].vaccineRecords.push(Certificate({
            ipfsHash: _ipfsHash,
            description: _description,
            timestamp: block.timestamp
        }));
        emit VaccineAdded(_id, _ipfsHash);
    }


    function addHealth(uint _id, string memory _record) public {
        require(msg.sender == shelter, "Only shelter can add");
        pets[_id].healthRecords.push(_record);
        emit HealthRecordAdded(_id, _record);
    }

    function addAchievement(uint _id, string memory _ipfsHash, string memory _description) public {
        require(msg.sender == pets[_id].currentOwner || msg.sender == shelter, "Only pet owner or shelter can add achievement");
        pets[_id].achievements.push(Certificate({
            ipfsHash: _ipfsHash,
            description: _description,
            timestamp: block.timestamp
        }));
        emit AchievementAdded(_id, _ipfsHash);
    }



    function requestAdoption(uint _id) public {
        require(msg.sender != pets[_id].currentOwner, "Already the owner");
        pets[_id].adoptionRequested = true;
        pets[_id].adoptionCandidate = msg.sender;
        emit AdoptionRequested(_id, msg.sender);
    }

    function approveAdoption(uint _id) public {
        require(msg.sender == shelter, "Only shelter can approve");
        require(pets[_id].adoptionRequested, "No adoption requested");

        pets[_id].currentOwner = pets[_id].adoptionCandidate;
        pets[_id].adoptionRequested = false;
        pets[_id].adoptionCandidate = address(0);

        emit AdoptionApproved(_id, pets[_id].currentOwner);
    }

// mengambil argumen dasar dari pet
    function getPetBasic(uint _id) public view returns (
        string memory name,
        string memory species,
        address owner,
        string memory tokenURI,
        string[] memory healthRecords
    ) {
        Pet storage p = pets[_id];
        return (
            p.name,
            p.species,
            p.currentOwner,
            p.tokenURI,
            p.healthRecords
        );
    }
    // untuk mengambil URI Token atau hash yang tersimpan di smart contract
    function getTokenURI(uint _id) public view returns (string memory) {
        return pets[_id].tokenURI;
    }

    function getVaccineCertificates(uint _id) public view returns (Certificate[] memory) {
        return pets[_id].vaccineRecords;
    }

    function getAchievementCertificates(uint _id) public view returns (Certificate[] memory) {
        return pets[_id].achievements;
    }

    function getPetCounter() external view returns (uint256) {
        return petCounter;
    }

}
