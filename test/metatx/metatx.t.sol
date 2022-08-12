// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/metatx/Forwarder.sol";
import "../../src/metatx/Recipient.sol";

contract MetaTxTest is Test {
    Box private recipient;
    Forwarder private forwarder;
    bytes private Signature;
    Forwarder.ForwardRequest private request;

    function setUp() public {
        vm.chainId(4);
        forwarder = new Forwarder("Forwarder", "1");
        recipient = new Box(address(forwarder));
        Signature = hex"a39fa6101761d1a912d26ab259c186e58c1208cecf1ee8703554ff405b3309032a96ca0e06820fba236b06662d92dc430a28061fa0afece16619c9b3e7f562df1b";
        request = Forwarder.ForwardRequest({
            from: address(0x11475691C2CAA465E19F99c445abB31A4a64955C),
            to: address(0x185a4dc360CE69bDCceE33b3784B0282f7961aea),
            value: 0,
            gas: 500000000000,
            nonce: 0,
            data: hex"6057361d0000000000000000000000000000000000000000000000000000000000000014"
        });
    }

    function testArg() public view {
        console2.log(address(forwarder));
        console2.log(address(recipient));
    }

    function testVerify() public {
        vm.chainId(4);
        assertTrue(forwarder.verify(request, Signature));
    }

    function testFailVerify() public {
        vm.chainId(4);
        bytes memory failSign = hex"a39fa6101761d1a912d26ab259c186e58c1208cecf1ee8703554ff405b3309032a96ca0e06820fba236b06662d92dc430a28061fa0afece16619c9b3e7f562df1c";
        assertTrue(forwarder.verify(request, failSign));
    }

    function testExecute() public {
        vm.chainId(4);
        forwarder.execute(request, Signature);
        assertEq(recipient.retrieve(), 20);
    }
}
