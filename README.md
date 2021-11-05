## AWS Transfer Family Builders' Session

The AWS Transfer Family builders' session for enabling complex permission patterns in minutes initializes your environment using this repository on an AWS Cloud9 instance.

The CSV data of names are fake names we automatically generated with a script. Any real names in the file is purely coincidental.

The CloudFormation stack must be the one used in the lab, and must be named **transfer-builders-session** for this script to work. If named something else, the stack name variable in **mount.sh** must be changed.

The Cloud9 instance clones the repository into a folder called **init/**. From your home environment directory in Cloud9, you would run the following commands to initialize the environment.

```bash
chmod +x ./init/mount.sh
nohup ./init/mount.sh &
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Copyright

According to World Health Organization (WHO) in [FAQ Licensing ICD-10](https://www.who.int/docs/default-source/publishing-policies/who-faq-licensing-icd-10.pdf), "ICD-10 is the international standard diagnostic classification for all general epidemiological purposes, many health management purposes and clinical use. These include analysis of the general health situation of population groups and monitoring the incidence and prevalence of diseases, as well as other health problems with respect to variables such as the characteristics and circumstances of the individuals affected, reimbursement, case-mix, resource allocation, quality, patient safety, and guidelines."

The usage of ICD-10 codes in this lab are for educational purposes. The ICD-10 codes and descriptions used for this workshop are in the file **CommonICD10Codes.csv**. At the time of publication, the link for registration is available [here](https://www.who.int/standards/classifications/apps/icd/ClassificationDownload) and appears to be inactive, stating, "This page cannot be found The page or file you are trying to access cannot be found".
