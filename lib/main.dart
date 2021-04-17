import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_cart/firebase/screens/my_drawer.dart';
import 'package:firebase_cart/model/cart_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase/firebase_action.dart';
import 'firebase/screens/cart_detail_screen.dart';
import 'model/drink_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  runApp(MyApp(app: app));
}

class MyApp extends StatelessWidget {
  final FirebaseApp app;

  MyApp({this.app});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/cartPage':
            return PageTransition(
                child: CardDetail(),
                settings: settings,
                type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);
  final String title;
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
    List<DrinkModel> drinkModels = new List<DrinkModel>.empty(growable: true);
    List<CartModel> cartModels = new List<CartModel>.empty(growable: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Center(child: Text(widget.title)), actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 20),
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.reference().child('Cart').onValue,
            builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
              if (snapshot.hasData) {
                Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                cartModels.clear();
                if (map != null) {
                  map.forEach((key, value) {
                    var cartModel =
                        CartModel.fromJson(json.decode(json.encode(value)));
                    cartModel.key = key;
                    cartModels.add(cartModel);
                  });
                }

                var numberItemInCart;
                if (cartModels.length != 0) {
                  numberItemInCart = cartModels
                      .map<int>((m) => m.quantity)
                      .reduce((value, element) => value + element);
                } else {
                  numberItemInCart = 0;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/cartPage');
                  },
                  child: Center(
                      child: Badge(
                    showBadge: true,
                    badgeContent: Text(
                        '${numberItemInCart > 9 ? 9.toString() + "+" : numberItemInCart.toString()} ',
                        style: TextStyle(color: Colors.white)),
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  )),
                );
              } else {
                return Center(
                    child: Badge(
                  showBadge: true,
                  badgeContent:
                      Text('0', style: TextStyle(color: Colors.white)),
                  child: Icon(Icons.shopping_cart, color: Colors.red),
                ));
              }
            },
          ),
        )
      ]),
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseDatabase.instance.reference().child('/Drink').onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  var map =
                      snapshot.data.snapshot.value as Map<dynamic, dynamic>;
                  drinkModels.clear();
                  map.forEach((key, value) {
                    var drinkModel = new DrinkModel.fromJson(
                        json.decode(json.encode(value)));
                    drinkModel.key = key;
                    drinkModels.add(drinkModel);
                  });

                  return StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: drinkModels.length,
                      padding: const EdgeInsets.all(2.0),
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: GestureDetector(
                            onTap: () async {
                              CartModel c;
                              if (cartModels.isNotEmpty) {
                                for (int i = 0; i < cartModels.length; i++) {
                                  if (cartModels[i].name ==
                                      drinkModels[index].name) {
                                    c = cartModels[i];
                                    if (c.quantity == 1) {
                                      if (await confirm(context,
                                          title: Text("ALERT"),
                                          content: Text(
                                              "Do you want to buy another ${drinkModels[index].name} ?"))) {
                                        updateToCart(_scaffoldKey, c, context);
                                      }
                                    }
                                  } else {
                                    addToCart(_scaffoldKey, drinkModels[index],
                                        context);
                                    print(
                                        "touched !!! ${drinkModels[index].name}");
                                  }
                                }
                              } else {
                                addToCart(
                                    _scaffoldKey, drinkModels[index], context);
                                print("touched !!! ${drinkModels[index].name}");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                  elevation: 8,
                                  child: Column(children: [
                                    Expanded(
                                        child: Image.network(
                                            drinkModels[index].image)),
                                    Text('${drinkModels[index].name}'),
                                    Text("${drinkModels[index].price} €")
                                  ])),
                            ),
                          ),
                        );
                      },
                      staggeredTileBuilder: (index) =>
                          StaggeredTile.count(1, 1.0));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      drawer: myDrawer(),
    );
  }
}
