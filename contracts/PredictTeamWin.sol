// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/ITreasury.sol";
import "./interfaces/IAuthority.sol";
import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

contract PredictTeamWin is BaseUpgradeable, FundForwarderUpgradeable {
  event PredictChampion(address user_, uint8 teamId_, uint256 amount_);

  uint8 private teamWin;
  uint256 private totalReward;
  address public commandGateAddress;
  address public paymentTokenAddress;

  mapping(uint8 => uint256) private teamTotal;
  mapping(address => mapping(uint8 => uint256)) private userBetTotal;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  modifier onlyCommandGate() {
    require(msg.sender == commandGateAddress, "Not Command Gate");
    _;
  }

  function init(ITreasury treasury_, IAuthority authority_) public initializer {
    __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
    __FundForwarder_init_unchained(treasury_);
    commandGateAddress = 0xaE7B8FDd75B9F2C73987E1396e773Ea111CE7106;
    paymentTokenAddress = 0x54c704E9d92B08C744112e9E1fE03A61245855F2;
  }

  function updateTreasury(
    ITreasury treasury_
  ) external override(BaseUpgradeable, FundForwarderUpgradeable) onlyRole(Roles.OPERATOR_ROLE) {
    emit TreasuryUpdated(treasury(), treasury_);
    _updateTreasury(treasury_);
  }

  function predictChampion(uint8 id_, address user_, address token_, uint256 value_) external onlyCommandGate {
    require(token_ == paymentTokenAddress, "Invalid payment token.");
    IERC20Upgradeable(paymentTokenAddress).approve(commandGateAddress, value_);
    teamTotal[id_] += value_;
    totalReward += value_;
    userBetTotal[user_][id_] += value_;

    emit PredictChampion(user_, id_, value_);
  }

  function getUserBetWithAddress(address user_, uint8 id_) external view returns (uint256) {
    uint256 amount = userBetTotal[user_][id_];
    return amount;
  }

  function updatePaymentToken(address paymentToken_) external onlyRole(Roles.UPGRADER_ROLE) {
    paymentTokenAddress = paymentToken_;
  }

  function updateCommandGate(address commandGate_) external onlyRole(Roles.UPGRADER_ROLE) {
    commandGateAddress = commandGate_;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyRole(Roles.OPERATOR_ROLE) {}
}
