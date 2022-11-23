// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {ERC1155} from "solmate/tokens/ERC1155.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {RoyaltyGuard} from "../royalty-guard/RoyaltyGuard.sol";

contract GuardedERC1155 is ERC1155, Owned, RoyaltyGuard {

  /*//////////////////////////////////////////////////////////////////////////
                              PRIVATE STORAGE
  //////////////////////////////////////////////////////////////////////////*/
  string private baseURI;
  string private name_;
  string private symbol_;
  uint256 private tokenIdCounter;

  /*//////////////////////////////////////////////////////////////////////////
                              CONSTRUCTOR
  //////////////////////////////////////////////////////////////////////////*/
  constructor(string memory _name, string memory _symbol, string memory _baseURI, address _newOwner) 
    Owned(_newOwner)
  {
    baseURI = _baseURI;
    name_ = _name;
    symbol_ = _symbol;
  }

  /*//////////////////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
  //////////////////////////////////////////////////////////////////////////*/
  function uri(uint256 _id) public view virtual override returns (string memory) {
    return string(abi.encodePacked(baseURI, _id));
  }

  /// @notice Returns the name of this 1155 contract.
  /// @return name of contract
  function name() external view returns (string memory) {
    return name_;
  }

  /// @notice Returns the symbol of this 1155 contract.
  /// @return symbol of contract
  function symbol() external view returns (string memory) {
    return symbol_;
  }

  /// @notice Create a new token sending the full {_amount} to {_to}.
  /// @dev Must be contract owner to mint new token.
  function mint(address _to, uint256 _amount) external onlyOwner{
    _mint(_to, tokenIdCounter++, _amount, "");
  }

  /// @notice Destroy {_amount} of token with id {_id}.
  /// @dev Must have a balance >= {_amount} of {_tokenId}.
  function burn(address _from, uint256 _id, uint256 _amount) external {
    if (balanceOf[_from][_id] < _amount) revert("INSUFFICIENT BALANCE");
    _burn(_from, _id, _amount);
  }

  /*//////////////////////////////////////////////////////////////////////////
                              ERC165 LOGIC
  //////////////////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 _interfaceId) public view virtual override (ERC1155, RoyaltyGuard) returns (bool) {
      return RoyaltyGuard.supportsInterface(_interfaceId) || ERC1155.supportsInterface(_interfaceId);
  }

  /*//////////////////////////////////////////////////////////////////////////
                          RoyaltyGuard LOGIC
  //////////////////////////////////////////////////////////////////////////*/

  /// @inheritdoc RoyaltyGuard
  function hasAdminPermission(address _addr) public view virtual override returns (bool) {
    return _addr == owner;
  }

  /// @dev Guards {setApprovalForAll} based on the type of list and depending if {_operator} is on the list.
  function setApprovalForAll(address _operator, bool _approved) public virtual override checkList(_operator) {
    super.setApprovalForAll(_operator, _approved);
  }
}
