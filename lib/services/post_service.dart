import 'package:blue/widgets/post.dart';

class PostService {
  Future<dynamic> Function(int) fn;
  dynamic Function(dynamic) transform;
  bool compact;
  PostService(this.fn, this.transform, this.compact);
  bool loaded = false;
  bool _complete = false;
  List<Post> _posts = [];
  int offset = 0;
  int loadIndex = 0;
  bool init = true;

  bool adding = false;

  get getLoaded => _complete;
  _addPosts() async {
    if (loaded) {
      return;
    }

    List<dynamic> _doc = await fn(offset);
    _doc.forEach((d) {
      _posts.add(Post.fromDocument(
        transform(
          d,
        ),
        commentsShown: true,
        isCompact: compact,
      ));
      offset++;
    });

    if (_doc.length == 0) {
      loaded = true;
    }
  }

  Future<List<Post>> getPosts(int count) async {
    if (adding) {
      return [];
    }
    adding = true;

    if (!init) {
      await Future.delayed(Duration(milliseconds: 800));
    }
    if (init) {
      init = false;
      await _addPosts();
    }
    if (_posts.length - loadIndex < 20) {
      _addPosts();
    }

    int start = loadIndex;
    loadIndex =
        _posts.length < loadIndex + count ? _posts.length : loadIndex + count;

    if (_posts.length - loadIndex < 20) {
      _addPosts();
    }

    if (loaded && loadIndex >= _posts.length - 1) {
      _complete = true;
    }
    adding = false;
    return _posts.sublist(start, loadIndex);
  }
}
