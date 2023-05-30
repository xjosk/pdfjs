import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
// Import for Android features.
//import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<String> navigateToPdfView() async {
    final files = await FilePicker.platform.pickFiles(withData: true);
    final file = files?.files.single;
    if (file == null) return '';
    final encoded = base64.encode(file.bytes!);
    return encoded;
  }

  late WebViewPlusController webViewController;

  @override
  void initState() {
    super.initState();
    // PlatformWebViewControllerCreationParams params =
    //     const PlatformWebViewControllerCreationParams();

    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams
    //       .fromPlatformWebViewControllerCreationParams(
    //     params,
    //   );
    // } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    //   params = AndroidWebViewControllerCreationParams
    //       .fromPlatformWebViewControllerCreationParams(
    //     params,
    //   );
    // }
    // webViewController = WebViewController.fromPlatformCreationParams(params)
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..addJavaScriptChannel('Flutter', onMessageReceived: (p0) {
    //     print(p0.message);
    //   })
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int progress) {},
    //       onPageStarted: (String url) {},
    //       onPageFinished: (String url) {},
    //       onWebResourceError: (WebResourceError error) {},
    //       onNavigationRequest: (NavigationRequest request) {
    //         if (request.url.startsWith('https://www.youtube.com/')) {
    //           return NavigationDecision.prevent;
    //         }
    //         return NavigationDecision.navigate;
    //       },
    //     ),
    //   )
    //   ..loadFlutterAsset('assets/pdf_editor.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: WebViewPlus(
            javascriptChannels: {
              JavascriptChannel(
                  name: 'Flutter',
                  onMessageReceived: (message) {
                    print(message.message);
                  })
            },
            onPageFinished: (_) async {
              webViewController.webViewController.runJavascript("""
      var pdfAsDataUri = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwogIC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAvTWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0KPj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAgL1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9udAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2JqCgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJUCjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVuZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4gCjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAwMDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9vdCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
      var blob = base64ToBlob(pdfAsDataUri);
      var url = URL.createObjectURL(blob);

      document.getElementById('pdf-js-viewer').setAttribute('src', 'web/viewer.html?file='+url);

      function base64ToBlob(base64) {
        const binaryString = window.atob(base64);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; ++i) {
          bytes[i] = binaryString.charCodeAt(i);
        }
      
        return new Blob([bytes], { type: 'application/pdf' });
      };
""");
            },
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.loadUrl('assets/pdf_editor.html');
            },
          ),
        ),

        // Expanded(
        //     child: WebViewWidget(controller: webViewController!)),
        // ElevatedButton(
        //     onPressed: () async {
        //       final string = await navigateToPdfView();
        //       if (string.isEmpty) return;
        //       webViewController?.runJavaScript(
        //           'document.getElementById("pdfEmbed").src = "data:application/pdf;base64,$string"; Flutter.postMessage([1,2,3,4])');
        //     },
        //     child: Text('mandar a webview')),
        // ElevatedButton(
        //     onPressed: () async {
        //       webViewController?.runJavaScript(
        //           'Flutter.postMessage(document.getElementById("pdfEmbed").src)');
        //     },
        //     child: Text('mandar a flutter')),
        IconButton(
          onPressed: navigateToPdfView,
          icon: const Icon(Icons.picture_as_pdf),
        ),
      ],
    ));
  }
}
