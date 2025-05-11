#!/bin/bash

set -o errexit -o nounset -o pipefail ${RUNNER_DEBUG:+-x}

check_command() {
  if ! [[ -x "$(command -v "$1")" ]]; then
    echo "Error: '$1' tool required - $2"
    exit 2
  fi
}

check_command "gh" "https://cli.github.com/"

# https://github.com/mislav/hub/issues/2923#issuecomment-1062045270
github_username="${GITHUB_REPOSITORY_OWNER:-$(gh api user --jq '.login')}"

repo_names=$(gh repo list --fork --limit 9999 --json name --jq '.[].name' "${github_username}")

while read -r repo_name; do {
  echo "Looking at ${repo_name}..."
  gh repo sync "${github_username}/${repo_name}"
} &
done <<< "${repo_names}"

wait
