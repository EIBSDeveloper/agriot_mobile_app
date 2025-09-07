import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Get.theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? LoadingAnimationWidget.waveDots(
                color: Get.theme.primaryColor,
                size: 50,
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: backgroundColor != null ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Sign in with Google',
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
      icon: const FaIcon(FontAwesomeIcons.google, color: Colors.redAccent, size: 24),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      onPressed: onPressed,
    );
}
