// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IRoyaltyGuard} from "./IRoyaltyGuard.sol";

type ListType is IRoyaltyGuard.ListType;

abstract contract RoyaltyGuard {
  /// @notice Returns the ListType currently being used;
  /// @return ListType of the list. Values are: 0 (OFF), 1 (ALLOW), 2 (DENY)
  ListType public listType;

  uint256 public deadmanListTriggerAfterDatetime;
  mapping(ListType => EnumerableSet.AddressSet) private list;
}
