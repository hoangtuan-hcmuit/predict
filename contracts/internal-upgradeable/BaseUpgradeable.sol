// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../interfaces/ITreasury.sol";
import "../interfaces/IAuthority.sol";

import "../libraries/Roles.sol";

error Base__Paused();
error Base__Unpaused();
error Base__AlreadySet();
error Base__Unauthorized();
error Base__AuthorizeFailed();
error Base__UserIsBlacklisted();

abstract contract BaseUpgradeable is ContextUpgradeable, UUPSUpgradeable {
  bytes32 private _authority;

  event AuthorityUpdated(IAuthority indexed from, IAuthority indexed to);

  modifier onlyRole(bytes32 role) {
    _checkRole(role, _msgSender());
    _;
  }

  modifier onlyWhitelisted() {
    _checkBlacklist(_msgSender());
    _;
  }

  modifier whenNotPaused() {
    _requireNotPaused();
    _;
  }

  modifier whenPaused() {
    _requirePaused();
    _;
  }

  function updateAuthority(IAuthority authority_) external onlyRole(Roles.OPERATOR_ROLE) {
    IAuthority old = authority();
    require(old != authority_, "Already set");
    __updateAuthority(authority_);
    emit AuthorityUpdated(old, authority_);
  }

  function updateTreasury(ITreasury treasury_) external virtual;

  function authority() public view returns (IAuthority authority_) {
    assembly {
      authority_ := sload(_authority.slot)
    }
  }

  function __Base_init(IAuthority authority_, bytes32 role_) internal onlyInitializing {
    __Base_init_unchained(authority_, role_);
  }

  function __Base_init_unchained(IAuthority authority_, bytes32 role_) internal onlyInitializing {
    authority_.requestAccess(role_);
    __updateAuthority(authority_);
  }

  function _checkBlacklist(address account_) internal view {
    require(!authority().isBlacklisted(account_), "User is blacklisted");
  }

  function _checkRole(bytes32 role_, address account_) internal view {
    require(authority().hasRole(role_, account_), "Unauthorized");
  }

  function __updateAuthority(IAuthority authority_) private {
    assembly {
      sstore(_authority.slot, authority_)
    }
  }

  function _requirePaused() internal view {
    require(authority().paused(), "Unpaused");
  }

  function _requireNotPaused() internal view {
    require(!authority().paused(), "Paused");
  }

  function _authorizeUpgrade(address implement_) internal virtual override onlyRole(Roles.UPGRADER_ROLE) {}

  function _hasRole(bytes32 role_, address account_) internal view returns (bool) {
    return authority().hasRole(role_, account_);
  }

  uint256[49] private __gap;
}
