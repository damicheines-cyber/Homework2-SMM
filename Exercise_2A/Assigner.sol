// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node.sol";

contract Assigner {
    address[] public nodes;

    // register new node
    function registerNode(address nodeAddress) external {
        require(nodeAddress != address(0), "Invalid node address");
        nodes.push(nodeAddress);
    }

    // update peers to maintain the circle
    function assignPeer(address nodeAddress) external {
        require(nodes.length > 0, "No nodes registered");
        uint total = nodes.length;

        if (total == 1) {
            Node(nodeAddress).add_peer(nodeAddress);
        } else {
            address head = nodes[0];
            address newTail = nodes[total - 1];
            address oldTail = nodes[total - 2];

            Node(oldTail).add_peer(newTail);
            Node(newTail).add_peer(head);
        }
    }
}