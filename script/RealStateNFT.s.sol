// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RealStateNFT} from "../src/RealStateNFT.sol";

contract RealStateNFTScript is Script {
    RealStateNFT public realStateNft;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        realStateNft = new RealStateNFT("RealEstate", "RSL");
        console.log("RealStateNFT contract address: ", address(realStateNft));

        vm.stopBroadcast();
    }
}
