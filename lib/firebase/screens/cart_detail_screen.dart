import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_cart/model/cart_model.dart';
import 'package:firebase_cart/model/drink_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_cart/firebase/firebase_action.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';

import '../firebase_action.dart';

class CardDetail extends StatefulWidget {
  @override
  _CardDetailState createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  List<DrinkModel> drinkModels = new List<DrinkModel>.empty(growable: true);
  List<CartModel> cartModels = new List<CartModel>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Cart'))),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('/Cart').onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.hasData) {
            var map = snapshot.data.snapshot.value as Map<dynamic, dynamic>;
            cartModels.clear();
            if (map != null) {
              map.forEach((key, value) {
                var cartModel =
                    new CartModel.fromJson(json.decode(json.encode(value)));
                cartModel.key = key;
                cartModels.add(cartModel);
              });
            }
            return cartModels.length > 0
                ? ListView.builder(
                    itemCount: cartModels.length,
                    itemBuilder: (context, index) {
                      return Stack(children: [
                        Card(
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    child: Image(
                                        image: NetworkImage(
                                            cartModels[index].image),
                                        fit: BoxFit.cover),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Text(cartModels[index].name,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Total: \$${cartModels[index].totalPrice}'),
                                                ElegantNumberButton(
                                                    initialValue:
                                                        cartModels[index]
                                                            .quantity,
                                                    buttonSizeHeight: 20,
                                                    buttonSizeWidth: 25,
                                                    minValue: 0,
                                                    maxValue: 99,
                                                    onChanged: (value) async {
                                                      cartModels[index]
                                                          .quantity = value;
                                                      cartModels[index]
                                                              .totalPrice =
                                                          double.parse(
                                                                  cartModels[
                                                                          index]
                                                                      .price) *
                                                              cartModels[index]
                                                                  .quantity;
                                                      updateToCart(
                                                          _scaffoldKey,
                                                          cartModels[index],
                                                          context);
                                                    },
                                                    decimalPlaces: 0)
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      if (await confirm(context,
                                          title: Text("Delete item"),
                                          content: Text(
                                              'Do you really want to delete this itel ?'),
                                          textOK: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          textCancel: Text('Cancel'))) {
                                        return deleteToCart(
                                            _scaffoldKey, cartModels[index]);
                                      }
                                    }))),
                      ]);
                    },
                  )
                : Center(
                    child: Text("Empty Cart"),
                  );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
