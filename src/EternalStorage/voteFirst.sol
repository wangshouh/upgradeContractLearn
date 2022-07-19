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
}

contract VoteContract {
    address eternalStorage;

    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
    }

    function getNumberOfVotes() public view returns(uint) {
        return EternalStorage(eternalStorage).getUIntValue(keccak256('votes'));
    }

    function vote() public {
        uint256 orgianVote = EternalStorage(eternalStorage).getUIntValue(keccak256('votes'));
        EternalStorage(eternalStorage).setUIntValue(keccak256('votes'), orgianVote+1);
    }
}