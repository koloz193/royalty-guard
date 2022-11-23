// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import {IRoyaltyGuard, RoyaltyGuard} from "../royalty-guard/RoyaltyGuard.sol";

contract RoyaltyGuardOwner is RoyaltyGuard {
  address public owner;

  constructor(address _owner, IRoyaltyGuard.ListType _listType, address[] memory _addrs) {
    owner = _owner;
    _setListType(_listType);
    _batchUpdateList(_listType, _addrs, true);
  }

  function hasAdminPermission(address _addr) public view override returns (bool) {
    return _addr == owner;
  }

  function testCheckList(address _addr) external checkList(_addr) {}
}

contract RoyaltyGuardTest is Test {
  RoyaltyGuardOwner guard;
  address alice;
  address bob;
  address charlie;

  function setUp() public {
    alice = address(0x1337);
    bob = address(0xBEEF);
    charlie = address(0xCAFE);

    address[] memory allowList = new address[](1);
    allowList[0] = bob;

    guard = new RoyaltyGuardOwner(alice, IRoyaltyGuard.ListType.ALLOW, allowList);
  }

  function testGetListType() public {
    IRoyaltyGuard.ListType listType = guard.getListType();
    assert(listType == IRoyaltyGuard.ListType.ALLOW);
  }

  function testListValues() public {
    address[] memory addrs = guard.getInUseList();
    assert(addrs.length == 1);
    assert(addrs[0] == bob);
  }

  function testCheckList_ALLOW(address _addr) public {
    if (_addr != bob) {
      vm.expectRevert(IRoyaltyGuard.Unauthorized.selector);
      guard.testCheckList(_addr);
    }

    guard.testCheckList(bob);

    address[] memory addrs = new address[](1);
    addrs[0] = _addr;

    vm.prank(alice);
    guard.batchAddAddressToRoyaltyList(IRoyaltyGuard.ListType.ALLOW, addrs);

    guard.testCheckList(_addr);
  }

  
}
