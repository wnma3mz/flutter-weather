// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'stock_data.dart';
import 'stock_list.dart';
import 'stock_strings.dart';
import 'stock_symbol_viewer.dart';
import 'stock_types.dart';

typedef ModeUpdater = void Function(StockMode mode);

enum StockHomeTab { market, portfolio }

class StockHome extends StatefulWidget {
  const StockHome(this.stocks, this.configuration, this.updater);

  final StockData stocks;
  final StockConfiguration configuration;
  final ValueChanged<StockConfiguration> updater;

  @override
  StockHomeState createState() => StockHomeState();
}

class StockHomeState extends State<StockHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _modeName = 'Light';

  void _handleSearchBegin() {
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
          _searchQuery.clear();
        });
      },
    ));
    setState(() {
      _isSearching = true;
    });
  }

  void _handleStockModeChange(StockMode value) {
    if ((widget.updater != null) && (value == StockMode.optimistic)) {
      _modeName = 'Dark';
      widget.updater(
          widget.configuration.copyWith(stockMode: StockMode.pessimistic));
    }
    if ((widget.updater != null) && (value == StockMode.pessimistic)) {
      _modeName = 'Light';
      widget.updater(
          widget.configuration.copyWith(stockMode: StockMode.optimistic));
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Center(child: Text('Weather')),
              decoration: BoxDecoration(
                color: Colors.purple,
              )
          ),
          const ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Stock List'),
            selected: true,
          ),
          // 分界线
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: Text('$_modeName Mode'),
            onTap: () {
              if (_modeName == 'Light')
                _handleStockModeChange(StockMode.optimistic);
              else if (_modeName == 'Dark')
                _handleStockModeChange(StockMode.pessimistic);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: _handleShowSettings,
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('About'),
            onTap: _handleShowAbout,
          ),
        ],
      ),
    );
  }

  void _handleShowSettings() {
    Navigator.popAndPushNamed(context, '/settings');
  }

  void _handleShowAbout() {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text('Weather'),
              content: new Text('Test Content'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                new LICENSES(title: 'Licenses')));
                  },
                  child: new Text('VIEW LICENSES'),
                ),
                new FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: new Text('OK'),
                ),
              ],
            ));
  }

  Widget buildAppBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(StockStrings.of(context).title()),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _handleSearchBegin,
          tooltip: 'Search',
        ),
      ],
      bottom: TabBar(
        tabs: <Widget>[
          Tab(text: StockStrings.of(context).market()),
          Tab(text: StockStrings.of(context).portfolio()),
        ],
      ),
    );
  }

  static Iterable<Stock> _getStockList(
      StockData stocks, Iterable<String> symbols) {
    return symbols
        .map<Stock>((String symbol) => stocks[symbol])
        .where((Stock stock) => stock != null);
  }

  Iterable<Stock> _filterBySearchQuery(Iterable<Stock> stocks) {
    if (_searchQuery.text.isEmpty) return stocks;
    final RegExp regexp = RegExp(_searchQuery.text, caseSensitive: false);
    return stocks.where((Stock stock) => stock.symbol.contains(regexp));
  }

  void _buyStock(Stock stock) {
    setState(() {
      stock.percentChange = stock.lastSale;
      stock.lastSale = stock.lastSale;
//      stock.percentChange = 100.0 * (1.0 / stock.lastSale);
//      stock.lastSale += 1.0;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Purchased ${stock.symbol} for ${stock.lastSale}'),
      action: SnackBarAction(
        label: 'BUY MORE',
        onPressed: () {
          _buyStock(stock);
        },
      ),
    ));
  }

  Widget _buildStockList(
      BuildContext context, Iterable<Stock> stocks, StockHomeTab tab) {
    return StockList(
      stocks: stocks.toList(),
      onAction: _buyStock,
      onOpen: (Stock stock) {
        Navigator.pushNamed(context, '/stock:${stock.symbol}');
      },
      onShow: (Stock stock) {
        _scaffoldKey.currentState.showBottomSheet<void>(
            (BuildContext context) => StockSymbolBottomSheet(stock: stock));
      },
    );
  }

  Widget _buildStockTab(
      BuildContext context, StockHomeTab tab, List<String> stockSymbols) {
    return AnimatedBuilder(
      key: ValueKey<StockHomeTab>(tab),
      animation: Listenable.merge(<Listenable>[_searchQuery, widget.stocks]),
      builder: (BuildContext context, Widget child) {
        return _buildStockList(
            context,
            _filterBySearchQuery(_getStockList(widget.stocks, stockSymbols))
                .toList(),
            tab);
      },
    );
  }

  static const List<String> portfolioSymbols = <String>['南昌'];

  Widget buildSearchBar() {
    return AppBar(
      leading: BackButton(
        color: Theme.of(context).accentColor,
      ),
      title: TextField(
        controller: _searchQuery,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search stock',
        ),
      ),
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _isSearching ? buildSearchBar() : buildAppBar(),
        drawer: _buildDrawer(context),
        body: TabBarView(
          children: <Widget>[
            _buildStockTab(
                context, StockHomeTab.market, widget.stocks.allSymbols),
            _buildStockTab(context, StockHomeTab.portfolio, portfolioSymbols),
          ],
        ),
      ),
    );
  }
}

class LICENSES extends StatelessWidget {
  const LICENSES({Key key, this.title}) : super(key: key);
  final title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
          appBar: new AppBar(
            title: new Text(title),
          ),
          body: new Center(child: new Text('This is TEST LICENSES!')),
        );
  }
}
