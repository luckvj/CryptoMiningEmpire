import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Premium toast notification system
class CryptoToast {
  static OverlayEntry? _currentToast;
  static bool _isShowing = false;
  
  /// Show a success toast
  static void success(BuildContext context, String message, {IconData? icon}) {
    _show(
      context,
      message,
      icon ?? Icons.check_circle_rounded,
      CyberpunkTheme.accentGreen,
    );
  }
  
  /// Show an error toast
  static void error(BuildContext context, String message, {IconData? icon}) {
    _show(
      context,
      message,
      icon ?? Icons.error_rounded,
      CyberpunkTheme.accentRed,
    );
  }
  
  /// Show a warning toast
  static void warning(BuildContext context, String message, {IconData? icon}) {
    _show(
      context,
      message,
      icon ?? Icons.warning_rounded,
      CyberpunkTheme.accentOrange,
    );
  }
  
  /// Show an info toast
  static void info(BuildContext context, String message, {IconData? icon}) {
    _show(
      context,
      message,
      icon ?? Icons.info_rounded,
      CyberpunkTheme.primaryBlue,
    );
  }
  
  /// Show purchase success toast
  static void purchase(BuildContext context, String itemName, double cost) {
    _show(
      context,
      'Purchased $itemName for \$${cost.toStringAsFixed(0)}',
      Icons.shopping_cart_checkout_rounded,
      CyberpunkTheme.accentGreen,
    );
  }
  
  static void show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color color,
  }) {
    _show(context, message, icon, color);
  }
  
  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color accentColor,
  ) {
    // Remove existing toast immediately
    if (_isShowing && _currentToast != null) {
      _currentToast!.remove();
      _currentToast = null;
    }
    
    _isShowing = true;
    
    final overlay = Overlay.of(context);
    
    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        accentColor: accentColor,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
          _isShowing = false;
        },
      ),
    );
    
    overlay.insert(_currentToast!);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onDismiss;
  
  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.onDismiss,
  });
  
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  bool _visible = true;
  
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _visible = false);
        Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _visible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: _visible ? Offset.zero : const Offset(0, -0.5),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.surfaceColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 20,
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: CyberpunkTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.3, end: 0, duration: 250.ms, curve: Curves.easeOutCubic),
            ),
          ),
        ),
      ),
    );
  }
}
