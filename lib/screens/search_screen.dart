// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import './home.dart';
import './search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List _list;
    QuerySnapshot searches;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> peopleResultsFuture;
  Future<QuerySnapshot> postsResultsFuture;
  bool recentSearchesLoading = false;
  Widget recentSearchesWidget;
  handleSearch(String query) {
    Future<QuerySnapshot> people = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();
    setState(() {
      peopleResultsFuture = people;
    });
    Future<QuerySnapshot> posts = postsCollectionGroupRef
        .where('title', isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      postsResultsFuture = posts;
    });
   
       searchesRef.doc(currentUser.id).collection('userSearches').doc().set({
        'order':1,
        'searches': [{query:DateTime.now()}],
      });
    
    if(_list.length>1999 ){
      searchesRef.doc(currentUser.id).collection('userSearches').doc().set({
        'order':searches.docs.first.data()['order']+1,
        'searches': [{query:DateTime.now()}],
      });
    }else{
       searchesRef.doc(currentUser.id).collection('userSearches').doc(searches.docs.first.reference.id).update({
        'searches': FieldValue.arrayUnion([{query:DateTime.now()}]),
      });
    }
 
  }
 bool loading= true;
getRecentSearches()async{
    
  searches = await searchesRef.doc(currentUser.id).collection('userSearches').orderBy('order',descending: true).limit(1).get();
    List _fullList = searches.docs.first.data()['searches'];
     List _timeList = [];
     _list.forEach((element) {
    _fullList .add(element.values.first);
     _list.add(element.keys.first);
      });
    if(_list == null || _list.length == 0){
   recentSearchesWidget = Container(height: 100,width: double.infinity,child: Center(child:Text('No Recent searches Found!',)));
    }else{
int start = _list.length-4;
    if(start < 0)
    start = 0;
    List _recentSearches =  _list.sublist(start,_list.length);
     List _timeposts =  _timeList.sublist(start,_list.length);
  
    
     recentSearchesWidget = new ListView.builder(
            shrinkWrap: true,
            itemCount: _recentSearches.length,
            itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    key: UniqueKey(),
                title: Text(_recentSearches[index],
                
                ),trailing: IconButton(icon: Icon(Icons.clear,
                color: Theme.of(context).iconTheme.color,
                ),
                onPressed: ()async{
                  setState(() {
           
                 searchesRef..doc(currentUser.id).collection('userSearches').doc(searches.docs.first.id).update({
                   'searches': FieldValue.arrayRemove([{_recentSearches[index]:_timeposts[index]}]) ,
                 });  
           _recentSearches[index].removeAt(index);       
                  });
                },
                ),
                );
            });
    }
    setState(() {
      loading = false;
    });
          
        }

  

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  PreferredSize buildSearchField(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: EdgeInsets.all(6),
          width: 15,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor,),
          child: IconButton(
              iconSize: 18,
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 18,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        elevation: 1,
        backgroundColor: Theme.of(context).canvasColor,
        title: Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 1),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(maxLength: 100,
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',counterText: '',
                hintStyle: TextStyle(
                  color:  Theme.of(context).iconTheme.color.withOpacity(0.8),
                ),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).cardColor,),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).cardColor,),
                ),
                prefixIcon: Icon(
      FlutterIcons.search_oct,
      size: 22,
      color: Colors.grey,
    ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: clearSearch,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  ),
                ),
              ),
              onFieldSubmitted: (search){
                  // if((_list != null && _list.length != 0)||searches.docs.length == 0|| true)// TODO check for 0 due to some error
                   {
  handleSearch(search);
                print('sfsf');
                  }         
              
                },
            ),
          ),
        ),
      ),
    );
  }

  Container recentSearches() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
       peopleResultsFuture == null && postsResultsFuture == null
          ?   recentSearchesWidget  : Container()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: buildSearchField(context),
      body: peopleResultsFuture == null && postsResultsFuture == null
          ? (loading? circularProgress():Column(
            children: [
              Container(
                height: 200,
                child: recentSearchesWidget),
                Expanded(child: emptyState(context, "Search something new!", 'Searching'))
            ],
          ))
          :
          searchResultsScreen(
              peopleResultsFuture, postsResultsFuture, searchController,
              context
              ),
    );
  }
}
