#!/bin/bash

# Cloudflare Pages Custom Domain Setup Script
# This script adds latinenglishbible.com to the Pages project and configures DNS

set -e

# Configuration
ACCOUNT_ID="8ee4d2ac81da038bec97f4bdb831be92"
PROJECT_NAME="latinenglishbible"
CUSTOM_DOMAIN="latinenglishbible.com"
PAGES_DOMAIN="latinenglishbible.pages.dev"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "Cloudflare Pages Custom Domain Setup"
echo "=================================================="
echo ""
echo "Project: $PROJECT_NAME"
echo "Custom Domain: $CUSTOM_DOMAIN"
echo "Pages Domain: $PAGES_DOMAIN"
echo ""

# Check if CLOUDFLARE_API_TOKEN is set
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}Error: CLOUDFLARE_API_TOKEN environment variable is not set${NC}"
    echo ""
    echo "Please create an API token with the following permissions:"
    echo "  - Account | Cloudflare Pages | Edit"
    echo "  - Zone | DNS | Edit"
    echo ""
    echo "Create token at: https://dash.cloudflare.com/profile/api-tokens"
    echo ""
    echo "Then run:"
    echo "  export CLOUDFLARE_API_TOKEN='your_token_here'"
    echo "  ./setup_custom_domain.sh"
    exit 1
fi

echo -e "${YELLOW}Step 1: Getting Zone ID for $CUSTOM_DOMAIN${NC}"
echo "=========================================="

# Get the zone ID for the domain
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${CUSTOM_DOMAIN}" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

# Check if the API call was successful
SUCCESS=$(echo "$ZONE_RESPONSE" | jq -r '.success')
if [ "$SUCCESS" != "true" ]; then
    echo -e "${RED}Error: Failed to fetch zone information${NC}"
    echo "$ZONE_RESPONSE" | jq -r '.errors'
    exit 1
fi

# Extract zone ID
ZONE_ID=$(echo "$ZONE_RESPONSE" | jq -r '.result[0].id // empty')

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}Error: Domain $CUSTOM_DOMAIN not found in your Cloudflare account${NC}"
    echo ""
    echo "Please add the domain to Cloudflare first:"
    echo "  1. Go to https://dash.cloudflare.com"
    echo "  2. Click 'Add a Site'"
    echo "  3. Enter $CUSTOM_DOMAIN"
    echo "  4. Follow the setup wizard"
    echo ""
    echo "After adding the domain, run this script again."
    exit 1
fi

echo -e "${GREEN}✓ Found Zone ID: $ZONE_ID${NC}"
echo ""

echo -e "${YELLOW}Step 2: Adding custom domain to Pages project${NC}"
echo "=========================================="

# Add custom domain to Pages project
DOMAIN_RESPONSE=$(curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT_NAME}/domains" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${CUSTOM_DOMAIN}\"}")

# Check if the API call was successful
SUCCESS=$(echo "$DOMAIN_RESPONSE" | jq -r '.success')
if [ "$SUCCESS" != "true" ]; then
    # Check if domain already exists
    ERROR_MESSAGE=$(echo "$DOMAIN_RESPONSE" | jq -r '.errors[0].message')
    if [[ "$ERROR_MESSAGE" == *"already exists"* ]]; then
        echo -e "${YELLOW}⚠ Domain already added to Pages project${NC}"
    else
        echo -e "${RED}Error: Failed to add domain to Pages project${NC}"
        echo "$DOMAIN_RESPONSE" | jq -r '.errors'
        exit 1
    fi
else
    echo -e "${GREEN}✓ Custom domain added to Pages project${NC}"
fi
echo ""

echo -e "${YELLOW}Step 3: Creating DNS CNAME record${NC}"
echo "=========================================="

# Check if CNAME already exists
EXISTING_RECORDS=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=CNAME&name=${CUSTOM_DOMAIN}" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

RECORD_COUNT=$(echo "$EXISTING_RECORDS" | jq -r '.result | length')

if [ "$RECORD_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠ CNAME record already exists${NC}"
    echo "$EXISTING_RECORDS" | jq -r '.result[] | "  Name: \(.name)\n  Content: \(.content)\n  Proxied: \(.proxied)"'

    # Update existing record
    RECORD_ID=$(echo "$EXISTING_RECORDS" | jq -r '.result[0].id')

    DNS_RESPONSE=$(curl -s -X PUT \
      "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"type\": \"CNAME\",
        \"name\": \"${CUSTOM_DOMAIN}\",
        \"content\": \"${PAGES_DOMAIN}\",
        \"ttl\": 1,
        \"proxied\": true
      }")

    SUCCESS=$(echo "$DNS_RESPONSE" | jq -r '.success')
    if [ "$SUCCESS" != "true" ]; then
        echo -e "${RED}Error: Failed to update DNS record${NC}"
        echo "$DNS_RESPONSE" | jq -r '.errors'
        exit 1
    fi
    echo -e "${GREEN}✓ DNS CNAME record updated${NC}"
else
    # Create new CNAME record
    DNS_RESPONSE=$(curl -s -X POST \
      "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"type\": \"CNAME\",
        \"name\": \"${CUSTOM_DOMAIN}\",
        \"content\": \"${PAGES_DOMAIN}\",
        \"ttl\": 1,
        \"proxied\": true
      }")

    SUCCESS=$(echo "$DNS_RESPONSE" | jq -r '.success')
    if [ "$SUCCESS" != "true" ]; then
        echo -e "${RED}Error: Failed to create DNS record${NC}"
        echo "$DNS_RESPONSE" | jq -r '.errors'
        exit 1
    fi
    echo -e "${GREEN}✓ DNS CNAME record created${NC}"
fi
echo ""

echo -e "${YELLOW}Step 4: Verifying domain configuration${NC}"
echo "=========================================="

# Check Pages project domains
PROJECT_RESPONSE=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT_NAME}" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

DOMAINS=$(echo "$PROJECT_RESPONSE" | jq -r '.result.domains[]')

echo "Current domains for project:"
echo "$DOMAINS"
echo ""

echo -e "${GREEN}=================================================="
echo "✓ Setup Complete!"
echo "==================================================${NC}"
echo ""
echo "Your custom domain is now configured:"
echo "  • Custom Domain: https://$CUSTOM_DOMAIN"
echo "  • Pages Domain: https://$PAGES_DOMAIN"
echo ""
echo "Note: It may take a few minutes for DNS changes to propagate."
echo "You can verify the setup at:"
echo "  https://dash.cloudflare.com/$ACCOUNT_ID/pages/view/$PROJECT_NAME/domains"
echo ""
