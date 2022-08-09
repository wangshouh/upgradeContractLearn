// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-712/product.sol";
import "../../src/EIP-712/IProduct.sol";

contract ProductTest is Test {
    ProductEIP712 private product;

    function setUp() public {
        product = new ProductEIP712("Ether Mail", "1");
    }

    function testArg() public {
        vm.chainId(4);
        console2.log(address(product));
    }

    function testVerify() public {
        vm.chainId(4);
        vm.prank(0x11475691C2CAA465E19F99c445abB31A4a64955C);

        bytes
            memory Signature = hex"70aa843f69e5d32252c65011b34831e79c9c64752134d9318cdefb7f8d7a04ac08a2193aedb8f329a8d80f5390c7f661fe447ccc9337ebed15b578c01d7dc71e1c";
        IProduct.Person memory PersonFrom = IProduct.Person({
            name: "Cow",
            wallet: address(0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826)
        });
        IProduct.Person memory PersonTo = IProduct.Person({
            name: "Bob",
            wallet: address(0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB)
        });
        IProduct.Mail memory mail = IProduct.Mail({
            contents: "Hello, Bob!",
            from: PersonFrom,
            to: PersonTo
        });
        product.verify(mail, Signature);
        vm.stopPrank();
    }
}
