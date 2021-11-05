## AWS Transfer Family Builders' Session

The AWS Transfer Family builders' session for enabling complex permission patterns in minutes initializes your environment using this repository on an AWS Cloud9 instance.

The CSV data of names are fake names we automatically generated with a script. Any real names in the file is purely coincidental.

The CloudFormation stack must be the one used in the lab, and must be named **transfer-builders-session** for this script to work. If named something else, the stack name variable in **mount.sh** must be changed.

The Cloud9 instance clones the repository into a folder called **init**. From your home environment directory in Cloud9, you would run the following commands to initialize the environment.

```bash
chmod +x ./init/mount.sh
nohup ./init/mount.sh &
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
