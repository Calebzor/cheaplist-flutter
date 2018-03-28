import 'dart:async';

import 'package:cheaplist/dto/merchant_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.orangeAccent[400],
);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'CheapList',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new MyHomePage(title: 'CheapList'),
    );
  }
}

class MerchantItemList extends StatelessWidget {
  final String merchantId;
  final String filter;

  MerchantItemList(merchantId, filter)
      : merchantId = merchantId,
        filter = filter;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: getMerchantItems(merchantId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new ListView(
          children: getListItems(context, filter, snapshot.data.documents),
        );
      },
    );
  }

  List<StatelessWidget> getListItems(
      BuildContext context, String filter, List<DocumentSnapshot> documents) {
    List<StatelessWidget> widgets = new List<StatelessWidget>();
    for (var document in documents) {
      if (shouldShow(document, filter)) {
        MerchantItem item = new MerchantItem(merchantId, document['name'],
            document['price'], document['thumbnail'], document['imageURL']);
        GestureDetector listItem = new GestureDetector(
          child: new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(item.name),
                    new Text('${item.price}'),
                    new Image.network(
                      item.thumbnail,
                      width: 50.0,
                    )
                  ])),
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new DetailScreen(item: item)),
            );
          },
        );
        widgets.add(listItem);
      }
    }
    return widgets;
  }

  bool shouldShow(DocumentSnapshot document, String filter) {
    if (filter == null) {
      return true;
    }
    return document['name'].toLowerCase().contains(filter);
  }
}

Stream<QuerySnapshot> getMerchantItems(String merchantId) {
  return Firestore.instance
      .collection("merchantItems/" + merchantId + "/items")
      .snapshots;
}

class DetailScreen extends StatelessWidget {
  DetailScreen({Key key, this.item}) : super(key: key);

  final MerchantItem item;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(item.name),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(item.name),
            new Image.network(
              item.imageURL,
              width: 250.0,
            )
          ],
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchBarDemoHomeState createState() => new _SearchBarDemoHomeState(title);
}

class _SearchBarDemoHomeState extends State<MyHomePage> {
  String title;

  SearchBar searchBar;
  String filter = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text(title), actions: [searchBar.getSearchAction(context)]);
  }

  void onSubmitted(String value) {
    setState(() {
      if (value == null || value == "") {
        title = "CheapList";
      }
      else {
        title = value;
      }
      filter = value;
    });
  }

  _SearchBarDemoHomeState(String title) {
    this.title = title;
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        clearOnSubmit: false);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: searchBar.build(context),
      key: _scaffoldKey,
      body: new Row(
        children: <Widget>[
          new Expanded(
            child: new MerchantItemList("3QFbXk5gw0KXfNCZTiOi", filter),
          ),
          new Expanded(
            child: new MerchantItemList("oS53CrXawnyVOXVf6VKw", filter),
          ),
        ],
      ),
    );
  }
}
