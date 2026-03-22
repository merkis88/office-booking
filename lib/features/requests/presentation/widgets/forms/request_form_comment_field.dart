import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class RequestFormCommentField extends StatelessWidget {
  const RequestFormCommentField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Введите комментарий',
          filled: true,
          fillColor: AppColors.formSurface,
          contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87, width: 1),
          ),
        ),
      ),
    );
  }
}
