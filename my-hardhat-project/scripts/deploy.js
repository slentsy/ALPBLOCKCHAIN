const hre = require("hardhat");

async function main() {
  const PetCertificate = await hre.ethers.getContractFactory("PetCertificate");
  const petCertificate = await PetCertificate.deploy();

  await petCertificate.waitForDeployment(); 

  // console.log("PetCertificate deployed to:", await petCertificate.getAddress());
  console.log("PetCertificate deployed to:", await petCertificate.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
