import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleNFT", (m) => {
  const simpleNFT = m.contract("SimpleNFT");
  return { simpleNFT };
});