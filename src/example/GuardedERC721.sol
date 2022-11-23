// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {RoyaltyGuard} from "../royalty-guard/RoyaltyGuard.sol";

contract GuardedERC721 is ERC721, Owned, RoyaltyGuard {

  /*//////////////////////////////////////////////////////////////////////////
                              PRIVATE STORAGE
  //////////////////////////////////////////////////////////////////////////*/
  string private baseURI;
  uint256 private tokenCounter;

  /*//////////////////////////////////////////////////////////////////////////
                              CONSTRUCTOR
  //////////////////////////////////////////////////////////////////////////*/
  constructor(string memory _name, string memory _symbol, string memory _baseURI, address _newOwner) 
    ERC721(_name, _symbol)
    Owned(_newOwner)
  {
    baseURI = _baseURI;
  }

  /*//////////////////////////////////////////////////////////////////////////
                              ERC721 LOGIC
  //////////////////////////////////////////////////////////////////////////*/
  
  /// @notice Retrieve the tokenURI for a token with the supplied _id
  /// @dev Wont throw or revert given a nonexistent tokenId
  /// @return string token uri
  function tokenURI(uint256 _id) public view virtual override returns (string memory) {
    return string(abi.encodePacked(baseURI, _id));
  }

  /// @notice Create a new token sending directly to {_to}.
  /// @dev Must be contract owner to mint new token.
  function mint(address _to) external onlyOwner {
    _mint(_to, tokenCounter++);
  }

  /// @notice Destroy token with id {_id}.
  /// @dev Must be the token owner to call.
  function burn(uint256 _id) external {
    if (_ownerOf[_id] != msg.sender) revert("NOT_OWNER");
    _burn(_id);
  }

  /*//////////////////////////////////////////////////////////////////////////
                              ERC165 LOGIC
  //////////////////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 _interfaceId) public view virtual override (ERC721, RoyaltyGuard) returns (bool) {
      return RoyaltyGuard.supportsInterface(_interfaceId) || ERC721.supportsInterface(_interfaceId);
  }

  /*//////////////////////////////////////////////////////////////////////////
                          RoyaltyGuard LOGIC
  //////////////////////////////////////////////////////////////////////////*/

  /// @inheritdoc RoyaltyGuard
  function hasAdminPermission(address _addr) public view virtual override returns (bool) {
    return _addr == owner;
  }

  /// @dev Guards {approve} based on the type of list and depending if {_spender} is on the list.
  function approve(address _spender, uint256 _id) public virtual override checkList(_spender) {
    super.approve(_spender, _id);
  }

  /// @dev Guards {setApprovalForAll} based on the type of list and depending if {_operator} is on the list.
  function setApprovalForAll(address _operator, bool _approved) public virtual override checkList(_operator) {
    super.setApprovalForAll(_operator, _approved);
  }
}
