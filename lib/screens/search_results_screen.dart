import 'package:blue/services/functions.dart';
import 'package:blue/services/go_to.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../widgets/progress.dart';
import '../services/hasura.dart';
import '../widgets/post.dart';
import '../widgets/empty_state.dart';

enum SearchResultsType { posts, people, tags }

class SearchResultsScreen extends StatefulWidget {
  final SearchResultsType type;
  final String search;

  SearchResultsScreen(this.type, this.search, Key key) : super(key: key);
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool loading = true;
  List<dynamic> widgets = [];
  searchTags() async {
    List<dynamic> _tags = await Hasura.searchTags(widget.search);

    if (this.mounted)
      setState(() {
        widgets = _tags
            .map((doc) => ListTile(
                  leading: CircleAvatar(
                    child: Icon(FluentIcons.number_symbol_24_filled,
                        color: Theme.of(context).iconTheme.color),
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  // subtitle: Text('199,928,392 Posts',
                  //     style: TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w400,
                  //         color: Theme.of(context)
                  //             .iconTheme
                  //             .color
                  //             .withOpacity(0.8))),
                  title: Text(
                    '${doc["label"]}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ))
            .toList();
        loading = false;
      });
  }

  searchPeople() async {
    List<dynamic> _people = await Hasura.searchPeople(widget.search);
    if (this.mounted)
      setState(() {
        widgets = _people
            .map((doc) => ListTile(
                  onTap: () {
                    GoTo().profileScreen(context, doc["user_id"]);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(doc['avatar_url'] ??
                        "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                  ),
                  subtitle: Text('${doc["name"]}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              .withOpacity(0.8))),
                  title: Text(
                    '${doc["username"]}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ))
            .toList();
        loading = false;
      });
  }

  searchPosts() async {
    List<dynamic> _posts = await Hasura.searchPosts(widget.search);
    if (this.mounted)
      setState(() {
        _posts.forEach((doc) {
          widgets.add(Post.fromDocument(
            doc,
            isCompact: true,
            commentsShown: false,
          ));
        });
        loading = false;
      });
  }

  getPeople() async {}
  @override
  void initState() {
    if (widget.type == SearchResultsType.posts) {
      searchPosts();
    }

    if (widget.type == SearchResultsType.people) {
      searchPeople();
    }

    if (widget.type == SearchResultsType.tags) {
      searchTags();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? circularProgress()
        : widgets.length == 0
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Center(
                    child: emptyState(context, "No Results!", 'Searching')),
              )
            : ListView.builder(
                itemBuilder: (context, i) {
                  return widgets[i];
                },
                itemCount: widgets.length,
              );
  }
}
