// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-712/simple.sol";

contract ContractTest is Test {
    Example private signContract;

    function setUp() public {
        signContract = new Example();
    }
    
}