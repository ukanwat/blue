import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

/// Link Preview Widget
class LinkPreview extends StatefulWidget {
  const LinkPreview({
    Key key,
    @required this.url,
    this.cache = const Duration(hours: 1),
    this.builder,
    this.titleStyle,
    this.bodyStyle,
    this.showMultimedia = true,
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

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  String _url;
  InfoBase _info;
   bool _failedToLoadImage = false;
  @override
  void initState() {
    _init();
    super.initState();
  }
    static String _getUriWithPrefix(uri) {
    if (uri == null || uri == "") {
      return uri;
    }
    Uri prefixUri;
    Uri parsedUri = Uri.parse(uri);
    if (!parsedUri.host.startsWith('www')) {
      prefixUri = parsedUri.replace(host: 'www.' + parsedUri.host);
    }
    return prefixUri.toString();
  }
    void _validateImageUri(uri) async {
   await precacheImage(NetworkImage(uri), context, onError: (e, stackTrace) {
     setState(() {
         _failedToLoadImage = true;
     });
      
     
    });
  }
  Future<void> _init() async {
    _url = widget.url.trim();
    if (_url.startsWith("http")) {
      _info = await WebAnalyzer.getInfo(
        _url,
        cache: widget.cache,
        multimedia: widget.showMultimedia,
      );
         if (mounted) setState(() {});
         if(_info.runtimeType == WebInfo)
      _validateImageUri((_info as WebInfo).icon);
    } else {
      print("Links don't start with http or https from : $_url");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('efesfsefsef');
    if (widget.builder != null) {
      return widget.builder(_info);
    }
    print('efesfsefsef');
    if ( _info is YoutubeInfo) {
      print((_info as YoutubeInfo).url);
      return  Container(
        height: (MediaQuery.of(context).size.width-20)*(9/16),
        child: Stack(
          children: <Widget>[
             CachedNetworkImage(
          imageUrl: (_info as  YoutubeInfo).url,
          fit: BoxFit.contain,
        ),Container(width: double.infinity,
          child: Column(
            children: <Widget>[
                if( (_info as  YoutubeInfo).title != '')SizedBox(height: 10,),
              Expanded(child: Icon(FlutterIcons.youtube_mco,size: 60,)),
              if( (_info as  YoutubeInfo).title != '')
              Container(padding: EdgeInsets.symmetric(horizontal: 6),
                width: double.infinity,
                color: Colors.black.withOpacity(0.3),height: 30,child: Center(child: Text( (_info as  YoutubeInfo).title,maxLines: 1,overflow: TextOverflow.ellipsis,style: widget.titleStyle,)),)
            ],
          ),
        )
          ],
        ),
      );
    }
print('efesfsefsef');
    if (_info == null || _info is VideoInfo) {
      return const SizedBox();
    }
print('efesfsefsef');
    if (_info is ImageInfo) {
      return
       CachedNetworkImage(
        imageUrl: (_info as ImageInfo).url,
        fit: BoxFit.contain,
      );
    }

    final WebInfo info = _info;
    final bool hasDescription = WebAnalyzer.isNotEmpty(info.description);
    final Color iconColor = widget.titleStyle?.color;
    print('${info.title}////////////////////////////////////////////////////////////////////////////////////////////////////////////////////');
    return Container(
      width: double.infinity,
      child: Row(
        
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[  if (WebAnalyzer.isNotEmpty(info.icon))
                Container(
                  padding: EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                      imageUrl:_failedToLoadImage == false
              ? info.icon
              : _getUriWithPrefix(info.icon), 
                      fit: BoxFit.cover,
                      height: 76,
                      width: 76,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(FlutterIcons.link_fea, size: 45, color: iconColor),
                ),
                 Expanded(
                                    child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            
          Row(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
            
              const SizedBox(width: 6),
              Expanded(
                child:
                Text(
                    WebAnalyzer.isNotEmpty(info.title)?
              info.title:widget.url,maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: widget.titleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(FlutterIcons.link_external_oct,size: 20,),
              )
            ],
          ),
          if (hasDescription)
            Padding(
              padding: const EdgeInsets.only(left: 6,bottom: 6,right: 6,top: 0),
              child: Text(
                info.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: widget.bodyStyle,
              ),
            ),]),
                 )
        ],
      ),
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

  WebInfo({this.title, this.icon, this.description});
}

/// Image Information
class ImageInfo extends InfoBase {
  final String url;

  ImageInfo({this.url});
}

/// Video Information
class VideoInfo extends InfoBase {
  final String url;
  VideoInfo({this.url});
}
/// YoutubeInfo Information
class YoutubeInfo extends InfoBase {
  final String url;
    final String title;
  YoutubeInfo({this.url,this.title});
}

/// Web analyzer
class WebAnalyzer {
  static final Map<String, InfoBase> _map = {};
  static final RegExp _bodyReg = RegExp(r"<body[^>]*>([\s\S]*)<\/body>");
  static final RegExp _scriptReg = RegExp(r"<script[^>]*>([\s\S]*)<\/script>");
  /// Is it an empty string
  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase> getInfo(String url,
      {Duration cache, bool multimedia = true}) async {
    url = url.replaceFirst("https", "http");
    InfoBase info = _map[url];
    if (info != null) {
      if (info._timeout.isAfter(DateTime.now())) {
        return info;
      } else {
        _map.remove(url);
      }
    }
    try {
      final response = await http.get(url);
      if (multimedia) {
        final String contentType = response.headers["content-type"];
        if (contentType != null) {
          if (contentType.contains("image/")) {
            info = ImageInfo(url: url);
          } else if (contentType.contains("video/")) {
            info = VideoInfo(url: url);
          }
        }
      }
               
      info ??= _getWebInfo(response, url, multimedia);

      if (cache != null && info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {
      print("Get web info error($url) $e");
    }

    return info;
  }

  static InfoBase _getWebInfo(
      http.Response response, String url, bool multimedia) {
    if (response.statusCode == 200) {
  print("asadasdasdawsdasdasda");
      var urlPattern = r"((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$";
     bool isYoutubeVideo  = RegExp(urlPattern,).hasMatch(url);
      String  mediaBody;
      try {
        mediaBody = const Utf8Decoder().convert(response.bodyBytes);
              // Improved performance
       mediaBody =  mediaBody.replaceFirst(_bodyReg, "<body></body>");
       mediaBody =  mediaBody.replaceAll(_scriptReg, "");
      final mediaDocument = parser.parse( mediaBody);
           if(isYoutubeVideo){
            return YoutubeInfo(url: _analyzeIcon(mediaDocument, url),title:  _analyzeTitle(mediaDocument));
      }
      // get image or video
      if (multimedia) {
        final gif = _analyzeGif(mediaDocument, url);
        if (gif != null) return gif;

        final video = _analyzeVideo(mediaDocument, url);
        if (video != null) return video;

      }
         final info = WebInfo(
        title: _analyzeTitle(mediaDocument),
        icon: _analyzeIcon(mediaDocument, url),
        description: _analyzeDescription(mediaDocument),
      );
      return info;
      
      } catch (e) {
        print("//axaxaxxaxaxax");
  
      }

 var requiredAttributes = ['title', 'image'];
    var data = {};
           var document = parser.parse(response.body);
      var openGraphMetaTags = _getOgPropertyData(document);

      openGraphMetaTags.forEach((element) {
        var ogTagTitle = element.attributes['property'].split("og:")[1];
        var ogTagValue = element.attributes['content'];
        if ((ogTagValue != null && ogTagValue != "") ||
            requiredAttributes.contains(ogTagTitle)) {
          if (ogTagTitle == "image" && !ogTagValue.startsWith("http")) {
            data[ogTagTitle] = "http://" + _extractHost(url) + ogTagValue;
          } else {
            data[ogTagTitle] = ogTagValue;
          }
        }
      });
      _scrapeDataToEmptyValue(data, document, url);
      return WebInfo(
      description: data['description'],
      icon: data['image'],
      title: data['title']
    );
    }
  return null;
  }
  


 
  ///////////////////////////////////
  static void _scrapeDataToEmptyValue(Map data, Document document, String url) {
    if (!data.containsKey("title") ||
        data["title"] == null ||
        data["title"] == "") {
      data["title"] = _scrapeTitle(document);
    }

    if (!data.containsKey("image") ||
        data["image"] == null ||
        data["image"] == "") {
      data["image"] = _scrapeImage(document, url);
    }

    if (!data.containsKey("description") ||
        data["description"] == null ||
        data["description"] == "") {}
    data["description"] = _scrapeDescription(document);
  }

  static String _scrapeTitle(Document document) {
    var tagTitle = document.head.getElementsByTagName("title")[0].text;
    if (tagTitle != null) {
      return tagTitle;
    }
    return "";
  }

  static String _scrapeDescription(Document document) {
    var meta = document.getElementsByTagName("meta");
    var description = "";
    var metaDescription = meta.firstWhere(
        (e) => e.attributes["name"] == "description",
        orElse: () => null);

    if (metaDescription != null) {
      description = metaDescription.attributes["content"];
    }

    if (description != null && description != "") {
      return description;
    } else {
      description = document.head.getElementsByTagName("title")[0].text;
    }
    return description;
  }

  static String _scrapeImage(Document document, String url) {
    var images = document.body.getElementsByTagName("img");
    var imageSrc = "";
     print('$imageSrc ppppppppppppppppppppppppppppppppppppppp');
    if (images.length > 0) {
      imageSrc = images[0].attributes["src"];

      if (!imageSrc.startsWith("http")) {
        imageSrc = "http://" + _extractHost(url) + imageSrc;
      }
    }
    if (imageSrc == "") {
      print("WARNING - WebPageParser - " + url);
      print(
          "WARNING - WebPageParser - image might be empty. Tag <img> was not found.");
    }
    print('$imageSrc ppppppppppppppppppppppppppppppppppppppp');
    return imageSrc;
  }

  static List<Element> _getOgPropertyData(Document document) {
    return document.head.querySelectorAll("[property*='og:']");
  }

  // static String _addWWWPrefixIfNotExists(String uri) {
  //   if (uri == null || uri == "") {
  //     return uri;
  //   }

  //   Uri prefixUri;
  //   Uri parsedUri = Uri.parse(uri);
  //   if (!parsedUri.host.startsWith('www')) {
  //     prefixUri = parsedUri.replace(host: 'www.' + parsedUri.host);
  //   }
  //   return prefixUri.toString();
  // }
  ///////////////////////////////////////////////
  static InfoBase _analyzeGif(Document document, String url) {
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      if (gif != null) return ImageInfo(url: _handleUrl(url, gif));
    }
    return null;
  }

  static InfoBase _analyzeVideo(Document document, String url) {
    final video = _getMetaContent(document, "property", "og:video");
    if (video != null) return VideoInfo(url: _handleUrl(url, video));
    return null;
  }

  static String _getMetaContent(
      Document document, String property, String propertyValue) {
    final meta = document.head.getElementsByTagName("meta");
    final ele = meta.firstWhere((e) => e.attributes[property] == propertyValue,
        orElse: () => null);
    if (ele != null) return ele.attributes["content"];
    return null;
  }

  static String _getHost(String url) {
    final Uri uri = Uri.parse(url);
    return uri.host;
  }

  static String _analyzeTitle(Document document) {
    final title = _getMetaContent(document, "property", "og:title");
    if (title != null) return title;
    final list = document.head.getElementsByTagName("title");
    if (list.isNotEmpty) {
      final tagTitle = list.first.text;
      if (tagTitle != null) return tagTitle;
    }
    return '';
  }

  static String _analyzeDescription(Document document) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description");
    return description;
  }
  //   static String _analyzeIcon(Document document, String url) {
  //   var images = document.body.getElementsByTagName("img");
  //   var imageSrc = "";
  //   if (images.length > 0) {
  //     imageSrc = images[0].attributes["src"];

  //     if (!imageSrc.startsWith("http")) {
  //       imageSrc = "http://" + _extractHost(url) + imageSrc;
  //     }
  //   }
  //   if (imageSrc == "") {
  //     print("WARNING - WebPageParser - " + url);
  //     print(
  //         "WARNING - WebPageParser - image might be empty. Tag <img> was not found.");
  //   }
  //   return imageSrc;
  // }
  static String _extractHost(String link) {
    Uri uri = Uri.parse(link);
    return uri.host;
  }

  
  static String _analyzeIcon(Document document, String url) {
    final meta = document.head.getElementsByTagName("link");
    String icon = "";
    final metaIcon = meta.firstWhere((e) {
      final rel = e.attributes["rel"];
      if (rel == "icon" ||
          rel == "shortcut icon" ||
          rel == "fluid-icon" ||
          rel == "apple-touch-icon") {
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
      final meta = document.head.getElementsByTagName("meta");
      final metaDescription = meta.firstWhere(
          (e) => e.attributes["property"] == "og:image",
          orElse: () => null);

      if (metaDescription != null) {
        icon = metaDescription.attributes["content"];
      }
    }

    return _handleUrl(url, icon);
  }

  static String _handleUrl(String host, String source) {
    if (isNotEmpty(source)) {
      if (!source.startsWith("http")) {
        if (source.startsWith("//")) {
          source = source.replaceFirst("//", "http://");
        } else {
          source = "http://${_getHost(host)}$source";
        }
      }
    }
    return source;
  }
}
