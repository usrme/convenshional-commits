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

function show_current_character_limit() {
  # $1 - overall character limit
  # $2 - the string whose length should be deducted
  #      from the overall character limit

  local character_limit="$1"
  local deducted_string="$2"

  deducted_string_length="${#deducted_string}"
  column_length=$((character_limit-deducted_string_length))

  # Deduct an additional 4 characters to account for
  # padding used in actual output
  #
  # 4 because 2 is for the input line and the other 2
  # is for this line's own padding
  printf "%$((column_length-4))s \
    $(echo -e "${ORANGE}* <- type until here (${column_length} left)${NOFORMAT}")" "" | \
    tr " " " "
  echo ""
}

function set_default_choices() {
  CHOICES[fix]="Bug fix. Correlates with PATCH in SemVer"; CHOICE_ORDERS+=("fix")
  CHOICES[feat]="New feature. Correlates with MINOR in SemVer"; CHOICE_ORDERS+=("feat")
  CHOICES[docs]="Changes to documentation or code comments"; CHOICE_ORDERS+=("docs")
  CHOICES[style]="Changes that do not affect the meaning of the code (e.g. formatting)"; CHOICE_ORDERS+=("style")
  CHOICES[refactor]="Changes that neither fix a bug nor add a feature"; CHOICE_ORDERS+=("refactor")
  CHOICES[perf]="Changes that improve performance"; CHOICE_ORDERS+=("perf")
  CHOICES[test]="Changes that add missing or corrects existing tests"; CHOICE_ORDERS+=("test")
  CHOICES[build]="Changes to the build system or external dependencies"; CHOICE_ORDERS+=("build")
  CHOICES[ci]="Changes to CI/CD configuration files or scripts"; CHOICE_ORDERS+=("ci")
}

if [[ $(git diff --no-ext-diff --cached --name-only) == "" ]]; then
  echo "Error: no files added to staging"
  exit 1
fi

CONFIG_DIR="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
CONFIG_FILE="${CONFIG_DIR}/$(basename "${BASH_SOURCE[0]%%.*}").conf"

declare -A CHOICES
declare -a CHOICE_ORDERS

# This number indicates the number of characters that have
# to be deducted from the overall limit no matter what as
# they are used for formatting
deducted_characters="(): "
deducted_character_count="${#deducted_characters}"
found_custom_character_limit="false"

if [[ -e "$CONFIG_FILE" ]]; then
  lines_in_conf_file=0
  while IFS=': ' read -r key value; do
    ((lines_in_conf_file=lines_in_conf_file+1))
    # Use 'total_input_char_limit' as a reserved key
    # for configuring character count limit
    #
    # Using more awkward wording with 'total' at the front
    # to make it clear it is a prefix that can be expanded
    # to other types of limits in the future
    #
    # This also somewhat mirrors the configuration option
    # available to be set in Comet Alt
    if [[ "$key" == "total_input_char_limit" ]]; then
      found_custom_character_limit="true"
      character_limit="$value"
      continue
    fi

    # Associative arrays do not keep ordering based on insertion, but on hash,
    # so keep a separate regular array that keeps insertion order and use that
    # later on for proper ordering
    CHOICES["$key"]="$value"; CHOICE_ORDERS+=("$key")
  done < "$CONFIG_FILE"
else
  # If no configuration file was found
  set_default_choices
fi

if [[ "$found_custom_character_limit" == "true" && "$lines_in_conf_file" -eq 1 ]]; then
  # If only total input character limit was set in configuration file
  set_default_choices
fi

if [[ "$found_custom_character_limit" == "false" ]]; then
  character_limit=80
fi

clear_count=2
if [[ "$character_limit" -gt 0 ]]; then
  clear_count=3
fi

((character_limit=character_limit-deducted_character_count))

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
echo -e "  ${scope_question}"
if [[ "$character_limit" -gt 0 ]]; then
  show_current_character_limit "$character_limit" "$choice_type"
fi
read -r -p "  " scope
clear_lines "$clear_count"
echo -e "  ${scope_question} ${GREEN}${scope}${NOFORMAT}"

#-----------------------------------------------------------------------------
# Prompt for commit message
#-----------------------------------------------------------------------------
echo "  ${message_question}"
if [[ "$character_limit" -gt 0 ]]; then
  # The characters we need to deduct now include the type of choice
  # made at the start and the scope that was input
  show_current_character_limit "$character_limit" "${choice_type}${scope}"
fi
read -r -p "  " message
clear_lines "$clear_count"
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
