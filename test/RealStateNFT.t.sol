// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RealStateNFT.sol"; // Substitua pelo caminho correto do contrato

contract PropertyTest is Test {

    RealStateNFT realStateNFTContract;
    address owner = address(0x123);

    function setUp() public {
        vm.startPrank(owner);
        realStateNFTContract = new RealStateNFT("RealEstate", "RSL");
        vm.stopPrank();
    }

    function testMintProperty_ShouldSucceed() public {
        uint256 price = 2 ether;
        uint256 rentPrice = 0.5 ether;
        uint8 rentAdjustmentInPercentage = 5;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);
        vm.stopPrank();

        (uint256 id, uint256 propertyPrice, uint256 propertyRentPrice, RealStateNFT.PropertyStatus status, address tenant, uint256 rentStartTime, uint8 propertyRentAdjustmentInPercentaget) = PropertyTest.realStateNFTContract.properties(0);

        assertEq(id, 0, "Incorrect id");
        assertEq(propertyPrice, price, "Incorrect price");
        assertEq(propertyRentPrice, rentPrice, "Incorrect rentPrice");
        assertEq(uint8(status), uint8(RealStateNFT.PropertyStatus.Available), "Incorrect status");
        assertEq(tenant, address(0), "Tenant should be zero address");
        assertEq(rentStartTime, 0, "Rent start time should be zero");
        assertEq(propertyRentAdjustmentInPercentaget, rentAdjustmentInPercentage, "Incorrect rent adjustment in percentage");
    }

    function testMintProperty_ShouldRevertIfCalledByNonOwner() public {
        address nonOwner = address(0x456);

        uint256 price = 2 ether;
        uint256 rentPrice = 0.5 ether;
        uint8 rentAdjustmentInPercentage = 5;

        vm.startPrank(nonOwner);

        vm.expectRevert("UNAUTHORIZED");
        realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);

        vm.stopPrank();
    }

    function testGetAllPropertyIds_ShouldReturnEmptyArrayInitially() public view {
        uint256[] memory propertyIds = PropertyTest.realStateNFTContract.getAllPropertyIds();

        assertEq(propertyIds.length, 0, "Should be empty");
    }

    function testGetAllPropertyIds_ShouldReturnArrayWithOneElementAfterMinting() public {
        uint256 price = 2 ether;
        uint256 rentPrice = 0.5 ether;
        uint8 rentAdjustmentInPercentage = 5;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);
        vm.stopPrank();

        uint256[] memory propertyIds = PropertyTest.realStateNFTContract.getAllPropertyIds();

        assertEq(propertyIds.length, 1, "Should have one element");
        assertEq(propertyIds[0], 0, "Should have the correct id");
    }

    function testGetAllPropertyIds_ShouldReturnArrayWithMultipleElements() public {
        uint256 price = 2 ether;
        uint256 rentPrice = 0.5 ether;
        uint8 rentAdjustmentInPercentage = 5;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);
        PropertyTest.realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);
        PropertyTest.realStateNFTContract.mintProperty(price, rentPrice, rentAdjustmentInPercentage);
        vm.stopPrank();

        uint256[] memory propertyIds = PropertyTest.realStateNFTContract.getAllPropertyIds();

        assertEq(propertyIds.length, 3, "Should have three elements");
        assertEq(propertyIds[0], 0, "Should have the correct id");
        assertEq(propertyIds[1], 1, "Should have the correct id");
        assertEq(propertyIds[2], 2, "Should have the correct id");
    }

    function testBuyProperty_ShouldSucceedWhenCorrectValueIsSent() public {
        uint256 propertyId = 0;
        uint256 price = 2 ether;
    
        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, 0.5 ether, 5);
        vm.stopPrank();
    
        address buyer = address(0x456);
        uint256 correctValue = price;
    
        vm.startPrank(buyer);
        vm.deal(buyer, correctValue);
        PropertyTest.realStateNFTContract.buyProperty{value: correctValue}(propertyId);
        vm.stopPrank();
    
        (uint256 id, uint256 propertyPrice, uint256 propertyRentPrice, RealStateNFT.PropertyStatus status, address tenant, uint256 rentStartTime, uint8 propertyRentAdjustmentInPercentage) = PropertyTest.realStateNFTContract.properties(propertyId);
        assertEq(uint8(status), uint8(RealStateNFT.PropertyStatus.Sold), "Status should be Sold");
        assertEq(PropertyTest.realStateNFTContract.ownerOf(propertyId), buyer, "Buyer should be the new owner");
    }

    function testBuyProperty_ShouldRevertWhenIncorrectValueIsSent() public {    
        uint256 propertyId = 0;
        uint256 price = 2 ether;
    
        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, 0.5 ether, 5);
        vm.stopPrank();

        address buyer = address(0x456);
        uint256 incorrectValue = 1 ether;
    
        vm.startPrank(buyer);
        vm.deal(buyer, incorrectValue);
        vm.expectRevert("Incorrect value to buy the property");
        PropertyTest.realStateNFTContract.buyProperty{value: incorrectValue}(propertyId);
        vm.stopPrank();
    }

    function testBuyProperty_ShouldRevertWhenPropertyIsNotAvailable() public {
        uint256 propertyId = 0;
        uint256 price = 2 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(price, 0.5 ether, 5);
        vm.stopPrank();

        address firstBuyer = address(0x456);
        vm.startPrank(firstBuyer);
        vm.deal(firstBuyer, price);
        PropertyTest.realStateNFTContract.buyProperty{value: price}(propertyId);
        vm.stopPrank();

        address secondBuyer = address(0x789);
        vm.startPrank(secondBuyer);
        vm.deal(secondBuyer, price);
        vm.expectRevert("Property not available for sale");
        PropertyTest.realStateNFTContract.buyProperty{value: price}(propertyId);
        vm.stopPrank();
    }

    function testRentProperty_ShouldSucceedWhenCorrectValueIsSent() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        uint256 correctValue = rentPrice;

        vm.startPrank(tenant);
        vm.deal(tenant, correctValue);
        PropertyTest.realStateNFTContract.rentProperty{value: correctValue}(propertyId);
        vm.stopPrank();

        (uint256 id, uint256 propertyPrice, uint256 propertyRentPrice, RealStateNFT.PropertyStatus status, address propertyTenant, uint256 rentStartTime, uint8 propertyRentAdjustmentInPercentage) = PropertyTest.realStateNFTContract.properties(propertyId);
        assertEq(uint8(status), uint8(RealStateNFT.PropertyStatus.Rented), "Status should be Rented");
        assertEq(propertyTenant, tenant, "Tenant should be set correctly");
        assertEq(rentStartTime, block.timestamp, "Rent start time should be set correctly");

        (uint256 amount, uint256 dueDate, uint8 currentInstallment) = PropertyTest.realStateNFTContract.rentInvoices(propertyId);
        assertEq(amount, rentPrice, "Invoice amount should match rent price");
        assertEq(dueDate, block.timestamp + 30 days, "Due date should be 30 days from now");
        assertEq(currentInstallment, 1, "Current installment should be 1");
    }

    function testRentProperty_ShouldRevertWhenIncorrectValueIsSent() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        uint256 incorrectValue = 0.3 ether;

        vm.startPrank(tenant);
        vm.deal(tenant, incorrectValue);
        vm.expectRevert("Incorrect value to rent the property");
        PropertyTest.realStateNFTContract.rentProperty{value: incorrectValue}(propertyId);
        vm.stopPrank();
    }

    function testRentProperty_ShouldRevertWhenPropertyIsNotAvailable() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address firstTenant = address(0x456);
        vm.startPrank(firstTenant);
        vm.deal(firstTenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();

        address secondTenant = address(0x789);
        vm.startPrank(secondTenant);
        vm.deal(secondTenant, rentPrice);
        vm.expectRevert("Property not available for rent");
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();
    }

    function testRentProperty_ShouldEmitEventsCorrectly() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        uint256 correctValue = rentPrice;

        vm.startPrank(tenant);
        vm.deal(tenant, correctValue);
        vm.expectEmit(true, true, true, true);
        emit RealStateNFT.PropertyRented(propertyId, tenant);
        vm.expectEmit(true, true, true, true);
        emit RealStateNFT.RentPaid(propertyId, tenant, rentPrice, 1);
        PropertyTest.realStateNFTContract.rentProperty{value: correctValue}(propertyId);
        vm.stopPrank();
    }

    function testPayRent_ShouldSucceedWhenCorrectValueIsSent() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();

        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        vm.expectEmit(true, true, true, true);
        emit RealStateNFT.RentPaid(propertyId, tenant, rentPrice, 2);
        PropertyTest.realStateNFTContract.payRent{value: rentPrice}(propertyId);
        vm.stopPrank();

        (uint256 amount, uint256 dueDate, uint8 currentInstallment) = PropertyTest.realStateNFTContract.rentInvoices(propertyId);
        assertEq(currentInstallment, 2, "Current installment should be 2");
        assertEq(dueDate, block.timestamp + 60 days, "Due date should be updated by 30 days");
    }

    function testPayRent_ShouldRevertWhenIncorrectValueIsSent() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;
    
        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();
    
        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();
    
        uint256 incorrectValue = 0.3 ether;
        vm.startPrank(tenant);
        vm.deal(tenant, incorrectValue);
        vm.expectRevert("Incorrect value to pay the rent");
        PropertyTest.realStateNFTContract.payRent{value: incorrectValue}(propertyId);
        vm.stopPrank();
    }

    function testPayRent_ShouldRevertWhenPropertyIsNotRented() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        vm.expectRevert("The property is not rented");
        PropertyTest.realStateNFTContract.payRent{value: rentPrice}(propertyId);
        vm.stopPrank();
    }

    function testPayRent_ShouldRevertWhenCalledByNonTenant() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();

        address nonTenant = address(0x789);
        vm.startPrank(nonTenant);
        vm.deal(nonTenant, rentPrice);
        vm.expectRevert("Only the tenant can pay the rent");
        PropertyTest.realStateNFTContract.payRent{value: rentPrice}(propertyId);
        vm.stopPrank();
    }

    function testCancelRent_ShouldSucceedWhenCalledByOwner() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit RealStateNFT.RentCleared(propertyId, owner);
        PropertyTest.realStateNFTContract.cancelRent(propertyId);
        vm.stopPrank();

        (uint256 id, uint256 propertyPrice, uint256 propertyRentPrice, RealStateNFT.PropertyStatus status, address propertyTenant, uint256 rentStartTime, uint8 propertyRentAdjustmentInPercentage) = PropertyTest.realStateNFTContract.properties(propertyId);
        assertEq(uint8(status), uint8(RealStateNFT.PropertyStatus.Available), "Status should be Available");
        assertEq(propertyTenant, address(0), "Tenant should be zero address");
        assertEq(rentStartTime, 0, "Rent start time should be zero");
    }

    function testCancelRent_ShouldRevertWhenCalledByNonOwner() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        address tenant = address(0x456);
        vm.startPrank(tenant);
        vm.deal(tenant, rentPrice);
        PropertyTest.realStateNFTContract.rentProperty{value: rentPrice}(propertyId);
        vm.stopPrank();

        address nonOwner = address(0x789);
        vm.startPrank(nonOwner);
        vm.expectRevert("Only the owner can cancel the rent");
        PropertyTest.realStateNFTContract.cancelRent(propertyId);
        vm.stopPrank();
    }

    function testCancelRent_ShouldRevertWhenPropertyIsNotRented() public {
        uint256 propertyId = 0;
        uint256 rentPrice = 0.5 ether;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, rentPrice, 5);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert("The property is not rented");
        PropertyTest.realStateNFTContract.cancelRent(propertyId);
        vm.stopPrank();
    }

    function testTokenURI_ShouldReturnCorrectURI() public {
        uint256 propertyId = 0;

        vm.startPrank(owner);
        PropertyTest.realStateNFTContract.mintProperty(2 ether, 0.5 ether, 5);
        vm.stopPrank();

        string memory expectedURI = string.concat("https://api.example.com/images/", LibString.toString(propertyId));
        string memory actualURI = PropertyTest.realStateNFTContract.tokenURI(propertyId);

        assertEq(actualURI, expectedURI, "URI should match the expected format");
    }
}
