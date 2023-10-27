// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract PropertySystem {

    address public administrator;

    enum Status { ForSale, Sold }

    struct Property {
        address propertyOwner;
        uint propertyPrice; // Ether
        Status status;
    }

    mapping(uint => Property) properties; 

    modifier onlyAdmin() {
        require(msg.sender == administrator, "You are not the admin!");
        _;
    }

    modifier enoughPayment(uint propertyId) {
        require(msg.value >= (properties[propertyId].propertyPrice * 1 ether), "Not enough payment");
        _;
    }

    modifier notOwner(uint propertyId) {
        require (msg.sender != properties[propertyId].propertyOwner, "You are already the owner!");
        _;
    }

    modifier forSale(uint propertyId) {
        require (Status.ForSale == properties[propertyId].status, "Propery not for sale!");
        _;       
    }

    constructor() {
        administrator = msg.sender;
    }

    function addProperty(uint propertyId, uint propertyPrice) external onlyAdmin {
        properties[propertyId] = Property(msg.sender,propertyPrice,Status.ForSale);
    }

    function buyProperty(uint propertyId) external payable enoughPayment(propertyId) notOwner(propertyId) forSale(propertyId) {
        properties[propertyId].propertyOwner = msg.sender;
        properties[propertyId].status = Status.Sold;
    }

    function viewProperty(uint propertyId) external view returns(Property memory) {
        return properties[propertyId];
    }

}
