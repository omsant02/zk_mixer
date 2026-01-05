import {Barretenberg, randomBytes} from "@aztec/bb.js";
import {ethers} from "ethers";

export default async function generateCommitment() {
    const bb = await Barretenberg.new();
    
    const nullifier = randomBytes(32);
    const secret = randomBytes(32);

    const commitmentResult = await bb.poseidon2Hash({inputs: [nullifier, secret]});
    const commitmentHash = commitmentResult.hash;
    const result = ethers.AbiCoder.defaultAbiCoder().encode(
        ["bytes32"],
        [commitmentHash]
    )
    
    return result;
}

(async () => {
    try {
        const commitment = await generateCommitment();
        process.stdout.write(commitment);
        process.exit(0);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
})();