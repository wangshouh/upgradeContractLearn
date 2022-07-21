// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Proxy {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    constructor(bytes memory constructData, address contractLogic) {
        // save the code address
        assembly {
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                contractLogic
            )
        }
        (bool success, ) = contractLogic.delegatecall(
            constructData
        );
        require(success, "Construction failed");
    }

    fallback() external payable {
        assembly { 
            let contractLogic := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), contractLogic, 0, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            ) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                newAddress
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract Owned {
    address owner;

    function setOwner(address _owner) internal {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner is allowed to perform this action"
        );
        _;
    }
}

contract LibraryLockDataLayout {
    bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {
    modifier delegatedOnly() {
        require(
            initialized == true,
            "The library is locked. No direct 'call' is allowed"
        );
        _;
    }

    function initialize() internal {
        initialized = true;
    }
}

contract DataLayout is LibraryLockDataLayout {
    uint256 public totalSupply;
    uint256 public supplyAmount;
}

contract NumberStorage is
    LibraryLock,
    DataLayout,
    Owned,
    Proxiable
{
    function constructor1() public {
        totalSupply = 1000;
        initialize();
    }

    function updateCode(address newCode) public onlyOwner delegatedOnly {
        updateCodeAddress(newCode);
    }

    function addNumber(uint256 _number) public {
        require(
            supplyAmount + _number < totalSupply,
            "Greater than the maximum supply"
        );
        supplyAmount = supplyAmount + _number;
    }
}
