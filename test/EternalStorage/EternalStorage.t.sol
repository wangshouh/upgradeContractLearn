// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EternalStorage/EternalStorage.sol";

contract ContractTest is Test {

    EternalStorage private storageEth;

    function setUp() public {
        storageEth = new EternalStorage();
    }

    function testGetIntValue() public {
        storageEth.setUIntValue(keccak256('votes'), 1);
        uint256 intValue = storageEth.getUIntValue(keccak256('votes'));
        assertEq(intValue, 1);
    }
}
