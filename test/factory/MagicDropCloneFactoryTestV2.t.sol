// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {MagicDropCloneFactory} from "../../contracts/factory/MagicDropCloneFactory.sol";
import {TokenStandard} from "../../contracts/common/Structs.sol";

contract MagicDropCloneFactoryTest is Test {
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
        factory.createContract("TestNFT", "TNFT", TokenStandard.ERC721, payable(user), 0);
    }

    function testFailWithdrawToNonOwner() public {
        vm.startPrank(user);
        factory.withdraw(user);
    }
}
