// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract ERC2771Recipient {
    address private _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function getTrustedForwarder()
        public
        view
        virtual
        returns (address forwarder)
    {
        return _trustedForwarder;
    }

    function _setTrustedForwarder(address _forwarder) internal {
        _trustedForwarder = _forwarder;
    }

    function isTrustedForwarder(address forwarder)
        public
        view
        virtual
        returns (bool)
    {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual returns (address ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            ret = msg.sender;
        }
    }

    function _msgData() internal view virtual returns (bytes calldata ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}

contract Box is ERC2771Recipient {
    constructor(address trustedForwarder) ERC2771Recipient(trustedForwarder) {}

    uint256 private _value;

    event NewValue(uint256 newValue);
    event Sender(address sender);

    function store(uint256 newValue) public {
        _value = newValue;
        emit NewValue(newValue);
        emit Sender(_msgSender());
    }

    function retrieve() public view returns (uint256) {
        return _value;
    }
}
