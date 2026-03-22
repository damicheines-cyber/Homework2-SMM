// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

//importing recquired files
import "remix_tests.sol";
import "remix_accounts.sol";
import "consensus.sol";
import "blockchain.sol";
import "Staking.sol";
import "Assigner_noVRF.sol";

//We use wrappers to expose internal variables so they can be tested without modifying the original contracts.
contract ConsensusWrapper is Consensus {
    function getPeerCount() external view returns (uint) {
        return current_validator_nodes.length;
    }

    function getQuorum() external view returns (uint) {
        return quorum;
    }
}
contract BlockchainWrapper is Blockchain {
    constructor(string memory genesisMsg) Blockchain(genesisMsg) {}

    function exposeBuildBlock(string memory message) external view returns (Block memory) {
        return build_block(message);
    }

    function getChainLength() external view returns (uint) {
        return blockchain.length;
    }

    function getNextBlockNum() external view returns (uint) {
        return next_block_num;
    }
}
//Initializing instances of each tested contract before running tests so they can be reused across all unit tests
contract Test {
    ConsensusWrapper consensus;
    BlockchainWrapper blockchainWrapper;
    Staking staking;
    AssignernoVRF assigner;

    function beforeAll() public payable {
        consensus = new ConsensusWrapper();
        blockchainWrapper = new BlockchainWrapper("genesis");
        staking = (new Staking){value: 1 ether}();
        assigner = new AssignernoVRF();
    }

//Consensus unit test
    function testConsensusAddPeer() public {
        consensus.add_peer(address(0x123));
        Assert.equal(consensus.getPeerCount(), uint(1), "peer count should be 1");
        Assert.equal(consensus.getQuorum(), uint(1), "quorum should be 1");
    }

// Blockchain unit test
    function testBlockchainCheckBlock() public {
        Blockchain.Block memory b = blockchainWrapper.exposeBuildBlock("hello");
        uint result = blockchainWrapper.check_block(b);
        Assert.equal(result, uint(1), "valid block should return 1");
    }

// Staking unit test
    function testStakingMinimumStake() public {
        Assert.equal(staking.minimumStake(), uint(1 ether), "minimum stake should be 1 ether");
    }

// Assigner_noVRF unit test
    function testAssignerRegisterAndSelectProposer() public {
        assigner.registerNode(address(0x111));
        assigner.registerNode(address(0x222));

        assigner.selectProposer(1);
        address proposer = assigner.getCurrentProposer();

        bool valid = proposer == address(0x111) || proposer == address(0x222);
        Assert.ok(valid, "selected proposer should be a registered node");
    }
}

// Node unit test*
contract NodeWrapper is Node {
    constructor(address[] memory peers, string memory genesisMsg,address assignerAddr,
        address stakingAddr) Node(peers, genesisMsg,assignerAddr, stakingAddr) {}

    function getPeerCount() external view returns (uint) {
        return current_validator_nodes.length;
    }
    function getQuorumValue() external view returns (uint) {
        return quorum;
    }
    function getChainLength() external view returns (uint) {
        return blockchain.length;
    }
    function getNextBlockNum() external view returns (uint) {
        return next_block_num;
    }
}
contract TestNode {
    NodeWrapper nodeA;
    NodeWrapper nodeB;
    function beforeAll() public {
    address[] memory peersA; // Use memory instead of storage
    nodeA = new NodeWrapper(peersA, "start", address(0), address(0));
    address[] memory peersB;
    peersB[0] = address(nodeA);
    nodeB = new NodeWrapper(peersB, "start", address(0), address(0));
}
    function testConstructorAddsPeers() public {
        Assert.equal(nodeA.getPeerCount(), uint(1), "node A should know node B after Node B deployment");
        Assert.equal(nodeB.getPeerCount(), uint(1), "node B should know node A from constructor input");
        Assert.equal(nodeA.getQuorumValue(), uint(1), "node A quorum should be 1");
        Assert.equal(nodeB.getQuorumValue(), uint(1), "node B quorum should be 1");
    }
}

// integration test
contract TestIntegration {
    NodeWrapper nodeA;
    NodeWrapper nodeB;
    NodeWrapper nodeC;
    function beforeAll() public {
        address[] memory peersA;
        nodeA = new NodeWrapper(peersA, "start", address(0), address(0));
        address[] memory peersB;
        peersB[0] = address(nodeA);
        nodeB = new NodeWrapper(peersB, "start", address(0), address(0));
        address[] memory peersC;
        peersC[0] = address(nodeA);
        peersC[1] = address(nodeB);
        nodeC = new NodeWrapper(peersC, "start", address(0), address(0));
    }
    function testEndToEndConsensusBuildsBlock() public {
        nodeA.user_input("hello");
        nodeA.propose_block();
        nodeA.check_block_finality_and_build();
        Assert.equal(nodeA.getChainLength(), uint(2), "node A should have 2 blocks after finalization");
        Assert.equal(nodeB.getChainLength(), uint(2), "node B should have 2 blocks after finalization");
        Assert.equal(nodeC.getChainLength(), uint(2), "node C should have 2 blocks after finalization");
        Assert.equal(nodeA.getNextBlockNum(), uint(2), "node A next block number should be 2");
        Assert.equal(nodeB.getNextBlockNum(), uint(2), "node B next block number should be 2");
        Assert.equal(nodeC.getNextBlockNum(), uint(2), "node C next block number should be 2");
    }
}
