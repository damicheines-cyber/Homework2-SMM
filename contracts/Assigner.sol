// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./node.sol";

// VRF imports
// talking to the oracle 
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Assigner is VRFConsumerBaseV2Plus {

    // Ring network

    address[] public nodes;
    address public currentProposer;

    // VARIABLES TO MAKE A REQUEST

    uint256 public s_subscriptionId; 
    bytes32 public s_keyHash; 
    uint32 public s_callbackGasLimit = 100000;
    uint16 public s_requestConfirmations = 3;
    uint32 public s_numWords = 1; 
    uint256[] public s_randomWords;
    uint256 public s_requestId;

    event ReturnedRandomness(uint256[] randomWords);

    // Constructor
    constructor(
        uint256 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
    }

    // VRF request

    function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
        s_requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: s_requestConfirmations,
                callbackGasLimit: s_callbackGasLimit,
                numWords: s_numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    // VRF response
    // This is the function the Oracle calls back with the answer

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        s_randomWords = randomWords;
        emit ReturnedRandomness(randomWords);

        // select proposer
        require(nodes.length > 0, "No nodes available");

        // we use '%' (modulo) to get a number between 0 and the list size
        uint256 index = randomWords[0] % nodes.length;

        //  save the winner's address
        currentProposer = nodes[index];
    }


    // register new node
    function registerNode(address nodeAddress) external {
        require(nodeAddress != address(0), "Invalid node address");
        nodes.push(nodeAddress);
    }

    // update peers to maintain the circle

    function assignPeer(address nodeAddress) external {
        require(nodes.length > 0, "No nodes available");

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


    function getCurrentProposer() public view returns (address) {
        return currentProposer;
    }
}