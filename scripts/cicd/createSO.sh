
#get org name parameter flag value
while getopts ":n:" opt; do
  case $opt in
    n)
      ORG_NAME=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

#if scratch org name was not provided, exit from script and notify the user 
if [ ! -n "$ORG_NAME"  ] 
then
  echo "Please use flag -n to pass Scratch Org name. Scratch org was not created"
  exit 1 
fi

#creating Scratch org
echo "Your scratch org is building. Please wait, it could take up to few minutes"
sfdx force:org:create -f config/project-scratch-def.json -a ${ORG_NAME} --json

if [ "$?" = "1" ] 
then
	echo "Scratch org was not created."
	exit 1
fi
echo "Your Scratch org is created."

#import chatter group
RES=$(sfdx force:data:tree:import --json -f scripts/cicd/CollaborationGroup.json -u ${ORG_NAME})

#assign group id to variable
GROUPID=$(echo ${RES} | grep -o '"[^"]*"\s*:\s*"[^"]*"' | grep -E '^"(id)"' | cut -b 8-25)
echo ${GROUPID}

#make backup copy of original Trade Insert process builder, we need to do that in order to change Id on the pb
mkdir -p temp
cp force-app/main/default/flows/Trade_Insert.flow-meta.xml temp

#replace original Id of the group to new group created on scratch org
sed -i "s/0F93X000000ghqLSAQ/${GROUPID}/" force-app/main/default/flows/Trade_Insert.flow-meta.xml
sed -i "s/0F93X000000ghqLSAQ/${GROUPID}/" force-app/main/default/flows/Trade_Insert.flow-meta.xml

#deploying metadata:
echo "Metadata deploy started"
sfdx force:source:push -u ${ORG_NAME}

if [ "$?" = "1" ]
then 
	echo "Metadata was not deployed"
	exit 1
fi

echo "Metadata was deployed succesfully."

#bring back original process builder
rm force-app/main/default/flows/Trade_Insert.flow-meta.xml
cp temp/Trade_Insert.flow-meta.xml force-app/main/default/flows
rm -rf temp

sfdx force:user:permset:assign -n Exchange_Rates_App_User -u ${ORG_NAME} --json
if [ "$?" = "1" ]
then
	echo "Permission sets were not assigned."
	exit 1
fi	

echo "Permission sets were assigned successfully."

sfdx force:org:open -u ${ORG_NAME} -p lightning/app/c__Exchange_Rates/
