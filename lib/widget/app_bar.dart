// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

StyleAppBar(title) {
  return AppBar(
    centerTitle: true,
    title: Text(title),
    backgroundColor: const Color.fromARGB(255, 3, 100, 191),
    foregroundColor: Colors.white,
  );
}
