class CartModel {
  String key, name, image, price;
  int quantity;
  double totalPrice;

  CartModel(
      {this.key,
      this.name,
      this.image,
      this.price,
      this.quantity,
      this.totalPrice});

  CartModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    image = json['image'];
    price = json['price'].toString();
    quantity = json['quantity'] as int;
    totalPrice = double.parse(json['totalPrice'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['image'] = this.image;
    data['price'] = this.price.toString();
    data['quantity'] = this.quantity;
    data['totalPrice'] = this.totalPrice;
    return data;
  }

  get getPrice => this.price;

  set setPrice(price) => this.price = price;

  get getQuantity => this.quantity;

  set setQuantity(quantity) => this.quantity = quantity;

  get getTotalPrice => this.totalPrice;

  set setTotalPrice(totalPrice) => this.totalPrice = totalPrice;
}
