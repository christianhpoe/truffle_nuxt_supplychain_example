// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ItemManager.sol";

contract  Item {
    uint public priceInWei;
    uint public index;
    uint public pricePaid;
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        parentContract = _parentContract;
        index = _index;
    }
    
    receive() external payable {
        require(pricePaid == 0, "Item already paid");
        require(priceInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
        ( bool success, ) = address(parentContract).call{value:msg.value}(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
        require(success, "Transaction was not successfull, cancelling");
    }
}
