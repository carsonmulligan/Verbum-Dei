# Cloudflare Custom Domain Setup

Quick start guide for setting up `latinenglishbible.com` as a custom domain for your Cloudflare Pages project.

## Quick Start (3 Steps)

### 1. Create API Token

Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens) and create a custom token with:

- **Permissions**:
  - Account | Cloudflare Pages | Edit
  - Zone | DNS | Edit
  - Zone | Zone | Read

- **Account Resources**: Include | Your Account
- **Zone Resources**: Include | Specific zone | `latinenglishbible.com`

Copy the token when shown.

### 2. Set Token and Run Setup

```bash
export CLOUDFLARE_API_TOKEN='your_token_here'
./setup_custom_domain.sh
```

### 3. Verify

Visit https://latinenglishbible.com after 1-2 minutes.

---

## Alternative: Manual Dashboard Setup

If you prefer not to use the API:

1. Go to [Cloudflare Pages Dashboard](https://dash.cloudflare.com/8ee4d2ac81da038bec97f4bdb831be92/pages)
2. Click `latinenglishbible` project
3. Go to "Custom domains" tab
4. Click "Set up a domain"
5. Enter `latinenglishbible.com`
6. Cloudflare automatically creates the CNAME record

---

## Check Current Status

Without API token:
```bash
./check_domain_status.sh
```

With API token:
```bash
export CLOUDFLARE_API_TOKEN='your_token'
./check_domain_status.sh
```

Or visit the dashboard:
https://dash.cloudflare.com/8ee4d2ac81da038bec97f4bdb831be92/pages/view/latinenglishbible/domains

---

## Files in This Directory

- **`setup_custom_domain.sh`** - Automated setup script (recommended)
- **`check_domain_status.sh`** - Check if domain is configured
- **`DOMAIN_SETUP_INSTRUCTIONS.md`** - Detailed step-by-step guide with troubleshooting

---

## Prerequisites

Before running the setup:

1. **Domain must be in Cloudflare**: Add `latinenglishbible.com` to your Cloudflare account if not already added
   - Go to https://dash.cloudflare.com
   - Click "Add a Site"
   - Enter domain and follow wizard
   - Update nameservers at your domain registrar

2. **Required tools**: The scripts require `jq` and `curl`
   ```bash
   brew install jq  # If not already installed
   ```

---

## What the Setup Does

The automated setup script will:

1. ✓ Verify the domain exists in your Cloudflare account
2. ✓ Add `latinenglishbible.com` to the Pages project via API
3. ✓ Create a proxied CNAME record: `latinenglishbible.com` → `latinenglishbible.pages.dev`
4. ✓ Verify the configuration
5. ✓ Display current project domains

SSL certificate is automatically provisioned by Cloudflare (takes 1-15 minutes).

---

## Troubleshooting

**"Domain not found in Cloudflare account"**
- Add the domain at https://dash.cloudflare.com first
- Wait for nameserver propagation (can take 24-48 hours)

**"Invalid API token"**
- Ensure token has Pages Edit and DNS Edit permissions
- Token must not be expired
- Check Account and Zone resources are set correctly

**"Domain already exists"**
- This is fine! The script will update the configuration
- Verify at the dashboard link shown in output

**SSL Certificate pending**
- Wait 10-15 minutes for automatic provisioning
- Check status in Pages → Custom domains tab

---

## Support Resources

- [Cloudflare Pages Custom Domains Docs](https://developers.cloudflare.com/pages/configuration/custom-domains/)
- [Cloudflare API - Pages Domains](https://developers.cloudflare.com/api/resources/pages/subresources/projects/subresources/domains/methods/create/)
- [Cloudflare Community](https://community.cloudflare.com)

---

## Project Information

- **Pages Project**: latinenglishbible
- **Account ID**: 8ee4d2ac81da038bec97f4bdb831be92
- **Current Pages URL**: https://a09625b3.latinenglishbible.pages.dev
- **Target Custom Domain**: latinenglishbible.com
