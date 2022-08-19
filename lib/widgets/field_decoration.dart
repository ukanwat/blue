import 'package:flutter/material.dart';
import 'package:get/get.dart';

InputDecoration fieldDecoration(String hint, {String errorText}) {
  return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Theme.of(Get.context).cardColor,
      border: InputBorder.none,
      hintText: hint,
      errorText: errorText ?? null,
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.transparent, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.transparent, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.transparent, width: 1),
      ));
}
