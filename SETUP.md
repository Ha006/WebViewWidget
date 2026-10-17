# Setup – Sökmotorn iOS builds

## Sideload IPA (Henrik / free Apple ID)

1. Sign in to [codemagic.io](https://codemagic.io) with GitHub, add the repo `Ha006/WebViewWidget`, and run the workflow **`ios-unsigned-ipa`**.
2. Download the IPA (`Sokmotorn.ipa`) from the build artifacts (or the email to admin@klasholmgren.se).
3. Henrik installs it on his iPhone with [Sideloadly](https://sideloadly.io/) or [AltStore](https://altstore.io/) using his own free Apple ID. With a free Apple ID the app must be re-signed every 7 days.

## TestFlight (`ios-testflight`)

1. In Codemagic, ensure the App Store Connect integration is named **`CodemagicASCKey`** (or change that name in `codemagic.yaml`).
2. Set **`APP_STORE_APPLE_ID`** in `codemagic.yaml` (App Store Connect → App Information → Apple ID). Leave as `TBD` until you have it.
3. Run workflow **`ios-testflight`**. The IPA is uploaded to App Store Connect; internal group **Testers** gets the build (no beta review). You also get an email at admin@klasholmgren.se.
