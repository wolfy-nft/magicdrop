// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {MagicDropCloneFactory} from "../../contracts/factory/MagicDropCloneFactory.sol";
import {TokenStandard} from "../../contracts/common/Structs.sol";
import {ERC721MagicDropCloneable} from "../../contracts/nft/erc721m/clones/ERC721MagicDropCloneable.sol";

contract MagicDropCloneFactoryTestV2 is Test {
    MagicDropCloneFactory internal factory;

    address internal owner = payable(address(0x1));
    address internal user = payable(address(0x2));

    function setUp() public {
        vm.startPrank(owner);

        factory = new MagicDropCloneFactory(owner);

        vm.deal(user, 100 ether);

        vm.stopPrank();
    }

    function testCreateContract() public {
        vm.startPrank(user);
        address contractAddress = factory.createContract("TestNFT", "TNFT", TokenStandard.ERC721, payable(user), 0);
        vm.stopPrank();

        vm.assertEq(ERC721MagicDropCloneable(contractAddress).owner(), user);
    }

    function testCreateContractDeterministic() public {
        vm.startPrank(user);
        bytes32 salt = bytes32(uint256(0));
        address contractAddress =
            factory.createContractDeterministic("TestNFT", "TNFT", TokenStandard.ERC721, payable(user), 0, salt);
        vm.stopPrank();

        vm.assertEq(ERC721MagicDropCloneable(contractAddress).owner(), user);
    }

    function testPredictDeploymentAddress() public {
        bytes32 salt = bytes32(uint256(0));
        address expectedAddress = factory.predictDeploymentAddress(salt);

        vm.startPrank(user);
        address contractAddress = factory.createContractDeterministic("TestNFT", "TNFT", TokenStandard.ERC721, payable(user), 0, salt);
        vm.stopPrank();

        vm.assertEq(contractAddress, expectedAddress);
    }

    function testFailWithdrawToNonOwner() public {
        vm.startPrank(user);
        vm.expectRevert("Unauthorized()");
        factory.withdraw(user);
    }
}
