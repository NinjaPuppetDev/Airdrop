// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {PizzaToken} from "../src/PizzaToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 25 * 1e18;

    function deployMerkleAirdop() public returns (MerkleAirdrop, PizzaToken) {
        vm.startBroadcast();
        PizzaToken pizzaToken = new PizzaToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(pizzaToken)));
        pizzaToken.mint(pizzaToken.owner(), s_amountToTransfer);
        IERC20(pizzaToken).transfer(address(merkleAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (merkleAirdrop, pizzaToken);
    }

    function run() external returns (MerkleAirdrop, PizzaToken) {
        return deployMerkleAirdop();
    }
}
