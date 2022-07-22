// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-1822/EIP1822.sol";

contract ContractTest is Test {
    Proxy private proxy;
    NumberStorage private number;

    function setUp() public {
        number = new NumberStorage();
        address numberAddress = address(number);
        proxy = new Proxy(abi.encodeWithSignature("constructor1()"), numberAddress);
    }

    function testInit() public {
        (bool initCall, bytes memory initSupply) = address(proxy).call(
            abi.encodeWithSignature("totalSupply()")
        );

        require(initCall, "Init test call Error");

        uint256 returnNumber = abi.decode(initSupply, (uint256));
        assertEq(returnNumber, 1000);
    }

    function testAddNumber() public {
        (bool addCall, ) = address(proxy).call(
            abi.encodeWithSignature("addNumber(uint256)", 100)
        );

        require(addCall, "AddNumber Call Error");

        (bool amountCall, bytes memory amount) = address(proxy).call(
            abi.encodeWithSignature("supplyAmount()")
        );

        require(amountCall, "Amount Call Error");

        assertEq(abi.decode(amount, (uint256)), 100);
    }
}