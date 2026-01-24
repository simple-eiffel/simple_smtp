# 7S-01: SCOPE
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## What Problem Does This Solve?

simple_smtp provides native email sending capabilities for Eiffel:
- Send plain text and HTML emails
- Support multiple recipients (To, Cc, Bcc)
- Handle attachments with Base64 encoding
- Support various SMTP configurations (plain, STARTTLS, SSL/TLS)
- Authenticate with AUTH LOGIN and AUTH PLAIN

## Target Users

1. **Application Developers** - Need to send transactional emails
2. **Notification Systems** - Automated email alerts
3. **Contact Forms** - Web application integrations

## Domain

Email transmission via SMTP protocol.

## In-Scope

- SMTP connection (ports 25, 587, 465)
- AUTH LOGIN and AUTH PLAIN authentication
- Multiple recipients (To, Cc, Bcc)
- Plain text and HTML bodies
- File attachments (Base64 encoded)
- Reply-To header support
- RFC 5321/5322 compliant message formatting
- Quick facade for zero-configuration setup

## Out-of-Scope

- Email receiving (POP3/IMAP)
- Template rendering
- Mailing list management
- Bounce handling
- DKIM/SPF signing
