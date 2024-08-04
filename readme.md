# Read Me

This repo is a proof of concept for using terraform, AWS API Gateway, AWS Lambda, and AWS EFS to create a system for doing code checking, metrics, and storing data in an SQLite database.

The lambda functions use the following:

```json
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Action": "lambda:InvokeFunction",
   "Resource": "arn:aws:lambda:us-east-1:446923752902:function:*"
  },
  {
   "Effect": "Allow",
   "Action": "logs:CreateLogGroup",
   "Resource": "arn:aws:logs:us-east-1:446923752902:*"
  },
  {
   "Effect": "Allow",
   "Action": [
    "logs:CreateLogStream",
    "logs:PutLogEvents"
   ],
   "Resource": [
    "arn:aws:logs:us-east-1:446923752902:log-group:/aws/lambda/*:*"
   ]
  },
  {
   "Sid": "Statement1",
   "Effect": "Allow",
   "Action": [
    "elasticfilesystem:ClientMount",
    "elasticfilesystem:ClientWrite"
   ],
   "Resource": [
    "arn:aws:elasticfilesystem:us-east-1:446923752902:file-system/fs-043bee284f07253c9"
   ]
  },
  {
   "Sid": "Statement2",
   "Effect": "Allow",
   "Action": [
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface"
   ],
   "Resource": [
    "*"
   ]
  }
 ]
}
```

Note: For the ec2 create/describe/delete network interfaces I do not know what resources these are applying to (I suspect EFS), so the resource is intentionally vague. All other resources are setup after the fact.

I assume that this policy will need to be adapted for terraform

## Deploy

To deploy, run the code `./deploy` from the root of the project file.

The deploy runs 3 tasks

- Create a docker to compile native node modules
  - This is necessary because sqlite uses native node modules
  - It is important that the docker file matches the lambda deploy, and is compiled using the same node version as the lambda function
  - The docker instance runs script.sh which installs nvm, deletes and recreates node_modules and package-lock.json, zips the file and outputs the ziped files (ready for upload to lambda) to the `zips` folder
- Sync the zips folder with an S3 bucket
- Run the terraform command which creates the lambda functions with the zip files from S3, efs, and API gateway endpoints

## Warnings

Updating the zip files in S3 does not automatically update the lambda function. **The function has to be redeployed in order to use the updated code**
