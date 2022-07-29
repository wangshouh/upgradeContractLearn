// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library MyStructStorage {
    bytes32 constant MYSTRUCT_POSITION =
        keccak256("com.mycompany.projectx.mystruct");

    struct MyStruct {
        uint256 var1;
        bytes var2;
        mapping(address => uint256) var3;
    }

    function myStructStorage()
        internal
        pure
        returns (MyStruct storage mystruct)
    {
        bytes32 position = MYSTRUCT_POSITION;
        assembly {
            mystruct.slot := position
        }
    }
}

contract TestStruct {
    function myFunction(uint256 inputUint) external {
        MyStructStorage.MyStruct storage mystruct = MyStructStorage
            .myStructStorage();

        mystruct.var1 = inputUint;
    }
}


