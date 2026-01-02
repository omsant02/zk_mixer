// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IVerifier} from "./Verifier.sol";
import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";

contract Mixer is IncrementalMerkleTree{
    IVerifier public immutable i_verifier;

    mapping (bytes32 => bool) public s_commitments;
    mapping (bytes32 => bool) public s_nullifierHashes;

    uint256 public constant DENOMINATION = 0.001 ether;

    //EVENT
    event Deposit(bytes32 indexed commitment, uint32 insertedIndex, uint256 timestamp);
    event Withdraw(address indexed recipient, bytes32 nullifierHash);

    //Error
    error Mixer__CommitmentAlreadyAdded(bytes32 commitment);
    error Mixer__DepositAmountNotCorrect(uint256 amountSent, uint256 expectedAmount);
    error Mixer__UnknownRoot(bytes32 root);
    error Mixer__NullifierAlreadyUsed(bytes32 nullifierHash);
    error Mixer__InvalidProof();
    error Mixer__PaymentFailed(address recipient, uint256 amount);

    constructor(IVerifier _verifier, uint32 _merkleTreeDepth, Poseidon2 _hasher) IncrementalMerkleTree(_merkleTreeDepth, _hasher){
        i_verifier = _verifier;
    }

    function deposit(bytes32 _commitment) external payable {
        if(s_commitments[_commitment]) {
            revert Mixer__CommitmentAlreadyAdded(_commitment);
        }
        if(msg.value != DENOMINATION) {
            revert Mixer__DepositAmountNotCorrect(msg.value, DENOMINATION);
        }
        uint32 insertedIndex = _insert(_commitment);
        s_commitments[_commitment] = true;

        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    function withdraw(bytes memory _proof, bytes32 _root, bytes32 _nullifierHash, address payable _recipient) external {
        if(!isKnownRoot(_root)) {
            revert Mixer__UnknownRoot(_root);
        }

        if (s_nullifierHashes[_nullifierHash]) {
            revert Mixer__NullifierAlreadyUsed(_nullifierHash);
        }

        bytes32[] memory publicInputs = new bytes32[](3);
        publicInputs[0] = _root;
        publicInputs[1] = _nullifierHash;
        publicInputs[2] = bytes32(uint256(uint160(address(_recipient))));

        if (!i_verifier.verify(_proof, publicInputs)) {
            revert Mixer__InvalidProof();
        }

        s_nullifierHashes[_nullifierHash] = true;

        (bool success,) = _recipient.call{value: DENOMINATION}("");
        if (!success) {
            revert Mixer__PaymentFailed(_recipient, DENOMINATION);
        }

        emit Withdraw(_recipient, _nullifierHash);
    }
}