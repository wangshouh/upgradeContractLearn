// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract NFTData {
    string public name;
    string public symbol;
    string public baseURI;
    uint256 public currentTokenId;
    uint256 public totalSupply;
}

contract NFTLogicV1 is NFTData, Initializable {
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _totalSupply
    ) public initializer {
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
        totalSupply = _totalSupply;
    }

    function mint() public returns (uint256) {
        require(currentTokenId+1 < totalSupply, "Over Max");
        currentTokenId += 1;
        return currentTokenId;
    }
}
