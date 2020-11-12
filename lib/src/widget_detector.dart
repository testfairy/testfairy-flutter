import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:testfairy/testfairy.dart';

/// State for the gesture detection wrapper
class TestFairyGestureDetectorState extends State<TestFairyGestureDetector> {
  final GlobalKey _ignorePointerKey = GlobalKey();

  _CancelableTask? _tapDetectionTask;
  Function? _inspectElement;

  int _lastPanDownTime = 0;
  int _detectedTapCount = 0;
  int _detectedLongPressCount = 0;

  /// Flutter calls this on touch down
  void _handlePanDown(DragDownDetails event) {
//    print("TestFairy: _handlePanDown");

    _lastPanDownTime = DateTime.now().millisecondsSinceEpoch;
    _inspectElement = _detectElement(event.globalPosition);
  }

  /// Flutter calls this on dragged touch up which we don't consider as an interaction
  void _handlePanEnd(DragEndDetails event) {
//    print("TestFairy: _handlePanEnd");

    _flush(discard: true);
  }

  /// Flutter calls this on touch up, we use it to detect consumed gestures manually without intercepting them
  void _handlePanCancel() {
//    print("TestFairy: _handlePanCancel");

    if (_tapDetectionTask != null) {
      _tapDetectionTask!.cancel();
      _tapDetectionTask = null;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPanDownTime < kLongPressTimeout.inMilliseconds) {
      _detectedTapCount++;
    } else {
      _detectedLongPressCount++;
    }

    _tapDetectionTask = _CancelableTask(kDoubleTapTimeout, _flush);
  }

  /// Flutter calls this on an unconsumed tap
  void _handleTap() {
//    print("TestFairy: _handleTap");

    _detectedLongPressCount = 0;
    _detectedTapCount = 1;

    _flush();
  }

  /// Flutter calls this on an unconsumed long press
  void _handleLongPress() {
//    print("TestFairy: _handleLongPress");

    _detectedLongPressCount = 1;
    _detectedTapCount = 0;

    _flush();
  }

  /// Flutter calls this on an unconsumed double press
  void _handleDoublePress() {
//    print("TestFairy: _handleDoublePress");

    _detectedTapCount = 2;
    _detectedLongPressCount = 0;

    _flush();
  }

  /// Flush results to TestFairy SDK
  void _flush({bool discard = false}) {
//    print("Tap count:" + _detectedTapCount.toString());
//    print("LongPress count:" + _detectedLongPressCount.toString());

    if (_tapDetectionTask != null) {
      _tapDetectionTask!.cancel();
      _tapDetectionTask = null;
    }

    final bool useless = _detectedTapCount > 2 ||
        (_detectedTapCount == 0 && _detectedLongPressCount == 0);

    if (discard || useless) {
      _inspectElement = null;
      _detectedTapCount = 0;
      _detectedLongPressCount = 0;
      _lastPanDownTime = 0;

      return;
    }

    if (_inspectElement != null) {
      // If null, hit test was unsuccessful
      _inspectElement!(); // This is the guy who sends results to TestFairy
    }

    _inspectElement = null;
    _detectedTapCount = 0;
    _detectedLongPressCount = 0;
    _lastPanDownTime = 0;
  }

  /// Check which widget user tapped and return a lambda which inspects the widget to send findings to TestFairy
  Function? _detectElement(Offset position) {
    final RenderIgnorePointer renderIgnorePointer =
        _ignorePointerKey.currentContext!.findRenderObject()
            as RenderIgnorePointer;
    RenderBox? childRenderObject = renderIgnorePointer.child;

    // Find root RenderBox
    while (childRenderObject is! RenderBox) {
      RenderBox? result;
      childRenderObject?.visitChildren((RenderObject object) {
        if (result != null) {
          return;
        }

        if (object is RenderBox) {
          result = object;
        }

        childRenderObject = object as RenderBox;
      });
    }

    return _findHitWidget(
        _hitTestPossibleElements(position, childRenderObject!));
  }

  /// For a given position and RenderBox, returns all hit widgets
  List<_RenderObjectElement> _hitTestPossibleElements(
      Offset position, RenderBox object) {
    final List<_RenderObjectElement> elements = <_RenderObjectElement>[];

    // Get hitTest candidates from RenderBox/RenderSliver hit test methods
    final BoxHitTestResult testResult = BoxHitTestResult();
    // flaw: if renderObject doesn't implement hitTest or add itself to result, then we can't obtain it. Fix later!
    object.hitTest(testResult, position: position);

    final List<HitTestEntry> hitTestEntries = testResult.path.toList();
    // Get element of renderObject in order to get widget.key and runtimeType
    for (int i = 0; i < hitTestEntries.length; i++) {
      // BoxHitTestEntry or SliverHitTestEntry
      final dynamic testEntry = hitTestEntries[i];
      // Traverse parent of current element until it is next render object's element
      final Element ele = testEntry.target.debugCreator.element as Element;

      elements.add(_RenderObjectElement(testEntry.target as RenderObject,
          ele)); // If you want to filter, inspect ele

      final dynamic nextTestEntry =
          (i + 1) < hitTestEntries.length ? hitTestEntries[i + 1] : null;
      // We need to traverse up the elements tree until we meet element of render object of nextTestEntry
      ele.visitAncestorElements((Element ancestor) {
        // Ignore debug widgets
        if (nextTestEntry == null ||
            ancestor == nextTestEntry.target.debugCreator.element) {
          return false;
        }

        elements.add(_RenderObjectElement(testEntry.target as RenderObject,
            ancestor)); // If you want to filter, inspect ancestor

        return true;
      });
    }

    return elements;
  }

  /// For a given list of hit results, finds the user facing widget
  Function? _findHitWidget(List<_RenderObjectElement> elements) {
    RenderBox? lastRenderBox;
    final List<_RenderObjectElement> elementsOfSameSize =
        <_RenderObjectElement>[];
    bool alreadyVisited = false;

    Function? elementInspector;
    for (int i = 0; i < elements.length; i++) {
      final _RenderObjectElement element = elements[i];
      if (element.renderObject is! RenderBox) {
        continue;
      }

      final RenderBox renderBox = element.renderObject as RenderBox;
      // Avoid repeated elements on same renderObject or its wrappers
      if (lastRenderBox != null && renderBox.size != lastRenderBox.size) {
        // Transform local coordinate to global
        final Matrix4 transform = lastRenderBox.getTransformTo(null);
        final Offset origin =
            MatrixUtils.transformPoint(transform, Offset.zero);
        final Rect boundsRect = origin & lastRenderBox.paintBounds.size;

        // Visit selected widget
        if (!alreadyVisited) {
          final List<_RenderObjectElement> localCreatedElements =
              <_RenderObjectElement>[];

          final Function(_RenderObjectElement) addToCreated =
              (_RenderObjectElement e) {
            if (e._isCreatedLocally()) {
              localCreatedElements.add(e);
            }
          };

          elementsOfSameSize.forEach(addToCreated);

          if (localCreatedElements.isNotEmpty) {
            alreadyVisited = true;

            try {
              // Build lambda to send to TestFairy
              elementInspector = _buildElementInspector(
                  boundsRect, localCreatedElements.first);
            } catch (e, s) {
              print(e);
              print(s);
            }
          }
        }

        //clear array of elements of same size
        elementsOfSameSize.removeRange(0, elementsOfSameSize.length);
        elementsOfSameSize.add(element);
      } else {
        elementsOfSameSize.add(element);
      }
      lastRenderBox = renderBox;
    }

    return elementInspector;
  }

  static Map<String, dynamic> getPropertiesFromElement(Element element,
      {bool assumeRoot = false}) {
    final Key? widgetKey = element.widget.key;
    String? scrollableParentWidgetKey;
    String? widgetKeyString;
    String text = '';
    Element? scrollableParent;

    if (widgetKey != null && widgetKey is ValueKey) {
      widgetKeyString = widgetKey.toString();
    }

    // Extract text by traversing children
    try {
      // Traverse through parents to find a usable widget key and scrollable parent
      if (!assumeRoot) {
        element.visitAncestorElements((Element? parent) {
          if (parent != null) {
//            print('---\n' + parent.toString() + '\n----\n');

            // Detect ancestor widget key
            if (parent.widget.key != null &&
                parent.widget.key is ValueKey &&
                widgetKeyString == null) {
              widgetKeyString = parent.widget.key.toString();
            }

            // List of possible scrollable parent widget types
            final bool parentIsScrollable = parent.widget is ScrollView ||
                parent.widget is CustomScrollView ||
                parent.widget is SingleChildScrollView ||
                parent.widget is PageView;

            // Detect ancestor scrollable widget key
            if (parentIsScrollable &&
                parent.widget.key != null &&
                parent.widget.key is ValueKey &&
                scrollableParentWidgetKey == null) {
              scrollableParent = parent;
              scrollableParentWidgetKey = parent.widget.key.toString();

//              print('---\nScrollable key: ' +
//                  (scrollableParentWidgetKey ?? 'none') +
//                  '\n----\n');

              // If we found a scrollable parent, there is no way we can find a key for the tapped widget,
              // assume it's already found and stop visiting ancestor elements
              return false;
            }
          }

          return true;
        });

//        print('Widget Key: ' + (widgetKeyString ?? 'none'));
      } else {
//        print('Widget Key2: ' + (widgetKeyString ?? 'none'));
      }

      Function(Element)? gatherText;
      final Function(Element) _gatherText = (Element element) {
        final dynamic widget =
            element.widget; // This will throw if we are not a UI widget

        try {
          // This will throw if we are not a container widget
          final dynamic _ = widget.child;
        } catch (/*x*/ _) {
          // If we reach here, it means currently interacted widget is already a leaf node
          try {
            // If the leaf node is a Text widget, we can grab the text
            final dynamic textElement = element;

            if (textElement.widget.data is String &&
                _VisibilityInfo(element).visibleFraction > 0) {
              final String content = textElement.widget.data.toString();

//              print('visibileFraction for ($content): ' +
//                  _VisibilityInfo(element).visibleFraction.toString());

              text += content + ' ';
            }
          } catch (/*e*/ _) {
//            print(e);
          }
//          print(x);
        }

        // Visit all children recursively
        element.visitChildElements((Element e) {
          gatherText?.call(e);
        });
      };
      gatherText = _gatherText;

      bool textAlreadyFound = false;
      try {
        // If current element is a Text widget, we can grab the text
        final dynamic textElement = element;
        if (textElement.widget.data is String) {
          text += textElement.widget.data.toString() + ' ';
          textAlreadyFound = true;
        }
      } catch (_) {
//        print(e);
      }

      // Recurse deeper
      if (!textAlreadyFound) {
        element.visitChildElements(gatherText);
      }
    } catch (_) {}

    return <String, dynamic>{
      'text': text.trim(),
      'widgetKey': widgetKeyString,
      'scrollableParentWidgetKey': scrollableParentWidgetKey,
      'scrollableParent': scrollableParent
    };
  }

  /// Builds a deferred lambda to inspect given element, sends results to TestFairy native SDK
  Function _buildElementInspector(
      Rect boundsRect, _RenderObjectElement element) {
//    print("_buildElementInspector");

    // Common properties
    final String widgetType = element.widgetTypeString;
    final String elementString = element.toString();
    final String widgetString = element.element.toString();

    // TODO : don't assume root if scrollableParent is needed (add killswitch)
    final Map<String, dynamic> elementProps =
        getPropertiesFromElement(element.element, assumeRoot: true);

    String? scrollableParentWidgetKey =
        elementProps['scrollableParentWidgetKey'] as String?;
    String textInScrollableParent = elementProps['scrollableParent'] != null
        ? (getPropertiesFromElement(elementProps['scrollableParent'] as Element,
            assumeRoot: true)['text'] as String)
        : '';

    String text = elementProps['text'] as String? ?? '';
    String? widgetKey = elementProps['widgetKey'] as String?;

    // Clean up spaces
    text = text.trim();
    textInScrollableParent = textInScrollableParent.trim();

    // Clean up debug markers
    widgetKey = widgetKey?.replaceAll('[<\'', '');
    widgetKey = widgetKey?.replaceAll('\'>]', '');
    scrollableParentWidgetKey =
        scrollableParentWidgetKey?.replaceAll('[<\'', '');
    scrollableParentWidgetKey =
        scrollableParentWidgetKey?.replaceAll('\'>]', '');

    final String finalWidgetType = widgetType.toString();
    final String finalAccessibilityHint = widgetString.toString();
    final String finalAccessibilityIdentifier = (widgetKey ?? '');
    final String finalAccessibilityLabel = elementString.toString();
    final String finalScrollableParentAccessibilityIdentifier =
        (scrollableParentWidgetKey ?? '');
    final String finalTextInScrollableParent = textInScrollableParent;

    // Since everything is already extracted above, calling the lambda below is
    // safe even when the widget is already destroyed ^^
    return () {
      UserInteractionKind kind =
          UserInteractionKind.USER_INTERACTION_BUTTON_PRESSED;

      if (_detectedLongPressCount > 0) {
        kind = UserInteractionKind.USER_INTERACTION_BUTTON_LONG_PRESSED;
      } else if (_detectedTapCount >= 2) {
        kind = UserInteractionKind.USER_INTERACTION_BUTTON_DOUBLE_PRESSED;
      }

      TestFairy.addUserInteraction(kind, text, <String, String>{
        'className': finalWidgetType,
        'accessibilityHint': finalAccessibilityHint,
        'accessibilityIdentifier': finalAccessibilityIdentifier,
        'accessibilityLabel': finalAccessibilityLabel,
        'scrollableParentAccessibilityIdentifier':
            finalScrollableParentAccessibilityIdentifier,
        'textInScrollableParent': finalTextInScrollableParent
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    children.add(GestureDetector(
      onTap: _handleTap,
      onPanDown: _handlePanDown,
      onPanCancel: _handlePanCancel,
      onPanEnd: _handlePanEnd,
      onLongPress: _handleLongPress,
      onDoubleTap: _handleDoublePress,
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      child: IgnorePointer(
        key: _ignorePointerKey,
        ignoring: false,
        child: widget.child, // This is the original app root
      ),
    ));

    return Stack(children: children, textDirection: TextDirection.ltr);
  }
}

/// RenderObject, Element pair
class _RenderObjectElement with WidgetInspectorService {
  RenderObject renderObject;
  Element element;

  _RenderObjectElement(this.renderObject, this.element);

  Key? get widgetKey => element.widget.key;

  String? get widgetKeyString {
    if (widgetKey is ValueKey) {
      return widgetKey.toString();
    }
    return null;
  }

  Type get widgetType => element.widget.runtimeType;

  String get widgetTypeString => widgetType.toString();

  Map<dynamic, dynamic>? _jsonInfoMap;

  /// In which file widget is constructed. Map keys: file, line, column
  Map<dynamic, dynamic> get locationInfoMap {
    if (_jsonInfoMap == null) {
      getJsonInfo();
    }

    return _jsonInfoMap!['creationLocation'] as Map<dynamic, dynamic>;
  }

  String? get localFilePosition {
    if (_isCreatedLocally()) {
      String filePath = locationInfoMap['file'] as String;
      final RegExp pathPattern = RegExp('.*(/lib/.+)');
      filePath = pathPattern.firstMatch(filePath)!.group(1)!;
      return "file: $filePath, line: ${locationInfoMap["line"]}";
    }
    return null;
  }

  Map<dynamic, dynamic>? getJsonInfo() {
    if (_jsonInfoMap != null) {
      return _jsonInfoMap;
    }

    //warning: consumes a lot of time
    WidgetInspectorService.instance.setSelection(element);
    final String jsonStr =
        WidgetInspectorService.instance.getSelectedWidget(null, '');
    return _jsonInfoMap = json.decode(jsonStr) as Map<dynamic, dynamic>;
  }

  bool _isCreatedLocally() {
    final String fileLocation = locationInfoMap['file'] as String;
    const String flutterFrameworkPath = '/packages/flutter/lib/src/';
    return !fileLocation.contains(flutterFrameworkPath);
  }

  @override
  String toString() {
    return 'renderObject: $renderObject, widgetKey: $widgetKey, widgetType: $widgetType';
  }
}

/// A task run with delay, can be canceled before delayed duration
class _CancelableTask {
  Future<void>? _future;
  bool _canceled = false;

  _CancelableTask(Duration delay, Function operation) {
    _future = Future<void>.delayed(delay, () {
      if (!_canceled) {
        operation();
      }
    });
  }

  void cancel() {
    _canceled = true;
  }

  void waitTask() async {
    if (_future != null) {
      await _future!;
    }
  }
}

/// Data passed to the [VisibilityDetector.onVisibilityChanged] callback.
class _VisibilityInfo {
  Size size;
  Rect? visibleBounds;

  /// Constructor.
  ///
  /// `key` corresponds to the [Key] used to construct the corresponding
  /// [VisibilityDetector] widget.  Must not be null.
  ///
  /// If `size` or `visibleBounds` are omitted or null, the [VisibilityInfo]
  /// will be initialized to [Offset.zero] or [Rect.zero] respectively.  This
  /// will indicate that the corresponding widget is completely hidden.
  _VisibilityInfo(Element element) : size = element.size ?? Size.zero {
    final RenderBox renderBox = element.renderObject as RenderBox;
    final Matrix4 transform = renderBox.getTransformTo(null);
    final Offset origin = MatrixUtils.transformPoint(transform, Offset.zero);

    visibleBounds = origin & renderBox.paintBounds.size;

    final Rect intersectionWithScreen = visibleBounds?.intersect(Rect.fromLTRB(
            0,
            0,
            ui.window.physicalSize.width / ui.window.devicePixelRatio,
            ui.window.physicalSize.height / ui.window.devicePixelRatio)) ??
        Rect.zero;

//    print('-------');
//    print('visibleBounds: ' + visibleBounds.toString());
//    print('renderBox.paintBounds: ' + renderBox.paintBounds.toString());
//    print('ui.window.physicalSize: ' + ui.window.physicalSize.toString());
//    print(
//        'ui.window.devicePixelRatio: ' + ui.window.devicePixelRatio.toString());
//    print('intersectionWithScreen: ' + intersectionWithScreen.toString());
//    print('-------');

    if (intersectionWithScreen.size.width *
                intersectionWithScreen.size.height ==
            0 ||
        intersectionWithScreen.right <= intersectionWithScreen.left ||
        intersectionWithScreen.bottom <= intersectionWithScreen.top) {
      visibleBounds = Rect.zero;
    }
  }

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  double get visibleFraction {
    final double visibleArea = _area(visibleBounds?.size ?? Size.zero);
    final double maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      // Avoid division-by-zero.
      return 0;
    }

    double visibleFraction = visibleArea / maxVisibleArea;

    if (_floatNear(visibleFraction, 0)) {
      visibleFraction = 0;
    } else if (_floatNear(visibleFraction, 1)) {
      // The inexact nature of floating-point arithmetic means that sometimes
      // the visible area might never equal the maximum area (or could even
      // be slightly larger than the maximum).  Snap to the maximum.
      visibleFraction = 1;
    }

    return visibleFraction;
  }

  /// The tolerance used to determine whether two floating-point values are
  /// approximately equal.
  static const double _kDefaultTolerance = 0.01;

  /// Computes the area of a rectangle of the specified dimensions.
  static double _area(Size size) {
    return size.width * size.height;
  }

  /// Returns whether two floating-point values are approximately equal.
  static bool _floatNear(double f1, double f2) {
    final double absDiff = (f1 - f2).abs();
    return absDiff <= _kDefaultTolerance ||
        (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
  }
}
