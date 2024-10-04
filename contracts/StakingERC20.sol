// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract StakingERC20 is ReentrancyGuard {

    IERC20 public stakingToken;
    uint256 public constant maxDuration = 60; // in seconds
    uint256 public constant DaysInYears = 365; // days
    uint256 public constant Rate = 10; // in percentage

    struct Staker {
        string name;
        uint256 accountBalance;
        uint256 stakeTime;
        bool isCreated;
    }

    // Mapping staker's address to their staker info
    mapping(address => Staker) public stakers;

    // Constructor to set the staking token
    constructor(IERC20 _stakingToken) {
        stakingToken = _stakingToken;
    }

    // Function to stake ERC20 tokens
    function stakeTokens(string memory _name, uint256 _amount) external nonReentrant {
        require(msg.sender != address(0), "Address zero detected");
        require(_amount > 0, "Cannot stake 0 tokens");

        Staker storage staker = stakers[msg.sender];

        // If it's the first time staking, set the name
        if (!staker.isCreated) {
            staker.name = _name;
            staker.isCreated = true;
        }

        staker.accountBalance += _amount;
        staker.stakeTime = block.timestamp;

        // Transfer the staking tokens from the user to the contract
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    // Function to calculate staking rewards
    function calculateRewards(address _staker) public view returns (uint256) {
        Staker storage staker = stakers[_staker];
        require(staker.isCreated, "Staker does not exist");

        uint256 stakedTime = block.timestamp - staker.stakeTime;
        uint256 stakedAmount = staker.accountBalance;

        // Assuming Rate is the annual percentage rate (APR)
        uint256 rewards = (stakedTime * stakedAmount * Rate) / (DaysInYears * 1 days * 100);
        return rewards;
    }

    // Function to withdraw staked tokens and rewards
    function withdrawRewards() external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.accountBalance > 0, "No tokens staked");

        // Calculate the rewards
        uint256 rewards = calculateRewards(msg.sender);

        // Store the amount to transfer
        uint256 amountToTransfer = staker.accountBalance + rewards;

        // Reset staker's balance and staking time
        staker.accountBalance = 0;
        staker.stakeTime = 0;

        // Transfer the staked tokens and rewards back to the staker
        stakingToken.transfer(msg.sender, amountToTransfer);
    }

    // Function to check the contract's token balance (for demonstration/testing purposes)
    function contractTokenBalance() external view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }
}