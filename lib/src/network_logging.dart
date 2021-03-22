// @dart = 2.12
// ignore_for_file: avoid_return_types_on_setters

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import '../testfairy_flutter.dart';

class TestFairyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient? clientToWrap = super.createHttpClient(context);

    return TestFairyHttpClient(context: context, wrappedClient: clientToWrap);
  }
}

abstract class TestFairyHttpClient extends HttpClient {
  factory TestFairyHttpClient(
      {SecurityContext? context, HttpClient? wrappedClient}) {
    if (wrappedClient == null) {
      return _TestFairyHttpClient(HttpClient(context: context));
    } else {
      return _TestFairyHttpClient(wrappedClient);
    }
  }
}

class _TestFairyHttpClient implements TestFairyHttpClient {
  HttpClient wrappedClient;

  _TestFairyHttpClient(this.wrappedClient);

  @override
  void set autoUncompress(bool autoUncompress) {
    wrappedClient.autoUncompress = autoUncompress;
  }

  @override
  bool get autoUncompress {
    return wrappedClient.autoUncompress;
  }

  @override
  void set connectionTimeout(Duration? connectionTimeout) {
    wrappedClient.connectionTimeout = connectionTimeout;
  }

  @override
  Duration get connectionTimeout {
    return wrappedClient.connectionTimeout!;
  }

  @override
  void set idleTimeout(Duration idleTimeout) {
    wrappedClient.idleTimeout = idleTimeout;
  }

  @override
  Duration get idleTimeout {
    return wrappedClient.idleTimeout;
  }

  @override
  void set maxConnectionsPerHost(int? maxConnectionsPerHost) {
    wrappedClient.maxConnectionsPerHost = maxConnectionsPerHost;
  }

  @override
  int get maxConnectionsPerHost {
    return wrappedClient.maxConnectionsPerHost!;
  }

  @override
  void set userAgent(String? userAgent) {
    wrappedClient.userAgent = userAgent;
  }

  @override
  String get userAgent {
    return wrappedClient.userAgent!;
  }

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    wrappedClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    wrappedClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  void set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm)? f) {
    wrappedClient.authenticate = f;
  }

  @override
  void set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String realm)?
          f) {
    wrappedClient.authenticateProxy = f;
  }

  @override
  void set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port)? callback) {
    wrappedClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    wrappedClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return wrappedClient.delete(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return wrappedClient.deleteUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  void set findProxy(String Function(Uri url)? f) {
    wrappedClient.findProxy = f;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return wrappedClient.get(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return wrappedClient.getUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return wrappedClient.head(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return wrappedClient.headUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return wrappedClient
        .open(method, host, port, path)
        .then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return wrappedClient.openUrl(method, url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return wrappedClient.patch(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return wrappedClient.patchUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return wrappedClient.post(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return wrappedClient.postUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return wrappedClient.put(host, port, path).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return wrappedClient.putUrl(url).then((HttpClientRequest req) {
      return _TestFairyClientHttpRequest(req);
    });
  }
}

class _TestFairyClientHttpRequest implements HttpClientRequest {
  HttpClientRequest wrappedRequest;

  _TestFairyClientHttpRequest(this.wrappedRequest);

  @override
  bool get bufferOutput {
    return wrappedRequest.bufferOutput;
  }

  @override
  void set bufferOutput(bool bufferOutput) {
    wrappedRequest.bufferOutput = bufferOutput;
  }

  @override
  int get contentLength {
    return wrappedRequest.contentLength;
  }

  @override
  void set contentLength(int contentLength) {
    wrappedRequest.contentLength = contentLength;
  }

  @override
  Encoding get encoding {
    return wrappedRequest.encoding;
  }

  @override
  void set encoding(Encoding encoding) {
    wrappedRequest.encoding = encoding;
  }

  @override
  bool get followRedirects {
    return wrappedRequest.followRedirects;
  }

  @override
  void set followRedirects(bool followRedirects) {
    wrappedRequest.followRedirects = followRedirects;
  }

  @override
  int get maxRedirects {
    return wrappedRequest.maxRedirects;
  }

  @override
  void set maxRedirects(int maxRedirects) {
    wrappedRequest.maxRedirects = maxRedirects;
  }

  @override
  bool get persistentConnection {
    return wrappedRequest.persistentConnection;
  }

  @override
  void set persistentConnection(bool persistentConnection) {
    wrappedRequest.persistentConnection = persistentConnection;
  }

  @override
  void add(List<int> data) {
    wrappedRequest.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    wrappedRequest.addError(error, stackTrace);
  }

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) {
    return wrappedRequest.addStream(stream);
  }

  @override
  Future<HttpClientResponse> close() {
    final int startTimeMillis = DateTime.now().millisecondsSinceEpoch;
    final int requestSize = wrappedRequest.contentLength;

    return wrappedRequest.close().then((HttpClientResponse res) {
      final int endTimeMillis = DateTime.now().millisecondsSinceEpoch;

      TestFairy.addNetworkEvent(uri.toString(), method, res.statusCode,
          startTimeMillis, endTimeMillis, requestSize, res.contentLength, null);

      return res;
    }).catchError((Object error) {
      final int endTimeMillis = DateTime.now().millisecondsSinceEpoch;

      TestFairy.addNetworkEvent(uri.toString(), method, -1, startTimeMillis,
          endTimeMillis, requestSize, -1, error.toString());

      throw error;
    });
  }

  @override
  HttpConnectionInfo? get connectionInfo => wrappedRequest.connectionInfo;

  @override
  List<Cookie> get cookies => wrappedRequest.cookies;

  @override
  Future<HttpClientResponse> get done => wrappedRequest.done;

  @override
  Future<dynamic> flush() {
    return wrappedRequest.flush();
  }

  @override
  HttpHeaders get headers => wrappedRequest.headers;

  @override
  String get method => wrappedRequest.method;

  @override
  Uri get uri => wrappedRequest.uri;

  @override
  void write(Object? obj) {
    wrappedRequest.write(obj);
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    wrappedRequest.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    wrappedRequest.writeCharCode(charCode);
  }

  @override
  void writeln([Object? obj = '']) {
    wrappedRequest.writeln(obj);
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    wrappedRequest.abort(exception, stackTrace);
  }
}
