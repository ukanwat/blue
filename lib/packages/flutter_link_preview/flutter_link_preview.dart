import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

/// Link Preview Widget
class FlutterLinkPreview extends StatefulWidget {
  const FlutterLinkPreview({
    Key key,
    @required this.url,
    this.cache = const Duration(hours: 24),
    this.builder,
    this.titleStyle,
    this.bodyStyle,
    this.showMultimedia = true,
    this.useMultithread = false,
  }) : super(key: key);

  /// Web address, HTTP and HTTPS support
  final String url;

  /// Cache result time, default cache 1 hour
  final Duration cache;

  /// Customized rendering methods
  final Widget Function(InfoBase info) builder;

  /// Title style
  final TextStyle titleStyle;

  /// Content style
  final TextStyle bodyStyle;

  /// Show image or video
  final bool showMultimedia;

  /// Whether to use multi-threaded analysis of web pages
  final bool useMultithread;

  @override
  _FlutterLinkPreviewState createState() => _FlutterLinkPreviewState();
}

class _FlutterLinkPreviewState extends State<FlutterLinkPreview> {
  String _url;
  InfoBase _info;

  @override
  void initState() {
    _url = widget.url.trim();
    _info = WebAnalyzer.getInfoFromCache(_url);
    if (_info == null) _getInfo();
    super.initState();
  }

  Future<void> _getInfo() async {
    if (_url.startsWith("http")) {
      _info = await WebAnalyzer.getInfo(
        _url,
        cache: widget.cache,
        multimedia: widget.showMultimedia,
        useMultithread: widget.useMultithread,
      );
      if (mounted) setState(() {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder(_info);
    }

    if (_info == null) return const SizedBox();

    if (_info is WebImageInfo) {
      return Image.network(
        (_info as WebImageInfo).image,
        fit: BoxFit.contain,
      );
    }

    final WebInfo info = _info;
    if (!WebAnalyzer.isNotEmpty(info.title)) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Image.network(
              info.icon ?? "",
              fit: BoxFit.contain,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.link, size: 30, color: widget.titleStyle?.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                info.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.titleStyle,
              ),
            ),
          ],
        ),
        if (WebAnalyzer.isNotEmpty(info.description)) ...[
          const SizedBox(height: 8),
          Text(
            info.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: widget.bodyStyle,
          ),
        ],
      ],
    );
  }
}

abstract class InfoBase {
  DateTime _timeout;
}

/// Web Information
class WebInfo extends InfoBase {
  final String title;
  final String icon;
  final String description;
  final String image;
  final String redirectUrl;

  WebInfo({
    this.title,
    this.icon,
    this.description,
    this.image,
    this.redirectUrl,
  });
}

/// Image Information
class WebImageInfo extends InfoBase {
  final String image;

  WebImageInfo({this.image});
}

/// Video Information
class WebVideoInfo extends WebImageInfo {
  WebVideoInfo({String image}) : super(image: image);
}

/// Web analyzer
class WebAnalyzer {
  static final Map<String, InfoBase> _map = {};
  static final RegExp _bodyReg =
      RegExp(r"<body[^>]*>([\s\S]*?)<\/body>", caseSensitive: false);
  static final RegExp _htmlReg = RegExp(
      r"(<head[^>]*>([\s\S]*?)<\/head>)|(<script[^>]*>([\s\S]*?)<\/script>)|(<style[^>]*>([\s\S]*?)<\/style>)|(<[^>]+>)|(<link[^>]*>([\s\S]*?)<\/link>)|(<[^>]+>)",
      caseSensitive: false);
  static final RegExp _metaReg = RegExp(
      r"<(meta|link)(.*?)\/?>|<title(.*?)</title>",
      caseSensitive: false,
      dotAll: true);
  static final RegExp _titleReg =
      RegExp("(title|icon|description|image)", caseSensitive: false);
  static final RegExp _lineReg = RegExp(r"[\n\r]|&nbsp;|&gt;");
  static final RegExp _spaceReg = RegExp(r"\s+");

  /// Is it an empty string
  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static InfoBase getInfoFromCache(String url) {
    final InfoBase info = _map[url];
    if (info != null) {
      if (!info._timeout.isAfter(DateTime.now())) {
        _map.remove(url);
      }
    }
    return info;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase> getInfo(String url,
      {Duration cache = const Duration(hours: 24),
      bool multimedia = true,
      bool useMultithread = false}) async {
    // final start = DateTime.now();

    InfoBase info = getInfoFromCache(url);
    if (info != null) return info;
    try {
      if (useMultithread)
        info = await _getInfoByIsolate(url, multimedia);
      else
        info = await _getInfo(url, multimedia);

      if (cache != null && info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {}

    return info;
  }

  static Future<InfoBase> _getInfo(String url, bool multimedia) async {
    final response = await _requestUrl(url);

    if (response == null) return null;
    if (multimedia) {
      final String contentType = response.headers["content-type"];
      if (contentType != null) {
        if (contentType.contains("image/")) {
          return WebImageInfo(image: url);
        } else if (contentType.contains("video/")) {
          return WebVideoInfo(image: url);
        }
      }
    }

    return _getWebInfo(response, url, multimedia);
  }

  static Future<InfoBase> _getInfoByIsolate(String url, bool multimedia) async {
    final sender = ReceivePort();
    final Isolate isolate = await Isolate.spawn(_isolate, sender.sendPort);
    final sendPort = await sender.first as SendPort;
    final answer = ReceivePort();

    sendPort.send([answer.sendPort, url, multimedia]);
    final List<String> res = await answer.first;

    InfoBase info;
    if (res != null) {
      if (res[0] == "0") {
        info = WebInfo(
            title: res[1], description: res[2], icon: res[3], image: res[4]);
      } else if (res[0] == "1") {
        info = WebVideoInfo(image: res[1]);
      } else if (res[0] == "2") {
        info = WebImageInfo(image: res[1]);
      }
    }

    sender.close();
    answer.close();
    isolate.kill(priority: Isolate.immediate);

    return info;
  }

  static void _isolate(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    port.listen((message) async {
      final SendPort sender = message[0];
      final String url = message[1];
      final bool multimedia = message[2];

      final info = await _getInfo(url, multimedia);

      if (info is WebInfo) {
        sender.send(["0", info.title, info.description, info.icon, info.image]);
      } else if (info is WebVideoInfo) {
        sender.send(["1", info.image]);
      } else if (info is WebImageInfo) {
        sender.send(["2", info.image]);
      } else {
        sender.send(null);
      }
      port.close();
    });
  }

  static final Map<String, String> _cookies = {
    "weibo.com":
        "YF-Page-G0=02467fca7cf40a590c28b8459d93fb95|1596707497|1596707497; SUB=_2AkMod12Af8NxqwJRmf8WxGjna49_ygnEieKeK6xbJRMxHRl-yT9kqlcftRB6A_dzb7xq29tqJiOUtDsy806R_ZoEGgwS; SUBP=0033WrSXqPxfM72-Ws9jqgMF55529P9D9W59fYdi4BXCzHNAH7GabuIJ"
  };

  static bool _certificateCheck(X509Certificate cert, String host, int port) =>
      true;

  static Future<Response> _requestUrl(String url,
      {int count = 0, String cookie, useDesktopAgent = true}) async {
    if (url.contains("m.toutiaoimg.cn")) useDesktopAgent = false;
    Response res;
    final uri = Uri.parse(url);
    final ioClient = HttpClient()..badCertificateCallback = _certificateCheck;
    final client = IOClient(ioClient);
    final request = Request('GET', uri)
      ..followRedirects = false
      ..headers["User-Agent"] = useDesktopAgent
          ? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"
          : "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
      ..headers["cache-control"] = "no-cache"
      ..headers["Cookie"] = cookie ?? _cookies[uri.host]
      ..headers["accept"] = "*/*";
    final stream = await client.send(request);

    if (stream.statusCode == HttpStatus.movedTemporarily ||
        stream.statusCode == HttpStatus.movedPermanently) {
      if (stream.isRedirect && count < 6) {
        final String location = stream.headers['location'];
        if (location != null) {
          url = location;
          if (location.startsWith("/")) {
            url = uri.origin + location;
          }
        }
        if (stream.headers['set-cookie'] != null) {
          cookie = stream.headers['set-cookie'];
        }
        count++;
        client.close();
        return _requestUrl(url, count: count, cookie: cookie);
      }
    } else if (stream.statusCode == HttpStatus.ok) {
      res = await Response.fromStream(stream);
      if (uri.host == "m.tb.cn") {
        final match = RegExp(r"var url = \'(.*)\'").firstMatch(res.body);
        if (match != null) {
          final newUrl = match.group(1);
          if (newUrl != null) {
            return _requestUrl(newUrl, count: count, cookie: cookie);
          }
        }
      }
    }
    client.close();
    return res;
  }

  static Future<InfoBase> _getWebInfo(
      Response response, String url, bool multimedia) async {
    if (response.statusCode == HttpStatus.ok) {
      String html;
      try {
        html = const Utf8Decoder().convert(response.bodyBytes);
      } catch (e) {
        try {
          html = gbk.decode(response.bodyBytes);
        } catch (e) {}
      }

      if (html == null) {
        return null;
      }

      // Improved performance
      // final start = DateTime.now();
      final headHtml = _getHeadHtml(html);
      final document = parser.parse(headHtml);
      final uri = Uri.parse(url);

      // get image or video
      if (multimedia) {
        final gif = _analyzeGif(document, uri);
        if (gif != null) return gif;

        final video = _analyzeVideo(document, uri);
        if (video != null) return video;
      }

      String title = _analyzeTitle(document);
      String description =
          _analyzeDescription(document, html)?.replaceAll(r"\x0a", " ");
      if (!isNotEmpty(title)) {
        title = description;
        description = null;
      }

      final info = WebInfo(
        title: title,
        icon: _analyzeIcon(document, uri),
        description: description,
        image: _analyzeImage(document, uri),
        redirectUrl: response.request.url.toString(),
      );
      return info;
    }
    return null;
  }

  static String _getHeadHtml(String html) {
    html = html.replaceFirst(_bodyReg, "<body></body>");
    final matchs = _metaReg.allMatches(html);
    final StringBuffer head = StringBuffer("<html><head>");
    if (matchs != null) {
      matchs.forEach((element) {
        final String str = element.group(0);
        if (str.contains(_titleReg)) head.writeln(str);
      });
    }
    head.writeln("</head></html>");
    return head.toString();
  }

  static InfoBase _analyzeGif(Document document, Uri uri) {
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      if (gif != null) return WebImageInfo(image: _handleUrl(uri, gif));
    }
    return null;
  }

  static InfoBase _analyzeVideo(Document document, Uri uri) {
    final video = _getMetaContent(document, "property", "og:video");
    if (video != null) return WebVideoInfo(image: _handleUrl(uri, video));
    return null;
  }

  static String _getMetaContent(
      Document document, String property, String propertyValue) {
    final meta = document.head.getElementsByTagName("meta");
    final ele = meta.firstWhere((e) => e.attributes[property] == propertyValue,
        orElse: () => null);
    if (ele != null) return ele.attributes["content"]?.trim();
    return null;
  }

  static String _analyzeTitle(Document document) {
    final title = _getMetaContent(document, "property", "og:title");
    if (title != null) return title;
    final list = document.head.getElementsByTagName("title");
    if (list.isNotEmpty) {
      final tagTitle = list.first.text;
      if (tagTitle != null) return tagTitle.trim();
    }
    return "";
  }

  static String _analyzeDescription(Document document, String html) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description") ??
        _getMetaContent(document, "name", "Description");

    if (!isNotEmpty(description)) {
      // final DateTime start = DateTime.now();
      String body = html.replaceAll(_htmlReg, "");
      body = body.trim().replaceAll(_lineReg, " ").replaceAll(_spaceReg, " ");
      if (body.length > 300) {
        body = body.substring(0, 300);
      }
      return body;
    }
    return description;
  }

  static String _analyzeIcon(Document document, Uri uri) {
    final meta = document.head.getElementsByTagName("link");
    String icon = "";
    // get icon first
    var metaIcon = meta.firstWhere((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    }, orElse: () => null);

    metaIcon ??= meta.firstWhere((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "shortcut icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    }, orElse: () => null);

    if (metaIcon != null) {
      icon = metaIcon.attributes["href"];
    } else {
      return "${uri.origin}/favicon.ico";
    }

    return _handleUrl(uri, icon);
  }

  static String _analyzeImage(Document document, Uri uri) {
    final image = _getMetaContent(document, "property", "og:image");
    return _handleUrl(uri, image);
  }

  static String _handleUrl(Uri uri, String source) {
    if (isNotEmpty(source) && !source.startsWith("http")) {
      if (source.startsWith("//")) {
        source = "${uri.scheme}:$source";
      } else {
        if (source.startsWith("/")) {
          source = "${uri.origin}$source";
        } else {
          source = "${uri.origin}/$source";
        }
      }
    }
    return source;
  }
}
