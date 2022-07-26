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

    function ProxyMint(address ProxyAddress) internal returns (uint256) {
        (bool success, bytes memory data) = address(ProxyAddress).call(
            abi.encodeWithSignature("mint()")
        );

        require(success, "Mint Fail");    
        return abi.decode(data, (uint256));
    }

    function ProxyBurn(address ProxyAddress) internal returns (uint256) {
        (bool success, bytes memory data) = address(ProxyAddress).call(
            abi.encodeWithSignature("burn()")
        );
        require(success, "Burn Fail");
        return abi.decode(data, (uint256));
    }

    function testMint() public {
        uint256 currentTokenId = ProxyMint(address(proxy));
        assertEq(currentTokenId, 1);    
    }

    function testUpgradeByOwner() public {
        uint256 upgradeBeforeMint = ProxyMint(address(proxy));
        assertEq(upgradeBeforeMint, 1); 

        upgrade.upgradeTo(address(NFTUp));

        uint256 currentTokenId = ProxyBurn(address(proxy));
        assertEq(currentTokenId, 0);  
    }

    function testFailUpgradeByNotOwner() public {
        vm.prank(address(1));
        upgrade.upgradeTo(address(NFTUp));
        proxy.upgradeProxy(address(upgrade), bytes(""));
        vm.stopPrank();
    }

    
    function testMultiProxy() public {
        NFTProxy proxyNext = new NFTProxy(
            address(upgrade),
            abi.encodeWithSignature("initialize(string,uint256)", "TEST2", 1000)
        );
        uint256 ProxyNextBeforeMint = ProxyMint(address(proxyNext));       
        assertEq(ProxyNextBeforeMint, 1); 
        uint256 ProxyBeforeMint = ProxyMint(address(proxy));
        assertEq(ProxyBeforeMint, 1);

        upgrade.upgradeTo(address(NFTUp));

        uint256 ProxyNextBurnId = ProxyBurn(address(proxyNext));
        assertEq(ProxyNextBurnId, 0);  
        uint256 ProxyBurnId = ProxyBurn(address(proxy));
        assertEq(ProxyBurnId, 0); 
    }
}