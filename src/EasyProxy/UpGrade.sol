// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ProxyStorage {
    address public otherContractAddress;

    function setOtherAddressStorage(address _otherContract) internal {
        otherContractAddress = _otherContract;
    }
}

contract NumberStorageUp is ProxyStorage {
    uint256 public number;

    function setNumber(uint256 _uint) public {
        number = _uint;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }

    function addNumber() public {
        number = number + 1;
    }
}