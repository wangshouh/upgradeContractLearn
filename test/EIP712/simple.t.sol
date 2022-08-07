// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-712/simple.sol";

contract ContractTest is Test {
    Example private signContract;

    function setUp() public {
        signContract = new Example();
    }
    function testSign() public {
        // Example signed message
        Example.Mail memory mail = Example.Mail({
            from: Example.Person({
               name: "Cow",
               wallet: 0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826
            }),
            to: Example.Person({
                name: "Bob",
                wallet: 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB
            }),
            contents: "Hello, Bob!"
        });
        uint8 v = 28;
        bytes32 r = 0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d;
        bytes32 s = 0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562;
        
        assertTrue(signContract.verify(mail, v, r, s));
    }
}