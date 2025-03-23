import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotWebViewScreen extends StatefulWidget {
  const ChatbotWebViewScreen({super.key});

  @override
  State<ChatbotWebViewScreen> createState() => _ChatbotWebViewScreenState();
}

class _ChatbotWebViewScreenState extends State<ChatbotWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() => isLoading = true);
              },
              onPageFinished: (String url) {
                setState(() => isLoading = false);
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView Error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: const Color(0xFF121212),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
