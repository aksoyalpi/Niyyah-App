# Niyyah Website

Single-page landing site (plain HTML + CSS, no build step) for early-access
signup and newsletter.

## Structure

```
website/
  index.html          # the whole page
  privacy.html        # GDPR privacy policy (placeholders to fill)
  imprint.html        # § 5 DDG imprint (placeholders to fill)
  styles.css          # palette copied from lib/core/theme/app_theme.dart
  assets/
    icon.svg          # app icon (green crescent)
    fonts/Amiri-*.ttf # Arabic in the mockup (self-hosted)
    fonts/Fraunces-*.woff2 # display serif for headings (600 + italic, latin subset)
```

Design constants mirror the app: accent `#2F6B4F`, background `#FCFBF7`,
text `#211F1C` / `#6F6A63`, divider `#ECE8E0`.

## Preview locally

```
cd website && python3 -m http.server 8080
```

Open http://localhost:8080.

## Newsletter signup (MailerLite)

The signup section in `index.html` contains a placeholder form wrapped in
`<!-- REPLACE this form with your MailerLite embed -->` comments. To make it
live:

1. Create a free account at https://www.mailerlite.com (free tier: 500
   subscribers / 12,000 emails per month).
2. Verify your sender domain/email.
3. Go to **Forms → Embedded**, create a form.
4. **Double opt-in is enabled by default** — keep it on (recommended for GDPR;
   edit the confirmation email text to your taste).
5. Add a consent note to the form ("I agree to receive emails…") under form
   fields if you want an explicit checkbox.
6. In the form builder, prefer the **Custom HTML** option if available and
   paste the markup from the placeholder (keep `name="email"` on the input so
   MailerLite picks up the address); otherwise use the JavaScript embed and
   swap the whole placeholder block for it.
7. Style to match: primary `#2F6B4F`, button radius 12px.
8. Test the full loop: submit → confirmation email → click → subscriber
   appears as "confirmed".

Mailchimp is not recommended (free tier now only 250 contacts). Buttondown
(pure HTML form, no JS) is a fallback if MailerLite is ever dropped, free up
to 100 subscribers.

## Deploy (Cloudflare Pages, free)

1. Create a free Cloudflare account.
2. Dashboard → **Workers & Pages → Create → Pages → Upload assets**.
3. Name the project `niyyah`, drag the `website/` folder's *contents* into the
   upload. Site goes live at `https://niyyah.pages.dev`.
4. Later: buy a domain (e.g. `niyyah.app`), add it under the Pages project →
   **Custom domains**; DNS + HTTPS are automatic if the domain is in
   Cloudflare.

CLI alternative: `npx wrangler pages deploy . --project-name=niyyah`
(from inside `website/`).

## Legal pages

`privacy.html` (GDPR policy) and `imprint.html` (§ 5 DDG) exist but contain
`[PLACEHOLDER]` blocks. Each file has an HTML comment at the top listing
exactly what to fill in: your name, full postal address (no P.O. box — German
law), city, and the "last updated" date. Contact email is already set to
`alaksoftware@gmail.com`. The text is a draft, not legal advice — cross-check
with a generator (eRecht24 etc.) or a lawyer before launch.

## Before public launch

- [ ] Fill the `[PLACEHOLDER]` blocks in `privacy.html` and `imprint.html`.
- [ ] Swap the phone mockup for a real app screenshot (hero `.phone` block).
- [ ] Add `og:image` (1200×630 PNG) for social sharing.
- [ ] Review MailerLite list settings + confirmation email wording.
