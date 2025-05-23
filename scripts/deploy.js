const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const GNaira = await hre.ethers.getContractFactory("GNaira");

  // Deploy the contract
  // Note: You'll need to provide the governor and approver addresses
  const governor = "0x06a9C53e1Dd1d4411F21d0AaD3B98448c343DCae" // Replace with actual governor address
  const approver = "0x4e143f76CE2Fbef0898766BbF8093FFc6AAd7A89"; // Replace with actual approver address
  
  console.log("Deploying GNaira contract...");
  const gnaira = await GNaira.deploy(governor, approver);
  
  // Wait for deployment to finish
  await gnaira.waitForDeployment();
  const address = await gnaira.getAddress();
  console.log(`GNaira deployed to: ${address}`);
  console.log(`View contract on Basescan: https://sepolia.basescan.org/address/${address}`);

  // Wait for a few block confirmations before verifying
  console.log("Waiting for block confirmations...");
  // Wait for 5 blocks
  for(let i = 0; i < 5; i++) {
    await new Promise(resolve => setTimeout(resolve, 2000)); // Wait 2 seconds between blocks
  }

  // Verify the contract on Basescan
  console.log("Verifying contract on Basescan...");
  try {
    await hre.run("verify:verify", {
      address: address,
      constructorArguments: [governor, approver],
      network: "base_sepolia"
    });
    console.log("Contract verified successfully!");
    console.log(`View verified contract on Basescan: https://sepolia.basescan.org/address/${address}#code`);
  } catch (error) {
    console.log("Verification failed:", error);
    console.log("You can try verifying manually on Basescan using the following parameters:");
    console.log(`Contract Address: ${address}`);
    console.log("Constructor Arguments:", [governor, approver]);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
