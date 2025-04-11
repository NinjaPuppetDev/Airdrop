// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {PizzaToken} from "../src/PizzaToken.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdop} from "../script/DeployAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    PizzaToken public pizzaToken;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT = 25 * 1e18;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] proof = [proofOne, proofTwo];
    address public gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdop deployer = new DeployMerkleAirdop();
            (airdrop, pizzaToken) = deployer.deployMerkleAirdop();
        } else {
            pizzaToken = new PizzaToken();
            airdrop = new MerkleAirdrop(ROOT, pizzaToken);
            pizzaToken.mint(pizzaToken.owner(), AMOUNT_TO_CLAIM);
            pizzaToken.transfer(address(airdrop), AMOUNT_TO_CLAIM);
        }

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = pizzaToken.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);

        uint256 endingBalance = pizzaToken.balanceOf(user);

        console.log("Starting balance: ", startingBalance);
        console.log("Ending balance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
