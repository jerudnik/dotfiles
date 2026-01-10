#!/bin/bash
# ~/bin/sync-secrets.sh

# Color codes for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration: Map Bitwarden sources to Keychain service names and env vars
# Format: "folder:note_name:field_name:keychain_service:env_var_name"
declare -a SECRETS=(
    # API Keys note
    "secrets:API Keys:exa:exa-api-key:EXA_API_KEY"
    "secrets:API Keys:context7:context7-api-key:CONTEXT7_API_KEY"
    "secrets:API Keys:anthropic:anthropic-api-key:ANTHROPIC_API_KEY"
    "secrets:API Keys:openAI:openai-api-key:OPENAI_API_KEY"
    "secrets:API Keys:github_token:github-token:GITHUB_TOKEN"
    "secrets:API Keys:opencode_zen:opencode-zen-key:OPENCODE_ZEN_KEY"
    "secrets:API Keys:togetherAI:togetherai-api-key:TOGETHERAI_API_KEY"
    "secrets:API Keys:openRouter:openrouter-api-key:OPENROUTER_API_KEY"
    "secrets:API Keys:googleAI:googleai-api-key:GOOGLEAI_API_KEY"
    "secrets:API Keys:handwritingOCR:handwriting-ocr-key:HANDWRITING_OCR_KEY"
    "secrets:API Keys:braveSearch:brave-search-key:BRAVE_SEARCH_KEY"

    # Obsidian Keys note
    "secrets:Obsidian Keys:just-testing:obsidian-test-key:OBSIDIAN_TEST_KEY"
)

# Check if script is being sourced (for environment export)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    SOURCED=true
else
    SOURCED=false
fi

# Ensure Bitwarden is unlocked
echo -e "${BLUE}Checking Bitwarden status...${NC}"
if ! bw status | jq -e '.status == "unlocked"' > /dev/null 2>&1; then
    echo -e "${RED}❌ Bitwarden is locked. Please unlock it first:${NC}"
    echo "   bw unlock --raw | pbcopy"
    echo "   export BW_SESSION=\$(pbpaste)"
    if [ "$SOURCED" = true ]; then
        return 1
    else
        exit 1
    fi
fi

echo -e "${GREEN}✓ Bitwarden is unlocked${NC}\n"

# Cache for note items to avoid repeated queries
declare -A NOTE_CACHE

# Function to fetch and cache a note
fetch_note() {
    local folder="$1"
    local note_name="$2"
    local cache_key="${folder}:${note_name}"

    # Return from cache if already fetched
    if [[ -n "${NOTE_CACHE[$cache_key]}" ]]; then
        echo "${NOTE_CACHE[$cache_key]}"
        return 0
    fi

    # Search for the note in the specified folder
    local note_data
    note_data=$(bw list items --folderid "$(bw get folder "$folder" | jq -r '.id')" 2>/dev/null | \
                jq --arg name "$note_name" '.[] | select(.name == $name and .type == 2)' 2>/dev/null)

    if [ -z "$note_data" ]; then
        return 1
    fi

    # Cache it
    NOTE_CACHE[$cache_key]="$note_data"
    echo "$note_data"
    return 0
}

# Process each secret
success_count=0
fail_count=0

for secret_config in "${SECRETS[@]}"; do
    IFS=':' read -r folder note_name field_name keychain_service env_var <<< "$secret_config"

    echo -e "${YELLOW}Processing ${env_var}...${NC}"
    echo -e "  ${BLUE}Source: ${folder}/${note_name} → ${field_name}${NC}"

    # Fetch the note (with caching)
    note_data=$(fetch_note "$folder" "$note_name")

    if [ -z "$note_data" ]; then
        echo -e "${RED}  ❌ Could not find note '$note_name' in folder '$folder'${NC}\n"
        ((fail_count++))
        continue
    fi

    # Extract the field value
    SECRET_VALUE=$(echo "$note_data" | jq -r --arg field "$field_name" \
                   '.fields[]? | select(.name == $field) | .value // empty')

    if [ -z "$SECRET_VALUE" ]; then
        echo -e "${RED}  ❌ Field '$field_name' not found in note${NC}\n"
        ((fail_count++))
        continue
    fi

    # Store in macOS Keychain
    if security add-generic-password -U -s "$keychain_service" -a "$USER" -w "$SECRET_VALUE" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Stored in Keychain as '$keychain_service'${NC}"
    else
        echo -e "${RED}  ❌ Failed to store in Keychain${NC}\n"
        ((fail_count++))
        continue
    fi

    # Export to environment if sourced
    if [ "$SOURCED" = true ]; then
        export "$env_var"="$SECRET_VALUE"
        echo -e "${GREEN}  ✓ Exported to \$$env_var${NC}"
    fi

    ((success_count++))
    echo
done

# Summary
echo -e "${BLUE}═══════════════════════════════════════${NC}"
if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}🎉 All ${success_count} secrets synced successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  ${success_count} succeeded, ${fail_count} failed${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

if [ "$SOURCED" = false ]; then
    echo -e "${YELLOW}💡 Tip: To also export to your current shell, run:${NC}"
    echo "   ${BLUE}load-secrets${NC}"
fi
