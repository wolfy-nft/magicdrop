// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {IMagicDropCloneFactory} from "../interfaces/IMagicDropCloneFactory.sol";
import {IMagicDropTokenImplRegistry} from "../interfaces/IMagicDropTokenImplRegistry.sol";
import {IInitializableToken} from "../interfaces/IInitializableToken.sol";
import {TokenStandard} from "../common/Structs.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract MagicDropCloneFactory is
    IMagicDropCloneFactory,
    Ownable2StepUpgradeable,
    UUPSUpgradeable
{
    IMagicDropTokenImplRegistry public immutable registry;

    error ImplementationNotRegistered();

    constructor(
        IMagicDropTokenImplRegistry _registry
    ) {
        if (address(_registry) == address(0)) {
            revert ConstructorRegistryAddressCannotBeZero();
        }

        registry = _registry;
    }

    function initialize() public initializer {
        __Ownable2Step_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        emit MagicDropFactoryInitialized();
    }

    function createContract(
        string calldata name,
        string calldata symbol,
        TokenStandard standard,
        address payable initialOwner,
        uint256 implId,
        bytes32 salt
    ) external override returns (address) {
        address impl = registry.getImplementation(standard, implId);

        if (impl == address(0)) {
            revert ImplementationNotRegistered();
        }

        bytes32 cloneSalt = keccak256(abi.encodePacked(salt, blockhash(block.number)));

        address instance = Clones.cloneDeterministic(impl, cloneSalt);

        IInitializableToken(instance).initialize(
            name,
            symbol,
            initialOwner
        );

        emit NewContractInitialized({
            contractAddress: instance,
            initialOwner: initialOwner,
            implId: implId,
            standard: standard,
            name: name,
            symbol: symbol
        });

        return instance;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
