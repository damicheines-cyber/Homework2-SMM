// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// PAS ENCORE TESTE
// attente du pull pour les autres documents
// import "./node.sol";

contract Assigner {
    address[] public nodes;

    // register new node
    function registerNode(address nodeAddress) external {
        nodes.push(nodeAddress);
    }

    // update peers to maintain the circle
    function assignPeer(address nodeAddress) external {
        uint total = nodes.length;
        if (total == 1) {
            // a single node should point to itself.
            Node(nodeAddress).set_peer(nodeAddress);
        } else {
            address head = nodes[0];
            address newTail = nodes[total - 1];
            address oldTail = nodes[total - 2];

            // update the old end of the line to point to the new person
            Node(oldTail).set_peer(newTail);
            
            // close the ring
            Node(newTail).set_peer(head);
        }
    }
}