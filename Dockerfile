FROM python:3.9-alpine3.20

RUN apk add --no-cache bash curl openssl wget

COPY acme_tiny_dns.py /usr/local/bin/acme-tiny-dns

RUN set -eux; \
	acme-tiny-dns --help

CMD ["acme-tiny-dns"]
