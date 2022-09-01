// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {

    // Variables
    addres payable public immutable feeAccount; // Address que recibe fees
    uint public immutable feePercent;
    uint public itemCount;

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    // itemId -> Item
    mapping(uint => Item) public items;

    event 0ffered(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );
    
    event Bought(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    constructor(uint _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    // Hacer oferta de item dentro del marketplace
    function makeItem(IERC721 _nft, uint _tokenId, uint price) external nonReentrant {
        require(_price > 0, "El precio debe ser mayor a cero");
    // Incrementar itemCount
    itemCount ++;
    // Transferir nft
        nft.transferFrom(msg.sender, address(this), _tokenId);
        // Agregar nuevo item de mapping items
        items[itemCount] = Item (
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        // Emitir evento de oferta
        emit Offered(
            itemCount,
            Address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "El Item no existe");
        require(msg.value >= totalPrice, "No disponer ether para la compra");
        require(!item.sold, "Item ya vendido");
        // Pago vendedor y feeAccount
        item.seller.transfer(item.price);
        feeAcount.transfer(_totalPrice - item.price);
        // Actualizar item a vendido
        item.sold = true;
        // Transfer nft al comprador
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        // Emite el evento de compra
        emit Bought(
            _itemId,
            address (item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function getTotalPrice(uint _itemId) view public returns(uint){
        return((items[_itemId].price*(100 + feePercent))/100);
    }
}