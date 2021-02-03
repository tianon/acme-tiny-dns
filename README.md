# acme-tiny-dns

This is a fork of [conchyliculture/acme-tiny-dns](https://github.com/conchyliculture/acme-tiny-dns) which is itself a fork of [acme-tiny](https://github.com/diafygi/acme-tiny).

> Thanks a lot to [diafygi](https://github.com/diafygi) to let us escape from all the other ACME client craziness.

See https://github.com/diafygi/acme-tiny/compare/master...tianon:tianon (specifically, `acme_tiny.py → acme_tiny_dns.py`) for the full delta from the original.

Start with https://github.com/diafygi/acme-tiny#how-to-use-this-script -- we'll only document the delta.

## How to use this script

> If you already have a Let's Encrypt issued certificate and just want to renew,
> you should only have to do Steps 3 and 6.

### Step 1: Create a Let's Encrypt account private key (if you haven't already)

### Step 2: Create a certificate signing request (CSR) for your domains.

```
# For wildcard domains (only possible via DNS challenge)
openssl req -new -sha256 -key domain.key -subj "/" -addext "subjectAltName = DNS:*.yoursite.com" > domain.csr
```

### Step 3: Write a hook script that will talk to your DNS server and update the zone

A DNS-01 challenge requires the challenge token to be stored in a DNS record of type TXT (and name `_acme-challenge`) in your domain's zone.

How to do this will depend on each DNS implementation, so you have to provide your own script.

This script will be called by `acme_tiny_dns.py`:

```
# Add the record
subprocess.check_call([hook, 'update', domain, record_value])
...
# Remove the record
subprocess.check_call([hook, 'cleanup', domain])
```

### Step 4: Get a signed certificate!

Pass `--hook` with a path to the script instead of `--acme-dir`:

```
# Run the script on your server
python acme_tiny_dns.py --account-key ./account.key --csr ./domain.csr --hook /path/to/hook/script > ./signed_chain.crt
```

### Step 5: Install the certificate

### Step 6: Setup an auto-renew cronjob

(Don't forget to replace `--acme-dir` with `--hook`.)

**NOTE:** Since Let's Encrypt's ACME v2 release (acme-tiny 4.0.0+), the intermediate
certificate is included in the issued certificate download, so you no longer have
to independently download the intermediate certificate and concatenate it to your
signed certificate. If you have an shell script or Makefile using acme-tiny &lt;4.0 (e.g. before
2018-03-17) with acme-tiny 4.0.0+, then you may be adding the intermediate
certificate to your signed_chain.crt twice (which
[causes issues with at least GnuTLS 3.7.0](https://gitlab.com/gnutls/gnutls/-/issues/1131)
besides making the certificate slightly larger than it needs to be). To fix,
simply remove the bash code where you're downloading the intermediate and adding
it to the acme-tiny certificate output.

## Permissions

**BE SURE TO:**
* Backup your account private key (e.g. `account.key`)
* Don't allow this script to be able to read your domain private key!
* Don't allow this script to be run as root!

## Staging Environment

Let's Encrypt recommends testing new configurations against their staging servers,
so when testing out your new setup, you can use
`--directory-url https://acme-staging-v02.api.letsencrypt.org/directory`
to issue fake test certificates instead of real ones from Let's Encrypt's production servers.
See [https://letsencrypt.org/docs/staging-environment/](https://letsencrypt.org/docs/staging-environment/)
for more details.

## Feedback/Contributing

This project has a very, very limited scope and codebase. I'm happy to receive
bug reports and pull requests, but please don't add any new features. This
script must stay under 200 lines of code to ensure it can be easily audited by
anyone who wants to run it.

If you want to add features for your own setup to make things easier for you,
please do! It's open source, so feel free to fork it and modify as necessary.
