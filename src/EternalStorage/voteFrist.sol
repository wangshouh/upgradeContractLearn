// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error GetValueFail();
error SetValueFail();

contract Vote {
    address eternalStorage;

    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
    }

    function getNumberOfVotes() public returns(uint) {
        (bool success, bytes memory data) = eternalStorage.call(
		    abi.encodeWithSignature("getUIntValue(bytes32)", keccak256('votes'))
	    );
        if (!success) {
            revert GetValueFail();
        }

        return abi.decode(data, (uint256));
    }

    function vote() public {
        uint256 orgianVote = getNumberOfVotes();
        (bool success,) = eternalStorage.call(
            abi.encodeWithSignature("setUIntValue(bytes32, uint256)", keccak256('votes'), orgianVote+1)
        );
        if (!success) {
            revert SetValueFail();
        }
    }
}