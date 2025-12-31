import 'package:flutter/material.dart';

/// Camera overlay with receipt guide frame
class CameraOverlay extends StatelessWidget {
  final double frameWidth;
  final double frameHeight;
  final double cornerRadius;
  final double cornerLength;
  final double cornerWidth;
  final Color frameColor;
  final Color overlayColor;

  const CameraOverlay({
    super.key,
    this.frameWidth = 0.85,
    this.frameHeight = 0.6,
    this.cornerRadius = 12,
    this.cornerLength = 30,
    this.cornerWidth = 4,
    this.frameColor = Colors.white,
    this.overlayColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * frameWidth;
        final height = constraints.maxHeight * frameHeight;
        final left = (constraints.maxWidth - width) / 2;
        final top = (constraints.maxHeight - height) / 2 - 40;

        return Stack(
          children: [
            // Top overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top,
              child: Container(color: overlayColor),
            ),

            // Bottom overlay
            Positioned(
              top: top + height,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: overlayColor),
            ),

            // Left overlay
            Positioned(
              top: top,
              left: 0,
              width: left,
              height: height,
              child: Container(color: overlayColor),
            ),

            // Right overlay
            Positioned(
              top: top,
              right: 0,
              width: left,
              height: height,
              child: Container(color: overlayColor),
            ),

            // Corner frames
            _buildCorners(left, top, width, height),

            // Guide text
            Positioned(
              top: top + height + 20,
              left: 0,
              right: 0,
              child: const Text(
                'Align receipt within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorners(double left, double top, double width, double height) {
    return Stack(
      children: [
        // Top-left corner
        Positioned(
          left: left,
          top: top,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            cornerRadius: cornerRadius,
            color: frameColor,
            position: _CornerPosition.topLeft,
          ),
        ),

        // Top-right corner
        Positioned(
          right: left,
          top: top,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            cornerRadius: cornerRadius,
            color: frameColor,
            position: _CornerPosition.topRight,
          ),
        ),

        // Bottom-left corner
        Positioned(
          left: left,
          top: top + height - cornerLength,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            cornerRadius: cornerRadius,
            color: frameColor,
            position: _CornerPosition.bottomLeft,
          ),
        ),

        // Bottom-right corner
        Positioned(
          right: left,
          top: top + height - cornerLength,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            cornerRadius: cornerRadius,
            color: frameColor,
            position: _CornerPosition.bottomRight,
          ),
        ),
      ],
    );
  }
}

enum _CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final double cornerLength;
  final double cornerWidth;
  final double cornerRadius;
  final Color color;
  final _CornerPosition position;

  const _Corner({
    required this.cornerLength,
    required this.cornerWidth,
    required this.cornerRadius,
    required this.color,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(cornerLength, cornerLength),
      painter: _CornerPainter(
        color: color,
        strokeWidth: cornerWidth,
        cornerRadius: cornerRadius,
        position: position,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerRadius;
  final _CornerPosition position;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (position) {
      case _CornerPosition.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, cornerRadius);
        path.quadraticBezierTo(0, 0, cornerRadius, 0);
        path.lineTo(size.width, 0);
        break;
      case _CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width - cornerRadius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
        path.lineTo(size.width, size.height);
        break;
      case _CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height - cornerRadius);
        path.quadraticBezierTo(0, size.height, cornerRadius, size.height);
        path.lineTo(size.width, size.height);
        break;
      case _CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height - cornerRadius);
        path.quadraticBezierTo(
            size.width, size.height, size.width - cornerRadius, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
