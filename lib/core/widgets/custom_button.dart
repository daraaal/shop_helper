
import 'package:flutter/material.dart';
import '../app_colors.dart';

enum ButtonType { primary, ghost, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: icon != null
          ? _buildButtonWithIcon()
          : _buildButtonWithoutIcon(),
    );
  }

  Widget _buildButtonWithoutIcon() {
    switch (type) {
      case ButtonType.ghost:
        return OutlinedButton(
          onPressed: onPressed,
          style: _getStyle(),
          child: Text(text),
        );
      case ButtonType.danger:
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: _getStyle(),
          child: Text(text),
        );
    }
  }

  Widget _buildButtonWithIcon() {
    switch (type) {
      case ButtonType.ghost:
        return OutlinedButton.icon(
          onPressed: onPressed,
          style: _getStyle(),
          icon: Icon(icon, size: 20),
          label: Text(text),
        );
      case ButtonType.danger:
      case ButtonType.primary:
        return ElevatedButton.icon(
          onPressed: onPressed,
          style: _getStyle(),
          icon: Icon(icon, size: 20),
          label: Text(text),
        );
    }
  }

  ButtonStyle _getStyle() {
    Color backgroundColor = AppColors.primaryGreen;
    Color foregroundColor = AppColors.textDark;
    BorderSide side = BorderSide.none;

    if (type == ButtonType.ghost) {
      backgroundColor = Colors.transparent;
      foregroundColor = AppColors.textLight;
      side = const BorderSide(color: AppColors.borderGrey);
    } else if (type == ButtonType.danger) {
      backgroundColor = AppColors.dangerRed;
      foregroundColor = Colors.white;
    }

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(backgroundColor),
      foregroundColor: MaterialStateProperty.all(foregroundColor),
      side: MaterialStateProperty.all(side),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
          return type == ButtonType.ghost ? 0 : 2;
        },
      ),
    );
  }
}