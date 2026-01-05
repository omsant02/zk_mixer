// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Mixer} from "../src/Mixer.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {IncrementalMerkleTree, Poseidon2} from "../src/IncrementalMerkleTree.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract MixerTest is Test {
    Mixer public mixer;
    HonkVerifier public verifier;
    Poseidon2 public hasher;
    address public recipient = makeAddr("recipient");
    
    function setUp() public {
        verifier = new HonkVerifier();
        hasher = new Poseidon2();
        mixer = new Mixer(verifier, 20, hasher);
    }

    function _getCommitment() public returns(bytes32){
        string[] memory inputs = new string[](3);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateCommitment.ts";

        bytes memory result = vm.ffi(inputs);

        bytes32 _commitment = abi.decode(result, (bytes32));

        return _commitment;
    }

    function testMakeDeposit() public {
        bytes32 _commitment = _getCommitment();
        console.log("_commitment:");
        console.logBytes32(_commitment);
    }
}