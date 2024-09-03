First upload your project to GitHub. You can do it easily over VSCode.

![image](https://github.com/user-attachments/assets/1e8f37f1-201b-430f-a5db-ae9682721faa)

Go to AWS console, and create your project with the following steps:

![image](https://github.com/user-attachments/assets/9eb1d207-6f64-4fcb-8cec-eab5596230b7)

![image](https://github.com/user-attachments/assets/44818199-3093-4678-acf5-fe4a5d868012)

![image](https://github.com/user-attachments/assets/d76f0db5-586e-43bc-b7f4-54f537e30ec5)

![image](https://github.com/user-attachments/assets/169aafff-34a1-4a1b-bb47-6c986ab71305)

![image](https://github.com/user-attachments/assets/60f4cdf2-dac0-4579-bf2c-2e2455fcedc1)

![image](https://github.com/user-attachments/assets/b8b62cff-c8ea-4580-b3ee-c484633ad1b2)

![image](https://github.com/user-attachments/assets/bdd0c531-bc2c-4909-8698-7d3c393b860b)

```yaml
version: 1
backend:
  phases:
    build:
      commands:
        - npm ci --cache .npm --prefer-offline
        - npx ampx pipeline-deploy --branch $AWS_BRANCH --app-id $AWS_APP_ID --outputs-format dart --outputs-out-dir lib
frontend:
  phases:
    preBuild:
      commands:
        - echo "Installing Flutter SDK"
        - git clone https://github.com/flutter/flutter.git -b stable --depth 1
        - export PATH="$PATH:$(pwd)/flutter/bin"
        - flutter config --no-analytics
        - flutter doctor
    build:
      commands:
        - echo "Installing dependencies"
        - flutter pub get
        - echo "Building Flutter web application with WASM support"
        - flutter build web
  artifacts:
    baseDirectory: build/web
    files:
      - '**/*'
  cache:
    paths:
      - flutter/.pub-cache
```
