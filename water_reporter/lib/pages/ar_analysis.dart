import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class AreaScanner extends StatefulWidget {
  const AreaScanner({super.key});

  @override
  State<AreaScanner> createState() => _AreaScannerState();
}

class _AreaScannerState extends State<AreaScanner> {
  String analysisResult = "Upload an image to detect waste materials";

  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _sendForAnalysis(pickedFile);
    }
  }

  Future<void> _sendForAnalysis(XFile pickedFile) async {
    final uri = Uri.parse("http://192.168.208.86:3001/analyze");

    final request = http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);
      setState(() {
        analysisResult = _parseAnalysisResult(jsonData["markdownOutput"]);
      });
    } else {
      setState(() => analysisResult = "Error analyzing image.");
    }
  }

  String _parseAnalysisResult(String markdownOutput) {
    final RegExp singleItemRegExp = RegExp(
        r'\*\*Item Name:\*\*\s*(.*?)\s*\*\*Classification:\*\*\s*(\w+)\s*\*\*Confidence Score:\*\*\s*(\d+)%');
    final RegExp multipleItemsRegExp = RegExp(
        r'\*\*Item (\d+):\*\*\s*(.*?)\s*\*\*Classification:\*\*\s*(\w+)\s*\*\*Confidence Score:\*\*\s*(\d+)%');

    final matchesForSingleItem = singleItemRegExp.firstMatch(markdownOutput);
    final matchesForMultipleItems =
        multipleItemsRegExp.allMatches(markdownOutput);

    String result = '';

    if (matchesForSingleItem != null) {
      String itemName = matchesForSingleItem.group(1) ?? 'Unknown';
      String classification = matchesForSingleItem.group(2) ?? 'Unknown';
      String confidence = matchesForSingleItem.group(3) ?? '0';

      result +=
          "Item Name: $itemName\nClassification: $classification\nConfidence: $confidence%\n\n";
    }

    if (matchesForMultipleItems.isNotEmpty) {
      for (final match in matchesForMultipleItems) {
        String itemNumber = match.group(1) ?? 'Unknown';
        String itemName = match.group(2) ?? 'Unknown';
        String classification = match.group(3) ?? 'Unknown';
        String confidence = match.group(4) ?? '0';

        result +=
            "Item $itemNumber: $itemName\nClassification: $classification\nConfidence: $confidence%\n\n";
      }
    }
    return result.isEmpty ? 'No items found in analysis.' : result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waste Analyzer")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(8),
                  child: _cameraController?.value.isInitialized ?? false
                      ? SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: CameraPreview(_cameraController!),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      analysisResult,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
