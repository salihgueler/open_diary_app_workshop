import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_diary_app/models/ModelProvider.dart';

class EntryCreatePage extends StatefulWidget {
  const EntryCreatePage({super.key});

  @override
  State<EntryCreatePage> createState() => _EntryCreatePageState();
}

class _EntryCreatePageState extends State<EntryCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  XFile? _image;
  int _selectedMood = 0;
  String? _statusText;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _statusText == null
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Title Input
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Detail Input (Multiline)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Detail',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      controller: _detailController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Image Picker
                    TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Pick an Image'),
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            _image = pickedFile;
                          });
                        }
                      },
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.file(
                          File(_image!.path),
                          height: 200,
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    // Mood Selector
                    const Text('Select Your Mood',
                        style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMoodIcon(
                          1,
                          Icons.sentiment_very_dissatisfied,
                          'Very Dissatisfied',
                        ),
                        _buildMoodIcon(
                          2,
                          Icons.sentiment_dissatisfied,
                          'Dissatisfied',
                        ),
                        _buildMoodIcon(
                          3,
                          Icons.sentiment_neutral,
                          'Neutral',
                        ),
                        _buildMoodIcon(
                          4,
                          Icons.sentiment_satisfied,
                          'Satisfied',
                        ),
                        _buildMoodIcon(
                          5,
                          Icons.sentiment_very_satisfied,
                          'Very Satisfied',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    // Submit Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final id = UUID.getUUID();
                          final mood = _toEntryMood(_selectedMood);
                          if (_image != null) {
                            await Amplify.Storage.uploadFile(
                                localFile: AWSFile.fromPath(_image!.path),
                                path: StoragePath.fromString(
                                  'entryImages/$id.png',
                                ),
                                onProgress: (progress) {
                                  setState(() {
                                    _statusText =
                                        'Uploading file: ${((progress.fractionCompleted) * 100).toStringAsFixed(2)}';
                                  });
                                  final request = ModelMutations.create(
                                    Entry(
                                      id: id,
                                      title: _titleController.text,
                                      details: _detailController.text,
                                      mood: mood,
                                      addedDate: TemporalDate(DateTime.now()),
                                      image: '$id.png',
                                    ),
                                  );
                                  setState(() {
                                    _statusText = 'Saving the entry.';
                                  });
                                  Amplify.API.mutate(request: request);
                                }).result;
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          } else {
                            final request = ModelMutations.create(
                              Entry(
                                id: id,
                                title: _titleController.text,
                                details: _detailController.text,
                                mood: mood,
                                addedDate: TemporalDate(DateTime.now()),
                              ),
                            );
                            setState(() {
                              _statusText = 'Saving the entry.';
                            });
                            await Amplify.API.mutate(request: request).response;
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(_statusText!),
              ),
      ),
    );
  }

  EntryMood _toEntryMood(int index) {
    switch (_selectedMood) {
      case 0:
        return EntryMood.veryBad;
      case 1:
        return EntryMood.bad;
      case 2:
        return EntryMood.okay;
      case 3:
        return EntryMood.good;
      case 4:
        return EntryMood.veryGood;
      default:
        return EntryMood.okay;
    }
  }

  Widget _buildMoodIcon(int value, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, size: 40.0),
      color: _selectedMood == value ? Colors.blue : Colors.grey,
      onPressed: () {
        setState(() {
          _selectedMood = value;
        });
      },
      tooltip: tooltip,
    );
  }
}
