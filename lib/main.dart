import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // use imageCache.clear(); to clear cached images cache

import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(new MyApp());

// Define global variables
String _url = "";
List<String> _imgArr = new List<String>();
String _coverImage = "";
String _errorImg = "https://derpicdn.net/img/view/2018/3/24/1689611__safe_applejack_404_earth+pony_female_hat_mare_official+art_pony_simple+background_solo_transparent+background.png";
String _currentQuery = "";

class MyApp extends StatelessWidget {// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Chryssibooru',
      theme: new ThemeData(
        primarySwatch: Colors.teal,
        canvasColor: Colors.white12,
      ),
      home: new MyHomePage(title: 'Chryssibooru'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Textfield controller
  final TextEditingController _textfieldController = new TextEditingController();

  // Get results from Json
  Future<Map> get(String query, int perpage) async {
    var httpClient = new HttpClient();
    var uri = new Uri.http('derpibooru.org', '/search.json', {'q': '$query', 'perpage': '$perpage'});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = await json.decode(responseBody);

    // Display the query URL
    _url = uri.toString();
    print ("QUERY_URL: " + _url);

    return data;
  }

  // Put results in the list
  void queryToList() async {
    // Get query string and sanitize it
    String query = _textfieldController.text.toLowerCase();
    _currentQuery = query;

    Map data = await get(query, 30);

    // Add all images to array
    if (query != _currentQuery) {
      for (var v in data['search']) {
        _imgArr.add("http:" + v['image']);
      }
    } else {
      _imgArr.clear();
      for (var v in data['search']) {
        _imgArr.add("http:" + v['image']);
      }
    }

    if (_imgArr.isEmpty)
      print("ERR: NO_RESULTS");
    else
      print ("SUCC: " + _imgArr.length.toString() + " elements in query");
  }

  // Get random Chrysalis pic
  Future<String> getRandomChryssi() async {
    String q = "chrysalis, safe, -animated, solo";
    Map map = await get(q, 30);

    // Make a list of Chryssi images
    List<String> imgs = new List<String>();
    for(var v in map['search'])
    {
      imgs.add("http:" + v['image']);
    }

    // Select a random image
    var rng = new Random();
    int i = rng.nextInt(imgs.length);

    // Print random img to console
    print (imgs[i]);
    //Save in a variable
    _coverImage = imgs[i];

    // Return random pic
    return imgs[i];
  }

  // Get main Derpi URL from image URL
  String getMainUrl(String url) {
    List<String> strList = url.split("/");
    List<String> strList2 = strList[strList.length-1].split("_");

    print (strList2[0]);
    return strList2[0];
  }

  // Open image in browser
  void openImageInBrowser (String url) async {
    url = "https://derpibooru.org/" + getMainUrl(url);

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not open $url';
      }
  }

  // Open Ko-Fi
  void kofi() async {
    const url = 'https://ko-fi.com/angius';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  

  // Widgets
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.filter_list),
              onPressed: null
          )
        ],

        title: new Text(widget.title),
      ),

      body: new Container(
        padding: new EdgeInsets.all(5.0),

        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Search...',
                hintStyle: new TextStyle(
                  color: Colors.teal,
                ),
                prefixIcon: new Icon(
                  Icons.search,
                ),
              ),
              style: new TextStyle(
                color: Colors.teal,
              ),
              keyboardType: TextInputType.text,
              maxLines: 1,
              controller: _textfieldController,
            ),



          ],
        ),
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: queryToList,
        tooltip: 'Search',
        child: new Icon(Icons.search),
      ),



      // Drawer
      drawer: new Drawer(
          child: new ListView(
            children: <Widget> [
              new Container(
                color: Colors.teal,

                child: new DrawerHeader(
                  child: new Container(
                    decoration: new BoxDecoration(

                      border: new Border(
                        bottom: new BorderSide(color: Colors.white12, style: BorderStyle.solid, width: 2.0),
                        top: new BorderSide(color: Colors.white12, style: BorderStyle.solid, width: 2.0),
                        left: new BorderSide(color: Colors.white12, style: BorderStyle.solid, width: 2.0),
                        right: new BorderSide(color: Colors.white12, style: BorderStyle.solid, width: 2.0),
                      ),
                      borderRadius: new BorderRadius.all(new Radius.circular(0.3)),
                    ),

                    child: new FutureBuilder(
                      future: getRandomChryssi(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none: return new Text(
                              "Loading...",
                            style: new TextStyle(
                              color: Colors.black12,
                              fontSize: 12.0,
                            ),
                            textAlign: TextAlign.center,
                          );

                          case ConnectionState.waiting: return new  CircularProgressIndicator(
                            strokeWidth: 5.5,
                            backgroundColor: Colors.black87,
                          );

                          default:
                            if (snapshot.hasError)
                              return new GestureDetector(
                                child:
                                  new CachedNetworkImage(
                                    imageUrl: "$_errorImg",
                                    placeholder: new CircularProgressIndicator(
                                      strokeWidth: 5.5,
                                      backgroundColor: Colors.black87,
                                    ),
                                    errorWidget: new Icon(Icons.error),
                                    fit: BoxFit.cover,
                                ),

                                onTap: (){
                                  openImageInBrowser("$_errorImg");
                                },
                              );
                            else
                              return new GestureDetector(
                                child:
                                  new CachedNetworkImage(
                                      imageUrl: "${snapshot.data}",
                                      placeholder: new CircularProgressIndicator(
                                        strokeWidth: 5.5,
                                        backgroundColor: Colors.black87,
                                      ),
                                      errorWidget: new Icon(Icons.error),
                                      fit: BoxFit.cover,
                                  ),

                                onTap: (){
                                  openImageInBrowser(snapshot.data);
                                },
                                );
                        }
                      },
                    ),
                  ),
                ),
              ),

              new Container(
                child: new Column(
                  children: <Widget>[

                    new ListTile(
                      leading: new Icon(
                          Icons.settings,
                          color: Colors.teal,
                      ),
                      title: new Text(
                          'Settings',
                          style: new TextStyle(
                            color: Colors.teal,
                          ),
                      ),
                      onTap: getRandomChryssi,
                    ),

                    new ListTile(
                      leading: new Icon(
                          Icons.free_breakfast,
                          color: Colors.teal,
                      ),
                      title: new Text(
                          'Buy me a coffe',
                          style: new TextStyle(
                            color: Colors.teal,
                          ),
                      ),
                      onTap: kofi,
                    ),

                    new Divider(color: Colors.teal,),

                    new ListTile(
                      leading: new Icon(
                          Icons.help,
                          color: Colors.teal,
                      ),
                      title: new Text(
                          'About',
                          style: new TextStyle(
                            color: Colors.teal,
                          ),
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => new FullscreenView())
                        );
                      },
                    ),
                  ],
                ),
              ),

            ],
          )
      ),
    );
  }
}



// Second screen
class FullscreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: null,
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('Go back!'),
        ),
      ),
    );
  }
}