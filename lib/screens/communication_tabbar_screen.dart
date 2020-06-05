import 'package:blue/screens/activity_feed_screen.dart';
import 'package:blue/screens/chats_screen.dart';
import 'package:flutter/material.dart';

class CommunicationTabbarScreen extends StatefulWidget {
  @override
  _CommunicationTabbarScreenState createState() =>
      _CommunicationTabbarScreenState();
}

class _CommunicationTabbarScreenState extends State<CommunicationTabbarScreen> {
  TextEditingController searchController = TextEditingController();
  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  handleSearch(String query) {}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 1),
            child: Container(
              height: 38,
              alignment: Alignment.center,
              child: TextFormField(
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontSize: 18),
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  fillColor: Colors.grey[300],
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(width: 0, color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(55),
                    borderSide: BorderSide(width: 0, color: Colors.white),
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon:
                      // searchController.text.isEmpty? IconButton(icon: Icon(Icons.search), onPressed: () => handleSearch) :
                      IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: clearSearch,
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    iconSize: 22,
                  ),
                ),
                onFieldSubmitted: handleSearch,
              ),
            ),
          ),
          bottom: TabBar(
            //indicator: BoxDecoration(shape: BoxShape.rectangle),
            indicatorWeight: 3, indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            labelColor: Theme.of(context).primaryColor,
            tabs: <Widget>[
              Tab(
                text: 'Direct',
              ),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body:
            TabBarView(children: <Widget>[ChatsScreen(), ActivityFeedScreen()]),
      ),
    );
  }
}
