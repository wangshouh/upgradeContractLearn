// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/EIP-1967/NFTImplementation.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract ContractTest is Test {
    using stdStorage for StdStorage;
    BeaconProxy private proxy;
    UpgradeableBeacon private upgrade;
    NFTImplementation private NFT;
    
    function setUp() public {
        NFT = new NFTImplementation();
        upgrade = new UpgradeableBeacon(address(NFT));
        proxy = new BeaconProxy(
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

}