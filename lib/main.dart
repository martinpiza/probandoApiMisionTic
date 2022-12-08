import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probando/model/Gif.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Gif>> _listadoGift;

  Future<List<Gif>> _getGifs() async {
    List<Gif> resp = [];
    var url = Uri.parse(
        "https://api.giphy.com/v1/gifs/trending?api_key=f8M1jSJDWOfYkh6XzT3te39y6qbv9PAE&limit=10&rating=g");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        Gif gif = Gif(item["title"], item["images"]["downsized"]["url"]);
        resp.add(gif);
      }
    } else {
      throw Exception("No se pudo consumir la api");
    }
    return resp;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listadoGift = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: FutureBuilder(
            future: _listadoGift,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 2,
                  children: _listGifts(snapshot.data as List<Gif>),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("tiene error");
              }
              return Text("no debe llegar hasta aca");
            }),
      ),
    );
  }

  List<Widget> _listGifts(List<Gif> data) {
    List<Widget> resp = [];
    for (var gif in data) {
      resp.add(Card(
          child: Column(
        children: [
          Expanded(
              child: Image.network(
            gif.url,
            fit: BoxFit.fill,
          )),
        ],
      )));
    }
    return resp;
  }
}
