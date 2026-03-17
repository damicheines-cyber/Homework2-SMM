# Homework2-SMM

# Team Task Checklist

## Eya — Exercise 1 + Node Logic

* [ ] **Exercise 1:** Update function scoping (`public`, `private`, `internal`, `external`) and add justification comments.
* [ ] Create **Node.sol basic structure**.
* [ ] Implement `user_input()` to store the message in `current_message`.
* [ ] Implement recursive `propagate(address originator, string message)`.
* [ ] Implement block functions: `propose_block()`, `check_block()`, `finalize_block()`.
* [ ] Implement overloaded `propagate(address proposer, Block block)`.

## Lou — Exercise 2A + VRF

* [ ] Create **Assigner.sol** contract.
* [ ] Implement node registration `registerNode()`.
* [ ] Implement ring topology with `assignPeer()`.
* [ ] Ensure each node stores only **one peer (nextPeer)**.
* [ ] Integrate **Chainlink VRF**.
* [ ] Request randomness using `requestRandomWords()`.
* [ ] Select proposer using `random % nodes.length`.
* [ ] Store proposer in `currentProposer`.

## Inès — Consensus + Staking

* [ ] Create **Staking.sol** contract.
* [ ] Require **minimum funding on deployment**.
* [ ] Implement `stake()` to lock proposer funds.
* [ ] Modify `propose_block()` to require staking.
* [ ] Implement **2/3 quorum rule** in consensus logic.
* [ ] Implement `releaseStake()` for valid blocks.
* [ ] Implement `slashStake()` if block is rejected.

## All Members — Exercise 3

* [ ] Write **unit tests for at least 1 function in each contract**.
* [ ] Write **integration test** (full consensus flow).
* [ ] Run static analysis tool (**Slither or SolidityScan**).
* [ ] Save results in `vulnerabilities.md`.
* [ ] Write **vulnerability business report** (prioritized fixes).
