# Online Calculator

A free, fast, ad-supported collection of calculators tailored for New Zealand — covering finance, property, health, math, and construction. No signup, no tracking beyond standard analytics, no nonsense.

Live at **[onlinecalculator.co.nz](https://onlinecalculator.co.nz)**.

## What's inside

22 calculators across 5 categories:

| Category | Calculators |
|---|---|
| **Finance** | GST, PAYE, KiwiSaver, mortgage, loan, compound interest, currency converter, percentage |
| **Property** | Mortgage, rental yield, rent-vs-buy, bright-line test |
| **Health** | BMI, calorie, ideal weight, pregnancy due date |
| **Math** | Age, fraction, scientific |
| **Construction** | Concrete volume, decking, paint |

All calculations run client-side in your browser — nothing is sent to a server.

## Tech stack

- **Static HTML/CSS/JS** — no frameworks, no build step
- **Nginx** (alpine) for serving, with clean URLs and gzip
- **Docker** + **docker-compose** for packaging
- **Traefik** for TLS, HTTPS redirect, and www → apex redirect
- **GitHub Actions** for auto-deploy to the production VPS on push to `main`

## Running locally

You need Docker installed. From the repo root:

```bash
docker compose up --build
```

The site will be available at `http://localhost` (you'll need to comment out the Traefik labels in `docker-compose.yml` if you don't have Traefik running, and expose port 80 with `ports: ["8080:80"]`).

Or, since it's a pure static site, just open `index.html` directly in your browser.

## Deployment

`main` is the deploy branch. Every push triggers `.github/workflows/deploy.yml`, which SSHes into the production VPS, pulls the latest code, and rebuilds the container.

Required GitHub secrets:

| Secret | Purpose |
|---|---|
| `VPS_HOST` | VPS IP or hostname |
| `VPS_USER` | SSH user on the VPS |
| `VPS_SSH_KEY` | Private SSH key (full file contents) |
| `VPS_APP_DIR` | Path to the app directory on the VPS |

## IndexNow

Bing/Yandex/Naver/Seznam are notified of URL updates via [IndexNow](https://www.indexnow.org/). Google does **not** use IndexNow — it relies on `sitemap.xml` and Search Console.

- Key: `f14f367cd310965f5fa459458e7540e7`
- Verification file: [`/f14f367cd310965f5fa459458e7540e7.txt`](./f14f367cd310965f5fa459458e7540e7.txt) — must stay reachable at the site root
- After a content deploy, ping all URLs:

  ```powershell
  pwsh .\tools\indexnow-ping.ps1
  # or just the URLs that changed:
  pwsh .\tools\indexnow-ping.ps1 -Urls "https://onlinecalculator.co.nz/finance/gst-calculator/"
  ```

## Project structure

```
.
├── index.html             # Homepage
├── 404.html               # Not-found page
├── assets/                # Shared CSS, JS, icons
├── finance/               # Finance calculators
├── property/              # Property calculators
├── health/                # Health calculators
├── math/                  # Math calculators
├── construction/          # Construction calculators
├── privacy/, disclaimer/  # Legal pages
├── Dockerfile             # Nginx + static files
├── docker-compose.yml     # Traefik-fronted deployment
├── nginx.conf             # Server config
├── sitemap.xml, robots.txt, ads.txt
└── .github/workflows/     # CI/CD
```

## Disclaimer

The calculators are provided for general information only. They are not financial, medical, legal, or professional advice. Always check with a qualified advisor before making decisions based on the results. Tax rates and rules reflect the **2026** NZ tax year and may change.

## License

All rights reserved. The source is published for transparency, not as an open-source project — please don't redistribute or republish the site or its content. Open an issue if you'd like to discuss other uses.
