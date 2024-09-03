For creating an AWS Amplify project, now you don't need the extra Amplify CLI. With the Amplify Gen 2, now you can create your infrastructure with code.

For creating an Amplify project, you should run the following code:

```bash
npm create amplify@latest -y
```

This will create an AWS Amplify project with a basic to-do application as a backend. 

<TBd Add the fact that you need two important permissions for iam user>

For testing out the backend environments, AWS Amplify offers a sandbox environment, for running the sandbox environment, you have to run the following command:

```bash
npx ampx sandbox --outputs-format dart --outputs-out-dir lib
```

This will deploy your backend with actual cloud resources with a disposable matter.

Once you see a message like the following, you are ready to move on.
