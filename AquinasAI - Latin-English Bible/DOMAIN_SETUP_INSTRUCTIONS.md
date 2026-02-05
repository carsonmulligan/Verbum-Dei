# Custom Domain Setup for latinenglishbible.com

This guide will help you set up the custom domain `latinenglishbible.com` for your Cloudflare Pages project `latinenglishbible`.

## Current Status

- **Pages Project**: `latinenglishbible`
- **Current URL**: https://a09625b3.latinenglishbible.pages.dev
- **Target Domain**: latinenglishbible.com
- **Account ID**: 8ee4d2ac81da038bec97f4bdb831be92

---

## Option 1: Automated Setup (Recommended)

### Prerequisites

1. **Add the domain to Cloudflare** (if not already added):
   - Go to https://dash.cloudflare.com
   - Click "Add a Site"
   - Enter `latinenglishbible.com`
   - Follow the setup wizard
   - Update your domain's nameservers at your registrar to point to Cloudflare

2. **Create a Cloudflare API Token**:
   - Go to https://dash.cloudflare.com/profile/api-tokens
   - Click "Create Token"
   - Use "Create Custom Token" with these permissions:
     - **Account** | Cloudflare Pages | **Edit**
     - **Zone** | DNS | **Edit**
     - **Zone** | Zone | **Read**
   - Set Account Resources: Include | Your Account
   - Set Zone Resources: Include | Specific zone | `latinenglishbible.com`
   - Click "Continue to summary" → "Create Token"
   - **Copy the token** (you'll only see it once!)

### Running the Script

```bash
# Set your API token as an environment variable
export CLOUDFLARE_API_TOKEN='your_token_here'

# Run the setup script
./setup_custom_domain.sh
```

The script will:
1. ✓ Get the Zone ID for latinenglishbible.com
2. ✓ Add the custom domain to your Pages project
3. ✓ Create a proxied CNAME record pointing to latinenglishbible.pages.dev
4. ✓ Verify the configuration

---

## Option 2: Manual Setup via Cloudflare Dashboard

### Step 1: Add the domain to Cloudflare (if needed)

1. Go to https://dash.cloudflare.com
2. Click "Add a Site"
3. Enter `latinenglishbible.com`
4. Follow the wizard and update nameservers at your registrar

### Step 2: Add Custom Domain to Pages Project

1. Go to https://dash.cloudflare.com/8ee4d2ac81da038bec97f4bdb831be92/pages
2. Click on the `latinenglishbible` project
3. Go to "Custom domains" tab
4. Click "Set up a domain"
5. Enter `latinenglishbible.com`
6. Click "Continue"
7. Cloudflare will automatically create the CNAME record for you

### Step 3: Verify Setup

1. Check the "Custom domains" tab shows `latinenglishbible.com` as "Active"
2. Visit https://latinenglishbible.com to verify it works
3. SSL certificate should be provisioned automatically (may take a few minutes)

---

## Option 3: Manual Setup via API

### Prerequisites

- Create an API token (see Option 1 above)
- Install `jq` for JSON parsing: `brew install jq`

### Step 1: Get Zone ID

```bash
export CLOUDFLARE_API_TOKEN='your_token_here'

curl -X GET "https://api.cloudflare.com/client/v4/zones?name=latinenglishbible.com" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```

Save the Zone ID output.

### Step 2: Add Domain to Pages Project

```bash
curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/8ee4d2ac81da038bec97f4bdb831be92/pages/projects/latinenglishbible/domains" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "latinenglishbible.com"}'
```

### Step 3: Create DNS CNAME Record

Replace `YOUR_ZONE_ID` with the Zone ID from Step 1:

```bash
curl -X POST \
  "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "name": "latinenglishbible.com",
    "content": "latinenglishbible.pages.dev",
    "ttl": 1,
    "proxied": true
  }'
```

### Step 4: Verify Configuration

```bash
# Check Pages project domains
curl -X GET \
  "https://api.cloudflare.com/client/v4/accounts/8ee4d2ac81da038bec97f4bdb831be92/pages/projects/latinenglishbible" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result.domains'

# Check DNS records
curl -X GET \
  "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records?type=CNAME&name=latinenglishbible.com" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq
```

---

## Adding www Subdomain (Optional)

To also support `www.latinenglishbible.com`:

### Via Dashboard
1. In the Pages project → Custom domains
2. Click "Set up a domain"
3. Enter `www.latinenglishbible.com`

### Via API
```bash
# Add www to Pages project
curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/8ee4d2ac81da038bec97f4bdb831be92/pages/projects/latinenglishbible/domains" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "www.latinenglishbible.com"}'

# Create www CNAME record
curl -X POST \
  "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "name": "www.latinenglishbible.com",
    "content": "latinenglishbible.pages.dev",
    "ttl": 1,
    "proxied": true
  }'
```

---

## Troubleshooting

### Domain not found in Cloudflare
- Ensure you've added the domain to Cloudflare first
- Check that nameservers are updated at your registrar
- Wait for nameserver propagation (can take 24-48 hours)

### SSL Certificate Issues
- Cloudflare automatically provisions SSL certificates
- This can take 10-15 minutes after adding the domain
- Check status in Pages → Custom domains tab

### DNS Propagation
- DNS changes can take a few minutes to propagate globally
- Use `dig latinenglishbible.com` to check DNS records
- Use https://www.whatsmydns.net to check global propagation

### API Errors
- Ensure your API token has the correct permissions
- Check that the token hasn't expired
- Verify the Account ID and Project Name are correct

---

## Verification Checklist

- [ ] Domain added to Cloudflare account
- [ ] Nameservers updated at registrar (if needed)
- [ ] Custom domain added to Pages project
- [ ] CNAME record created and proxied
- [ ] SSL certificate provisioned (Active status)
- [ ] Website accessible at https://latinenglishbible.com
- [ ] Optional: www subdomain configured

---

## Resources

- [Cloudflare Pages Custom Domains Documentation](https://developers.cloudflare.com/pages/configuration/custom-domains/)
- [Cloudflare API Documentation - Pages Domains](https://developers.cloudflare.com/api/resources/pages/subresources/projects/subresources/domains/methods/create/)
- [Cloudflare API Documentation - DNS Records](https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/)
- [Create API Tokens](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

---

## Support

If you encounter issues:
1. Check the Cloudflare dashboard for error messages
2. Review the API response errors
3. Visit the Cloudflare Community: https://community.cloudflare.com
4. Contact Cloudflare Support if needed
