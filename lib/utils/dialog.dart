import 'package:flutter/material.dart';

class DetailDialog {
  static Future<dynamic> bottomDialog(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      // 关键属性：设置为 true 即可自由控制弹窗高度
      isScrollControlled: true,
      // 将背景蒙层设为透明，以便自定义弹窗圆角效果
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          // 核心：设置弹窗高度为屏幕高度的一半
          width: MediaQuery.of(context).size.width * 2,
          height: MediaQuery.of(context).size.height / 2,
          // 设置顶部左右圆角，形成“抽屉”效果
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          // child: 在这里放置你的列表、表单等具体内容
          child: ExcludeSemantics(
            excluding: true, // 全局包装
            child: child,
          ),
        );
      },
    );
  }
}

class DialogUtil {
  static Future<dynamic> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,  // 点击外部不关闭
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('加载中...'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确定')
              )
            ],
          ),
        );
      },
    );
  }

  static Future<dynamic> showAnimatedDialog(BuildContext context, String message) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text('message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('关闭'),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}