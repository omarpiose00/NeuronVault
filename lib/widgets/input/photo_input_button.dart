// lib/widgets/input/photo_input_button.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoInputButton extends StatefulWidget {
  /// Callback chiamata quando l'utente seleziona una foto
  final Function(XFile) onPhotoSelected;

  /// Indica se l'app sta elaborando una richiesta
  final bool isLoading;

  /// Sorgente dell'immagine (fotocamera o galleria)
  final ImageSource source;

  /// Dimensione del pulsante
  final double size;

  /// Colore personalizzato del pulsante
  final Color? color;

  const PhotoInputButton({
    Key? key,
    required this.onPhotoSelected,
    this.isLoading = false,
    this.source = ImageSource.gallery,
    this.size = 48,
    this.color,
  }) : super(key: key);

  @override
  State<PhotoInputButton> createState() => _PhotoInputButtonState();
}

class _PhotoInputButtonState extends State<PhotoInputButton> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (widget.isLoading) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: widget.source,
        imageQuality: 80,
      );

      if (photo != null) {
        widget.onPhotoSelected(photo);
      }
    } catch (e) {
      // Mostra un errore se necessario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante la selezione dell\'immagine: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    _controller.forward();
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading) return;
    _controller.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    if (widget.isLoading) return;
    _controller.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = widget.color ??
        (isDark ? theme.colorScheme.primaryContainer : theme.colorScheme.primary);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _pickImage,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.size,
              width: widget.size,
              decoration: BoxDecoration(
                color: _isPressed
                    ? buttonColor.withOpacity(0.7)
                    : buttonColor.withOpacity(isDark ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(widget.size / 2),
                border: Border.all(
                  color: buttonColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: _isPressed
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    buttonColor,
                  ),
                ),
              )
                  : Icon(
                widget.source == ImageSource.camera
                    ? Icons.camera_alt
                    : Icons.photo_library,
                color: buttonColor,
                size: widget.size / 2,
              ),
            ),
          );
        },
      ),
    );
  }
}