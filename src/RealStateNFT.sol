// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "solmate/utils/LibString.sol";

import "forge-std/console.sol";

// Author: @Luan-Web3
contract RealStateNFT is ERC721, Owned {
    enum PropertyStatus { Available, Rented, Sold }

    struct Property {
        uint256 id;
        uint256 price;
        uint256 rentPrice;
        PropertyStatus status;
        address tenant;
        uint256 rentStartTime;
        uint8 rentAdjustmentInPercentage;
    }

    struct Invoice {
        uint256 amount;
        uint256 dueDate;
        uint8 currentInstallment;
    }

    uint256 public currentTokenId;
    uint256[] public propertyIds;

    mapping(uint256 => Property) public properties;
    mapping(uint256 => Invoice) public rentInvoices;

    event PropertyMinted(uint256 indexed propertyId, address owner, uint256 price, uint256 rentPrice);
    event PropertySold(uint256 propertyId, address buyer);
    event PropertyRented(uint256 indexed propertyId, address tenant);
    event RentPaid(uint256 indexed propertyId, address tenant, uint256 amount, uint8 installment);
    event RentCleared(uint256 indexed propertyId, address tenant);

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Owned(msg.sender) {}

    function mintProperty(uint256 price, uint256 rentPrice, uint8 rentAdjustmentInPercentage) external onlyOwner {
        uint256 propertyId = currentTokenId;
        _safeMint(msg.sender, propertyId);
        
        properties[propertyId] = Property({
            id: propertyId,
            price: price,
            rentPrice: rentPrice,
            status: PropertyStatus.Available,
            tenant: address(0),
            rentStartTime: 0,
            rentAdjustmentInPercentage: rentAdjustmentInPercentage
        });
        propertyIds.push(propertyId);

        emit PropertyMinted(propertyId, msg.sender, price, rentPrice);
        currentTokenId++;
    }

    function getAllPropertyIds() public view returns (uint256[] memory) {
        return propertyIds;
    }

    function buyProperty(uint256 propertyId) external payable {
        Property storage property = properties[propertyId];
        address ownerProperty = ownerOf(propertyId);

        require(property.status == PropertyStatus.Available, "Property not available for sale");
        require(msg.value == property.price, "Incorrect value to buy the property");

        getApproved[propertyId] = msg.sender;

        transferFrom(ownerProperty, msg.sender, propertyId);
        payable(ownerProperty).transfer(msg.value);

        property.status = PropertyStatus.Sold;
        emit PropertySold(propertyId, msg.sender);
    }

    function rentProperty(uint256 propertyId) external payable {
        Property storage property = properties[propertyId];

        require(property.status == PropertyStatus.Available, "Property not available for rent");
        require(msg.value == property.rentPrice, "Incorrect value to rent the property");

        property.tenant = msg.sender;
        property.status = PropertyStatus.Rented;
        property.rentStartTime = block.timestamp;

        payable(ownerOf(propertyId)).transfer(msg.value);

        rentInvoices[propertyId] = Invoice({
            amount: property.rentPrice,
            dueDate: block.timestamp + 30 days,
            currentInstallment: 1
        });

        emit PropertyRented(propertyId, msg.sender);
        emit RentPaid(propertyId, msg.sender, msg.value, 1);
    }

    function payRent(uint256 propertyId) external payable {
        Property storage property = properties[propertyId];

        require(property.status == PropertyStatus.Rented, "The property is not rented");
        require(msg.sender == property.tenant, "Only the tenant can pay the rent");

        Invoice storage invoice = rentInvoices[propertyId];

        require(msg.value == invoice.amount, "Incorrect value to pay the rent");

        invoice.currentInstallment++;
        invoice.dueDate += 30 days;
        payable(ownerOf(propertyId)).transfer(msg.value);

        if (invoice.currentInstallment % 13 == 0) {
            invoice.amount += invoice.amount * property.rentAdjustmentInPercentage / 100;
        }

        emit RentPaid(propertyId, msg.sender, msg.value, invoice.currentInstallment);
    }

    function cancelRent(uint256 propertyId) external {
        Property storage property = properties[propertyId];
        address ownerProperty = ownerOf(propertyId);

        require(property.status == PropertyStatus.Rented, "The property is not rented");
        require(ownerProperty == msg.sender, "Only the owner can cancel the rent");

        property.status = PropertyStatus.Available;
        property.tenant = address(0);
        property.rentStartTime = 0;

        emit RentCleared(propertyId, msg.sender);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return string.concat("https://api.example.com/images/", LibString.toString(id));
    }
}
