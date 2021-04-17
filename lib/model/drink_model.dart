class DrinkModel {
  String key, name, price, image;

  DrinkModel({this.key, this.name, this.image, this.price});

  DrinkModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    price = json['price'].toString();
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['price'] = this.price.toString();
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
