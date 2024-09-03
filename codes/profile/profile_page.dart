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
