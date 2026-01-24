# S04: FEATURE SPECIFICATIONS
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## SIMPLE_SMTP Features

### Configuration
| Feature | Signature | Description |
|---------|-----------|-------------|
| set_credentials | (username, password: STRING) | Auth credentials |
| set_auth_method | (method: STRING) | "PLAIN" or "LOGIN" |
| set_from | (email: STRING; name: detachable STRING) | Sender |
| set_reply_to | (email: STRING; name: detachable STRING) | Reply-To header |
| set_timeout | (seconds: INTEGER) | Connection timeout |
| enable_tls | | SSL/TLS mode (port 465) |
| enable_starttls | | STARTTLS mode (port 587) |

### Recipients
| Feature | Signature | Description |
|---------|-----------|-------------|
| add_to | (email: STRING; name: detachable STRING) | Add To recipient |
| add_cc | (email: STRING; name: detachable STRING) | Add Cc recipient |
| add_bcc | (email: STRING; name: detachable STRING) | Add Bcc recipient |
| clear_recipients | | Remove all recipients |

### Content
| Feature | Signature | Description |
|---------|-----------|-------------|
| set_subject | (subject: STRING) | Email subject |
| set_body | (body: STRING) | Plain text body |
| set_html_body | (html: STRING) | HTML body |
| set_body_with_html | (text, html: STRING) | Both bodies |
| add_attachment | (filename, content, mime: STRING) | Add attachment |
| clear_attachments | | Remove all attachments |

### Sending
| Feature | Signature | Description |
|---------|-----------|-------------|
| send | : BOOLEAN | Send email |
| send_async | (callback: detachable PROCEDURE) | Async send |

### Status
| Feature | Signature | Description |
|---------|-----------|-------------|
| has_error | : BOOLEAN | Send failed |
| last_error | : STRING | Error message |
| last_response | : STRING | Server response |
| to_count / cc_count / bcc_count | : INTEGER | Recipient counts |
