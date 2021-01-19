import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle myStyle(double size,
    [FontWeight weight, Color color, double spacing]) {
  return GoogleFonts.ubuntu(
      fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);
}

class PaddedTextField extends StatelessWidget {
  final String hintText;
  final Function validatorFun;
  final Function onSaveFun;
  final bool hidePassword;

  PaddedTextField(
      {this.hintText, this.validatorFun, this.onSaveFun, this.hidePassword});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        obscureText: hidePassword,
        validator: validatorFun,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: GoogleFonts.ubuntu(),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onSaved: onSaveFun,
      ),
    );
  }
}
