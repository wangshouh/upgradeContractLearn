// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-1822/EIP1822.sol";

contract ContractTest is Test {
    using stdStorage for StdStorage;
    Proxy private proxy;
    NumberStorage private number;
    NumberStorageUp private numberUp;

    function setUp() public {
        number = new NumberStorage();
        numberUp = new NumberStorageUp();
        address numberAddress = address(number);
        proxy = new Proxy(
            abi.encodeWithSignature("constructor1()"),
            numberAddress
        );
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

    function testFailOverMax() public {
        uint256 slot = stdstore
            .target(address(proxy))
            .sig("supplyAmount()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedsupplyAmount = bytes32(abi.encode(10_000));
        vm.store(address(proxy), loc, mockedsupplyAmount);
        (bool addCall, ) = address(proxy).call(
            abi.encodeWithSignature("addNumber(uint256)", 100)
        );

        require(addCall, "Add Error");
    }

    function testFailDirectCall() public {
        (bool initCall, ) = address(proxy).call(
            abi.encodeWithSignature("initialized()")
        );
        require(initCall);
        (bool addCall, ) = address(number).call(
            abi.encodeWithSignature("addNumber(uint256)", 100)
        );

        require(addCall);
    } 

    function testContractUpgradeGet() public {
        (bool addCall, ) = address(proxy).call(
            abi.encodeWithSignature("addNumber(uint256)", 100)
        );

        require(addCall, "AddNumber Call Error");

        (bool UpgradeCall, ) = address(proxy).call(
            abi.encodeWithSignature("updateCode(address)", address(numberUp))
        );
        
        require(UpgradeCall, "Upgrade Fail");

        (bool amountCall, bytes memory amount) = address(proxy).call(
            abi.encodeWithSignature("supplyAmount()")
        );

        require(amountCall, "Amount Call Error");

        assertEq(abi.decode(amount, (uint256)), 100);

    }
    
}
