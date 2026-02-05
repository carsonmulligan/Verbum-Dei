#!/bin/bash

# Quick check to see if domain is already configured
# This uses wrangler's OAuth token indirectly through API calls

ACCOUNT_ID="8ee4d2ac81da038bec97f4bdb831be92"
PROJECT_NAME="latinenglishbible"
CUSTOM_DOMAIN="latinenglishbible.com"

echo "======================================"
echo "Domain Status Check"
echo "======================================"
echo ""

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "⚠️  No CLOUDFLARE_API_TOKEN found in environment"
    echo ""
    echo "To check via API, create a token at:"
    echo "https://dash.cloudflare.com/profile/api-tokens"
    echo ""
    echo "Then run:"
    echo "  export CLOUDFLARE_API_TOKEN='your_token_here'"
    echo "  ./check_domain_status.sh"
    echo ""
    echo "Or check manually at:"
    echo "https://dash.cloudflare.com/$ACCOUNT_ID/pages/view/$PROJECT_NAME/domains"
    exit 0
fi

echo "Checking Pages project domains..."
echo ""

RESPONSE=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT_NAME}" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

SUCCESS=$(echo "$RESPONSE" | jq -r '.success')

if [ "$SUCCESS" != "true" ]; then
    echo "❌ Error fetching project information"
    echo "$RESPONSE" | jq -r '.errors'
    exit 1
fi

echo "Current domains for $PROJECT_NAME:"
echo ""

DOMAINS=$(echo "$RESPONSE" | jq -r '.result.domains[]' 2>/dev/null)

if [ -z "$DOMAINS" ]; then
    echo "  • latinenglishbible.pages.dev (default)"
    echo ""
    echo "❌ Custom domain $CUSTOM_DOMAIN is NOT configured"
else
    echo "$DOMAINS" | while read -r domain; do
        if [ "$domain" = "$CUSTOM_DOMAIN" ]; then
            echo "  • $domain ✅ (custom domain is configured!)"
        else
            echo "  • $domain"
        fi
    done
    echo ""

    if echo "$DOMAINS" | grep -q "$CUSTOM_DOMAIN"; then
        echo "✅ Custom domain $CUSTOM_DOMAIN is configured!"
        echo ""
        echo "Check DNS propagation:"
        echo "  dig $CUSTOM_DOMAIN"
        echo "  curl -I https://$CUSTOM_DOMAIN"
    else
        echo "❌ Custom domain $CUSTOM_DOMAIN is NOT configured"
    fi
fi

echo ""
echo "Dashboard URL:"
echo "https://dash.cloudflare.com/$ACCOUNT_ID/pages/view/$PROJECT_NAME/domains"
