// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/EasyProxy/ProxyEasy.sol";

contract MyScript is Script {
    function run() external {
        vm.startBroadcast();

        NumberStorage numberStorage = new NumberStorage();
        NumberStorageUp numberStorageUp = new NumberStorageUp();
        address numberAddress = address(numberStorage);
        ProxyEasy proxy = new ProxyEasy(numberAddress);

        vm.stopBroadcast();
    }
}