// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import "../libraries/LibAppStorage.sol";

contract TestFacet {

    AppStorage internal s;
    
    function name() external view returns (string memory) {
        return s.name;
    }

    function totalSupply() external view returns (uint256) {
        return s.totalSupply;
    }

    function maxSupply() external view returns (uint256) {
        return s.maxSupply;
    }

    function setName(string memory _name) external {
        s.name = _name;
    } 
}
