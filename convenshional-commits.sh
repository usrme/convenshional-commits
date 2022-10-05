#!/usr/bin/env bash
#
# A conventional commit helper using just Bash.

set -Eeuo pipefail

# shellcheck disable=SC2034
function setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    ORANGE='\033[0;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
  else
    NOFORMAT=''
    RED=''
    GREEN=''
    ORANGE=''
    BLUE=''
    PURPLE=''
    CYAN=''
    YELLOW=''
  fi
}

function clear_lines() {
  # $1 - number of lines to clear
  #      defaults to 1, meaning the previous

  local line_count
  line_count="${1:-1}"

  if [[ "$line_count" == 1 ]]; then
    tput cuu1
    tput el
    return 0
  fi

  for _ in $(seq "$line_count"); do
    tput cuu1
    tput el
  done

  return 0
}

if [[ $(git diff --no-ext-diff --cached --name-only) == "" ]]; then
  echo "Error: no files added to staging"
  exit 1
fi

declare -A CHOICES
declare -a CHOICE_ORDERS

# Associative arrays do not keep ordering based on insertion, but on hash,
# so keep a separate regular array that keeps insertion order and use that
# later on for proper ordering
# TODO: Read from file in 'XDG_HOME' for configurability
CHOICES[fix]="Bug fix. Correlates with PATCH in SemVer"; CHOICE_ORDERS+=("fix")
CHOICES[feat]="New feature. Correlates with MINOR in SemVer"; CHOICE_ORDERS+=("feat")
CHOICES[docs]="Changes to documentation or code comments"; CHOICE_ORDERS+=("docs")
CHOICES[style]="Changes that do not affect the meaning of the code (e.g. formatting)"; CHOICE_ORDERS+=("style")
CHOICES[refactor]="Changes that neither fix a bug nor add a feature"; CHOICE_ORDERS+=("refactor")
CHOICES[perf]="Changes that improve performance"; CHOICE_ORDERS+=("perf")
CHOICES[test]="Changes that add missing or corrects existing tests"; CHOICE_ORDERS+=("test")
CHOICES[build]="Changes to the build system or external dependencies"; CHOICE_ORDERS+=("build")
CHOICES[ci]="Changes to CI/CD configuration files or scripts"; CHOICE_ORDERS+=("ci")

commit_question="What are you committing?"
scope_question="What is the scope? (optional)"
message_question="What is the commit message?"
body_question="Do you need to specify a body/footer? (y/N)"

# Total lines to be cleared later: 2
echo -e "\n    ${commit_question}\n"
setup_colors

#-----------------------------------------------------------------------------
# List all choices
#-----------------------------------------------------------------------------
index=0
for choice in "${CHOICE_ORDERS[@]}"; do
  ((index=index+1))
  printf '    %02d. %-12s %s\n' "$index" "$choice" "${CHOICES[$choice]}"
done

# Total lines to be cleared later: 4
echo ""
read -r -p "    Choose commit type with a number: " input

if [[ "$input" -lt 1 || "$input" -gt "$index" ]]; then
  echo "Choice '${input}' does fall within valid range 1-${index}"
  exit 1
fi

#-----------------------------------------------------------------------------
# Clear lines up until a certain amount
#-----------------------------------------------------------------------------
clear_lines $((index+4))

choice_type="${CHOICE_ORDERS[$input-1]}"
choice_desc="${CHOICES[$choice_type]}"
echo -e "  ${commit_question} ${GREEN}${choice_type}: ${choice_desc}${NOFORMAT}"

#-----------------------------------------------------------------------------
# Prompt for scope
#-----------------------------------------------------------------------------
read -r -p "  ${scope_question} " scope
clear_lines 1
echo -e "  ${scope_question} ${GREEN}${scope}${NOFORMAT}"

#-----------------------------------------------------------------------------
# Prompt for commit message
#-----------------------------------------------------------------------------
read -r -p "  ${message_question} " message
clear_lines 1
echo -e "  ${message_question} ${GREEN}${message}${NOFORMAT}"

#-----------------------------------------------------------------------------
# Prompt for whether to include commit body
#-----------------------------------------------------------------------------
read -r -p "  ${body_question} " body

if [[ "$body" == "" ]]; then
  body="N"
fi

if [[ "$body" != [yN] ]]; then
  echo "Input '${body}' wasn't 'y' or 'N'"
  exit 1
fi

clear_lines 1
echo -e "  ${body_question} ${GREEN}${body}${NOFORMAT}"

if [[ "$scope" == "" ]]; then
  message="${choice_type}: ${message}"
else
  message="${choice_type}(${scope}): ${message}"
fi

#-----------------------------------------------------------------------------
# Start committing
#-----------------------------------------------------------------------------
if [[ "$body" == "y" ]]; then
  args=("-m" "$message" "--edit")
else
  args=("-m" "$message")
fi

echo -e "\n  ---\n"
git commit "${args[@]}" "$@"