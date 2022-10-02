import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControl extends StatelessWidget {
  const NavigationControl(this._webViewControllerFuture, {Key? key})
      : assert(_webViewControllerFuture != null),
        super(key: key);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        builder: (context, snapshot) {
          final bool webViewReady =
              snapshot.connectionState == ConnectionState.done;
          final WebViewController? controller = snapshot.data;
          return Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
                tooltip: 'menu',
              ),
              IconButton(
                onPressed: !webViewReady
                    ? null
                    : () async {
                        if (await controller!.canGoBack()) {
                          await controller.goBack();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No back history item')));
                        }
                      },
                icon: const Icon(Icons.arrow_back),
                tooltip: 'back',
              ),
              IconButton(
                onPressed: !webViewReady
                    ? null
                    : () async {
                        if (await controller!.canGoForward()) {
                          await controller.goForward();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No forward history item')));
                        }
                      },
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'forward',
              )
            ],
          );
        },
        future: _webViewControllerFuture);
  }
}
