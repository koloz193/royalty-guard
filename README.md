# RoyaltyGuard

A general mixin for any owned/permissioned contract that allows for fine tuning function guards based off an ALLOW or DENY list. The best example of a use case at this point in time is the enforcement of royalty payouts through selecting which platforms are/arent allowed to move tokens on a users behalf. The implementation used here supports a list being ALLOW/DENY/OFF, with a default setting of OFF.

## Contracts

```ml
royalty-guard
├─ RoyaltyGuard — "Admin controlled ALLOW/DENY list primitives"
├─ extensions
│  ├─ RoyaltyGuardDeadmanTrigger - "RoyaltyGuard with a renewable deadman switch to turn list off after predefined period of time"
examples
├─ deadman-trigger
│  ├─ DeadmanGuardedERC721 - "GuardedERC721 with the deadman trigger extension"
│  ├─ DeadmanGuardedERC1155 - "GuardedERC1155 with the deadman trigger extension"
├─ GuardedERC721 — "Solmate based ERC721 with Owner restrictions and RoyaltyGuard"
├─ GuardedERC1155 — "Solmate based ERC1155 with Owner restrictionsand RoyaltyGuard"
```

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## How it works

`RoyaltyGuard` is an abstract contract that is meant to be inherrited to integrate with a contract. The main features of the contract are:
1. Configurable list type with options `OFF`, `ALLOW`, and `DENY`.
2. Flexible admin permissioning of Guard (note examples use `Owner` based permissioning but can leave it to anyone, `ROLE` based, etc.)

The two different active list types are `ALLOW` and `DENY`. In the `ALLOW` model, functions marked with the `checkList` modifier will `revert` with `Unauthorized` unless the supplied address is on the list. The `DENY` list takes the opposite approach and will `revert` if and only if the supplied address is on the list.

### Extensions

#### Deadman Trigger
  If the owner/permissioning group hasn't renewed the trigger, anyone can come in and activate the deadman trigger turning the list type to `OFF`. Even after deadman trigger has been activated, the owner/permissioning group can renew and change the list type to `ALLOW` or `DENY`.

  The two deadman trigger functions are `setDeadmanListTriggerRenewalDuration(uint256 _numYears)`, another admin guarded function, that renews the deadman switch for `_numYears` years and `activateDeadmanListTrigger()`, a public function, used to turn the list type to `OFF` and is only callable when the current `block.timestamp` is on or after the returned value from `getDeadmanTriggerAvailableDatetime()`.

  Source code at [RoyaltyGuardDeadmanTrigger](src/royalty-guard/extensions/RoyaltyGuardDeadmanTrigger.sol) with [examples](src/example/deadman-trigger/).

## How to Integrate

While there are other ways to integrate with `RoyaltyGuard`, these examples use the least amount of up front code relying on post contract deployment interactions to finish setup. 

The end result of this is the `RoyaltyGuard` integrated into a contract with type `OFF`, deadman trigger set to 0, all lists empty, and marked functions guarded by the `hasAdminPermission` function.

The minimal changes needed are inherit the `RoyaltyGuard` Contract, override `ERC165`'s `supportsInterface`, implement `hasAdminPermission`, and attach the `checkList` to any functions that need guarding.

Example setups can be found in [GuardedERC721](src/example/GuardedERC721.sol) and [GuardedERC1155](src/example/GuardedERC1155.sol).

For more advance setups, a set of internal functions is supplied that can be used for the purpose of setup within a contracts constructor. See [RoyaltyGuard](src/royalty-guard/RoyaltyGuard.sol).

## Usage

Guarded functions are those that are marked with the modifier `checkList(address _addr)` that checks the list type and changes based on the typing. 

The list type can be updated via `toggleListType(ListType _newListType)` which relies on the implemented function `hasAdminPermission(address _addr) returns (bool)`. The examples leverage use of an `Owner` to guard access. Valid inputs for `ListType` are `0` for OFF, `1` for ALLOW, and `2` for DENY. 

Adding, removing, and clearing a list also rely on `hasAdminPermission(address _addr) returns (bool)`. The relevant functions here are `batchAddAddressToRoyaltyList(ListType _listType, address[] _addrs)`, `batchRemoveAddressToRoyaltyList(ListType _listType, address[] _addrs)`, and `clearList(ListType _listType)`. 

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install koloz193/royalty-guard
```

## Acknowledgements

These contracts/readme utilize or were inspired by:

- [Solmate](https://github.com/transmissions11/solmate)
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
