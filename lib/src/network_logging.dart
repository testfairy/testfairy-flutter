// ignore_for_file: avoid_return_types_on_setters

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:testfairy/testfairy.dart';

class TestFairyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    var clientToWrap = super.createHttpClient(context);

    return new TestFairyHttpClient(
        context: context, wrappedClient: clientToWrap);
  }
}

abstract class TestFairyHttpClient extends HttpClient {
  factory TestFairyHttpClient(
      {SecurityContext context, HttpClient wrappedClient}) {
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
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    this.wrappedClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    this.wrappedClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  void set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm) f) {
    this.wrappedClient.authenticate = f;
  }

  @override
  void set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String realm)
          f) {
    this.wrappedClient.authenticateProxy = f;
  }

  @override
  void set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port) callback) {
    this.wrappedClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    this.wrappedClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return this
        .wrappedClient
        .delete(host, port, path)
        .then((HttpClientRequest req) {
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
    return this
        .wrappedClient
        .get(host, port, path)
        .then((HttpClientRequest req) {
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
    return this
        .wrappedClient
        .head(host, port, path)
        .then((HttpClientRequest req) {
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
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return this
        .wrappedClient
        .open(method, host, port, path)
        .then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return this
        .wrappedClient
        .openUrl(method, url)
        .then((HttpClientRequest req) {
      return new _TestFairyClientHttpRequest(req);
    });
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return this
        .wrappedClient
        .patch(host, port, path)
        .then((HttpClientRequest req) {
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
    return this
        .wrappedClient
        .post(host, port, path)
        .then((HttpClientRequest req) {
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
    return this
        .wrappedClient
        .put(host, port, path)
        .then((HttpClientRequest req) {
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

      TestFairy.addNetworkEvent(uri.toString(), method, res.statusCode,
          startTimeMillis, endTimeMillis, requestSize, res.contentLength, null);

      return res;
    }).catchError((error) {
      int endTimeMillis = new DateTime.now().millisecondsSinceEpoch;

      TestFairy.addNetworkEvent(uri.toString(), method, -1, startTimeMillis,
          endTimeMillis, requestSize, -1, error.toString());

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
