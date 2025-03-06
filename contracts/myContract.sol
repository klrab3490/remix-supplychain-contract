// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    struct Product {
        string productId;
        string name;
        string manufacturer;
        address currentCustodian; // Changed from string to address
        string currentLocation;
        uint256 manufactureDate;
        uint256 transferCount;
    }

    mapping(string => Product) private products;
    string[] private productIds; // Store all product IDs

    event ProductRegistered(string indexed productId, string name, address indexed manufacturer);
    event ProductTransferred(string indexed productId, address indexed from, address indexed to, string newLocation);

    modifier onlyCustodian(string memory _productId) {
        require(msg.sender == products[_productId].currentCustodian, "Not the custodian");
        _;
    }

    function registerProduct(
        string memory _productId,
        string memory _name,
        string memory _manufacturer,
        string memory _location
    ) public {
        require(bytes(products[_productId].productId).length == 0, "Product already exists");

        products[_productId] = Product({
            productId: _productId,
            name: _name,
            manufacturer: _manufacturer,
            currentCustodian: msg.sender, // Now correctly stored as an address
            currentLocation: _location,
            manufactureDate: block.timestamp,
            transferCount: 0
        });

        productIds.push(_productId); 
        emit ProductRegistered(_productId, _name, msg.sender);
    }

    function transferCustodian(string memory _productId, address _newCustodian, string memory _newLocation)
        public
        onlyCustodian(_productId)
    {
        require(_newCustodian != address(0), "Invalid address");

        products[_productId].currentCustodian = _newCustodian;
        products[_productId].currentLocation = _newLocation;
        products[_productId].transferCount += 1;

        emit ProductTransferred(_productId, msg.sender, _newCustodian, _newLocation);
    }

    function getProduct(string memory _productId) public view returns (Product memory) {
        return products[_productId];
    }

    function getAllProducts() external view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productIds.length);
        for (uint i = 0; i < productIds.length; i++) {
            allProducts[i] = products[productIds[i]];
        }
        return allProducts;
    }
}
