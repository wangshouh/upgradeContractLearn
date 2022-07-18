// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract EternalStorage {
    mapping(bytes32 => uint256) public UIntStorage;

    function getUIntValue(bytes32 record) public view returns (uint256) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint256 value) public {
        UIntStorage[record] = value;
    }

    mapping(bytes32 => bool) public BooleanStorage;

    function getBooleanValue(bytes32 record) public view returns (bool) {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) public {
        BooleanStorage[record] = value;
    }
}
