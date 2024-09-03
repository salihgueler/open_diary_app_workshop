For creating an AWS Amplify project, now you don't need the extra Amplify CLI. With the Amplify Gen 2, now you can create your infrastructure with code.

For creating an Amplify project, you should run the following code:

```bash
npm create amplify@latest -y
```

This will create an AWS Amplify project with a basic to-do application as a backend. 

For testing with the personalized backend deployment, AWS Amplify offers a sandbox environment, for running the sandbox environment, you have to run the following command:

```bash
npx ampx sandbox --outputs-format dart --outputs-out-dir lib
```

This will deploy your backend with actual cloud resources with a disposable matter.

Once you successfully deploy it, you can delete it by running the following:

```bash
npx ampx sandbox delete
```

Next step is to [add authentication](https://github.com/salihgueler/open_diary_app_workshop/blob/main/3_add_authentication.md).

