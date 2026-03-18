// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Blockchain{
    struct Block{
        bytes32 hash;
        bytes32 prevHash;
        uint blockNum;
        string message;
    }

    //Block[] public blockchain;
    Block[] internal blockchain; //We changed blockchain from public to internal because the state array is only manipulated within Blockchain and its child contract Node, and the modification allows inherited contracts to use the chain data without making the full structure externally accessible, which we need because Node pushes validated blocks into the blockchain

    //uint public next_block_num;
    uint internal next_block_num ; //We changed next_block_num from public to internal because this counter is only relevant to the internal blockchain logic and inherited contract behavior, and the modification allows Node to update and read the next block number without exposing it through a public getter, which we need because block validation and block insertion depend on the current expected block number

    // The first block of any blockchain is called the gensis block
    constructor(string memory secret_first_phrase){
        Block memory genesis = Block({
            hash: hashFunc(secret_first_phrase),
            prevHash: "",
            blockNum: 0,
            message: secret_first_phrase
        });
        next_block_num = 1;
        blockchain.push(genesis);
    }

    // Hash the message together
    //function hashFunc(string memory data) public pure returns(bytes32){
    function hashFunc(string memory data) private pure returns(bytes32){
    // We changed hashFunc from public to private because the function is only used inside Blockchain itself and never called from Node or outside contracts, and the modification allows the compiler to restrict access to the defining contract only, which we need because hashing is just an internal helper for creating block hashes
        return keccak256(abi.encodePacked(data));
    }

    //function build_block(string memory message) public view returns(Block memory){
    function build_block(string memory message) internal view returns(Block memory){ //We changed build_block from public to internal because the function must be accessible from the child contract Node but is not intended for external users, and the modification allows inherited contracts to reuse the block-construction logic without opening it as a public interface, which we need because Node calls build_block when a user submits a new message
        //fetch the current block
        Block memory current_block = blockchain[next_block_num-1];
        Block memory new_block = Block({
            hash: hashFunc(message),
            prevHash: current_block.hash,
            blockNum: next_block_num,
            message: message
        });

        return new_block;
    }
    // 1 for approved, 0 for fail
    //function check_block(Block memory proposed_block) public view returns(uint){
    function check_block(Block memory proposed_block) external view returns(uint){ //We changed check_block from public to external because the function is meant to be called by other deployed node contracts rather than from inside the same contract, and the modification allows direct inter-contract calls with lower overhead than a public function, which we need because each node checks a proposed block by calling Node(peer).check_block(current_block)
        //Get the current block
        Block memory current_block = blockchain[next_block_num-1];

        // Conditions can be enforced in Solidity using require or revert statements
        // Check that the block numbers are consequential
        // Check the hash and previous hash are correctly linked
        if(proposed_block.blockNum - current_block.blockNum != 1){
            return 0;
        }
        if(proposed_block.prevHash != current_block.hash){
            return 0;
        }

        return 1;
    }
}
