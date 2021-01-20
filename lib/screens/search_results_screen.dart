import 'package:flutter/material.dart';
import '../widgets/progress.dart';
import '../services/hasura.dart';
import '../widgets/post.dart';
import '../widgets/empty_state.dart';
enum SearchResultsType{
  posts,
  users,
  tags
}
class SearchResultsScreen extends StatefulWidget {
final SearchResultsType type;
SearchResultsScreen( this.type);
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool loading = true;
  List<dynamic> widgets = [];
  getPosts()async{
      dynamic _posts =  await  Hasura.getPosts(10, 0, "{created_at:desc}");
       print(_posts);
      setState(() {
   widgets = _posts.map((doc) => Post.fromDocument(doc,hasura: true,)).toList();
   loading = false;
      });

   }
  @override
  void initState() {
    getPosts();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return loading? circularProgress():widgets.length == 0? Container(height: MediaQuery.of(context).size.height,width: double.infinity,
      child:Center(child: emptyState(context, "Search something new!", 'Searching')),):ListView.builder(
      itemBuilder: (context,i){

        return widgets[i];
      },
      itemCount: widgets.length,
    );
  }
}