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

## Permissions

**BE SURE TO:**
* Backup your account private key (e.g. `account.key`)
* Don't allow this script to be able to read your domain private key!
* Don't allow this script to be run as root!

## Feedback/Contributing

This project has a very, very limited scope and codebase. I'm happy to receive
bug reports and pull requests, but please don't add any new features. This
script must stay under 200 lines of code to ensure it can be easily audited by
anyone who wants to run it.

If you want to add features for your own setup to make things easier for you,
please do! It's open source, so feel free to fork it and modify as necessary.
