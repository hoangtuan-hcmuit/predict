import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main() {
  const PredictTeamWin: ContractFactory = await ethers.getContractFactory("PredictTeamWin");
  const predictTeamWin: Contract = await upgrades.deployProxy(
    PredictTeamWin,
    ["0x9682c81CF7FbF006b4e823185acA44a6084E86Cc", "0x0B4769d0c9B42F1c3f929b86401C05A1498E2883"],
    { kind: "uups", initializer: "init" },
  );
  await predictTeamWin.deployed();

  console.log("Predict team win Proxy Contract deployed to: ", predictTeamWin.address);
  console.log(
    "Pridct team win Implementation deployed to: ",
    await upgrades.erc1967.getImplementationAddress(predictTeamWin.address),
  );

  // const CommitUtil: ContractFactory = await ethers.getContractFactory("CommitUtil");
  // const commitUtil: Contract = await CommitUtil.deploy();
  // await commitUtil.deployed();
  // console.log("CommitUtil deployed to ", commitUtil.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });