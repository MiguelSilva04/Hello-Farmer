import 'package:flutter/material.dart';

class BubbleSpecialThree extends StatefulWidget {
  final bool isSender;
  final String text;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final BoxConstraints? constraints;
  final ImageProvider? avatarImage;
  final String? hourSent;
  final String? senderName;
  final bool? isNickname;
  final bool? isSameUser;
  final Function(String) showAvatar;

  const BubbleSpecialThree({
    Key? key,
    this.isSender = true,
    this.constraints,
    required this.text,
    required this.showAvatar,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 16),
    this.avatarImage,
    this.hourSent,
    this.senderName,
    this.isNickname = false,
    this.isSameUser = false,
  }) : super(key: key);

  @override
  _BubbleSpecialThreeState createState() => _BubbleSpecialThreeState();
}

class _BubbleSpecialThreeState extends State<BubbleSpecialThree> {
  Widget getCircleAvatar() {
    return InkWell(
      onTap: () {
        if (widget.avatarImage is NetworkImage) {
          final networkImage = widget.avatarImage as NetworkImage;
          widget.showAvatar(networkImage.url);
        } else if (widget.avatarImage is FileImage) {
          final fileImage = widget.avatarImage as FileImage;
          widget.showAvatar(fileImage.file.path);
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: !widget.isSameUser! ? widget.avatarImage : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (widget.sent) {
      stateTick = true;
      stateIcon = const Icon(Icons.done, size: 18, color: Color(0xFF97AD8E));
    }
    if (widget.delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (widget.seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Column(
      crossAxisAlignment:
          widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!widget.isSender &&
            widget.senderName != null &&
            !widget.isSameUser!)
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 0),
            child: Text(
              widget.senderName!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontStyle:
                    (widget.isNickname!) ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isSender && widget.avatarImage != null)
              getCircleAvatar(),
            Align(
              alignment:
                  widget.isSender ? Alignment.topRight : Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: CustomPaint(
                  painter: _SpecialChatBubbleThree(
                    color: widget.color,
                    alignment:
                        widget.isSender
                            ? Alignment.topRight
                            : Alignment.topLeft,
                    tail: !widget.isSameUser!,
                  ),
                  child: Container(
                    constraints:
                        widget.constraints ??
                        BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .75,
                        ),
                    margin:
                        widget.isSender
                            ? const EdgeInsets.fromLTRB(7, 7, 17, 7)
                            : const EdgeInsets.fromLTRB(17, 7, 7, 7),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding:
                              widget.isSender
                                  ? EdgeInsets.only(
                                    right: 2,
                                    left:
                                        widget.text.trim().length <= 10
                                            ? 30
                                            : 15,
                                    bottom: 12,
                                  )
                                  : EdgeInsets.only(
                                    left: 2,
                                    right:
                                        widget.text.trim().length <= 10
                                            ? 30
                                            : (widget.text.trim().length <= 3
                                                ? 15
                                                : 0),
                                    bottom: 12,
                                  ),
                          child: Text(
                            widget.text,
                            style: widget.textStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: widget.isSender ? null : null,
                          right: widget.isSender ? 5 : 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.hourSent ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (widget.isSender)
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                              if (stateIcon != null &&
                                  stateTick &&
                                  widget.isSender)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: stateIcon,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isSender && widget.avatarImage != null)
              getCircleAvatar(),
          ],
        ),
      ],
    );
  }
}


class _SpecialChatBubbleThree extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;

  _SpecialChatBubbleThree({
    required this.color,
    required this.alignment,
    required this.tail,
  });

  final double _radius = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;
    if (alignment == Alignment.topRight) {
      if (tail) {
        var path = Path();

        /// starting point
        path.moveTo(_radius * 2, 0);

        /// top-left corner
        path.quadraticBezierTo(0, 0, 0, _radius * 1.5);

        /// left line
        path.lineTo(0, h - _radius * 1.5);

        /// bottom-left corner
        path.quadraticBezierTo(0, h, _radius * 2, h);

        /// bottom line
        path.lineTo(w - _radius * 3, h);

        /// bottom-right bubble curve
        path.quadraticBezierTo(
          w - _radius * 1.5,
          h,
          w - _radius * 1.5,
          h - _radius * 0.6,
        );

        /// bottom-right tail curve 1
        path.quadraticBezierTo(w - _radius * 1, h, w, h);

        /// bottom-right tail curve 2
        path.quadraticBezierTo(
          w - _radius * 0.8,
          h,
          w - _radius,
          h - _radius * 1.5,
        );

        /// right line
        path.lineTo(w - _radius, _radius * 1.5);

        /// top-right curve
        path.quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);

        canvas.clipPath(path);
        canvas.drawRRect(
          RRect.fromLTRBR(0, 0, w, h, Radius.zero),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      } else {
        var path = Path();

        /// starting point
        path.moveTo(_radius * 2, 0);

        /// top-left corner
        path.quadraticBezierTo(0, 0, 0, _radius * 1.5);

        /// left line
        path.lineTo(0, h - _radius * 1.5);

        /// bottom-left corner
        path.quadraticBezierTo(0, h, _radius * 2, h);

        /// bottom line
        path.lineTo(w - _radius * 3, h);

        /// bottom-right curve
        path.quadraticBezierTo(w - _radius, h, w - _radius, h - _radius * 1.5);

        /// right line
        path.lineTo(w - _radius, _radius * 1.5);

        /// top-right curve
        path.quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);

        canvas.clipPath(path);
        canvas.drawRRect(
          RRect.fromLTRBR(0, 0, w, h, Radius.zero),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      }
    } else {
      if (tail) {
        var path = Path();

        /// starting point
        path.moveTo(_radius * 3, 0);

        /// top-left corner
        path.quadraticBezierTo(_radius, 0, _radius, _radius * 1.5);

        /// left line
        path.lineTo(_radius, h - _radius * 1.5);
        // bottom-right tail curve 1
        path.quadraticBezierTo(_radius * .8, h, 0, h);

        /// bottom-right tail curve 2
        path.quadraticBezierTo(
          _radius * 1,
          h,
          _radius * 1.5,
          h - _radius * 0.6,
        );

        /// bottom-left bubble curve
        path.quadraticBezierTo(_radius * 1.5, h, _radius * 3, h);

        /// bottom line
        path.lineTo(w - _radius * 2, h);

        /// bottom-right curve
        path.quadraticBezierTo(w, h, w, h - _radius * 1.5);

        /// right line
        path.lineTo(w, _radius * 1.5);

        /// top-right curve
        path.quadraticBezierTo(w, 0, w - _radius * 2, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
          RRect.fromLTRBR(0, 0, w, h, Radius.zero),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      } else {
        var path = Path();

        /// starting point
        path.moveTo(_radius * 3, 0);

        /// top-left corner
        path.quadraticBezierTo(_radius, 0, _radius, _radius * 1.5);

        /// left line
        path.lineTo(_radius, h - _radius * 1.5);

        /// bottom-left curve
        path.quadraticBezierTo(_radius, h, _radius * 3, h);

        /// bottom line
        path.lineTo(w - _radius * 2, h);

        /// bottom-right curve
        path.quadraticBezierTo(w, h, w, h - _radius * 1.5);

        /// right line
        path.lineTo(w, _radius * 1.5);

        /// top-right curve
        path.quadraticBezierTo(w, 0, w - _radius * 2, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
          RRect.fromLTRBR(0, 0, w, h, Radius.zero),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
