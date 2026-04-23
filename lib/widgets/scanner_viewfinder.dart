import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class ScannerViewfinder extends StatelessWidget {
  const ScannerViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Coins du viseur
        const Positioned.fill(
          child: CustomPaint(
            painter: ViewfinderPainter(),
          ),
        ),
        
        // Ligne de scan laser
        Center(
          child: Container(
            width: 260,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0),
                  AppTheme.primary,
                  AppTheme.primary.withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .moveY(
            begin: -100,
            end: 100,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: 500.ms)
          .then()
          .moveY(
            begin: 100,
            end: -100,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  const ViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final length = size.width * 0.15;
    final radius = 12.0;
    
    // Zone centrale (rectangulaire avec bords arrondis)
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 220,
      height: 220,
    );

    // Dessiner les coins
    final path = Path();
    
    // Haut Gauche
    path.moveTo(rect.left, rect.top + length);
    path.lineTo(rect.left, rect.top + radius);
    path.arcToPoint(Offset(rect.left + radius, rect.top), radius: Radius.circular(radius));
    path.lineTo(rect.left + length, rect.top);

    // Haut Droite
    path.moveTo(rect.right - length, rect.top);
    path.lineTo(rect.right - radius, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + radius), radius: Radius.circular(radius));
    path.lineTo(rect.right, rect.top + length);

    // Bas Droite
    path.moveTo(rect.right, rect.bottom - length);
    path.lineTo(rect.right, rect.bottom - radius);
    path.arcToPoint(Offset(rect.right - radius, rect.bottom), radius: Radius.circular(radius));
    path.lineTo(rect.right - length, rect.bottom);

    // Bas Gauche
    path.moveTo(rect.left + length, rect.bottom);
    path.lineTo(rect.left + radius, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - radius), radius: Radius.circular(radius));
    path.lineTo(rect.left, rect.bottom - length);

    canvas.drawPath(path, paint);
    
    // Optionnel : un cadre semi-transparent autour
    final outerPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()..addRRect(innerRRect),
      ),
      outerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
