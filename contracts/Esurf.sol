// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "hardhat/console.sol";

contract Esurf {
    struct User {
        string name;
        string delivery_address;
        uint256[] product_ids;
        uint256[] purchase_history;
    }

    struct Review {
        address userAddress;
        string text;
        uint256 timestamp;
    }

    enum Category {
        Electronics,
        Accessories,
        Clothing,
        Furniture,
        Food
    }

    struct Product {
        uint256 id;
        string name;
        uint256 price;
        string description;
        Category category;
        address seller;
        uint256 stock;
        string image;
    }

    mapping(address => User) public users;
    mapping(uint256 => Product) public products;
    mapping(uint256 => Review[]) public productReviews;

    uint256 public productCount;

    function createOrEditUserProfile(
        string memory _name,
        string memory _delivery_address
    ) public {
        users[msg.sender] = User({
            name: _name,
            delivery_address: _delivery_address,
            product_ids: new uint256[](0),
            purchase_history: new uint256[](0)
        });
    }

    function getUserProfile() public view returns (User memory) {
        return users[msg.sender];
    }

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _description,
        Category _category,
        uint256 _stock,
        string memory _image
    ) public returns (uint256) {
        productCount++;

        products[productCount] = Product({
            id: productCount,
            name: _name,
            price: _price,
            description: _description,
            category: _category,
            seller: msg.sender,
            stock: _stock,
            image: _image
        });

        return productCount;
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productCount);
        for (uint256 i = 1; i <= productCount; i++) {
            allProducts[i - 1] = products[i];
        }
        return allProducts;
    }

    function addReview(uint256 _productId, string memory _text) public {
        require(bytes(_text).length > 0, "text cannot be empty");

        productReviews[_productId].push(
            Review({
                userAddress: msg.sender,
                text: _text,
                timestamp: block.timestamp
            })
        );
    }

    function getProductReviews(
        uint256 _productId
    ) public view returns (Review[] memory) {
        return productReviews[_productId];
    }

    function buyProduct(uint256 _productId, uint256 _quantity) public payable {
        Product storage product = products[_productId];
        console.log(msg.value, product.price, _quantity);
        require(product.stock >= _quantity, "out of stock");
        require(msg.value >= product.price * _quantity, "not enough funds");

        product.stock -= _quantity;

        users[msg.sender].purchase_history.push(_productId);

        payable(product.seller).transfer(product.price * _quantity);

        if (msg.value > product.price * _quantity) {
            payable(msg.sender).transfer(
                msg.value - (product.price * _quantity)
            );
        }

        // emit ProductPurchased(
        //     msg.sender,
        //     _productId,
        //     _quantity,
        //     product.price * _quantity
        // );
    }

    // event ProductPurchased(
    //     address buyer,
    //     uint256 productId,
    //     uint256 quantity,
    //     uint256 totalPrice
    // );
}
