// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IMagicDropMetadata} from "contracts/common/IMagicDropMetadata.sol";

interface IERC1155MagicDropMetadata is IMagicDropMetadata {
    struct TokenSupply {
        uint64 maxSupply;
        uint64 totalSupply;
        uint64 totalMinted;
    }

    error MaxSupplyCannotBeGreaterThan2ToThe64thPower();

    event MaxSupplyUpdated(uint256 tokenId, uint256 oldMaxSupply, uint256 newMaxSupply);

    error WalletLimitExceeded(uint256 tokenId);

    event WalletLimitUpdated(uint256 tokenId, uint256 newWalletLimit);

    function setMaxSupply(uint256 tokenId, uint256 newMaxSupply) external;

    function setWalletLimit(uint256 tokenId, uint256 newWalletLimit) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function maxSupply(uint256 tokenId) external view returns (uint256);

    function totalSupply(uint256 tokenId) external view returns (uint256);

    function totalMinted(uint256 tokenId) external view returns (uint256);

    function walletLimit(uint256 tokenId) external view returns (uint256);
}