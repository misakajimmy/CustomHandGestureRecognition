import 'package:flutter/material.dart';
import 'package:flutter_hand_tracking_plugin/HandGestureRecognition.dart';
import 'package:flutter_hand_tracking_plugin/flutter_hand_tracking_plugin.dart';
import 'package:flutter_hand_tracking_plugin/gen/landmark.pb.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _controller;
  List data;
  List<List> poseStored = [];

  @override
  void initState() {
    HandTrackingViewController _controller;
    this._controller = _controller;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('手势识别'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 500,
                child: HandTrackingView(
                  onViewCreated: (HandTrackingViewController c) {
                    setState(() => _controller = c);
                  },
                ),
              ),
              Container(

                height: 50,
                child: MaterialButton(
                  child: Text("添加一个手势"),
                  color: Colors.blue,
                  onPressed: () => addOnePose(),
                ),
              ),
              _controller == null
                  ? Text("Please grant camera permissions.")
                  : StreamBuilder<NormalizedLandmarkList>(
                      stream: _controller.landMarksStream,
                      initialData: NormalizedLandmarkList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        data = snapshot.data.landmark;
                        return snapshot.data.landmark != null &&
                                snapshot.data.landmark.length != 0
                            ? Stack(
                                children: <Widget>[
                                  Table(
                                    children:
                                        detectSimilar(snapshot.data.landmark),
                                  )
                                ],
                              )
                            : Text("No hand landmarks.");
                      }),
            ],
          ),
        ),
      ),
    );
  }

  void addOnePose() {
    List<double> trans = [];
    for (int i = 0; i < data.length; i++) {
      trans.add(data[i].x);
      trans.add(data[i].y);
    }
    poseStored.add(HandGestureRecognition.normalization(trans));
  }

  List<TableRow> detectSimilar(List nowdata) {
    var result = [
      TableRow(
        children: <Widget>[Text("手势编号"), Text("相似度")],
      )
    ];
    List<double> trans = [];
    for (int i = 0; i < nowdata.length; i++) {
      trans.add(nowdata[i].x);
      trans.add(nowdata[i].y);
    }
    trans = HandGestureRecognition.normalization(trans);
    for (var i = 0; i < poseStored.length; i++) {
      result.add(TableRow(
        children: <Widget>[
//          Text(trans.length.toString()),
//          Text(poseStored[i].length.toString()),
          Text(i.toString()),
          Text((HandGestureRecognition.sim(poseStored[i], trans) * 10 - 9)
              .toString()),
//          Text(poseStored[i]?.length.toString())
        ],
      ));
    }
    return result;
  }
}
