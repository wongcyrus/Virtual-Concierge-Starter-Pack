wget https://s3-us-west-2.amazonaws.com/sumerian-concierge-aws-resources/aws-resources.zip
unzip aws-resources.zip
rm -rf __MACOSX/
pip install awscli --upgrade --user
aws iam create-service-linked-role --aws-service-name lex.amazonaws.com
aws lex-models start-import --payload fileb://./aws-resources/resources/lex/SumerianConciergeConversation-Lex.zip --resource-type BOT --merge-strategy OVERWRITE_LATEST
sleep 10
aws lex-models put-bot-alias --name Prod --bot-name SumerianConciergeConversation --bot-version "\$LATEST"
lex_checksum=$(aws lex-models get-bot --name SumerianConciergeConversation --version-or-alias "\$LATEST" --query 'checksum' --output text)
sed -i "s/###checksum###/$lex_checksum/g" SumerianConciergeConversation.json
aws lex-models put-bot --name SumerianConciergeConversation --cli-input-json file://SumerianConciergeConversation.json
aws cloudformation create-stack --stack-name sumerianconcierge --template-body file://SumerianConciergeExperience-CloudFormationTemplate.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name sumerianconcierge
S3Bucket=$(aws cloudformation describe-stacks --stack-name sumerianconcierge --query 'Stacks[0].Outputs[?OutputKey==`S3Bucket`].OutputValue' --output text)
wget -P aws-resources/images/ https://raw.githubusercontent.com/inspirit/jsfeat/master/cascades/frontalface.js 
wget -P aws-resources/images/ https://raw.githubusercontent.com/inspirit/jsfeat/master/build/jsfeat-min.js 
aws s3 sync aws-resources/images/ s3://$S3Bucket