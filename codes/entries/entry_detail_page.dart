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
