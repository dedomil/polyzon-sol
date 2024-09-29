// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "hardhat/console.sol";

contract Esurf {
    struct User {
        string name;
        string delivery_address;
        uint256[] product_ids;
        uint256[] order_ids;
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

    enum OrderStatus {
        Shipped,
        OutForDelivery,
        Delivered,
        Cancelled
    }

    struct Order {
        uint256 order_id;
        uint256 product_id;
        OrderStatus status;
        uint256 quantity;
        uint256 timestamp;
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
    mapping(uint256 => Order) public orders;

    uint256 public productCount;
    uint256 public orderCount;

    function createOrEditUserProfile(
        string memory _name,
        string memory _delivery_address
    ) public {
        users[msg.sender] = User({
            name: _name,
            delivery_address: _delivery_address,
            product_ids: new uint256[](0),
            order_ids: new uint256[](0)
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

        users[msg.sender].product_ids.push(productCount);

        return productCount;
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productCount);
        for (uint256 i = 1; i <= productCount; i++) {
            allProducts[i - 1] = products[i];
        }
        return allProducts;
    }

    function getProduct(
        uint256 _productId
    ) public view returns (Product memory) {
        require(
            _productId > 0 && _productId <= productCount,
            "invalid product"
        );
        return products[_productId];
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

        orderCount++;
        Order memory newOrder = Order({
            order_id: orderCount,
            product_id: _productId,
            status: OrderStatus.Shipped,
            quantity: _quantity,
            timestamp: block.timestamp
        });

        orders[orderCount] = newOrder;
        users[msg.sender].order_ids.push(orderCount);

        payable(product.seller).transfer(product.price * _quantity);

        if (msg.value > product.price * _quantity) {
            payable(msg.sender).transfer(
                msg.value - (product.price * _quantity)
            );
        }
    }

    function getOrder(uint256 _orderId) public view returns (Order memory) {
        require(_orderId > 0 && _orderId <= orderCount, "invalid order");
        return orders[_orderId];
    }

    function updateOrderStatus(
        uint256 _orderId,
        OrderStatus _newStatus
    ) public {
        require(_orderId > 0 && _orderId <= orderCount, "invalid order");
        Order storage order = orders[_orderId];
        require(
            products[order.product_id].seller == msg.sender,
            "you're not a seller"
        );
        order.status = _newStatus;
    }

    function getUserOrders() public view returns (Order[] memory) {
        uint256[] memory userOrderIds = users[msg.sender].order_ids;
        Order[] memory userOrders = new Order[](userOrderIds.length);
        for (uint256 i = 0; i < userOrderIds.length; i++) {
            userOrders[i] = orders[userOrderIds[i]];
        }
        return userOrders;
    }
}
