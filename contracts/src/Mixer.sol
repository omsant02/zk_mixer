// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mixer {
    IVerifier public immutable i_verifier;

    mapping (bytes32 => bool) public s_commitments;

    uint256 public constant DENOMINATION = 0.001 ether;

    //Error
    error Mixer__CommitmentAlreadyAdded(bytes32 commitment);
    error Mixer__DepositAmountNotCorrect(uint256 amountSent, uint256 expectedAmount);

    constructor(IVerifier _verifier) {
        i_verifier = _verifier;
    }

    function deposit(bytes32 _commitment) external payable {
        if(s_commitments[_commitment]) {
            revert Mixer__CommitmentAlreadyAdded(_commitment);
        }
        if(msg.value != DENOMINATION) {
            revert Mixer__DepositAmountNotCorrect(msg.value, DENOMINATION);
        }
        s_commitments[_commitment] = true;
    }

    function withdraw(bytes calldata _proof) external {

    }
}