import { ethers } from "ethers";
import { whatsabi } from "@shazow/whatsabi";

const provider = new ethers.getDefaultProvider(); // substitute with your fav provider
const address = "0x47c02B023B6787EF4E503DF42bBB1a94f451a1C0"; // Or your fav contract address
const code = await provider.getCode(address); // Load the bytecode

// Get just the callable selectors
const selectors = whatsabi.selectorsFromBytecode(code);
console.log(selectors); // -> ["0x06fdde03", "0x46423aa7", "0x55944a42", ...]

// Get an ABI-like list of interfaces
const abi = whatsabi.abiFromBytecode(code);
console.log(abi);
// -> [
//  {"type": "event", "hash": "0x721c20121297512b72821b97f5326877ea8ecf4bb9948fea5bfcb6453074d37f"},
//  {"type": "function", "payable": true, "selector": "0x06fdde03", ...},
//  {"type": "function", "payable": true, "selector": "0x46423aa7", ...},
//   ...

// We also have a suite of database loaders for convenience
const signatureLookup = new whatsabi.loaders.SamczunSignatureLookup();
console.log(await signatureLookup.loadFunctions("0x06fdde03"));
// -> ["name()"]);
console.log(await signatureLookup.loadFunctions("0x46423aa7"));
// -> ["getOrderStatus(bytes32)"]);

// We also have event loaders!
console.log(
  await signatureLookup.loadEvents(
    "0x721c20121297512b72821b97f5326877ea8ecf4bb9948fea5bfcb6453074d37f"
  )
);
// -> ["CounterIncremented(uint256,address)"]

// There are more fancy loaders in whatsabi.loaders.*, take a look!
