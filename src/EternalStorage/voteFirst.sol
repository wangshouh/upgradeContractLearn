// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error GetValueFail();

contract VoteFirst {
    address eternalStorage;

    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
    }

    function getNumberOfVotes() public returns (uint256) {
        (bool success, bytes memory data) = eternalStorage.call(
            abi.encodeWithSignature("getUIntValue(bytes32)", keccak256("votes"))
        );
        if (!success) {
            revert GetValueFail();
        }

        return abi.decode(data, (uint256));
    }

    function vote() public {
        uint256 voteNum = getNumberOfVotes() + 1;
        (bool success, ) = eternalStorage.call(
            abi.encodeWithSignature(
                "setUIntValue(bytes32,uint256)",
                keccak256("votes"),
                voteNum
            )
        );
        if (!success) {
            revert("Call Error");
        }
    }
}
