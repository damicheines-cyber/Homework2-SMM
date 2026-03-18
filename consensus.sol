// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Consensus{
    //address[] public current_validator_nodes;
    // uint public quorum;
    address[]  internal current_validator_nodes; //We changed current_validator_nodes from public to internal because the variable is only needed inside Consensus and in the child contract Node, and the modification allows inherited access without exposing the validator list to the outside world, which we need because Node reads this array when proposing and finalizing blocks
    uint internal  quorum; //We changed quorum from public to internal because the variable is only used inside the contract hierarchy and not by external users, and the modification allows the child contract Node to access it directly while avoiding an unnecessary public getter, which we need because Node compares current block quorum with quorum before finalizing a block
        function add_peer(address peer) public{
        current_validator_nodes.push(peer);
        quorum++;
    }

    
}
