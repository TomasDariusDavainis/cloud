#!/usr/bin/env bash

set -e

bucket=${CLOUD_BUCKET?"Missing CLOUD_BUCKET in environment"}

echo Uploading template and assets
aws s3 sync s3-files/template/ s3://${bucket}/template --delete --exact-timestamps
aws s3 sync s3-files/inc/ s3://${bucket}/inc --delete --exact-timestamps
aws s3 cp s3-files/index.html s3://${bucket}/index.html

if [[ $1 == "lambda" ]]; then
	echo Preparing lambda
	[ -f lambda.zip ] && rm lambda.zip
	(
	cd lambda
	pip install -r requirements.txt -t .
	zip -q -r ../lambda.zip ./*
	)

	echo Deploying lambda
	aws lambda update-function-code --function-name cloud-handler --zip-file fileb://lambda.zip
fi
