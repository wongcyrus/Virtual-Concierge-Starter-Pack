region=us-east-1
wget https://s3-us-west-2.amazonaws.com/sumerian-concierge-aws-resources/aws-resources.zip
rm -rf aws-resources/
unzip aws-resources.zip
rm aws-resources.zip
rm -rf __MACOSX/
pip install awscli --upgrade --user
aws iam create-service-linked-role --aws-service-name lex.amazonaws.com
rm labmonitorassistant-Lex.zip
zip labmonitorassistant-Lex.zip SumerianConciergeConversation_Export.json
aws lex-models start-import --payload fileb://./labmonitorassistant-Lex.zip --resource-type BOT --merge-strategy OVERWRITE_LATEST --region $region
aws cloudformation create-stack --stack-name labmonitorassistant --template-body file://SumerianConciergeExperience-CloudFormationTemplate.yml --capabilities CAPABILITY_IAM --region $region
aws cloudformation wait stack-create-complete --stack-name labmonitorassistant --region $region
aws lex-models put-bot-alias --name Prod --bot-name labmonitorassistant --bot-version "\$LATEST" --region $region
sleep 10
lex_checksum=$(aws lex-models get-bot --name labmonitorassistant --version-or-alias "\$LATEST" --query 'checksum' --output text --region $region)
cp SumerianConciergeConversation.json SumerianConciergeConversation_original.json
sed -i "s/###checksum###/$lex_checksum/g" SumerianConciergeConversation.json
aws lex-models put-bot --name labmonitorassistant --cli-input-json file://SumerianConciergeConversation.json --region $region
S3Bucket=$(aws cloudformation describe-stacks --stack-name labmonitorassistant --query 'Stacks[0].Outputs[?OutputKey==`S3Bucket`].OutputValue' --output text --region $region)
wget -P aws-resources/images/ https://raw.githubusercontent.com/inspirit/jsfeat/master/cascades/frontalface.js 
wget -P aws-resources/images/ https://raw.githubusercontent.com/inspirit/jsfeat/master/build/jsfeat-min.js 
aws s3 sync aws-resources/images/ s3://$S3Bucket
rm SumerianConciergeConversation.json
mv SumerianConciergeConversation_original.json SumerianConciergeConversation.json
rm labmonitorassistant-Lex.zip
rm -rf aws-resources/
