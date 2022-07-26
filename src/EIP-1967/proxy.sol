// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";

contract NFTProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {}

    modifier OnlyContractOwner() {
        require(msg.sender == _getAdmin(), "Not Contract Owner");
        _;
    }

    function changeAdmin(address _newAdmin) public OnlyContractOwner {
        _changeAdmin(_newAdmin);
    }

    function upgradeProxy(address newBeacon, bytes memory data)
        public
        OnlyContractOwner
    {
        _upgradeBeaconToAndCall(newBeacon, data, false);
    }
}
