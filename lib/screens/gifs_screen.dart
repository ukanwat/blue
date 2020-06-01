import 'package:blue/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';

class GIFsScreen extends StatefulWidget {
  static const routeName = 'gifs';
  @override
  _GIFsScreenState createState() => _GIFsScreenState();
}

class _GIFsScreenState extends State<GIFsScreen> {
  GiphyCollection gifCollection;
  bool loading = false;
  final client = new GiphyClient(apiKey: '4ZvArkekyWmuf3ndnnO3FqSCvpYrdP6q');
  TextEditingController gifSearchController = TextEditingController();
  @override
  void initState(){
  getTrendingGIFs();
    super.initState();
  }
  
  
  getTrendingGIFs()async{
     setState(() {
      loading = true;
    });
gifCollection = await client.trending(limit: 50,
   );
    setState(() {
      loading = false;
    });
  }
  getSearchedGIFs(String searchTerm)async{
    setState(() {
      loading = true;
    });
    gifCollection = await client.search(gifSearchController.text);
    setState(() {
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,leading: CupertinoNavigationBarBackButton(),automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 0),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              controller: gifSearchController,
              decoration: InputDecoration(
                hintText: 'Search',
                fillColor: Colors.grey[300],
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onFieldSubmitted: getSearchedGIFs,
            ),
          ),
        ),
      ),
      body:loading? circularProgress(): GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0),
              itemCount:gifCollection.data.length ,
          itemBuilder: (_,i){
           return Container(
             child: GestureDetector(
               onTap: (){
                 Navigator.pop(context,gifCollection.data[i].images.original.url);
               },
                            child: Card(elevation: 0,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10),
               ),
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                     
                     gifCollection.data[i].images.previewGif.url,
                     height: MediaQuery.of(context).size.width/2-10,
                     fit: BoxFit.cover,
                   ),
                 ),
               ),
             ),
           );
          }),
    );
  }
}
class GIFCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}