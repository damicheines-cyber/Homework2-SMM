// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// select a random leader from a list of nodes

// talking to the oracle 
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// Verifiable random function infrastructure 
contract AssignerVRF is VRFConsumerBaseV2Plus {
    
    // nodes in the ring
    address[] public nodes;

    // variables to make a request
    uint256 public s_subscriptionId; 
    bytes32 public s_keyHash; 
    uint32 public s_callbackGasLimit = 100000;
    uint16 public s_requestConfirmations = 3;
    uint32 public s_numWords = 1; 
    uint256 public s_requestId;

    address public currentProposer;

   constructor(address vrfCoordinator) VRFConsumerBaseV2Plus(vrfCoordinator) {}


}