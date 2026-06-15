import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  final String title;
  const VideoPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  // 所有角圆角半径为20
                  boxShadow: [BoxShadow(color: Colors.black12)],
                ),
                child: Column(children: [
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
