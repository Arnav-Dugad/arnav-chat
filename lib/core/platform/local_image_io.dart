import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider localImage(String path) => FileImage(File(path));
