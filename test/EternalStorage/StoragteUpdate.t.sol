// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// import "../../src/EternalStorage/EternalStorage.sol";
import "../../src/EternalStorage/voteFirst.sol";
import "../../src/EternalStorage/voteSecond.sol";

contract ContractTest is Test {
    EternalStorage private storageEth;
    VoteFirst private voteFirst;
    VoteSecond private voteSecond;

    function setUp() public {
        storageEth = new EternalStorage();
        address storageAddress = address(storageEth);
        voteFirst = new VoteFirst(storageAddress);
        voteSecond = new VoteSecond(storageAddress);
    }

    function testGetValueFromFirst() public {
        voteFirst.vote();
        uint256 voteNum = voteFirst.getNumberOfVotes();
        assertEq(voteNum, 1);
    }

    function testGetValueFromSecond() public {
        voteSecond.vote();
        uint256 voteNum = voteSecond.getNumberOfVotes();
        assertEq(voteNum, 1);
    }

    function testCrossGetValue() public {
        voteFirst.vote();
        uint256 voteNum = voteSecond.getNumberOfVotes();
        assertEq(voteNum, 1);
    }
}
