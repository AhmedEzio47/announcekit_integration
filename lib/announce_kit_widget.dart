import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnnounceKitWidget extends StatefulWidget {
  const AnnounceKitWidget({super.key});

  @override
  _AnnounceKitWidgetState createState() => _AnnounceKitWidgetState();
}

class _AnnounceKitWidgetState extends State<AnnounceKitWidget> {
  late final WebViewController _controller;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("Page loading started: $url");
          },
          onPageFinished: (url) {
            debugPrint("Page loaded successfully: $url");
            if (!url.startsWith('about:')) {
              _controller
                  .runJavaScript('localStorage.setItem("key", "value");')
                  .then((_) => debugPrint("localStorage set successfully"))
                  .catchError((error) =>
                      debugPrint("Error setting localStorage: $error"));
            }
          },
          onWebResourceError: (error) {
            setState(() {
              errorMessage = "Web resource error: ${error.description}";
            });
            debugPrint("Web resource error: ${error.description}");
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHtmlFromFile();
    });
  }

  Future<void> _loadHtmlFromFile() async {
    try {
      await _controller.loadFlutterAsset('assets/announcekit_widget.html');
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : WebViewWidget(controller: _controller),
    );
  }
}
