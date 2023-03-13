pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTStaking is IERC721Receiver, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    uint256 public constant MINIMUM_STAKING_TIME = 30 days;
    uint256 public constant REWARD_RATE = 10; // 10%
    uint256 public constant DECIMALS = 100;

    struct Stake {
        uint256 tokenId;
        uint256 stakedTime;
        uint256 lastClaimedTime;
        bool active;
    }

    IERC721 public nft;
    mapping(address => Stake) public stakes;

    event Staked(address indexed owner, uint256 indexed tokenId, uint256 stakedTime);
    event Unstaked(address indexed owner, uint256 indexed tokenId, uint256 reward);
    event RewardClaimed(address indexed owner, uint256 indexed tokenId, uint256 reward);

    constructor(address _nftAddress) {
        nft = IERC721(_nftAddress);
    }

    function stake(uint256 _tokenId) external nonReentrant {
        require(nft.ownerOf(_tokenId) == msg.sender, "NFTStaking: not owner of token");
        require(!stakes[msg.sender].active, "NFTStaking: already staked");
        require(nft.getApproved(_tokenId) == address(this), "NFTStaking: not approved");
        
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        stakes[msg.sender] = Stake(_tokenId, block.timestamp, block.timestamp, true);

        emit Staked(msg.sender, _tokenId, block.timestamp);
    }

    function unstake() external nonReentrant {
        Stake storage stake = stakes[msg.sender];
        require(stake.active, "NFTStaking: not staked");
        require(block.timestamp >= stake.stakedTime.add(MINIMUM_STAKING_TIME), "NFTStaking: staking time not reached");

        uint256 reward = calculateReward(msg.sender, stake);
        nft.safeTransferFrom(address(this), msg.sender, stake.tokenId);
        delete stakes[msg.sender];

        emit Unstaked(msg.sender, stake.tokenId, reward);
    }

    function claimReward() external nonReentrant {
        Stake storage stake = stakes[msg.sender];
        require(stake.active, "NFTStaking: not staked");

        uint256 reward = calculateReward(msg.sender, stake);
        stake.lastClaimedTime = block.timestamp;

        emit RewardClaimed(msg.sender, stake.tokenId, reward);
    }

    function calculateReward(address _owner, Stake storage _stake) internal view returns (uint256) {
        uint256 stakedTime = block.timestamp.sub(_stake.lastClaimedTime);
        uint256 reward = stakedTime.mul(REWARD_RATE).mul(DECIMALS).div(MINIMUM_STAKING_TIME).div(DECIMALS);

        return reward;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
