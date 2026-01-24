# S07: SPECIFICATION SUMMARY
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## One-Line Description

Native Eiffel SMTP client for sending emails with authentication, attachments, and HTML support.

## Key Specifications

| Aspect | Specification |
|--------|---------------|
| **Type** | Service Library |
| **Protocol** | SMTP (RFC 5321) |
| **Authentication** | LOGIN, PLAIN |
| **Ports** | 25, 587, 465 |
| **Content** | Plain text, HTML, attachments |
| **Recipients** | To, Cc, Bcc |

## Quick Facade Providers

| Provider | Method | Host | Port |
|----------|--------|------|------|
| Gmail | `gmail` | smtp.gmail.com | 587 |
| Outlook | `outlook` | smtp.office365.com | 587 |
| Yahoo | `yahoo` | smtp.mail.yahoo.com | 587 |
| Custom | `server` | user-specified | user-specified |

## Typical Usage

```eiffel
-- Full API
create smtp.make ("smtp.gmail.com", 587)
smtp.set_credentials ("user@gmail.com", "app-password")
smtp.set_from ("user@gmail.com", "Sender")
smtp.add_to ("recipient@example.com", Void)
smtp.set_subject ("Hello")
smtp.set_body ("Message body")
smtp.send

-- Quick API
create mail.make
mail.gmail ("user@gmail.com", "app-password")
mail.send ("recipient@example.com", "Hello", "Body")
```

## Critical Invariants

1. Host and port must be valid for connection
2. Sender must be set before sending
3. At least one To recipient required
4. Subject and body (text or HTML) required
5. TLS flags are mutually exclusive
