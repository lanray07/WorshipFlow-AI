# GitHub TestFlight Setup

This repository can build and upload WorshipFlow AI to TestFlight through GitHub Actions.

## Workflow

Use `.github/workflows/testflight-upload.yml`.

Run it manually from:

`GitHub > Actions > TestFlight Upload > Run workflow`

## Required GitHub Secrets

Add these in:

`GitHub repo > Settings > Secrets and variables > Actions > New repository secret`

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect issuer ID |
| `ASC_PRIVATE_KEY` | Full contents of the `.p8` App Store Connect API key |
| `BUILD_CERTIFICATE_BASE64` | Base64 encoded Apple Distribution `.p12` certificate |
| `P12_PASSWORD` | Password for the `.p12` certificate |
| `PROVISION_PROFILE_BASE64` | Base64 encoded App Store provisioning profile for `com.worshipflow.ai` |
| `KEYCHAIN_PASSWORD` | Any strong temporary keychain password for CI |

## Create Base64 Values

On macOS:

```sh
base64 -i AppleDistribution.p12 | pbcopy
base64 -i WorshipFlowAI_AppStore.mobileprovision | pbcopy
```

Paste each copied value into the matching GitHub secret.

## App Store Connect API Key

Create an API key in:

`App Store Connect > Users and Access > Integrations > App Store Connect API`

The key should have enough access to upload builds for WorshipFlow AI.

## Notes

- The app bundle identifier is `com.worshipflow.ai`.
- The workflow uploads the exported `.ipa` as a GitHub Actions artifact before sending it to TestFlight.
- The app uses mock AI by default, so no AI API key is required for the build.
