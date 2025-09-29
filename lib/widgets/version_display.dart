import 'package:flutter/material.dart';
import '../services/version_service.dart';

class VersionDisplay extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;
  
  const VersionDisplay({
    super.key,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: VersionService.getVersion(),
      builder: (context, snapshot) {
        final version = snapshot.data ?? '1.0.0';
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v$version',
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
