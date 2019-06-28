// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of engine;

/// The web implementation of [ui.Paragraph].
class EngineParagraph extends ui.Paragraph {
  /// This class is created by the engine, and should not be instantiated
  /// or extended directly.
  ///
  /// To create a [ui.Paragraph] object, use a [ui.ParagraphBuilder].
  EngineParagraph({
    @required html.HtmlElement paragraphElement,
    @required ParagraphGeometricStyle geometricStyle,
    @required String plainText,
    @required ui.Paint paint,
    @required ui.TextAlign textAlign,
    @required ui.TextDirection textDirection,
    @required ui.Paint background,
  })  : assert((plainText == null && paint == null) ||
            (plainText != null && paint != null)),
        _paragraphElement = paragraphElement,
        _geometricStyle = geometricStyle,
        _plainText = plainText,
        _textAlign = textAlign,
        _textDirection = textDirection,
        _paint = paint,
        _background = background;

  final html.HtmlElement _paragraphElement;
  final ParagraphGeometricStyle _geometricStyle;
  final String _plainText;
  final ui.Paint _paint;
  final ui.TextAlign _textAlign;
  final ui.TextDirection _textDirection;
  final ui.Paint _background;

  @visibleForTesting
  String get plainText => _plainText;

  @visibleForTesting
  html.HtmlElement get paragraphElement => _paragraphElement;

  @visibleForTesting
  ParagraphGeometricStyle get geometricStyle => _geometricStyle;

  /// The instance of [TextMeasurementService] to be used to measure this
  /// paragraph.
  TextMeasurementService get _measurementService =>
      TextMeasurementService.forParagraph(this);

  /// The measurement result of the last layout operation.
  MeasurementResult _measurementResult;

  @override
  double get width => _measurementResult?.width ?? -1;

  @override
  double get height => _measurementResult?.height ?? 0;

  /// {@template dart.ui.paragraph.naturalHeight}
  /// The amount of vertical space the paragraph occupies while ignoring the
  /// [ParagraphGeometricStyle.maxLines] constraint.
  /// {@endtemplate}
  ///
  /// Valid only after [layout] has been called.
  double get _naturalHeight => _measurementResult?.naturalHeight ?? 0;

  /// The amount of vertical space one line of this paragraph occupies.
  ///
  /// Valid only after [layout] has been called.
  double get _lineHeight => _measurementResult?.lineHeight ?? 0;

  // TODO(flutter_web): see https://github.com/flutter/flutter/issues/33613.
  @override
  double get longestLine => 0;

  @override
  double get minIntrinsicWidth => _measurementResult?.minIntrinsicWidth ?? 0;

  @override
  double get maxIntrinsicWidth => _measurementResult?.maxIntrinsicWidth ?? 0;

  @override
  double get alphabeticBaseline => _measurementResult?.alphabeticBaseline ?? -1;

  @override
  double get ideographicBaseline =>
      _measurementResult?.ideographicBaseline ?? -1;

  @override
  bool get didExceedMaxLines => _didExceedMaxLines;
  bool _didExceedMaxLines = false;

  ui.ParagraphConstraints _lastUsedConstraints;

  /// Returns horizontal alignment offset for single line text when rendering
  /// directly into a canvas without css text alignment styling.
  double _alignOffset = 0.0;

  /// If not null, this list would contain the strings representing each line
  /// in the paragraph.
  List<String> get _lines => _measurementResult?.lines;

  @override
  void layout(ui.ParagraphConstraints constraints) {
    if (constraints == _lastUsedConstraints) {
      return;
    }

    _measurementResult = _measurementService.measure(this, constraints);
    _lastUsedConstraints = constraints;

    if (_geometricStyle.maxLines != null) {
      _didExceedMaxLines = _naturalHeight > height;
    } else {
      _didExceedMaxLines = false;
    }

    if (_measurementResult.isSingleLine && constraints != null) {
      switch (_textAlign) {
        case ui.TextAlign.center:
          _alignOffset = (constraints.width - maxIntrinsicWidth) / 2.0;
          break;
        case ui.TextAlign.right:
          _alignOffset = constraints.width - maxIntrinsicWidth;
          break;
        case ui.TextAlign.start:
          _alignOffset = _textDirection == ui.TextDirection.rtl
              ? constraints.width - maxIntrinsicWidth
              : 0.0;
          break;
        case ui.TextAlign.end:
          _alignOffset = _textDirection == ui.TextDirection.ltr
              ? constraints.width - maxIntrinsicWidth
              : 0.0;
          break;
        default:
          _alignOffset = 0.0;
          break;
      }
    }
  }

  /// Returns `true` if this paragraph can be directly painted to the canvas.
  ///
  ///
  /// Examples of paragraphs that can't be drawn directly on the canvas:
  ///
  /// - Rich text where there are multiple pieces of text that have different
  ///   styles.
  /// - Paragraphs that contain decorations.
  /// - Paragraphs that have a non-null word-spacing.
  /// - Paragraphs with a background.
  bool get _drawOnCanvas {
    bool canDrawTextOnCanvas;
    if (TextMeasurementService.enableExperimentalCanvasImplementation) {
      canDrawTextOnCanvas = _lines != null;
    } else {
      canDrawTextOnCanvas = _measurementResult.isSingleLine &&
          _plainText != null &&
          _geometricStyle.ellipsis == null;
    }

    return canDrawTextOnCanvas &&
        _geometricStyle.decoration == null &&
        _geometricStyle.wordSpacing == null;
  }

  /// Whether this paragraph has been laid out.
  bool get _isLaidOut => _measurementResult != null;

  /// Asserts that the properties used to measure paragraph layout are the same
  /// as the properties of this paragraphs root style.
  ///
  /// Ignores properties that do not affect layout, such as
  /// [ParagraphStyle.textAlign].
  bool _debugHasSameRootStyle(ParagraphGeometricStyle style) {
    assert(() {
      if (style != _geometricStyle) {
        throw Exception('Attempted to measure a paragraph whose style is '
            'different from the style of the ruler used to measure it.');
      }
      return true;
    }());
    return true;
  }

  @override
  List<ui.TextBox> getBoxesForRange(
    int start,
    int end, {
    ui.BoxHeightStyle boxHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle boxWidthStyle = ui.BoxWidthStyle.tight,
  }) {
    assert(boxHeightStyle != null);
    assert(boxWidthStyle != null);
    if (_plainText == null) {
      return <ui.TextBox>[];
    }

    final int length = _plainText.length;
    // Ranges that are out of bounds should return an empty list.
    if (start < 0 || end < 0 || start > length || end > length) {
      return <ui.TextBox>[];
    }

    return _measurementService.measureBoxesForRange(
      this,
      _lastUsedConstraints,
      start: start,
      end: end,
      alignOffset: _alignOffset,
      textDirection: _textDirection,
    );
  }

  ui.Paragraph _cloneWithText(String plainText) {
    return EngineParagraph(
      plainText: plainText,
      paragraphElement: _paragraphElement.clone(true),
      geometricStyle: _geometricStyle,
      paint: _paint,
      textAlign: _textAlign,
      textDirection: _textDirection,
      background: _background,
    );
  }

  @override
  ui.TextPosition getPositionForOffset(ui.Offset offset) {
    if (_plainText == null) {
      return const ui.TextPosition(offset: 0);
    }

    final double dx = offset.dx - _alignOffset;
    final TextMeasurementService instance = _measurementService;

    int low = 0;
    int high = _plainText.length;
    do {
      final int current = (low + high) ~/ 2;
      final double width = instance.measureSubstringWidth(this, 0, current);
      if (width < dx) {
        low = current;
      } else if (width > dx) {
        high = current;
      } else {
        low = high = current;
      }
    } while (high - low > 1);

    if (low == high) {
      // The offset falls exactly in between the two letters.
      return ui.TextPosition(offset: high, affinity: ui.TextAffinity.upstream);
    }

    final double lowWidth = instance.measureSubstringWidth(this, 0, low);
    final double highWidth = instance.measureSubstringWidth(this, 0, high);

    if (dx - lowWidth < highWidth - dx) {
      // The offset is closer to the low index.
      return ui.TextPosition(offset: low, affinity: ui.TextAffinity.downstream);
    } else {
      // The offset is closer to high index.
      return ui.TextPosition(offset: high, affinity: ui.TextAffinity.upstream);
    }
  }

  @override
  List<int> getWordBoundary(int offset) {
    if (_plainText == null) {
      return <int>[offset, offset];
    }

    final int start = WordBreaker.prevBreakIndex(_plainText, offset);
    final int end = WordBreaker.nextBreakIndex(_plainText, offset);
    return <int>[start, end];
  }
}

/// Converts [fontWeight] to its CSS equivalent value.
String fontWeightToCss(ui.FontWeight fontWeight) {
  if (fontWeight == null) {
    return null;
  }

  switch (fontWeight.index) {
    case 0:
      return '100';
    case 1:
      return '200';
    case 2:
      return '300';
    case 3:
      return 'normal';
    case 4:
      return '500';
    case 5:
      return '600';
    case 6:
      return 'bold';
    case 7:
      return '800';
    case 8:
      return '900';
  }

  assert(() {
    throw AssertionError(
      'Failed to convert font weight $fontWeight to CSS.',
    );
  }());

  return '';
}
