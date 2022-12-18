import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagramexample/components/heart_icon_animator.dart';
import 'package:instagramexample/utils/models.dart';
import 'package:instagramexample/utils/ui_utils.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  const CommentWidget(this.comment, {super.key});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  void _toggleIsLiked() {
    widget.comment.toggleLikeFor(currentUser);
  }

  Text _buildRichText() {
    var currentTextData = StringBuffer();
    var textSpans = <TextSpan>[
      TextSpan(text: '${widget.comment.user.name} ', style: bold),
    ];
    widget.comment.text.split(' ').forEach((word) {
      if (word.startsWith('#') && word.length > 1) {
        if (currentTextData.isNotEmpty) {
          textSpans.add(TextSpan(text: currentTextData.toString()));
          currentTextData.clear();
        }
        textSpans.add(TextSpan(text: '$word ', style: link));
      } else {
        currentTextData.write('$word ');
      }
    });
    if (currentTextData.isNotEmpty) {
      textSpans.add(TextSpan(text: currentTextData.toString()));
      currentTextData.clear();
    }
    return Text.rich(TextSpan(children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: <Widget>[
          _buildRichText(),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  HeartIconAnimator(
                    isLiked: widget.comment.isLikedBy(currentUser),
                    size: 14.0,
                    onTap: _toggleIsLiked,
                    triggerAnimationStream: const Stream.empty(),
                  ),
                  Text(
                    widget.comment.likes.isNotEmpty
                        ? '${widget.comment.likes.length}'
                        : '',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
