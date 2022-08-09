// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/cryptography/draft-EIP712.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "./IProduct.sol";

contract ProductEIP712 is EIP712, IProduct {
    event SignerOut(address signer);
    bytes32 constant PERSON_TYPEHASH =
        keccak256("Person(string name,address wallet)");

    bytes32 constant MAIL_TYPEHASH =
        keccak256(
            "Mail(Person from,Person to,string contents)Person(string name,address wallet)"
        );

    constructor(string memory _name, string memory _version)
        EIP712(_name, _version)
    {}

    function hash(Person memory person) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERSON_TYPEHASH,
                    keccak256(bytes(person.name)),
                    person.wallet
                )
            );
    }

    function hash(Mail memory mail) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    MAIL_TYPEHASH,
                    hash(mail.from),
                    hash(mail.to),
                    keccak256(bytes(mail.contents))
                )
            );
    }

    function verify(Mail memory mail, bytes memory signature) public {
        bytes32 digest = _hashTypedDataV4(hash(mail));
        address signer = ECDSA.recover(digest, signature);
        emit SignerOut(signer);
        require(signer == msg.sender, "Not sender");
    }
}
