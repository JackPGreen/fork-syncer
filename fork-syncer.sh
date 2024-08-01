#!/bin/bash

set -o errexit -o nounset -o pipefail

check_command() {
  if ! [[ -x "$(command -v "$1")" ]]; then
    echo "Error: '$1' tool required - $2"
    exit 2
  fi
}

check_command "gh" "https://cli.github.com/"

# https://github.com/mislav/hub/issues/2923#issuecomment-1062045270
github_username=$(gh api user --jq '.login')

repos=$(gh repo list --fork --limit 9999 --json name --jq '.[]' "${github_username}")

while read -r repo_data; do
  repo_name=$(echo "${repo_data}" | jq -r '.name')
  echo "Looking at ${repo_name}..."
  gh repo sync "${github_username}/${repo_name}"
done <<< "${repos}"
