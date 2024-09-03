For adding the data to your backend, open up the _amplify/data/resource.ts_ file and update the file with the following

```ts
import { type ClientSchema, a, defineData } from "@aws-amplify/backend";

/// Create a schema called Entry and Highlights. Entry has a lot of highlights. Entries have title, details, addedDate, and a enum mood with a nullable image property.
const schema = a
  .schema({
    Entry: a.model({
      title: a.string().required(),
      details: a.string().required(),
      addedDate: a.date().required(),
      mood: a.enum(["veryBad", "bad", "okay", "good", "veryGood"]),
      image: a.string(),
      highlights: a.hasMany("Highlight", "entryId"),
    }),
    Highlight: a.model({
      text: a.string().required(),
      addedDate: a.date().required(),
      entryId: a.id(),
      entry: a.belongsTo("Entry", "entryId"),
    }),
  })
  .authorization((allow) => [allow.owner()]);

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: "userPool",
  },
});
```

This will create a new backend structure with one to many relationship through Entry and Highlights. Once you save the file, it will create a GraphQL API and DynamoDB table to save your data.

For using this in your Flutter application, you will first add the libraries:

```yaml
dependencies:
  image_picker: ^1.1.2
  amplify_api: ^2.4.1
```

and run `flutter pub get`. 

Now let's use the backend in our application, first let's generate our model classes according to our backend definition:

```bash
npx ampx generate graphql-client-code --format modelgen --model-target dart --out lib/models
```

This will generate models for us.

> You can add the models to the analysis_options.yml file to exclude it from Dart analysis.

Next update the `_configureAmplify` function like the following:

```dart
Future<void> _configureAmplify() async {
  await Amplify.addPlugins([
    AmplifyAuthCognito(),
    AmplifyAPI(
      options: APIPluginOptions(
        modelProvider: ModelProvider.instance,
      ),
    ),
  ]);
  await Amplify.configure(amplifyConfig);
}
```

And create the _entry_list_page.dart_ file for listing the options:

```dart
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
          // Navigator.of(context).push(
          //  MaterialPageRoute(
          //    builder: (context) => const EntryCreatePage(),
          //  ),
          // );
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
                      // Navigator.push(
                      //  context,
                      //  MaterialPageRoute(
                      //    builder: (context) => EntryDetailPage(entry: entry),
                      //  ),
                      // );
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
```

This code will have querying and deleting operations for items. Now let's add a new _open_diary_home_page.dart_ file and have a bottom navigation between our account and entries.

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/entry_list_page.dart';
import 'package:open_diary_app/profile_page.dart';

class OpenDiaryAppHomePage extends StatefulWidget {
  const OpenDiaryAppHomePage({super.key});

  @override
  State<OpenDiaryAppHomePage> createState() => _OpenDiaryAppHomePageState();
}

class _OpenDiaryAppHomePageState extends State<OpenDiaryAppHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    EntryListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Diary'),
        actions: [
          IconButton(
            onPressed: Amplify.Auth.signOut,
            icon: const Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
```

Before we add the creation and details, we should [add storage capabilities](https://github.com/salihgueler/open_diary_app_workshop/blob/main/5_add_storage.md).




