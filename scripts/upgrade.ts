import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

const proxyAddress: string = "0xE4F00aCb59E43015D3c21d2cc07B21b80Ff9D531";

async function main(): Promise<void> {
  console.log("Deploying PredictTeamWin contract...");
  const Logic: ContractFactory = await ethers.getContractFactory("PredictTeamWin");
  const logic: Contract = await upgrades.upgradeProxy(proxyAddress, Logic);
  await logic.deployed();
  console.log("Logic Proxy Contract deployed to : ", logic.address);
  console.log(
    "Logic Contract implementation address is : ",
    await upgrades.erc1967.getImplementationAddress(logic.address),
  );
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });