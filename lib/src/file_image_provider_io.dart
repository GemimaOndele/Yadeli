import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider? fileImageProvider(String path) => FileImage(File(path));
