// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/material.dart';

void main() {
  ui.platformViewRegistry.registerViewFactory(
      'hello-world-html', (int viewId) => DivElement()..text = 'Hello, World');

  runApp(Directionality(
    textDirection: TextDirection.ltr,
    child: HtmlView(viewType: 'hello-world-html'),
  ));
}
