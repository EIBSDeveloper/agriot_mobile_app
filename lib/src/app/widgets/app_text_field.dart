import 'package:flutter/material.dart';

import '../../core/app_style.dart';

class AppTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final FocusNode? focusNode;
  const AppTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      // margin: EdgeInsets.symmetric(vertical: 8,),
      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow:  AppStyle.boxShadow,
        border: Border.all(color: Colors.grey.shade400  )
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon:
              prefixIcon != null
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: prefixIcon,
                  )
                  : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
