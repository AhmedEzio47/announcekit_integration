import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/web_content.html');

      final String htmlContent =
          await rootBundle.loadString('assets/announcekit_widget.html');

      await tempFile.writeAsString(htmlContent);

      final fileUrl = Uri.file(tempFile.path).toString();
      debugPrint("Loading from file URL: $fileUrl");

      await _controller.loadRequest(Uri.parse(fileUrl));
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
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHtmlFromFile,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
