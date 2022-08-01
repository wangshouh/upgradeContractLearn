// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/EIP-2535/Diamond.sol";
import "../../src/EIP-2535/facets/TestFacet.sol";
import "../../src/EIP-2535/facets/DiamondCutFacet.sol";
import "../../src/EIP-2535/facets/DiamondLoupeFacet.sol";
import "../../src/EIP-2535/facets/OwnershipFacet.sol";

import "../../src/EIP-2535/interfaces/IDiamondCut.sol";
import "../../src/EIP-2535/interfaces/IDiamondLoupe.sol";
import "../../src/EIP-2535/interfaces/IERC173.sol";

contract SetupScript is Script {
    function run() external {
        vm.startBroadcast();
        DiamondCutFacet cutfacet = new DiamondCutFacet();
        DiamondLoupeFacet loupefacet = new DiamondLoupeFacet();
        OwnershipFacet ownerfacet = new OwnershipFacet();

        bytes4[] memory cutFunctions = new bytes4[](1);
        bytes4[] memory loupeFunctions = new bytes4[](4);
        bytes4[] memory ownerFunctions = new bytes4[](2);
        IDiamondCut.FacetCut[] memory _diamondCut = new IDiamondCut.FacetCut[](
            3
        );

        cutFunctions[0] = bytes4(0x1f931c1c); //diamondCut((address,uint8,bytes4[])[],address,bytes)
        _diamondCut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(cutfacet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: cutFunctions
            })
        );

        loupeFunctions[0] = bytes4(0x7a0ed627); //facets()
        loupeFunctions[1] = bytes4(0xadfca15e); //facetFunctionSelectors(address)
        loupeFunctions[2] = bytes4(0x52ef6b2c); //facetAddresses()
        loupeFunctions[3] = bytes4(0xcdffacc6); //facetAddress(bytes4)
        _diamondCut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(loupefacet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: loupeFunctions
            })
        );

        ownerFunctions[0] = bytes4(0xf2fde38b); //transferOwnership(address)
        ownerFunctions[1] = bytes4(0x8da5cb5b); //owner
        _diamondCut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerfacet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: ownerFunctions
            })
        );

        Diamond.DiamondArgs memory diamondArgs;
        diamondArgs.name = "Test";
        diamondArgs.maxSupply = 1000;

        Diamond diamond = new Diamond(_diamondCut, diamondArgs);
        vm.stopBroadcast();
    }
}

contract UpdateScript is Script {
    function run() external {
        vm.startBroadcast();
        TestFacet testfacet = new TestFacet();
        bytes4[] memory testFunctions = new bytes4[](3);
        IDiamondCut.FacetCut[] memory _testDiamondCut = new IDiamondCut.FacetCut[](1);

        testFunctions[0] = bytes4(0x06fdde03); //name
        testFunctions[1] = bytes4(0x18160ddd); //totalSupply
        testFunctions[2] = bytes4(0xd5abeb01); //maxSupply

        _testDiamondCut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(testfacet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: testFunctions
            })
        );
        
        IDiamondCut(address(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9)).diamondCut(
            _testDiamondCut,
            address(0x0),
            new bytes(0)
        );
        vm.stopBroadcast();

    }
}