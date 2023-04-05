// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721A, IERC721A} from "ERC721A/ERC721A.sol";
import {IERC2981, ERC2981} from "openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "./IERC4906.sol";
import {ERC721RestrictApprove} from "./CAL/ERC721RestrictApprove.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract ExampleToken is
    IERC4906,
    AccessControl,
    ERC2981,
    ERC721RestrictApprove
{
    string private constant BASE_EXTENSION = ".json";
    uint256 private constant MAX_SUPPLY = 6000;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private baseURI;
    mapping(uint256 => string) private metadataURI;

    constructor(
        address _CALAddress
    ) ERC721RestrictApprove("ExampleToken", "EXAMPLE") {
        _setCAL(_CALAddress);
        CALLevel = 1;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721A) returns (string memory) {
        if (bytes(metadataURI[tokenId]).length == 0) {
            return
                string(
                    abi.encodePacked(ERC721A.tokenURI(tokenId), BASE_EXTENSION)
                );
        } else {
            return metadataURI[tokenId];
        }
    }

    // internal
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setTokenMetadataURI(
        uint256 tokenId,
        string memory metadata
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        metadataURI[tokenId] = metadata;
        emit MetadataUpdate(tokenId);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function mint(
        address _address,
        uint256 _count
    ) external onlyRole(MINTER_ROLE) {
        _mint(_address, _count);
    }

    function setBaseURI(
        string memory _newBaseURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
        emit BatchMetadataUpdate(1, MAX_SUPPLY);
    }

    function withdraw(
        address _to
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721RestrictApprove, ERC2981, AccessControl)
        returns (bool)
    {
        return
            ERC721RestrictApprove.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    /*///////////////////////////////////////////////////////////////
                    OVERRIDES ERC721RestrictApprove
    //////////////////////////////////////////////////////////////*/
    function addLocalContractAllowList(
        address transferer
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _addLocalContractAllowList(transferer);
    }

    function removeLocalContractAllowList(
        address transferer
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _removeLocalContractAllowList(transferer);
    }

    function getLocalContractAllowList()
        external
        view
        override
        returns (address[] memory)
    {
        return _getLocalContractAllowList();
    }

    function setCALLevel(
        uint256 level
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        CALLevel = level;
    }

    function setCAL(address calAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setCAL(calAddress);
    }
}
