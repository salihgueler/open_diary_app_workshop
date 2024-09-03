For adding the storage, you will create a new folder under **amplify** folder called **storage**. And you will add _resource.ts_ file under it. 

```ts
import { defineStorage } from "@aws-amplify/backend";

export const storage = defineStorage({
  name: "diaryEntryImageBucket",
  access: (allow) => ({
    "entryImages/*": [allow.authenticated.to(["read", "write"])],
  }),
});
```

With the code below, you define a bucket for your images and give access rights to folders based on authentication state. If you don't give any access rights, the bucket will be in hidden state for users.

For using the storage in your application, you will first add the library to your _pubspec.yaml_ file:

```yaml
dependencies:
  amplify_storage_s3: ^2.4.1
```

and `flutter pub get` to load the library. Next update the `_configureAmplify_` like the following:

```dart
Future<void> _configureAmplify() async {
  await Amplify.addPlugins([
    AmplifyAuthCognito(),
    AmplifyAPI(
      options: APIPluginOptions(
        modelProvider: ModelProvider.instance,
      ),
    ),
    AmplifyStorageS3(),
  ]);
  await Amplify.configure(amplifyConfig);
}
```

Next create _entry_create_page.dart_ file for the creation of the entries:
```dart
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
```

and create _entry_detail_page.dart_ for creating a detail view:

```dart
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/extensions.dart';
import 'package:open_diary_app/models/ModelProvider.dart';

class EntryDetailPage extends StatelessWidget {
  final Entry entry;

  const EntryDetailPage({
    super.key,
    required this.entry,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddHighlightDialog(context);
        },
        label: const Text('Add Highlight'),
        icon: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                entry.title,
              ),

              background: entry.image != null
                  ? FutureBuilder(
                      future: Amplify.Storage.getUrl(
                        path: StoragePath.fromString(
                          'entryImages/${entry.image!}',
                        ),
                      ).result,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.network(
                            snapshot.data!.url.toString(),
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    )
                  : Container(color: Colors.grey), // Placeholder if no image
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(entry.toIconData(),
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8.0),
                          Text(
                            _formatDate(entry.addedDate.getDateTime()),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        entry.details,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16.0),
                      HighlightsView(
                        entry: entry,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddHighlightDialog(BuildContext context) {
    TextEditingController highlightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Highlight'),
          content: TextField(
            controller: highlightController,
            decoration: const InputDecoration(
              hintText: 'Today I had....',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String highlightText = highlightController.text.trim();
                if (highlightText.isNotEmpty) {
                  Navigator.pop(context);
                  final member = Highlight(
                    text: highlightText,
                    addedDate: TemporalDate(
                      DateTime.now(),
                    ),
                    entry: entry,
                  );
                  final memberRequest = ModelMutations.create(member);
                  Amplify.API.mutate(request: memberRequest).response;
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class HighlightsView extends StatelessWidget {
  const HighlightsView({required this.entry, super.key});

  final Entry entry;
  @override
  Widget build(BuildContext context) {
    final highlightsQuery = ModelQueries.list(
      Highlight.classType,
      where: Highlight.ENTRY.eq(entry.id),
    );
    return FutureBuilder(
      future: Amplify.API.query(request: highlightsQuery).response,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data.hasErrors) {
            return Text('Error: ${data.errors}');
          }
          final highlights = data.data!.items;
          if (highlights.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Highlights',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ...highlights.map(
                (highlight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '• ${highlight!.text}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
```

With these pages, now you have upload and read operations for your images as well. Next we can deploy this.
