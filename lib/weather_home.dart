// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'weather_data.dart';
import 'weather_list.dart';
import 'weather_strings.dart';
import 'weather_symbol_viewer.dart';
import 'weather_types.dart';

typedef ModeUpdater = void Function(WeatherMode mode);

enum WeatherHomeTab { city, note }

class WeatherHome extends StatefulWidget {
  const WeatherHome(this.weathers, this.configuration, this.updater);

  final WeatherData weathers;
  final WeatherConfiguration configuration;
  final ValueChanged<WeatherConfiguration> updater;

  @override
  WeatherHomeState createState() => WeatherHomeState();
}

class WeatherHomeState extends State<WeatherHome> {
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

  void _handleWeatherModeChange(WeatherMode value) {
    if ((widget.updater != null) && (value == WeatherMode.optimistic)) {
      _modeName = 'Dark';
      widget.updater(
          widget.configuration.copyWith(weatherMode: WeatherMode.pessimistic));
    }
    if ((widget.updater != null) && (value == WeatherMode.pessimistic)) {
      _modeName = 'Light';
      widget.updater(
          widget.configuration.copyWith(weatherMode: WeatherMode.optimistic));
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
              )),
          const ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Weather List'),
            selected: true,
          ),
          // 分界线
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: Text('$_modeName Mode'),
            onTap: () {
              if (_modeName == 'Light')
                _handleWeatherModeChange(WeatherMode.optimistic);
              else if (_modeName == 'Dark')
                _handleWeatherModeChange(WeatherMode.pessimistic);
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
      title: Text(WeatherStrings.of(context).title()),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _handleSearchBegin,
          tooltip: 'Search',
        ),
      ],
      bottom: TabBar(
        tabs: <Widget>[
          Tab(text: WeatherStrings.of(context).market()),
          Tab(text: WeatherStrings.of(context).portfolio()),
        ],
      ),
    );
  }

  static Iterable<Weather> _getWeatherList(
      WeatherData weathers, Iterable<String> symbols) {
    return symbols
        .map<Weather>((String symbol) => weathers[symbol])
        .where((Weather weather) => weather != null);
  }

  Iterable<Weather> _filterBySearchQuery(Iterable<Weather> weathers) {
    if (_searchQuery.text.isEmpty) return weathers;
    final RegExp regexp = RegExp(_searchQuery.text, caseSensitive: false);
    return weathers.where((Weather weather) => weather.city.contains(regexp));
  }

  void _buyWeather(Weather weather) {
    setState(() {
      weather.wDwS = weather.weathers;
      weather.weathers = weather.weathers;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Purchased ${weather.city} for ${weather.weathers}'),
      action: SnackBarAction(
        label: 'BUY MORE',
        onPressed: () {
          _buyWeather(weather);
        },
      ),
    ));
  }

  Widget _buildWeatherList(
      BuildContext context, Iterable<Weather> weathers, WeatherHomeTab tab) {
    return WeatherList(
      weathers: weathers.toList(),
      onAction: _buyWeather,
      onOpen: (Weather weather) {
        Navigator.pushNamed(context, '/stock:${weather.city}');
      },
      onShow: (Weather weather) {
        _scaffoldKey.currentState.showBottomSheet<void>(
            (BuildContext context) =>
                WeatherSymbolBottomSheet(weather: weather));
      },
    );
  }

  Widget _buildWeatherTab(
      BuildContext context, WeatherHomeTab tab, List<String> weatherSymbols) {
    return AnimatedBuilder(
      key: ValueKey<WeatherHomeTab>(tab),
      animation: Listenable.merge(<Listenable>[_searchQuery, widget.weathers]),
      builder: (BuildContext context, Widget child) {
        return _buildWeatherList(
            context,
            _filterBySearchQuery(
                    _getWeatherList(widget.weathers, weatherSymbols))
                .toList(),
            tab);
      },
    );
  }

  static const List<String> noteSymbols = <String>['南昌'];
  final _saved = new List<String>();


  Widget buildSearchBar() {
    return AppBar(
      leading: BackButton(
        color: Theme.of(context).accentColor,
      ),
      title: TextField(
        controller: _searchQuery,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search city',
        ),
      ),
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  void _handleCreateCity() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => _CreateCitySheet(),
    );
  }

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      tooltip: 'New city',
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).accentColor,
      onPressed: _handleCreateCity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _isSearching ? buildSearchBar() : buildAppBar(),
        floatingActionButton: buildFloatingActionButton(),
        drawer: _buildDrawer(context),
        body: TabBarView(
          children: <Widget>[
            _buildWeatherTab(
                context, WeatherHomeTab.city, widget.weathers.allSymbols),
            _buildWeatherTab(
                context, WeatherHomeTab.note, noteSymbols),
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

class _CreateCitySheet extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '请输入新城市的名字',
          ),
        ),
        new RaisedButton(
          onPressed: () {
            // to-do add citys
              print(_controller.text);
//              WeatherData weathers;
//              weathers = WeatherData('101051201');
              Navigator.pop(context);
          },
          child: new Text('DONE'),
        ),
      ],
    );
  }
}
