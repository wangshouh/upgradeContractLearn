// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EasyProxy/ProxyEasy.sol";

contract ContractTest is Test {
    NumberStorage private numberStorage;
    NumberStorageUp private numberStorageUp;
    ProxyEasy private proxy;

    function setUp() public {
        numberStorage = new NumberStorage();
        address numberAddress = address(numberStorage);
        proxy = new ProxyEasy(numberAddress);
    }
}