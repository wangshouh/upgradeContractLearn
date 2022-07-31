// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct AppStorage {
    string name;
    uint256 totalSupply;
    uint256 maxSupply;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}