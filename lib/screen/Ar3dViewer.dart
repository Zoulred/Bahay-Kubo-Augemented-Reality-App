import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Simple3DViewer extends StatefulWidget {
  final String modelPath;
  final String modelName;

  const Simple3DViewer({
    super.key,
    required this.modelPath,
    required this.modelName,
  });

  @override
  State<Simple3DViewer> createState() => _Simple3DViewerState();
}

class _Simple3DViewerState extends State<Simple3DViewer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_get3DViewerHTML());
  }

  String _get3DViewerHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
</head>
<body style="margin: 0; padding: 0; background: black;">
    <model-viewer 
        src="${widget.modelPath}"
        alt="${widget.modelName}"
        auto-rotate
        camera-controls
        style="width: 100%; height: 100vh;"
        background-color="black">
    </model-viewer>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D View: ${widget.modelName}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Reload 3D Model',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
