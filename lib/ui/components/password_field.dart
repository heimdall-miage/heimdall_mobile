import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _defaultStrengthConfig = PasswordStrength();

class PasswordField extends StatefulWidget {
  final Key key;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final ValueChanged<String> onFieldSubmitted;
  final FocusNode focusNode;
  final String labelText;
  final String helperText;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final bool strengthChecker;
  final PasswordStrength passwordStrength;

  PasswordField({
    this.key,
    this.controller,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    this.focusNode,
    this.labelText = "Mot de passe",
    this.helperText,
    this.textInputAction,
    this.strengthChecker = false,
    this.passwordStrength = _defaultStrengthConfig,
  });

  @override
  State createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  bool _focused = false;
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    if (_focusNode != null) {
      _focusNode.addListener(() {
        setState(() {
          _focused = _focusNode != null ? _focusNode.hasFocus : false;
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
          key: widget.key,
          controller: widget.controller,
          obscureText: _obscure,
          autovalidate: widget.strengthChecker,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(right: 10, top: 12, bottom: 12),
              labelText: widget.labelText,
              helperText: widget.helperText,
              errorMaxLines: 6,
              suffix: InkWell(
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  _obscure ? FontAwesomeIcons.solidEye : FontAwesomeIcons.solidEyeSlash,
                  size: 18,
                  color: _focused ? Theme.of(context).primaryColor : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
              icon: const Icon(Icons.lock)
          ),
          autocorrect: false,
          textInputAction: widget.textInputAction,
          validator: (value) {
            String validation = widget.validator == null ? null : widget.validator(value);
            if (!widget.strengthChecker || validation != null) {
              return validation;
            } else {
              return widget.passwordStrength.checkPassword(value);
            }
          },
          onSaved: widget.onSaved,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: _focusNode,
        );
  }
}

class PasswordStrength {
  static const String defaultRegex = r'(?=REG).+';
  final int uppercase;
  final int lowercase;
  final int special;
  final int digit;
  final int length;

  const PasswordStrength({
    this.uppercase = 1,
    this.lowercase = 3,
    this.special = 0,
    this.digit = 1,
    this.length = 6,
  });

  RegExp getRegExp(String reg, int expected) {
    return RegExp(defaultRegex.replaceFirst('REG', List.filled(expected, '.*$reg').join()));
  }

  RegExp get uppercaseReg => getRegExp('[A-Z]', uppercase);
  RegExp get lowercaseReg => getRegExp('[a-z]', lowercase);
  RegExp get specialReg => getRegExp('[!@#\$&*]', special);
  RegExp get digitReg => getRegExp('[0-9]', digit);

  String checkPassword(String password) {
    StringBuffer validation = StringBuffer();
    if (length > 0 && password.length < length) {
      validation.writeln('- $length caractères minimum');
    }
    if (uppercase > 0 && !uppercaseReg.hasMatch(password)) {
      validation.writeln('- $uppercase majuscules');
    }
    if (lowercase > 0 && !lowercaseReg.hasMatch(password)) {
      validation.writeln('- $lowercase minuscules');
    }
    if (special > 0 && !specialReg.hasMatch(password)) {
      validation.writeln('- $special caractères spéciaux');
    }
    if (digit > 0 && !digitReg.hasMatch(password)) {
      validation.writeln('- $digit chiffres');
    }

    return validation.isEmpty ? null : '''Critères non remplis :
${validation.toString()}''';
  }
}