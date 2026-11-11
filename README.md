# Cardboard Clinic

Trading card assessment, care and restoration website, refreshed with the approachable collector identity. Deep teal, seafoam, warm ivory and restrained apricot accents. Cardboard Clinic stands independently, without a Cardboard Collective endorsement.

## Run

No install step or build dependencies are required. Serve the project directory with a static web server, or run `npm run build` and serve `dist/`. Run `npm run check` for the core pricing, counter and consent checks.

## Features retained from v6

- SGD treatment price list, market-value estimator and optional S$75 priority charge
- Customer email/password portal and private per-card progress tracking
- Staff-controlled intake, quotations, photographs, pricing, queue and portfolio
- Mandatory per-card consent acknowledgements, optional marketing permission, typed signature and staff verification before treatment
- Counter starting at 53 completed cards, plus distinct new closed records

## Live configuration

The supplied project has **blank Supabase configuration** and opens in a clearly labelled local demo mode. No customer database or live accounts were supplied. Set the public Supabase URL and anon/publishable key in `window.CARDBOARD_CLINIC_CONFIG` in `index.html` to connect an existing configured project. Never add a service-role key or any secret to browser files or Git.

For a new database, review and run `supabase_setup.sql`. It includes the prior upgrades and v6 consent tables/triggers. `V6_upgrade.sql` is retained for an existing installation that already has the earlier schema. See `SETUP.txt` for operational setup. Real authentication, row-level permissions and storage access need validation against the connected database before accepting customer data.

Customer accounts are provisioned by staff. Customers cannot create intake records themselves. Private card photographs use signed storage URLs. Portfolio photos go into the separate public bucket only after staff confirm publication permission.

## Artwork

`assets/logo.png` is the approved friendly logo adapted for the site. The workbench image is an AI-generated brand illustration, labelled as such on the page. It is not a real treatment result. Replace it with original workbench photography when available. No invented reviews or before/after results have been added.

## Deploy

`npm run build` creates only the public website and assets in `dist/`. Deploy that directory to any static host. Database SQL and setup documents remain outside the public build. `.openai/hosting.json` retains the private preview Site identity.
