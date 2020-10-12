import 'dart:async';
import 'dart:convert';

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

    final List hitTestEntries = testResult.path.toList();
    // Get element of renderObject in order to get widget.key and runtimeType
    for (int i = 0; i < hitTestEntries.length; i++) {
      // BoxHitTestEntry or SliverHitTestEntry
      final dynamic testEntry = hitTestEntries[i];
      // Traverse parent of current element until it is next render object's element
      Element ele = testEntry.target.debugCreator.element as Element;

      elements.add(_RenderObjectElement(testEntry.target as RenderObject,
          ele)); // If you want to filter, inspect ele

      final dynamic nextTestEntry =
          (i + 1) < hitTestEntries.length ? hitTestEntries[i + 1] : null;
      // We need to traverse up the elements tree until we meet element of render object of nextTestEntry
      ele.visitAncestorElements((Element ancestor) {
        if (nextTestEntry == null ||
            ancestor ==
                nextTestEntry
                    .target.debugCreator.element) // Ignore debug widgets
          return false;

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
    final List<_RenderObjectElement> elementsOfSameSize = [];
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
        final Offset origin = MatrixUtils.transformPoint(transform, Offset.zero);
        final Rect boundsRect = origin & lastRenderBox.paintBounds.size;

        // Visit selected widget
        if (!alreadyVisited) {
          final List<_RenderObjectElement> localCreatedElements = [];
          elementsOfSameSize.forEach((_RenderObjectElement e) {
            if (e._isCreatedLocally()) {
              localCreatedElements.add(e);
            }
          });
          if (localCreatedElements.isNotEmpty) {
            alreadyVisited = true;

            // Build lambda to send to TestFairy
            elementInspector =
                _buildElementInspector(boundsRect, localCreatedElements.first);
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

  /// Builds a deferred lambda to inspect given element, sends results to TestFairy native SDK
  Function _buildElementInspector(
      Rect boundsRect, _RenderObjectElement element) {
//    print("_buildElementInspector");

    // Common properties
    String? widgetKey = element.widgetKeyString;
    String? scrollableParentWidgetKey;
    final String widgetType = element.widgetTypeString;
    final String elementString = element.toString();
    final String widgetString = element.element.toString();

    // Extract text by traversing children
    String text = '';
    try {
      // Traverse through parents to find a usable widget key and scrollable parent
      if (widgetKey == null) {
        element.element.visitAncestorElements((Element? parent) {
          if (parent != null) {
//            print('---\n' + parent.toString() + '\n----\n');

            // Detect ancestor widget key
            if (parent.widget.key != null && parent.widget.key is ValueKey && widgetKey == null) {
              widgetKey = parent.widget.key.toString();
            }

            // List of possible scrollable parent widget types
            final bool parentIsScrollable =
                parent.widget is ScrollView ||
                parent.widget is CustomScrollView ||
                parent.widget is SingleChildScrollView ||
                parent.widget is PageView;

            // Detect ancestor scrollable widget key
            if (parentIsScrollable && parent.widget.key != null && parent.widget.key is ValueKey && scrollableParentWidgetKey == null) {
              scrollableParentWidgetKey = parent.widget.key.toString();
//              print('---\nScrollable key: ' + (scrollableParentWidgetKey ?? 'none') + '\n----\n');

              // If we found a scrollable parent, there is no way we can find a key for the tapped widget,
              // assume it's already found and stop visiting ancestor elements
              return false;
            }
          }

          return true;
        });

//        print("Widget Key: "  + (widgetKey ?? "none"));
      } else {
//        print("Widget Key: "  + widgetKey);
      }

      // Detect widget from element (an Element is an instance of a Widget)
      final dynamic widget =
          element.element.widget; // This will throw if we are not a UI widget

      dynamic child = widget.child; // This will throw if we are not a container widget

      // Traverse through children to build a Text representation of the hit widget
      while (child != null) {
        try {
          if (child.data is String) {
            // If our children has data, we append it to the built text
            text += child.data.toString() + ' ';
          }
        } catch (_) {}

        try {
          child =
              child.child; // Go deeper, throws if we are no longer a container
        } catch (_) {
          child = null; // Stop searching, we are at the leaf node
        }
      }
    } catch (_) {
      // If we reach here, it means the interacted widget is already a leaf node
      try {
        // If the leaf node is a Text widget, we can grab the text
        final dynamic textElement = element.element;
        text = textElement.widget.data.toString();
      } catch (_) {}
    }

    // Clean up spaces
    text = text.trim();
    
    // Clean up debug markers
    widgetKey = widgetKey?.replaceAll('[<\'', '');
    widgetKey = widgetKey?.replaceAll('\'>]', '');

    // Since everything is already extracted above, calling the lambda below is
    // safe even when the widget is already destroyed ^^
    return () {
      UserInteractionKind kind = UserInteractionKind.USER_INTERACTION_BUTTON_PRESSED;

      if (_detectedLongPressCount > 0) {
        kind = UserInteractionKind.USER_INTERACTION_BUTTON_LONG_PRESSED;
      } else if (_detectedTapCount >= 2) {
        kind = UserInteractionKind.USER_INTERACTION_BUTTON_DOUBLE_PRESSED;
      }

      TestFairy.addUserInteraction(
          kind,
          text,
          {
            'className': widgetType.toString(),
            'accessibilityHint': widgetString.toString(),
            'accessibilityIdentifier': (widgetKey ?? ""),
            'accessibilityLabel': elementString.toString(),
            'scrollableParentAccessibilityIdentifier': (scrollableParentWidgetKey ?? "")
          } as Map);
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

  Map? _jsonInfoMap;

  /// In which file widget is constructed. Map keys: file, line, column
  Map get locationInfoMap {
    if (_jsonInfoMap == null) {
      getJsonInfo();
    }

    return _jsonInfoMap!['creationLocation'] as Map;
  }

  String? get localFilePosition {
    if (_isCreatedLocally()) {
      String filePath = locationInfoMap['file'] as String;
      var pathPattern = RegExp('.*(/lib/.+)');
      filePath = pathPattern.firstMatch(filePath)!.group(1)!;
      return "file: $filePath, line: ${locationInfoMap["line"]}";
    }
    return null;
  }

  Map? getJsonInfo() {
    if (_jsonInfoMap != null) {
      return _jsonInfoMap;
    }

    //warning: consumes a lot of time
    WidgetInspectorService.instance.setSelection(element);
    final String jsonStr =
        WidgetInspectorService.instance.getSelectedWidget(null, '');
    return _jsonInfoMap = json.decode(jsonStr) as Map?;
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
