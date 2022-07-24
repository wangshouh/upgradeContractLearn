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
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), contractLogic, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
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
        require(!initialized, "Initalize finish.");
        initialize();
        setOwner(msg.sender); 
    }

    function updateCode(address newCode) public onlyOwner delegatedOnly {
        updateCodeAddress(newCode);
    }

    function addNumber(uint256 _number) public delegatedOnly {
        require(
            supplyAmount + _number < totalSupply,
            "Greater than the maximum supply"
        );
        supplyAmount = supplyAmount + _number;
    }
}

contract NumberStorageUp is
    LibraryLock,
    DataLayout,
    Owned,
    Proxiable
{
    function constructor1() public {
        totalSupply = 10000;
        require(!initialized, "Initalize finish.");
        initialize();
        setOwner(msg.sender);
    }

    function updateCode(address newCode) public onlyOwner delegatedOnly {
        updateCodeAddress(newCode);
    }

    function addNumber(uint256 _number) public delegatedOnly {
        require(
            supplyAmount + _number < totalSupply,
            "Greater than the maximum supply"
        );
        supplyAmount = supplyAmount + _number;
    }
}