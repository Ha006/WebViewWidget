import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// sökmotorn.se in punycode (IDNA) form.
const String kHomeUrl = 'https://xn--skmotorn-n4a.se';
const String kHomeHost = 'xn--skmotorn-n4a.se';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  /// Allows tests to inject a widget instead of the platform webview.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sökmotorn',
      debugShowCheckedModeBanner: false,
      home: home ?? const WebsitePage(),
    );
  }
}

bool isInternalHost(String host) =>
    host == kHomeHost || host.endsWith('.$kHomeHost') || host == 'sökmotorn.se';

class WebsitePage extends StatefulWidget {
  const WebsitePage({super.key});

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  late final WebViewController controller;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => progress = p),
          onNavigationRequest: (request) async {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            final web = uri.scheme == 'http' || uri.scheme == 'https';
            if (web && isInternalHost(uri.host)) {
              return NavigationDecision.navigate;
            }
            // External sites, mailto:, tel: etc. open outside the app.
            if (request.isMainFrame || !web) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(kHomeUrl));
  }

  Future<void> _reload() => controller.reload();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          await controller.goBack();
        } else if (context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 44,
          title: const Text('Sökmotorn'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Tillbaka',
            onPressed: () async {
              if (await controller.canGoBack()) controller.goBack();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Hem',
              onPressed: () => controller.loadRequest(Uri.parse(kHomeUrl)),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Uppdatera',
              onPressed: _reload,
            ),
          ],
          bottom: progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: progress / 100),
                )
              : null,
        ),
        body: SafeArea(child: WebViewWidget(controller: controller)),
      ),
    );
  }
}
