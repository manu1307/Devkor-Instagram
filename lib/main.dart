// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (c) => Store1()),
      ChangeNotifierProvider(create: (c) => Store2()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: style.theme,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;

  saveData() async {
    var storage = await SharedPreferences.getInstance();
    var map = {'age': 20};
    storage.setString('map', jsonEncode(map));
    var result = storage.getString('map') ?? '없는데';
  }

  @override
  void initState() {
    super.initState();
    saveData();
    getData();
  }

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
  }

// data에 새로운 아이템 add 해주는 함수임
  adddata(smalldata) {
    setState(() {
      data.add(smalldata);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instagram',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Upload(
                          userImage: userImage,
                          data: data,
                          uploadPost: adddata)));
            },
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          )
        ],
        elevation: 1,
      ),
      body: bodyelement(
        data: data,
        adddata: adddata,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'bag')
        ],
      ),
    );
  }
}

class Upload extends StatefulWidget {
  Upload({Key? key, this.userImage, this.data, this.uploadPost})
      : super(key: key);
  final userImage;
  final uploadPost;
  var data;
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final myController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close)),
                ],
              ),
              SizedBox(
                width: 400,
                height: 300,
                child: Image.file(
                  widget.userImage,
                  fit: BoxFit.cover,
                ),
              ),
              Text('업로드할 이미지'),
              Divider(
                height: 25,
              ),
              TextField(
                controller: myController,
                decoration: InputDecoration(hintText: 'Write a text'),
              ),
              TextButton(
                onPressed: () {
                  widget.uploadPost({
                    'id': widget.data.length,
                    'image': (widget.userImage.toString().substring(6)),
                    'likes': 5,
                    'user': 'Park',
                    'content': (myController.text).toString()
                  });
                  print(widget.data[widget.data.length - 1]);
                  Navigator.pop(context);
                },
                child: Text('upload'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class bodyelement extends StatefulWidget {
  bodyelement({
    Key? key,
    required this.data,
    this.adddata,
  }) : super(key: key);
  var data;
  final adddata;

  @override
  State<bodyelement> createState() => _bodyelementState();
}

class _bodyelementState extends State<bodyelement> {
  var scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getnewdata() async {
          var newdata = await http
              .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
          var newdata2 = jsonDecode(newdata.body);
          if (widget.data.length < 4) {
            widget.adddata(newdata2);
          } else {
            return;
          }
        }

        getnewdata();
      }
      // print(scroll.position.userScrollDirection.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: ((context, index) {
            return Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageSection(
                      imageUrl: widget.data[index]['image'],
                    ),
                    Text('좋아요 ${widget.data[index]["likes"]}개'),
                    GestureDetector(
                      child: Text(widget.data[index]['user']),
                      onTap: () {
                        context.read<Store1>().getData();
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: ((c, a1, a2) => Profile()),
                                transitionsBuilder: (c, a1, a2, child) =>
                                    FadeTransition(
                                      opacity: a1,
                                      child: child,
                                    ),
                                transitionDuration:
                                    Duration(milliseconds: 1000)));
                      },
                    ),
                    Text(widget.data[index]['content']),
                  ]),
            );
          }));
    } else {
      return Text('Loading');
    }
  }
}

class ImageSection extends StatefulWidget {
  ImageSection({Key? key, this.imageUrl}) : super(key: key);
  final imageUrl;
  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.startsWith('https')) {
      return Image.network(widget.imageUrl);
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Image.file(
          File(widget.imageUrl.replaceAll("'", "")),
        ),
      );
    }
  }
}

class Store2 extends ChangeNotifier {
  var name = "john kim";
  var follower = 0;
  var followerYes = false;
  addFollower() {
    if (followerYes == false) {
      follower++;
      followerYes = true;
    } else {
      follower--;
      followerYes = false;
    }
    notifyListeners();
  }
}

class Store1 extends ChangeNotifier {
  var profileImage = [];
  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(profileImage);
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.watch<Store2>().name),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(),
            ),
            SliverGrid(
                delegate: SliverChildBuilderDelegate(
                    (c, i) => Container(
                        child: Image.network(
                            '${context.watch<Store1>().profileImage[i]}')),
                    childCount: 6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2)),
          ],
        ));
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        CircleAvatar(
          backgroundColor: Colors.grey[500],
          radius: 30,
        ),
        Text('팔로워수 ${context.read<Store2>().follower}명'),
        ElevatedButton(
            onPressed: () {
              context.read<Store2>().addFollower();
            },
            child: Text('팔로우')),
      ]),
    );
  }
}
