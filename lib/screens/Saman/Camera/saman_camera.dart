import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_vision/google_ml_vision.dart'; // OCR
import 'package:palette_generator/palette_generator.dart'; // For color extraction

class CarScanner extends StatefulWidget {
  const CarScanner({Key? key}) : super(key: key);

  @override
  State<CarScanner> createState() => _CarScannerState();
}

class _CarScannerState extends State<CarScanner> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;
  String? licensePlate, brand, color;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _captureAndProcessImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      // Extract license plate
      final recognizedText = await _extractTextFromImage(imageFile);
      licensePlate = _extractLicensePlate(recognizedText ?? "");

      // Detect color
      color = await _detectColor(imageFile);

      // Simulate brand detection
      brand = "Simulated Brand"; // Replace with real logic or API if required

      if (licensePlate != null) {
        print("License Plate: $licensePlate\nBrand: $brand\nColor: $color");

        _showInfoDialog(
          title: "Car Details Detected",
          message: "License Plate: $licensePlate\nBrand: $brand\nColor: $color",
        );
      } else {
        _showErrorDialog("No license plate detected. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Error processing image: $e");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> _extractTextFromImage(File imageFile) async {
    final visionImage = GoogleVisionImage.fromFile(imageFile);
    final textRecognizer = GoogleVision.instance.textRecognizer();
    final visionText = await textRecognizer.processImage(visionImage);
    textRecognizer.close();
    return visionText.text;
  }

  String? _extractLicensePlate(String recognizedText) {
    final licensePlateRegex = RegExp(r'[A-Z]{1,3}\d{1,4}[A-Z]{1,3}');
    final matches = licensePlateRegex.firstMatch(recognizedText);
    return matches?.group(0);
  }

  Future<String?> _detectColor(File imageFile) async {
    final palette = await PaletteGenerator.fromImageProvider(FileImage(imageFile));
    final dominantColor = palette.dominantColor?.color;

    if (dominantColor != null) {
      final colorName = _mapColorToName(dominantColor);
      return colorName ?? "Unknown Color";
    }
    return "Unknown Color";
  }

  String? _mapColorToName(Color color) {
    const colorMapping = {
      'Red': [Colors.red, Colors.redAccent],
      'Blue': [Colors.blue, Colors.blueAccent],
      'Green': [Colors.green, Colors.greenAccent],
      'White': [Colors.white, Color(0xFFD6D6D6)], // Light grey
      'Black': [Colors.black, Color(0xFF424242)], // Dark grey
      'Silver': [Color(0xFFB0B0B0), Color(0xFFC0C0C0)], // Silver shades
    };

    for (final entry in colorMapping.entries) {
      if (entry.value.any((mappedColor) => _isSimilarColor(color, mappedColor))) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isSimilarColor(Color color1, Color color2) {
    const tolerance = 30;
    return (color1.red - color2.red).abs() < tolerance &&
        (color1.green - color2.green).abs() < tolerance &&
        (color1.blue - color2.blue).abs() < tolerance;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Scanner"),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _captureAndProcessImage,
              child: const Text("Capture and Detect"),
            ),
          ),
        ],
      ),
    );
  }
}
