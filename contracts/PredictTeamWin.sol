// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/ITreasury.sol";
import "./interfaces/IAuthority.sol";
import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract PredictTeamWin is BaseUpgradeable, FundForwarderUpgradeable {
  bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
  bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

  uint8 private teamWin;
  address public Treasury;
  address public CommandGate;
  address public PaymentToken;
  uint256 private totalReward;

  mapping(uint8 => uint256) private teamTotal;
  mapping(address => mapping(uint8 => uint256)) private userBetTotal;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  modifier onlyCommandGate() {
    require(msg.sender == CommandGate, "Not Command Gate");
    _;
  }

  function init(ITreasury treasury_, IAuthority authority_) public initializer {
    __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
    __FundForwarder_init_unchained(treasury_);
  }

  function updateTreasury(
    ITreasury treasury_
  ) external override(BaseUpgradeable, FundForwarderUpgradeable) onlyRole(Roles.OPERATOR_ROLE) {
    emit TreasuryUpdated(treasury(), treasury_);
    _updateTreasury(treasury_);
  }

  function predictChampion(uint8 id_, address user_, address token_, uint256 value_) external onlyCommandGate {
    require(token_ != PaymentToken, "Invalid payment token.");
    //
    teamTotal[id_] += value_;
    totalReward += value_;
    userBetTotal[user_][id_] += value_;
  }

  function setTeamWin(uint8 id_) external onlyRole(Roles.OPERATOR_ROLE) {
    teamWin = id_;
  }

  function resultChampion(address user_, address token_, uint256 value_) external {
    require(userBetTotal[user_][teamWin] != 0, "Unsettle bet");
    //
    //uint256 percentTeamTotalBet = (teamTotal[teamWin] / totalReward);
    // uint256 percentUserTotalBet = (userBetTotal[user_][teamWin] / totalReward) * 100;
    //uint256 userReward = (totalReward * (1 - percentTeamTotalBet)) + userBetTotal[user_][teamWin];
    uint256 percentReward = ( 2^64 * totalReward - teamTotal[teamWin] ) / totalReward;
    uint256 userReward = ;
    userBetTotal[user_][teamWin] = 0;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyRole(Roles.OPERATOR_ROLE) {}
}
