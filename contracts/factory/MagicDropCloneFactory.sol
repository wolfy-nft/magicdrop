// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {TokenStandard} from "../common/Structs.sol";
import {ERC721MagicDropCloneable} from "../nft/erc721m/clones/ERC721MagicDropCloneable.sol";
import {ZKProxy} from "../common/ZKProxy.sol";

interface ContractDeployer {
    function getNewAddressCreate2(address _sender, bytes32 _bytecodeHash, bytes32 _salt, bytes calldata _input)
        external
        view
        returns (address newAddress);

    function create2(bytes32 _salt, bytes32 _bytecodeHash, bytes calldata _input) external payable returns (address);
}

/// @title MagicDropCloneFactory
/// @notice A factory contract for creating and managing clones of MagicDrop contracts
/// @dev This contract uses the UUPS proxy pattern
contract MagicDropCloneFactory is Ownable {
    address public immutable implementation;
    uint256 public deploymentFee;

    address public constant CONTRACT_DEPLOYER = 0x0000000000000000000000000000000000008006;

    /*==============================================================
    =                             EVENTS                           =
    ==============================================================*/

    event MagicDropFactoryInitialized();
    event NewContractInitialized(
        address contractAddress, address initialOwner, uint32 implId, TokenStandard standard, string name, string symbol
    );
    event Withdrawal(address to, uint256 amount);

    /*==============================================================
    =                             ERRORS                           =
    ==============================================================*/

    error InitializationFailed();
    error RegistryAddressCannotBeZero();
    error InsufficientDeploymentFee();
    error WithdrawalFailed();
    error InitialOwnerCannotBeZero();

    /*==============================================================
    =                          CONSTRUCTOR                         =
    ==============================================================*/

    /// @param initialOwner The address of the initial owner
    constructor(address initialOwner) {
        _initializeOwner(initialOwner);

        emit MagicDropFactoryInitialized();

        implementation = address(new ERC721MagicDropCloneable());
    }

    /*==============================================================
    =                      PUBLIC WRITE METHODS                    =
    ==============================================================*/

    /// @notice Creates a new deterministic clone of a MagicDrop contract
    /// @param name The name of the new contract
    /// @param symbol The symbol of the new contract
    /// @param standard The token standard of the new contract
    /// @param initialOwner The initial owner of the new contract
    /// @param implId The implementation ID
    /// @param salt A unique salt for deterministic address generation
    /// @return The address of the newly created contract
    function createContractDeterministic(
        string calldata name,
        string calldata symbol,
        TokenStandard standard,
        address payable initialOwner,
        uint32 implId,
        bytes32 salt
    ) external payable returns (address) {
        if (initialOwner == address(0)) {
            revert InitialOwnerCannotBeZero();
        }

        if (msg.value != deploymentFee) {
            revert InsufficientDeploymentFee();
        }

        bytes memory bytecode = type(ZKProxy).creationCode;
        bytes memory constructorArgs = abi.encode(implementation);
        bytes memory deploymentBytecode = bytes.concat(bytecode, constructorArgs);

        address instance =
            ContractDeployer(CONTRACT_DEPLOYER).create2(salt, keccak256(deploymentBytecode), constructorArgs);

        ERC721MagicDropCloneable(instance).initialize(name, symbol, initialOwner);

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

    /// @notice Creates a new clone of a MagicDrop contract
    /// @param name The name of the new contract
    /// @param symbol The symbol of the new contract
    /// @param standard The token standard of the new contract
    /// @param initialOwner The initial owner of the new contract
    /// @param implId The implementation ID
    /// @return The address of the newly created contract
    function createContract(
        string calldata name,
        string calldata symbol,
        TokenStandard standard,
        address payable initialOwner,
        uint32 implId
    ) external payable returns (address) {
        if (initialOwner == address(0)) {
            revert InitialOwnerCannotBeZero();
        }

        if (msg.value != deploymentFee) {
            revert InsufficientDeploymentFee();
        }

        address instance = address(new ZKProxy(implementation));
        ERC721MagicDropCloneable(instance).initialize(name, symbol, initialOwner);

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

    /*==============================================================
    =                      PUBLIC VIEW METHODS                     =
    ==============================================================*/

    /// @notice Predicts the deployment address of a proxy contract
    /// @param salt The salt used for address generation
    /// @return The predicted proxy deployment address
    function predictDeploymentAddress(bytes32 salt) external view returns (address) {
        bytes memory bytecode = type(ZKProxy).creationCode;
        bytes memory constructorArgs = abi.encode(implementation);
        bytes memory deploymentBytecode = bytes.concat(bytecode, constructorArgs);

        return ContractDeployer(CONTRACT_DEPLOYER).getNewAddressCreate2(
            address(this), keccak256(deploymentBytecode), salt, constructorArgs
        );
    }

    /*==============================================================
    =                      ADMIN OPERATIONS                        =
    ==============================================================*/

    /// @notice Withdraws the contract's balance
    function withdraw(address to) external onlyOwner {
        (bool success,) = to.call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        emit Withdrawal(to, address(this).balance);
    }

    /// @dev Overriden to prevent double-initialization of the owner.
    function _guardInitializeOwner() internal pure virtual override returns (bool) {
        return true;
    }

    /// @notice Receives ETH
    receive() external payable {}

    /// @notice Fallback function to receive ETH
    fallback() external payable {}
}
