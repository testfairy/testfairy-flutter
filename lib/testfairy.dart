import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

//import 'package:http/http.dart' as http;

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//import 'package:simple_permissions/simple_permissions.dart';

class FeedbackOptions {
  String email;
  String text;
  double timestamp;
  int i = 0;
}

class TestFairy {
  // Private internals

  static const MethodChannel _channel =
      const MethodChannel('testfairy');
  static bool isMethodCallHandlerSet = false;
  static List<GlobalKey> _hiddenWidgets = [];

  static Future<dynamic> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callOnFeedbackSent':
        callOnFeedbackSent(call.arguments);
        break;
      case 'callOnFeedbackCancelled':
        callOnFeedbackCancelled(call.arguments);
        break;
      case 'callOnFeedbackFailed':
        callOnFeedbackFailed(call.arguments);
        break;
      case 'getHiddenRects':
        return getHiddenRects();
      case 'lock':
        return lock();
      case 'unlock':
        return unlock();
      case 'takeScreenshot':
        takeScreenshot();
        break;
      default:
        print('TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  static void prepareTwoWayInvoke() {
    if (!isMethodCallHandlerSet) {
      _channel.setMethodCallHandler(methodCallHandler);
      isMethodCallHandlerSet = true;
    }
  }

  static void lock() {
    GestureBinding.instance.lockEvents((){ return Future.value(null); });
    RendererBinding.instance.lockEvents((){ return Future.value(null); });
    PaintingBinding.instance.lockEvents((){ return Future.value(null); });
    SchedulerBinding.instance.lockEvents((){ return Future.value(null); });
    ServicesBinding.instance.lockEvents((){ return Future.value(null); });
    WidgetsBinding.instance.lockEvents((){ return Future.value(null); });
  }

  static void unlock() {
    GestureBinding.instance.unlocked();
    RendererBinding.instance.unlocked();
    PaintingBinding.instance.unlocked();
    SchedulerBinding.instance.unlocked();
    ServicesBinding.instance.unlocked();
    WidgetsBinding.instance.unlocked();
  }

  static List<Map<String, int>> getHiddenRects() {
    List<Map<String, int>> rects = [];

    _hiddenWidgets.forEach((gk) {
      RenderBox ro = gk.currentContext.findRenderObject();

      var pos = ro.localToGlobal(Offset.zero);
      pos = Offset(pos.dx * ui.window.devicePixelRatio, pos.dy * ui.window.devicePixelRatio);
//      print('Position is: ');
//      print(pos.toString());

      var size = gk.currentContext.size;
      size = Size(size.width * ui.window.devicePixelRatio, size.height * ui.window.devicePixelRatio);
//      print('Size is: ');
//      print(size.toString());

      rects.add({
        'x': pos.dx.toInt(),
        'y': pos.dy.toInt(),
        'w': size.width.toInt(),
        'h': size.height.toInt()
      });
    });

    return rects;
  }

  // Public Interface

  static Future<void> begin(String appToken) async {
    prepareTwoWayInvoke();

    await _channel.invokeMethod('begin', appToken);
  }

  static Future<void> beginWithOptions(String appToken, Map options) async {
    prepareTwoWayInvoke();

    var args = {'appToken': appToken, 'options': options};

    await _channel.invokeMethod('beginWithOptions', args);
  }

  static Future<void> setServerEndpoint(String endpoint) async {
    await _channel.invokeMethod('setServerEndpoint', endpoint);
  }

  static Future<String> getVersion() async {
    return await _channel.invokeMethod('getVersion');
  }

  static Future<void> sendUserFeedback(String feedback) async {
    await _channel.invokeMethod('sendUserFeedback', feedback);
  }

  static Future<void> addCheckpoint(String name) async {
    await _channel.invokeMethod('addCheckpoint', name);
  }

  static Future<void> addEvent(String name) async {
    await _channel.invokeMethod('addEvent', name);
  }

  static Future<void> setCorrelationId(String id) async {
    await _channel.invokeMethod('setCorrelationId', id);
  }

  static Future<void> identifyWithTraits(String id, Map traits) async {
    var args = {'id': id, 'traits': traits};

    await _channel.invokeMethod('identifyWithTraits', args);
  }

  static Future<void> identify(String id) async {
    await _channel.invokeMethod('identify', id);
  }

  static Future<void> setUserId(String id) async {
    await _channel.invokeMethod('setUserId', id);
  }

  static Future<void> setAttribute(String key, String value) async {
    var args = {'key': key, 'value': value};

    await _channel.invokeMethod('setAttribute', args);
  }

  static Future<String> getSessionUrl() async {
    return await _channel.invokeMethod('getSessionUrl');
  }

  static Future<void> showFeedbackForm() async {
    await _channel.invokeMethod('showFeedbackForm');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  static Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  static Future<void> logError(dynamic error) async {
    await _channel.invokeMethod('logError', error.toString());
  }

  static Future<void> log(String message) async {
    await _channel.invokeMethod('log', message);
  }

  static Future<void> setScreenName(String name) async {
    await _channel.invokeMethod('setScreenName', name);
  }

  static Future<bool> didLastSessionCrash() async {
    return await _channel.invokeMethod('didLastSessionCrash');
  }

  static Future<void> enableCrashHandler() async {
    await _channel.invokeMethod('enableCrashHandler');
  }

  static Future<void> disableCrashHandler() async {
    await _channel.invokeMethod('disableCrashHandler');
  }

  static Future<void> enableMetric(String metric) async {
    await _channel.invokeMethod('enableMetric', metric);
  }

  static Future<void> disableMetric(String metric) async {
    await _channel.invokeMethod('disableMetric', metric);
  }

  static Future<void> enableVideo(String policy, String quality, double framesPerSecond) async {
    var args = {
      'policy': policy,
      'quality': quality,
      'framesPerSecond': framesPerSecond
    };

    await _channel.invokeMethod('enableVideo', args);
  }

  static Future<void> disableVideo() async {
    await _channel.invokeMethod('disableVideo');
  }

  static Future<void> enableFeedbackForm(String method) async {
    await _channel.invokeMethod('enableFeedbackForm', method);
  }

  static Future<void> disableFeedbackForm() async {
    await _channel.invokeMethod('disableFeedbackForm');
  }

  static Future<void> setMaxSessionLength(double seconds) async {
    await _channel.invokeMethod('setMaxSessionLength', seconds);
  }

  static void hideWidget(GlobalKey widgetKey) {
    _hiddenWidgets.add(widgetKey);
  }

  static Future<void> takeScreenshot() async {
    var ps = WidgetsBinding.instance.window.physicalSize;
    double width = ps.width;
    double height = ps.height;

    await WidgetsBinding.instance.endOfFrame;

    var rects = getHiddenRects();

    var screenshot = await WidgetInspectorService.instance.screenshot(
        WidgetsBinding.instance.renderViewElement.findRenderObject(),
        width: width,
        height: height
    );

    ByteData byteData = await screenshot.toByteData(format: ui.ImageByteFormat.rawRgba);

    rects.forEach((r) {
      var x = r['x'];
      var y = r['y'];
      var w = r['w'];
      var h = r['h'];

//      print("Hidden Rect: " + r.toString());

      if(w > 0 && h > 0) {
        for (var i = x; i < x + w; i++) {
          for (var j = y; j < y + h; j++) {
            var fixedI = math.min(math.max(0, i), width).toInt() * 4;
            var fixedJ = math.min(math.max(0, j), height).toInt() * 4;

            byteData.setUint8((fixedJ * width.toInt()) + fixedI, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 1, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 2, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 3, 0);
          }
        }
      }
    });

    prepareTwoWayInvoke();

    var args = {
      'pixels': byteData.buffer.asUint8List(),
      'width': width.toInt(),
      'height': height.toInt()
    };

    await _channel.invokeMethod('sendScreenshot', args);
  }

  static Future<void> addNetworkEvent(
      String uri,
      String method,
      int code,
      int startTimeMillis,
      int endTimeMillis,
      int requestSize,
      int responseSize,
      String errorMessage
      ) async {
    var args = {
      'uri': uri,
      'method': method,
      'code': code,
      'startTimeMillis': startTimeMillis,
      'endTimeMillis': endTimeMillis,
      'requestSize': requestSize,
      'responseSize': responseSize,
      'errorMessage': errorMessage,
    };

    await _channel.invokeMethod('addNetworkEvent', args);
  }

  static Future<void> bringFlutterToFront() async {
    await _channel.invokeMethod('bringFlutterToFront');
  }

  // Feedback options callback mechanism

  static void testfairyVoid() {}

  static void testfairyFeedbackOptionsVoid(FeedbackOptions feedbackContent) {}

  static int feedbackOptionsIdCounter = 0;
  static var feedbackOptionsCallbacks = {};

  // TODO : implement this on iOS
  static Future<void> setFeedbackOptions(
      {String browserUrl,
      bool emailFieldVisible: true,
      bool emailMandatory: false,
      Function(FeedbackOptions) onFeedbackSent: testfairyFeedbackOptionsVoid,
      Function() onFeedbackCancelled: testfairyVoid,
      Function(FeedbackOptions) onFeedbackFailed:
          testfairyFeedbackOptionsVoid}) async {
    prepareTwoWayInvoke();

    var args = {
      'browserUrl': browserUrl,
      'emailFieldVisible': emailFieldVisible,
      'emailMandatory': emailMandatory,
      'callId': feedbackOptionsIdCounter
    };

    feedbackOptionsCallbacks.putIfAbsent(feedbackOptionsIdCounter.toString(),
        () {
      return {
        'onFeedbackSent': onFeedbackSent,
        'onFeedbackCancelled': onFeedbackCancelled,
        'onFeedbackFailed': onFeedbackFailed
      };
    });

    feedbackOptionsIdCounter++;
    await _channel.invokeMethod('setFeedbackOptions', args);
  }

  static void callOnFeedbackSent(Map args) {
    var opts = FeedbackOptions();

    opts.email = args['email'];
    opts.text = args['text'];
    opts.timestamp = args['timestamp'];
    opts.i = args['i'];

//    print(args['callId'].toString());

    feedbackOptionsCallbacks[args['callId'].toString()]['onFeedbackSent'](opts);
  }

  static void callOnFeedbackCancelled(int callId) {
    feedbackOptionsCallbacks[callId.toString()]['onFeedbackCancelled']();
  }

  static void callOnFeedbackFailed(Map args) {
    var opts = FeedbackOptions();

    opts.email = args['email'];
    opts.text = args['text'];
    opts.timestamp = args['timestamp'];
    opts.i = args['i'];

    feedbackOptionsCallbacks[args['callId'].toString()]
        ['onFeedbackFailed'](opts);
  }

  // Http overrides for network logging

  static HttpOverrides httpOverrides() {
    return new TestFairyHttpOverrides();
  }
}

class TestFairyHttpOverrides extends HttpOverrides {

  @override
  HttpClient createHttpClient(SecurityContext context) {
    var clientToWrap = super.createHttpClient(context);

    return new TestFairyHttpClient(context: context, wrappedClient: clientToWrap);
  }

}

abstract class TestFairyHttpClient extends HttpClient {

  factory TestFairyHttpClient({SecurityContext context, HttpClient wrappedClient}) {
    if (wrappedClient == null) {
      return new _TestFairyHttpClient(new HttpClient(context: context));
    } else {
      return new _TestFairyHttpClient(wrappedClient);
    }
  }

}

class _TestFairyHttpClient implements TestFairyHttpClient {

  HttpClient wrappedClient;

  _TestFairyHttpClient(HttpClient wrappedClient) {
    this.wrappedClient = wrappedClient;
  }

  @override
  void set autoUncompress(bool autoUncompress) {
    this.wrappedClient.autoUncompress = autoUncompress;
  }

  @override
  bool get autoUncompress {
    return this.wrappedClient.autoUncompress;
  }

  @override
  void set connectionTimeout(Duration connectionTimeout) {
    this.wrappedClient.connectionTimeout = connectionTimeout;
  }

  @override
  Duration get connectionTimeout {
    return this.wrappedClient.connectionTimeout;
  }

  @override
  void set idleTimeout(Duration idleTimeout) {
    this.wrappedClient.idleTimeout = idleTimeout;
  }

  @override
  Duration get idleTimeout {
    return this.wrappedClient.idleTimeout;
  }

  @override
  void set maxConnectionsPerHost(int maxConnectionsPerHost) {
    this.wrappedClient.maxConnectionsPerHost = maxConnectionsPerHost;
  }

  @override
  int get maxConnectionsPerHost {
    return this.wrappedClient.maxConnectionsPerHost;
  }

  @override
  void set userAgent(String userAgent) {
    this.wrappedClient.userAgent = userAgent;
  }

  @override
  String get userAgent {
    return this.wrappedClient.userAgent;
  }

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {
    this.wrappedClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {
    this.wrappedClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  void set authenticate(Future<bool> Function(Uri url, String scheme, String realm) f) {
    this.wrappedClient.authenticate = f;
  }

  @override
  void set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String realm) f) {
    this.wrappedClient.authenticateProxy = f;
  }

  @override
  void set badCertificateCallback(bool Function(X509Certificate cert, String host, int port) callback) {
    this.wrappedClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    this.wrappedClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return this.wrappedClient.delete(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return this.wrappedClient.deleteUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  void set findProxy(String Function(Uri url) f) {
    this.wrappedClient.findProxy = f;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return this.wrappedClient.get(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return this.wrappedClient.getUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return this.wrappedClient.head(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return this.wrappedClient.headUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    return this.wrappedClient.open(method, host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return this.wrappedClient.openUrl(method, url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return this.wrappedClient.patch(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return this.wrappedClient.patchUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return this.wrappedClient.post(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return this.wrappedClient.postUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return this.wrappedClient.put(host, port, path).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return this.wrappedClient.putUrl(url).then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }
}

class _TestFairyClientHttpRequest implements HttpClientRequest {

  HttpClientRequest wrappedRequest;

  _TestFairyClientHttpRequest(HttpClientRequest wrappedRequest) {
    this.wrappedRequest = wrappedRequest;
  }

  @override
  bool get bufferOutput {
    return this.wrappedRequest.bufferOutput;
  }

  @override
  void set bufferOutput(bool bufferOutput) {
    this.wrappedRequest.bufferOutput = bufferOutput;
  }

  @override
  int get contentLength {
    return this.wrappedRequest.contentLength;
  }

  @override
  void set contentLength(int contentLength) {
    this.wrappedRequest.contentLength = contentLength;
  }

  @override
  Encoding get encoding {
    return this.wrappedRequest.encoding;
  }

  @override
  void set encoding(Encoding encoding) {
    this.wrappedRequest.encoding = encoding;
  }

  @override
  bool get followRedirects {
    return this.wrappedRequest.followRedirects;
  }

  @override
  void set followRedirects(bool followRedirects) {
    this.wrappedRequest.followRedirects = followRedirects;
  }

  @override
  int get maxRedirects {
    return this.wrappedRequest.maxRedirects;
  }

  @override
  void set maxRedirects(int maxRedirects) {
    this.wrappedRequest.maxRedirects = maxRedirects;
  }

  @override
  bool get persistentConnection {
    return this.wrappedRequest.persistentConnection;
  }

  @override
  void set persistentConnection(bool persistentConnection) {
    this.wrappedRequest.persistentConnection = persistentConnection;
  }

  @override
  void add(List<int> data) {
    this.wrappedRequest.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    this.wrappedRequest.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return this.wrappedRequest.addStream(stream);
  }

  @override
  Future<HttpClientResponse> close() {
    int startTimeMillis = new DateTime.now().millisecondsSinceEpoch;
    int requestSize = this.wrappedRequest.contentLength;

    return this.wrappedRequest.close().then((HttpClientResponse res) {
      int endTimeMillis = new DateTime.now().millisecondsSinceEpoch;
      
      TestFairy.addNetworkEvent(
          uri.toString(),
          method,
          res.statusCode,
          startTimeMillis,
          endTimeMillis,
          requestSize,
          res.contentLength,
          null
      );

      return res;
    }).catchError((error) {
      int endTimeMillis = new DateTime.now().millisecondsSinceEpoch;

      TestFairy.addNetworkEvent(
          uri.toString(),
          method,
          -1,
          startTimeMillis,
          endTimeMillis,
          requestSize,
          -1,
          error.toString()
      );

      throw error;
    });
  }

  @override
  HttpConnectionInfo get connectionInfo => this.wrappedRequest.connectionInfo;

  @override
  List<Cookie> get cookies => this.wrappedRequest.cookies;

  @override
  Future<HttpClientResponse> get done => this.wrappedRequest.done;

  @override
  Future flush() {
    return this.wrappedRequest.flush();
  }

  @override
  HttpHeaders get headers => this.wrappedRequest.headers;

  @override
  String get method => this.wrappedRequest.method;

  @override
  Uri get uri => this.wrappedRequest.uri;

  @override
  void write(Object obj) {
    this.wrappedRequest.write(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    this.wrappedRequest.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    this.wrappedRequest.writeCharCode(charCode);
  }

  @override
  void writeln([Object obj = ""]) {
    this.wrappedRequest.writeln(obj);
  }

}