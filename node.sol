// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

import "./consensus.sol";
import "./blockchain.sol";

// Inherits both the blockchain and consensus mechanism
// This is because in reality, each validator has its own copy of the blockchain and consensus engine
contract Node is Blockchain, Consensus{
    //string public current_message;
    //uint public current_block_quorum;
    //Block public current_block;
    string private current_message; // We changed current_message from public to private because this variable is only a temporary value used inside Node, and the modification allows the contract to keep this working data hidden from both external contracts and child contracts, which we need because only Node itself uses it when building and resetting a proposed block
    uint private current_block_quorum;//We changed current_block_quorum from public to private because this variable is only an internal counter for the current node’s validation process, and the modification allows the contract to keep the voting state encapsulated inside Node, which we need because the quorum count is only updated and checked during block proposal and finality
    Block private current_block; //We changed current_block from public to private because the block being processed is only used by the current node during validation and finalization, and the modification allows the contract to avoid exposing intermediate block state to the outside world, which we need because only internal node logic reads, updates, and deletes this value
    
    /// @dev this function starts the genesis block and manually loads some peers, letting the peers know about the in the process
    /// check out what payable does
    constructor(address[] memory list_of_addresses, string memory message) Blockchain(message){
        uint i = list_of_addresses.length;
        while (i>0){
            // Get an address from the list
            address target = list_of_addresses[i-1];

            // Hard load a list of initial addresses
            add_peer(target);

            //Now let the peers know about the existence of this node
            Node(target).add_peer(address(this));
            
            //Move onto next address
            i--;
        }
    }

    // Nodes should be able to receive user data
    // In our very simple case, our node is only able to accept one message at a time.
    // In reality, validators pick transactions from a mempool
    function user_input(string calldata message) external {
        bytes memory converted_msg = bytes(message);
        require(converted_msg.length != 0, "Empty data requests not accepted");

        current_message = message;
        current_block = build_block(current_message);
    }

    // Validators are able to build and propose the next block on the chain.
    function propose_block() external {

        // Request all peers for approval, gain quorum
        uint length = current_validator_nodes.length;
        for (uint i = 0; i < length; i++){
            address peer = current_validator_nodes[i];
            current_block_quorum += Node(peer).check_block(current_block);
        }
    }

    // When blocks receive the required amount of approvals, they are added to the blockchain
    //function check_block_finality_and_build() public {
    function check_block_finality_and_build() external { //We changed check_block_finality_and_build from public to external because the function is intended to be triggered from outside the contract and is not called internally, and the modification allows it to remain callable by users while being slightly more efficient than public visibility, which we need because this function serves as an external entry point for finalizing the block after quorum is reached
        // Check quorum
        if(current_block_quorum==quorum){
            // Add block to the chain
            blockchain.push(current_block);
            next_block_num++;
            // Inform other Nodes to finalize this block
            uint length = current_validator_nodes.length;
            for(uint i = 0; i < length; i++ ){
                Node(current_validator_nodes[i]).finalize_block(current_block);
            }
        }
    }

    // Other nodes may send the finalize block command.
    // Check if the block conforms to th blockchain and add block
    function finalize_block(Block memory received_block) external {
        require(received_block.blockNum == next_block_num, "Block proposal failure");

        blockchain.push(received_block);
        next_block_num++;

        // Reset all current work
        current_message = "";
        current_block_quorum = 0;
        delete current_block;
    }
}