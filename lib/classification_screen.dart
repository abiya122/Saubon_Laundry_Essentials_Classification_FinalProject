import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  File? _image;
  List? _outputs;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite",
        labels: "assets/model/labels.txt",
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;
      setState(() {
        _loading = true;
        _image = File(image.path);
        _outputs = null;
      });
      await _classifyImage(_image!);
    } catch (e) {
      // Handle permission errors etc
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 10, // Get all results to sort or filter
      threshold: 0.1,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    
    setState(() {
      _loading = false;
      _outputs = output;
    });

    if (output != null && output.isNotEmpty) {
      // Extract the top result
      String rawLabel = output[0]['label'];
      // Clean label: "0 Iron" -> "Iron"
      String label = rawLabel.replaceAll(RegExp(r'^\d+\s+'), '');
      double confidence = output[0]['confidence'];

      // Only log if confidence is decent, e.g., > 0.7
      if (confidence > 0.7) {
        await _logToFirestore(label);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result logged to Analytics!')));
      }
    }
  }

  Future<void> _logToFirestore(String label) async {
    try {
      await FirebaseFirestore.instance.collection('classifications').add({
        'label': label,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classify Item')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: _image == null
                  ? Container(
                      height: 300,
                      width: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 100, color: Colors.grey),
                    )
                  : SizedBox(
                      height: 300,
                      child: Image.file(_image!),
                    ),
            ),
            const SizedBox(height: 20),
             _loading
                ? const CircularProgressIndicator()
                : _outputs != null
                    ? Column(
                        children: _outputs!.map((result) {
                          String label = result['label'].replaceAll(RegExp(r'^\d+\s+'), '');
                          double confidence = result['confidence'];
                          return ListTile(
                            title: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            trailing: Text("${(confidence * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 18)),
                          );
                        }).toList().take(3).toList(), // Show top 3
                      )
                    : const Text("Select an image to classify", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
