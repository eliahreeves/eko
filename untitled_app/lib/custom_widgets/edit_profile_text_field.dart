import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProfileInputFeild extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validatorFunction;
  final AutovalidateMode validator;
  final TextInputType inputType;
  final FocusNode? focus;
  final String filter;
  final double? width;
  final bool enabled;
  final bool password;
  final TextInputAction textInputAction;
  final int? maxLength;

  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  const ProfileInputFeild(
      {required this.label,
      required this.controller,
      this.onChanged,
      this.onTap,
      this.onTapOutside,
      this.onEditingComplete,
      this.focus,
      this.width,
      this.inputType = TextInputType.text,
      this.filter = r'[\s\S]*',
      this.validator = AutovalidateMode.disabled,
      this.validatorFunction,
      this.enabled = true,
      this.password = false,
      this.textInputAction = TextInputAction.next,
      this.maxLength,
      super.key});

  @override
  Widget build(BuildContext context) {
    double feildWidth;
    if (width == null) {
      feildWidth = MediaQuery.of(context).size.width * 0.9;
    } else {
      feildWidth = width!;
    }
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      width: feildWidth,
      child: TextFormField(
        enabled: enabled,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(filter)),
        ],
        // TODO: somehow make it so that IOS users can press '123' on your keyboard and you can put in newline
        textInputAction: TextInputAction.done,
        autovalidateMode: validator,
        validator: validatorFunction,
        controller: controller,
        focusNode: focus,
        onChanged: onChanged,
        onTap: onTap,
        onTapOutside: onTapOutside,
        onEditingComplete: onEditingComplete,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 3,
        maxLength: maxLength,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.tertiary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 18,
            letterSpacing: 1,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.primary,
          ),
          fillColor: Theme.of(context).colorScheme.onBackground,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
    );
  }
}
