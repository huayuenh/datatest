#!/usr/bin/env bash
###############################################################################
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2021. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
###############################################################################
set -eo pipefail

function main {
    local swaggerFile=$1
    local definitionsFile=$2

    if [ ! -f "${swaggerFile}" ]; then
        echo "Swagger file ${swaggerFile} not found"
        return 1
    fi

    if  [[ "${swaggerFile}" == *.yml ]] || [[ "${swaggerFile}" == *.yaml ]]; then
        # convert to json first
        local tempFile="${swaggerFile}.json"
        yq read "${swaggerFile}" --tojson > "${tempFile}"
        swaggerFile="${tempFile}"
    fi

    jq '{excludeScanTypes: [], apisToScan: [.paths | to_entries[] | {path: .key, method: (.value | keys[])}], apiDefinitionJson: .}' ${swaggerFile} > ${definitionsFile}

    if [ "${tempFile}" ]; then
        # clean up temp json file
        rm "$tempFile"
    fi
}

main "$@"
