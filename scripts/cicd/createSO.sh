
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
echo "Your scratch org building. Please wait, it could take up to few minutes"
sfdx force:org:create -f config/project-scratch-def.json -a ${ORG_NAME} --json

if [ "$?" = "1" ] 
then
	echo "Scratch org was not created."
	exit 1
fi
echo "Your Scratch org is created."

#deploying metadata:
echo "Metadata deploy started"
sfdx force:source:push -u ${ORG_NAME}

if [ "$?" = "1" ]
then 
	echo "Metadata was not deployed"
	exit 1
fi

echo "Metadata was deployed succesfully."

sfdx force:user:permset:assign -n ${Exchange_Rates_App_User} -u ${ORG_NAME} --json
if [ "$?" = "1" ]
then
	echo "Permission sets were not assigned."
	exit 1
fi	

echo "Permission sets were assigned successfully."

sfdx force:org:open -u ${ORG_NAME}