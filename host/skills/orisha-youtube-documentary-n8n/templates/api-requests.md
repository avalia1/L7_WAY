# API request templates

Load the secret without printing it:

```sh
source /Users/rnir_hrc_avd/.l7/secrets/orisha_documentary_n8n.env
```

Endpoint:

```sh
ORISHA_ENDPOINT=https://n8n.avli.cloud/webhook/v1/orisha/documentary/jobs
```

Create requests should default to dry_run true and both approval flags false. Never include the credential value in logs, commits, or screenshots.
