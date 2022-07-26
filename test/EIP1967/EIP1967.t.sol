// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-1967/NFTImplementation.sol";
import "../../src/EIP-1967/proxy.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract ContractTest is Test {
    using stdStorage for StdStorage;
    NFTProxy private proxy;
    UpgradeableBeacon private upgrade;
    NFTImplementation private NFT;
    NFTImplementationUp private NFTUp;
    
    function setUp() public {
        NFT = new NFTImplementation();
        NFTUp = new NFTImplementationUp();
        upgrade = new UpgradeableBeacon(address(NFT));
        proxy = new NFTProxy(
            address(upgrade),
            abi.encodeWithSignature("initialize(string,uint256)", "TEST", 1000)
        );
    }

    function testInit() public {
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("name()")
        );

        require(success, "Init Fail");
        string memory NFTName = abi.decode(data, (string));
        assertEq(NFTName, "TEST");
    }

    function testMint() public {
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("mint()")
        );

        require(success, "Mint Fail");
        uint256 currentTokenId = abi.decode(data, (uint256));
        assertEq(currentTokenId, 1);    
    }

    function testUpgradeByOwner() public {
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("mint()")
        );

        require(success, "Mint Fail");

        upgrade.upgradeTo(address(NFTUp));

        (bool burnCall, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("burn()")
        );
        require(burnCall, "Burn Fail");
        uint256 currentTokenId = abi.decode(data, (uint256));
        assertEq(currentTokenId, 0);  
    }

    function testFailUpgradeByNotOwner() public {
        vm.prank(address(1));
        upgrade.upgradeTo(address(NFTUp));
        proxy.upgradeProxy(address(upgrade), bytes(""));
        vm.stopPrank();
    }

    
    // function testMultiProxy() public {
    //     NFTProxy proxyNext = new NFTProxy(
    //         address(upgrade),
    //         abi.encodeWithSignature("initialize(string,uint256)", "TEST2", 1000)
    //     );
    //     (bool proxyMint, ) = address(proxy).call(
    //         abi.encodeWithSignature("mint()")
    //     );
    //     require(proxyMint, "Proxy Mint Fail");        
    //     (bool proxyNextMint, ) = address(proxyNext).call(
    //         abi.encodeWithSignature("mint()")
    //     );
    //     require(proxyNextMint, "ProxyNext Mint Fail");


    // }
}