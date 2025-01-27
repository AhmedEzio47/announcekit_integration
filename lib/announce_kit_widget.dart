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
    _controller = WebViewController(onPermissionRequest: (request) {
      debugPrint("Requesting permission: $request");
    })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("Page loading started: $url");
            _controller.runJavaScript('localStorage.setItem("key", "value");');
          },
          onPageFinished: (url) {
            debugPrint("Page loaded successfully: $url");
          },
          onWebResourceError: (error) {
            setState(() {
              errorMessage = "Web resource error: ${error.description}";
            });
            debugPrint("Web resource error: ${error.description}");
          },
        ),
      );

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final String htmlContent = await DefaultAssetBundle.of(context)
          .loadString('assets/announcekit_widget.html');
      await _controller.loadHtmlString(htmlContent);
    } catch (e) {
      setState(() {
        errorMessage = "Error loading HTML: $e";
      });
      debugPrint("Error loading HTML: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHtmlFromAssets,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
