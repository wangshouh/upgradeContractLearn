// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../src/EIP-2535/interfaces/IDiamondCut.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../src/EIP-2535/Diamond.sol";
import "../../src/EIP-2535/facets/TestFacet.sol";
import "../../src/EIP-2535/facets/DiamondCutFacet.sol";
import "../../src/EIP-2535/facets/DiamondLoupeFacet.sol";
import "../../src/EIP-2535/facets/OwnershipFacet.sol";

contract ContractTest is Test, IDiamondCut {
    using stdStorage for StdStorage;
    TestFacet private testfacet;
    DiamondCutFacet private cutfacet;
    DiamondLoupeFacet private loupefacet;
    OwnershipFacet private ownerfacet;
    Diamond private diamond;

    function setUp() public {
        cutfacet = new DiamondCutFacet();
        loupefacet = new DiamondLoupeFacet();
        ownerfacet = new OwnershipFacet();
        testfacet = new TestFacet();

        bytes4[] memory cutFunctions = new bytes4[](1);
        bytes4[] memory loupeFunctions = new bytes4[](4);
        bytes4[] memory ownerFunctions = new bytes4[](2);
        FacetCut[] memory _diamondCut = new FacetCut[](3);

        cutFunctions[0] = bytes4(0xd8e30e70); //diamondCut
        _diamondCut[0] = (
            FacetCut({
                facetAddress: address(cutfacet),
                action: FacetCutAction.Add,
                functionSelectors: cutFunctions
            })
        );
        loupeFunctions[0] = bytes4(0x7a0ed627); //face()
        loupeFunctions[1] = bytes4(0x567a3f7c); //facetFunctionSelectors()
        loupeFunctions[2] = bytes4(0x52ef6b2c); //facetAddresses()
        loupeFunctions[3] = bytes4(0xe6ff763a); //facetAddress()
        _diamondCut[1] = (
            FacetCut({
                facetAddress: address(loupefacet),
                action: FacetCutAction.Add,
                functionSelectors: loupeFunctions
            })
        );

        ownerFunctions[0] = bytes4(0x880ad0af); //transferOwnership
        ownerFunctions[1] = bytes4(0x8da5cb5b); //owner
        _diamondCut[2] = (
            FacetCut({
                facetAddress: address(ownerfacet),
                action: FacetCutAction.Add,
                functionSelectors: ownerFunctions
            })
        );

        Diamond.DiamondArgs memory diamondArgs;
        diamondArgs.name = "Test";
        diamondArgs.maxSupply = 1000;

        diamond = new Diamond(_diamondCut, diamondArgs);
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}

    function testfacetAddresses() public {
        (bool ok, bytes memory facetAddresses) = address(diamond).call(
            abi.encodeWithSignature("facetAddresses()")
        );
        require(ok, "Get facetAddresses Fail");

        address[] memory facetAddressesReturn = abi.decode(
            facetAddresses,
            (address[])
        );
        assertEq(facetAddressesReturn[0], address(cutfacet));
        assertEq(facetAddressesReturn[1], address(loupefacet));
        assertEq(facetAddressesReturn[2], address(ownerfacet));
    }
}
