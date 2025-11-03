BountyHub Smart Contract

Overview
**BountyHub** is a decentralized bounty and task reward platform built on the **Stacks blockchain**.  
It enables users to create, manage, and fund bounties in a transparent, trustless, and automated way using **Clarity smart contracts**.  
Participants can complete listed tasks, submit proof of work, and receive verified on-chain rewards in STX or supported tokens.

---

Features

- **Bounty Creation:**  
  Users can post bounties with detailed task descriptions and lock STX as rewards.

- **Submission & Approval:**  
  Participants can submit their completed work for review. Task owners verify and approve submissions.

- **Reward Distribution:**  
  Approved participants automatically receive the bounty reward from the contract.

- **Secure Escrow System:**  
  Rewards remain locked until a task is completed and verified.

- **On-Chain Transparency:**  
  All bounties, submissions, and payouts are verifiable on the blockchain.

---

Smart Contract Functionalities

| Function | Description |
|-----------|--------------|
| `create-bounty` | Allows a user to create a new bounty with reward amount and description. |
| `submit-task` | Enables a participant to submit proof of task completion. |
| `approve-submission` | Bounty owner approves a valid submission, triggering the reward payout. |
| `cancel-bounty` | Cancels an active bounty and refunds the locked STX to the owner. |
| `get-bounty` | Returns details of a specific bounty by ID. |
| `list-bounties` | Lists all open bounties for discovery. |

---

Technical Details

- **Language:** Clarity  
- **Network:** Stacks Blockchain  
- **Testing Framework:** Clarinet  
- **Token Support:** STX (default), with potential SIP-010 token integration  
- **Contract Type:** Decentralized Escrow and Bounty Management System  

---

Local Development

Prerequisites
Ensure you have the following installed:
- [Clarinet](https://docs.hiro.so/clarinet/getting-started)
- Node.js (optional, for automation scripts)

Steps to Run Locally
```bash
# Clone the repository
git clone https://github.com/your-username/bountyhub.git

# Navigate into the directory
cd bountyhub

# Run Clarity checks
clarinet check

# Run tests
clarinet test
