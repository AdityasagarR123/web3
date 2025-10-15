Sentiment-Weighted Voting Smart Contract
This Solidity smart contract implements an innovative voting system where the final outcome of a proposal is influenced by a dynamic, external sentiment score. It's designed to model a hybrid governance system where direct democratic voting is weighted by the broader public or community sentiment.

Core Concept
Traditional on-chain voting systems count every vote equally. This contract introduces a twist: the "weight" of positive and negative votes can be altered based on a sentiment score.

How it works:
A trusted entity (like a decentralized oracle or, in this implementation, the contract owner) provides a sentiment score ranging from -100 (overwhelmingly negative) to +100 (overwhelmingly positive).

A positive sentiment score increases the weight of all Positive votes and decreases the weight of Negative votes.

A negative sentiment score does the opposite, giving more power to the Negative votes.

This mechanism ensures that a proposal with massive public support gets an extra push, while a controversial proposal with significant public backlash faces a higher bar to pass, even if the raw vote count is close.

Features
Owner-Controlled Sessions: A designated owner is responsible for starting and ending voting periods.

Public Voting: Anyone can cast a vote (Positive, Negative, or Neutral) for the active proposal.

Prevents Double Voting: Each address can only vote once per contract deployment.

Sentiment Weighting: The owner can update a sentiment score that directly impacts the final vote tally.

Event-Driven: The contract emits events for key actions like starting a vote, casting a vote, and ending a session, allowing for easy off-chain monitoring.

Transparent Calculation: The final weighted tally is calculated on-chain, and the result ("Proposal Passed," "Proposal Failed," or "Tie") is emitted in an event.

How a Voting Session Works
Deployment & Ownership: The contract is deployed, and the deployer calls setOwner() to claim ownership.

Start Voting: The owner calls startVoting(string memory _proposalText) to begin a new session. This resets all vote counts and sets the proposal text.

Cast Votes: Users call castVote(VoteOption _vote) with their choice (0 for Negative, 1 for Neutral, 2 for Positive).

Update Sentiment: During the voting period, the owner (simulating an oracle) calls updateSentiment(int256 _newScore) to set the sentiment score. This can be done multiple times as sentiment changes.

End Voting: The owner calls endVoting(). The contract calculates the final weighted scores and determines the outcome. The VotingEnded event is emitted with the final tallies and result.

The Weighting Formula
The final tallies are calculated as follows:

positiveWeight = 1000 + sentimentScore

negativeWeight = 1000 - sentimentScore

finalPositiveTally = positiveVotes * positiveWeight

finalNegativeTally = negativeVotes * negativeWeight

The outcome is decided by comparing finalPositiveTally and finalNegativeTally.

The Oracle Problem
This implementation relies on a centralized owner to update the sentiment score. In a real-world, decentralized application, this function should be controlled by a trusted decentralized oracle (e.g., Chainlink). The oracle would fetch sentiment data from various off-chain sources (social media APIs, news analysis, etc.), aggregate it, and feed the score to the smart contract in a trustless manner.

Getting Started
To use this contract, you will need a development environment like Hardhat or Foundry.

Compile the Contract:
Use your preferred framework to compile SentimentVoting.sol.

Deploy to a Network:
Deploy the compiled contract to your desired blockchain (e.g., a local testnet, Ethereum testnet, or mainnet).

Interact with the Contract:

First, call setOwner() from the deployer address.

Use the contract's ABI to interact with its functions (startVoting, castVote, etc.) through a script or a dApp interface.
