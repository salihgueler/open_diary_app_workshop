
For adding authentication, you have to first check the _amplify/auth/resource.ts_ file. This file will alow you to add any authentication information in a declarative way. 

The current state of the file will allow you to add authentication flow with email. Let's update a few things to see how you can add some personal information about the user and how you can update the confirmation email for the user.

Let's see now how you can update the authentication flow with a few customizations:

```ts
export const auth = defineAuth({
  loginWith: {
    email: {
      verificationEmailSubject: "Verify your email for Open Diary!",
      verificationEmailBody: (code) =>
        `Welcome to Open Diary! Your verification code is ${code}. Enjoy!`,
      verificationEmailStyle: "CODE",
    },
  },
  userAttributes: {
    preferredUsername: {
      required: true,
    },
    givenName: {
      required: true,
    },
  },
});
```

As you see, even the language is TypeScript, the definition of the properties feels more abstract and you can just add any property by checking the details out. 

If you run the sandbox environment now, by running the following code, you will be ready to add the frontend piece:

```bash
npx ampx sandbox --outputs-format dart --outputs-out-dir lib
```


For adding the frontend part, you have to add the frontend libraries to the pubspec.yaml file and run `flutter pub get`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  amplify_flutter: ^2.4.1
  amplify_auth_cognito: ^2.4.1
  amplify_authenticator: ^2.1.3
```

You added the `amplify_flutter` for core functionality usages, `amplify_auth_cognito` for authentication configuration and `amplify_authenticator` to have easy to use authentication flow with a single line of code. 

Next, you can update the _main.dart_ file as follows: 

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/amplify_outputs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();
    runApp(const MainApp());
  } on AmplifyException catch (e) {
    runApp(ErrorWidget(e));
  }
}

Future<void> _configureAmplify() async {
  await Amplify.addPlugin(AmplifyAuthCognito());
  await Amplify.configure(amplifyConfig);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Open Diary App'),
            actions: [
              IconButton(
                onPressed: () {
                  Amplify.Auth.signOut();
                },
                icon: const Icon(Icons.exit_to_app),
              )
            ],
          ),
          body: const Center(
            child: Text('Hello World!'),
          ),
        ),
      ),
    );
  }
}
```

For reading the data about user authentication, you will call the auth functions like the following:

```dart
Future<UserInformation> _fetchUserInformation() async {
    final userInformation = await Amplify.Auth.getCurrentUser();
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    final email = userAttributes.firstWhere(
        (attribute) => attribute.userAttributeKey == AuthUserAttributeKey.email,
    );
    final username = userAttributes.firstWhere(
        (attribute) =>
            attribute.userAttributeKey == AuthUserAttributeKey.preferredUsername,
    );
    final fullName = userAttributes.firstWhere(
        (attribute) =>
            attribute.userAttributeKey == AuthUserAttributeKey.givenName,
    );
    return UserInformation(
        id: userInformation.userId,
        email: email.value,
        username: username.value,
        fullName: fullName.value,
    );
}
```

`getCurrentUser` brings the current logged in user with the logged in information, `fetchUserAttributes` brings all the attributes saved.

Create a new file called _profile_page.dart_ and update it like the following:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/user_information.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserInformation>(
          future: _fetchUserInformation(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userInformation = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/200',
                    ), // Make sure to add a profile picture asset
                  ),
                  const SizedBox(height: 16),
                  // Name Field
                  ProfileField(
                    label: 'Name',
                    initialValue: userInformation.fullName,
                  ),
                  const SizedBox(height: 16),
                  // Username Field
                  ProfileField(
                    label: 'Username',
                    initialValue: userInformation.username,
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  ProfileField(
                    label: 'Email',
                    initialValue: userInformation.email,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<UserInformation> _fetchUserInformation() async {
    final userInformation = await Amplify.Auth.getCurrentUser();
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    final email = userAttributes.firstWhere(
      (attribute) => attribute.userAttributeKey == AuthUserAttributeKey.email,
    );
    final username = userAttributes.firstWhere(
      (attribute) =>
          attribute.userAttributeKey == AuthUserAttributeKey.preferredUsername,
    );
    final fullName = userAttributes.firstWhere(
      (attribute) =>
          attribute.userAttributeKey == AuthUserAttributeKey.givenName,
    );
    return UserInformation(
      id: userInformation.userId,
      email: email.value,
      username: username.value,
      fullName: fullName.value,
    );
  }
}

class ProfileField extends StatelessWidget {
  ProfileField({
    super.key,
    required this.label,
    String initialValue = '',
  }) : controller = TextEditingController(text: initialValue);

  final String label;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
```

and for keeping the data, create a _user_information.dart_ file and paste the following to keep user related information.

```dart
class UserInformation {
  const UserInformation({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });

  final String id;
  final String email;
  final String username;
  final String fullName;

  @override
  int get hashCode => Object.hashAll([
        id,
        email,
        username,
        fullName,
      ]);

  @override
  bool operator ==(Object other) {
    return other is UserInformation &&
        (id == other.id) &&
        (email == other.email) &&
        (username == other.username) &&
        (fullName == other.fullName);
  }
}
```

Now you can [add data](https://github.com/salihgueler/open_diary_app_workshop/blob/main/4_add_data.md).
