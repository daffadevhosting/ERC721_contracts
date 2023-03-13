// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/SafeERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NftStaking is IERC721Receiver, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;
    using SafeERC721 for IERC721;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 reward;
    }

    IERC721 public nft;
    uint256 public constant REWARD_PER_DAY = 100;
    uint256 public minStakingTime = 1 days;
    uint256 public maxStakingTime = 30 days;
    mapping(uint256 => Stake) public stakes;
    mapping(address => EnumerableSet.UintSet) private stakedTokens;
    bool private isLocked;

    constructor(address nftAddress) {
        nft = IERC721(nftAddress);
    }

    function stake(uint256 tokenId, uint256 stakingTime) public nonReentrant {
        require(!isLocked, "Contract is locked");
        isLocked = true;
        require(stakingTime >= minStakingTime && stakingTime <= maxStakingTime, "Invalid staking time");
        require(nft.ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(stakedTokens[msg.sender].add(tokenId), "Already staked");
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        stakes[tokenId] = Stake({
            amount: tokenId,
            startTime: block.timestamp,
            endTime: block.timestamp.add(stakingTime),
            reward: stakes[tokenId].reward
        });
        isLocked = false;
    }

    function unstake(uint256 tokenId) public nonReentrant {
        require(!isLocked, "Contract is locked");
        isLocked = true;
        require(stakes[tokenId].amount == tokenId, "Invalid token ID");
        require(stakes[tokenId].endTime <= block.timestamp, "Staking time not reached");
        require(stakedTokens[msg.sender].remove(tokenId), "Token not staked");
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        delete stakes[tokenId];
        isLocked = false;
    }

    function claimReward(uint256 tokenId) public nonReentrant {
        require(!isLocked, "Contract is locked");
        isLocked = true;
        require(stakes[tokenId].amount == tokenId, "Invalid token ID");
        require(stakes[tokenId].endTime <= block.timestamp, "Staking time not reached");
        uint256 reward = calculateReward(tokenId);
        require(reward > 0, "No reward to claim");
        stakes[tokenId].reward = 0;
        (bool success, ) = msg.sender.call{value: reward}("");
        require(success, "Failed to send reward");
        isLocked = false;
    }

        function calculateReward(uint256 tokenId) public view returns (uint256) {
        require(stakes[tokenId].amount == tokenId, "Invalid token ID");
        uint256 stakingTime = block.timestamp.sub(stakes[tokenId].startTime);
        uint256 reward = stakes[tokenId].reward.add(stakingTime.mul(REWARD_PER_DAY).mul(stakes[tokenId].amount).div(1e18));
        return reward;
    }

    function setMinStakingTime(uint256 newMinStakingTime) public {
        require(msg.sender == owner(), "Not the owner");
        minStakingTime = newMinStakingTime;
    }

    function setMaxStakingTime(uint256 newMaxStakingTime) public {
        require(msg.sender == owner(), "Not the owner");
        maxStakingTime = newMaxStakingTime;
    }

    function withdraw() public {
        require(msg.sender == owner(), "Not the owner");
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to withdraw balance");
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function owner() public view returns (address) {
        return address(this);
    }

    function getStakedTokens(address staker) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](stakedTokens[staker].length());
        for (uint256 i = 0; i < stakedTokens[staker].length(); i++) {
            result[i] = stakedTokens[staker].at(i);
        }
        return result;
    }
}

