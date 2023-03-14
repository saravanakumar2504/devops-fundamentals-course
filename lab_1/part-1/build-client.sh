#!/bin/bash

npm  install
npm run build

if [[ $1 == "production" ]]
then
    export env=$1 
else
     export env=""
fi

echo "Zipped files: "

tar -cv ./dist/app | gzip > ./dist/client-app.zip

echo "Files inside dist folder: "

find ./dist -print0 | while IFS= read -r -d '' file
do 
    echo "$file"
done
