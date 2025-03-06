// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    address public adminAddress = 0x63Fd440E5a0b48E2515765b857C6e35544C8F573;

    struct Product {
        string productId;
        string name;
        string manufacturer;
        address currentCustodian;
        string currentLocation;
        uint256 manufactureDate;
        uint256 transferCount;
    }

    mapping(string => Product) private products;
    string[] private productIds;

    event ProductRegistered(string indexed productId, string name, address indexed manufacturer);
    event ProductTransferred(string indexed productId, address indexed from, address indexed to, string newLocation);

    modifier onlyCustodian(string memory _productId) {
        require(msg.sender == products[_productId].currentCustodian, "Not the custodian");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not the admin");
        _;
    }

    function registerProduct(
        string memory _productId,
        string memory _name,
        string memory _manufacturer,
        string memory _location
    ) public onlyAdmin {
        require(bytes(products[_productId].productId).length == 0, "Product already exists");

        products[_productId] = Product({
            productId: _productId,
            name: _name,
            manufacturer: _manufacturer,
            currentCustodian: msg.sender,
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
        require(msg.sender == adminAddress || msg.sender == products[_productId].currentCustodian, "Not authorized");
        return products[_productId];
    }

    function getAllProducts() external view returns (Product[] memory) {
        require(msg.sender == adminAddress, "Not authorized");
        Product[] memory allProducts = new Product[](productIds.length);
        for (uint i = 0; i < productIds.length; i++) {
            allProducts[i] = products[productIds[i]];
        }
        return allProducts;
    }
}
