#!/bin/bash

DEPLOYMENT_FILE=./deployment.yaml

ZAP_API_IMAGE="my-image"
DEPLOYMENT_NAME="my-deployment-name"
echo "=========================================================="
echo "UPDATING manifest with image information"
echo -e "Updating ${DEPLOYMENT_FILE} with image name: ${ZAP_API_IMAGE}"
# find the yaml document index for the K8S deployment definition
DEPLOYMENT_DOC_INDEX=$(yq read --doc "*" --tojson "$DEPLOYMENT_FILE" | jq -r 'to_entries | .[] | select(.value.kind | ascii_downcase=="deployment") | .key')
if [ -z "${DEPLOYMENT_DOC_INDEX}" ]; then
  echo "No Kubernetes Deployment definition found in ${DEPLOYMENT_FILE}. Updating YAML document with index 0"
  DEPLOYMENT_DOC_INDEX=0
fi
DEPLOY_FILE="deploy.yml"
yq read --doc $DEPLOYMENT_DOC_INDEX $DEPLOYMENT_FILE > "${DEPLOY_FILE}"

# Update deployment with image name
cp $DEPLOY_FILE "${DEPLOY_FILE}.bak"
cat "${DEPLOY_FILE}.bak" \
  | yq write - "spec.template.spec.containers[0].image" "${ZAP_API_IMAGE}" \
  | yq write - "metadata.name" "${DEPLOYMENT_NAME}" \
  > "${DEPLOY_FILE}"
#rm "${DEPLOY_FILE}.bak"
cat "${DEPLOY_FILE}"
DEPLOYMENT_FILE="${DEPLOY_FILE}" # use modified file
cat "${DEPLOYMENT_FILE}"