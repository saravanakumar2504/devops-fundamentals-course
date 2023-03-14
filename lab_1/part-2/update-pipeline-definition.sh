#!/bin/bash

jsonFilePath='../pipeline.json'
outputFile=pipeline-$(date "+%Y.%m.%d-%H.%M.%S").json;

checkJQ() {
  # jq test
  type jq >/dev/null 2>&1
  exitCode=$?
  jqDependency=null
  if [ "$exitCode" -ne 0 ]; then
    printf "  ${red}'jq' not found! (json parser)\n${end}"
    printf "    Ubuntu Installation: sudo apt install jq\n"
    printf "    Redhat Installation: sudo yum install jq\n"
    jqDependency=0
  else
    if [[ "$DEBUG" -eq 1 ]]; then
      printf "  ${grn}'jq' found!\n${end}"
    fi
  fi

  if [[ "$jqDependency" == 0 ]]; then
    printf "${red}Missing 'jq' dependency, exiting.\n${end}"
    # exit 1
  fi
}

# perform checks:
checkJQ

# The metadata property is removed               The value of the pipeline’s version property is incremented by 1
echo $(cat $jsonFilePath | jq  'del(.metadata)') |  jq  '.pipeline.version=.pipeline.version+1' | jq '.' > $outputFile

declare -A args
while [[ "$#" > "0" ]]; do
  case "$1" in 
    (--*=*)
        key="${1%%=*}" &&  key="${key/--/}" && val="${1#*=}"
        args[${key}]=${val}
       if [[ ${key} == 'branch' ]] 
        then
            jq --arg branchName "$val" '.pipeline.stages[0].actions[0].configuration.Branch = $branchName' "$outputFile" > tmp.$$.json && mv tmp.$$.json "$outputFile"
        elif [[ ${key} == 'owner' ]] 
        then
            jq --arg owner "$val" '.pipeline.stages[0].actions[0].configuration.Owner = $owner' "$outputFile" > tmp.$$.json && mv tmp.$$.json "$outputFile"
        elif [[ ${key} == 'poll-for-source-changes' ]] 
        then
            jq --arg pollForSourceChanges "$val" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pollForSourceChanges' "$outputFile" > tmp.$$.json && mv tmp.$$.json "$outputFile"
        elif [[ ${key} == 'configuration' ]] 
        then
            echo "configuration update is ${val}"
      fi
  esac
  shift
done

echo "args : $args"
for key in "${!args[@]}"; do echo "$key => ${args[$key]}"; done
