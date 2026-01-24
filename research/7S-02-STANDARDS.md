# 7S-02: STANDARDS
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Applicable Standards

### SMTP Standards
- **RFC 5321**: Simple Mail Transfer Protocol
- **RFC 5322**: Internet Message Format
- **RFC 4616**: AUTH PLAIN SASL Mechanism
- **RFC 4954**: SMTP AUTH Extension

### MIME Standards
- **RFC 2045**: MIME Part One (Format)
- **RFC 2046**: MIME Part Two (Media Types)
- **RFC 2047**: MIME Part Three (Headers)

### Encoding Standards
- **Base64**: RFC 4648 for attachments and auth
- **UTF-8**: Character encoding for content
- **CRLF**: Line endings (%R%N)

## Design Patterns

1. **Builder Pattern**: Fluent API for message construction
2. **Facade Pattern**: SIMPLE_SMTP_QUICK for common providers
3. **Strategy Pattern**: AUTH LOGIN vs AUTH PLAIN selection

## Message Format

```
Date: <RFC 5322 date>
From: "Name" <email>
To: recipients
Subject: subject
Message-ID: <unique@domain>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8

body
```

## References

- RFC 5321: https://datatracker.ietf.org/doc/html/rfc5321
- RFC 5322: https://datatracker.ietf.org/doc/html/rfc5322
- RFC 4616: https://datatracker.ietf.org/doc/html/rfc4616
