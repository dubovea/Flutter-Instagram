import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagramexample/components/comment_texts.dart';
import 'package:instagramexample/components/heart_icon_animator.dart';
import 'package:instagramexample/components/heart_overlay_animator.dart';
import 'package:instagramexample/components/likes_text.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagramexample/utils/models.dart';
import 'package:instagramexample/components/avatar_widget.dart';
import 'package:instagramexample/utils/ui_utils.dart';
import 'package:instagramexample/utils/storage_service.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget(this.post);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final StreamController<void> _doubleTapImageEvents =
      StreamController.broadcast();
  bool _isLiked = false;
  bool _isSaved = false;
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _doubleTapImageEvents.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _asyncCheckIsLiked();
  }

  void _asyncCheckIsLiked() async {
    _isLiked = await widget.post.isLikedBy(widget.post.id, currentUser);
    if (mounted) {
      setState(() => _isLiked = _isLiked);
    }
  }

  void _updateImageIndex(int index, reason) {
    setState(() => _currentImageIndex = index);
  }

  void _onDoubleTapLikePhoto() {
    setState(
        () => widget.post.addLikeIfUnlikedFor(widget.post.id, currentUser));
    _doubleTapImageEvents.sink.add(null);
  }

  void _toggleIsLiked() async {
    _isLiked = await widget.post.toggleLikeFor(widget.post.id, currentUser);
    setState(() => _isLiked = _isLiked);
  }

  void _toggleIsSaved() {
    setState(() => _isSaved = !_isSaved);
  }

  Future<void> _addComment(String text) async {
    await storage.addComment(widget.post.id, currentUser, text);
  }

  void _showAddCommentModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddCommentModal(
            user: currentUser,
            onPost: (String text) {
              _addComment(text);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // User Details
        Row(
          children: <Widget>[
            AvatarWidget(
              user: widget.post.user,
              onTap: () {},
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.post.user.name, style: bold),
                if (widget.post.location != null) Text(widget.post.location)
              ],
            ),
            const Spacer(),
            PopupMenuButton(
              initialValue: 2,
              child: Center(child: Icon(Icons.more_vert)),
              itemBuilder: (context) {
                return List.generate(1, (index) {
                  return PopupMenuItem(
                    value: index,
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        storage
                            .deletePost(widget.post.id)
                            .then((_) =>
                                print('Delete success ${widget.post.id}'))
                            .catchError(
                                (error) => print('Delete success $error'));
                      },
                      label: const Text('Удалить',
                          style: TextStyle(color: Colors.black)),
                    ),
                  );
                });
              },
            ),
          ],
        ),
        // Photo Carosuel
        GestureDetector(
          // ignore: sort_child_properties_last
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CarouselSlider(
                  items: widget.post.imageUrls.map((url) {
                    return Image.network(
                      url,
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width,
                    );
                  }).toList(),
                  options: CarouselOptions(
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      onPageChanged: _updateImageIndex)),
              HeartOverlayAnimator(
                  triggerAnimationStream: _doubleTapImageEvents.stream),
            ],
          ),
          onDoubleTap: _onDoubleTapLikePhoto,
        ),
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HeartIconAnimator(
                isLiked: _isLiked,
                size: 28.0,
                onTap: _toggleIsLiked,
                triggerAnimationStream: _doubleTapImageEvents.stream,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: _showAddCommentModal,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon: Icon(OMIcons.nearMe),
              onPressed: () => showSnackbar(context, 'Share'),
            ),
            Spacer(),
            if (widget.post.imageUrls.length > 1)
              PhotoCarouselIndicator(
                photoCount: widget.post.imageUrls.length,
                activePhotoIndex: _currentImageIndex,
              ),
            Spacer(),
            Spacer(),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon:
                  _isSaved ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
              onPressed: _toggleIsSaved,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Liked by
              // if (widget.post.likes.isNotEmpty)
              LikesText(widget.post.id),
              // Comments
              CommentTexts(widget.post.id),
              // Add a comment...
              Row(
                children: <Widget>[
                  AvatarWidget(
                    user: currentUser,
                    padding: EdgeInsets.only(right: 8.0),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Text(
                      'Добавить комментарий...',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: _showAddCommentModal,
                  ),
                ],
              ),
              // Posted Timestamp
              Text(
                widget.post.timeAgo(),
                style: TextStyle(color: Colors.grey, fontSize: 11.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhotoCarouselIndicator extends StatelessWidget {
  final int photoCount;
  final int activePhotoIndex;

  PhotoCarouselIndicator({
    required this.photoCount,
    required this.activePhotoIndex,
  });

  Widget _buildDot({required bool isActive}) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: isActive ? 7.5 : 6.0,
          width: isActive ? 7.5 : 6.0,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(photoCount, (i) => i)
          .map((i) => _buildDot(isActive: i == activePhotoIndex))
          .toList(),
    );
  }
}

class AddCommentModal extends StatefulWidget {
  final User user;
  final ValueChanged<String> onPost;

  AddCommentModal({required this.user, required this.onPost});

  @override
  _AddCommentModalState createState() => _AddCommentModalState();
}

class _AddCommentModalState extends State<AddCommentModal> {
  final _textController = TextEditingController();
  bool _canPost = false;

  @override
  void initState() {
    _textController.addListener(() {
      setState(() => _canPost = _textController.text.isNotEmpty);
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AvatarWidget(
          user: widget.user,
          onTap: () {},
        ),
        Expanded(
          child: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          child: Opacity(
            opacity: _canPost ? 1.0 : 0.4,
            child: Text('Post', style: TextStyle(color: Colors.blue)),
          ),
          onPressed:
              _canPost ? () => widget.onPost(_textController.text) : null,
        )
      ],
    );
  }
}
