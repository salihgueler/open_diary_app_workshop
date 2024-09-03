import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/entry_create_page.dart';
import 'package:open_diary_app/entry_detail_page.dart';
import 'package:open_diary_app/models/Entry.dart';
import 'package:open_diary_app/extensions.dart';

class EntryListPage extends StatelessWidget {
  const EntryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = ModelQueries.list(Entry.classType);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EntryCreatePage(),
            ),
          );
        },
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: FutureBuilder(
        future: Amplify.API.query(request: request).response,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data.hasErrors) {
              return Center(
                child: Text(
                  'Something went wrong \n ${snapshot.error}',
                ),
              );
            }
            final entries = data.data?.items ?? [];
            if (entries.isEmpty) {
              return const Center(
                child: Text(
                  'There is no item here. Add some!',
                ),
              );
            }
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index]!;
                return Dismissible(
                  key: Key(entry.id),
                  background: const ColoredBox(
                    color: Colors.red,
                    child: Text('Deleting...'),
                  ),
                  confirmDismiss: (direction) async {
                    final mutation = ModelMutations.delete(entry);
                    final result =
                        await Amplify.API.mutate(request: mutation).response;

                    return !result.hasErrors;
                  },
                  child: ListTile(
                    title: Text(entry.title),
                    leading: Icon(entry.toIconData()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryDetailPage(entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong \n ${snapshot.error}',
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
