import 'package:firebase_cart/model/cart_model.dart';
import 'package:firebase_cart/model/drink_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void addToCart(GlobalKey<ScaffoldState> _scaffoldKey, DrinkModel drinkModel,
    BuildContext context) {
  var cart = FirebaseDatabase.instance.reference().child('Cart');
  cart.child(drinkModel.key).once().then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      //If user already habe item in cart
      /*  var cartModel =
          CartModel.fromJson(json.decode(json.encode(snapshot.value)));
      cartModel.quantity++;

      cart
          .child(cartModel.key)
          .set(cartModel.toJson())
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Update successfuly'))))
          .catchError((e) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e'))));*/
    } else {
      //if user don't have item in  cart
      CartModel cartModel = new CartModel(
          name: drinkModel.name,
          key: drinkModel.key,
          price: drinkModel.price,
          image: drinkModel.image,
          quantity: 1,
          totalPrice: double.parse(drinkModel.price));

      cart
          .child(drinkModel.key)
          .set(cartModel.toJson())
          .then((value) => ScaffoldMessenger.of(_scaffoldKey.currentContext)
              .showSnackBar(SnackBar(content: Text('Add successfuly'))))
          .catchError((e) => ScaffoldMessenger.of(_scaffoldKey.currentContext)
              .showSnackBar(SnackBar(content: Text('$e'))));
    }
  });
}

void updateToCart(GlobalKey<ScaffoldState> _scaffoldKey, CartModel cartModel,
    BuildContext context) {
  var cart = FirebaseDatabase.instance.reference().child('Cart');
  cart
      .child(cartModel.key)
      .set(cartModel.toJson())
      .then((value) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update successfuly'))))
      .catchError((e) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e'))));
}

void deleteToCart(GlobalKey<ScaffoldState> _scaffoldKey, CartModel cartModel) {
  var cart = FirebaseDatabase.instance.reference().child('Cart');
  cart
      .child(cartModel.key)
      .remove()
      .then((value) => ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('Delete successfuly'))))
      .catchError((e) => ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('$e'))));
}
