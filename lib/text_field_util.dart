import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldUtil {
  static TextField numberInputFormat(TextField textField) {
    return TextField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
      ],
      keyboardType: TextInputType.number,
      onChanged: textField.onChanged,
    );
  }
}
