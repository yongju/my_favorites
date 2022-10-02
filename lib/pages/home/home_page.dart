import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_favorites/widgets/NavigationControl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title, this.cookieManager})
      : super(key: key);

  final CookieManager? cookieManager;

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    print('read in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('read in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('read in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        WebViewController controller = await _controller.future;
        if (await controller.canGoBack()) {
          await controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        // appBar: AppBar(title: Text(widget.title)),
        body: Stack(children: [
          SafeArea(
            child: WebView(
              initialUrl: 'https://m.stock.naver.com',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onProgress: (int progress) {
                print('WebView is loading (progress : $progress%)');
              },
              javascriptChannels: <JavascriptChannel>{
                _toasterJavascriptChannel(context),
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
              gestureNavigationEnabled: true,
              backgroundColor: const Color(0x00000000),
              debuggingEnabled: true,
              gestureRecognizers: Set()
                // ..add(Factory<VerticalMultiDragGestureRecognizer>(
                //      () => VerticalMultiDragGestureRecognizer()
                //     ..onStart = (position) {
                //       print('VerticalMultiDragGestureRecognizer onStart $position');
                //     }
                //   )),
                ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()
                      ..onStart = (details) {
                        print('VerticalDragGestureRecognizer onStart $details');
                      }
                      ..onUpdate = (details) {
                        print(
                            'VerticalDragGestureRecognizer onUpdate $details');
                      }
                      ..onDown = (details) {
                        print('VerticalDragGestureRecognizer onDown $details');
                      }
                      ..onCancel = () {
                        print('VerticalDragGestureRecognizer onCancel');
                      }
                      ..onEnd = (details) {
                        print('VerticalDragGestureRecognizer onEnd $details');
                      })),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'floating',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar:
            BottomAppBar(child: NavigationControl(_controller.future)),
      ),
    );
  }
}
