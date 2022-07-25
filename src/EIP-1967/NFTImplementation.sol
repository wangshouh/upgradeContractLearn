// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract NFTData {
    string public name;
    uint256 public currentTokenId;
    uint256 public totalSupply;
}

contract NFTImplementation is NFTData, Initializable {
    function initialize(
        string memory _name,
        uint256 _totalSupply
    ) public initializer {
        name = _name;
        totalSupply = _totalSupply;
    }

    function mint() public returns (uint256) {
        require(currentTokenId+1 < totalSupply, "Over Max");
        currentTokenId += 1;
        return currentTokenId;
    }
}
