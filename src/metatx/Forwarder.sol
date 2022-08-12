// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/draft-EIP712.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Forwarder is Ownable, EIP712 {
    using ECDSA for bytes32;
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }
    bytes32 private constant _TYPEHASH = keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");
    
    mapping(address => uint256) private _nonces;
    mapping(address => bool) private _senderWhitelist;

    event MetaTransactionExecuted(address indexed from, address indexed to, bytes indexed data);
    event AddressWhitelisted(address indexed sender);
    event AddressRemovedFromWhitelist(address indexed sender);


    constructor(string memory name, string memory version) EIP712(name, version) {
        address msgSender = msg.sender;
        addSenderToWhitelist(msgSender);
    }

    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        address signer = _hashTypedDataV4(keccak256(abi.encode(
            _TYPEHASH,
            req.from,
            req.to,
            req.value,
            req.gas,
            req.nonce,
            keccak256(req.data)
        ))).recover(signature);
        return _nonces[req.from] == req.nonce && signer == req.from;
    }
    function execute(ForwardRequest calldata req, bytes calldata signature) public payable returns (bool, bytes memory) {
        require(_senderWhitelist[msg.sender], "AwlForwarder: sender of meta-transaction is not whitelisted");
        require(verify(req, signature), "AwlForwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;

        (bool success, bytes memory returndata) = req.to.call{gas: req.gas, value: req.value}(abi.encodePacked(req.data, req.from));
        
        if (!success) {
            assembly {
                let p := mload(0x40)
                returndatacopy(p, 0, returndatasize())
                revert(p, returndatasize())
            }
        }

        assert(gasleft() > req.gas / 63);

        emit MetaTransactionExecuted(req.from, req.to, req.data);

        return (success, returndata);
    }
    function addSenderToWhitelist(address sender) public onlyOwner() {
        require(!isWhitelisted(sender), "AwlForwarder: sender address is already whitelisted"); 
        _senderWhitelist[sender] = true;
        emit AddressWhitelisted(sender);
    }

    function removeSenderFromWhitelist(address sender) public onlyOwner() {
        _senderWhitelist[sender] = false;
        emit AddressRemovedFromWhitelist(sender);
    }

    function isWhitelisted(address sender) public view returns (bool) {
        return _senderWhitelist[sender];
    }
}