#!/usr/bin/env bash

source ./cmds/contract.sh
source ./cmds/utils.sh

main_menu() {
    trap "echo 'Exiting...'; exit 1" SIGINT

    show_main_title

    load_private_key

    option=$(gum choose \
    "Deploy Contracts" \
    "Manage Contracts" \
    "Token Operations" \
    "Quit")

    case $option in
        "Deploy Contracts")
            deploy_contract
            ;;
        "Manage Contracts")
            contract_management_menu
            ;;
        "Token Operations")
            token_operations_menu
            ;;
        "Quit")
            echo "Exiting..."
            exit 0
            ;;
    esac

    go_to_main_menu_or_exit
}

contract_management_menu() {
    local option=$(gum choose \
        "Initialize contract" \
        "Set Base URI (ERC721 Only)" \
        "Set URI (ERC1155 Only)" \
        "Set Stages" \
        "Set Royalties" \
        "Set Global Wallet Limit" \
        "Set Max Mintable Supply" \
        "Set Mintable" \
        "Set Cosigner" \
        "Set Token URI Suffix" \
        "Set Timestamp Expiry" \
        "Transfer Ownership" \
        "Manage Authorized Minters"\
        "Go to Main Menu")

    case $option in
        "Initialize contract")
            setup_contract
            ;;
        "Set Global Wallet Limit")
            set_global_wallet_limit
            ;;
        "Set Max Mintable Supply")
            set_max_mintable_supply
            ;;
        "Set Mintable")
            set_mintable
            ;;
        "Set Stages")
            set_stages
            ;;
        "Set Timestamp Expiry")
            set_timestamp_expiry
            ;;
        "Transfer Ownership")
            transfer_ownership
            ;;
        "Set Royalties")
            set_royalties
            ;;
        "Set Base URI (ERC721 Only)")
            set_base_uri
            ;;
        "Set URI (ERC1155 Only)")
            set_uri
            ;;
        "Set Token URI Suffix")
            set_token_uri_suffix
            ;;
        "Set Cosigner")
            set_cosigner
            ;;
        "Manage Authorized Minters")
            manage_authorized_minters
            ;;
        "Go to Main Menu")
            main_menu
            ;;
    esac
}

token_operations_menu() {
    local option=$(gum choose \
        "Owner Mint" \
        "Send ERC721 Batch"\
        "Go to Main Menu")

    case $option in
        "Owner Mint")
            owner_mint
            ;;
        "Send ERC721 Batch")
            send_erc721_batch
            ;;
        "Go to Main Menu")
            main_menu
            ;;
    esac
}

go_to_main_menu_or_exit() {
    if gum confirm "Go to main menu?"; then
        main_menu
    else
        echo "Exiting..."
        exit 0
    fi
}
