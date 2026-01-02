use dep::poseidon::poseidon2::Poseidon2;
mod merkle_tree;

fn main(
    root: pub Field,
    nullifier_hash: pub Field,
    recipient: pub Field,

    nullifier: Field,
    secret: Field,
    merkle_proof: [Field; 20],
    is_even: [bool; 20],
) {
    let commitment: Field = Poseidon2::hash([nullifier, secret], 2);
    let computed_nullifier_hash: Field = Poseidon2::hash([nullifier], 1);
    assert(computed_nullifier_hash == nullifier_hash);

    let computed_root: Field = merkle_tree::compute_merkle_tree(commitment, merkle_proof, is_even);
    assert(computed_root == root);

    let recipient_binding = recipient * recipient;
    assert(recipient_binding == recipient * recipient);
}