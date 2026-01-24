# S02: CLASS CATALOG
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Class Hierarchy

```
ANY
├── SIMPLE_SMTP (full SMTP implementation)
└── SIMPLE_SMTP_QUICK (zero-config facade)
```

## Class Descriptions

### SIMPLE_SMTP
**Purpose**: Complete SMTP client with all features
**Responsibilities**:
- Socket connection management
- SMTP protocol conversation
- Authentication (LOGIN, PLAIN)
- Message building (headers, body, MIME)
- Recipient management (To, Cc, Bcc)
- Attachment handling

**Key Features**:
- Builder pattern for message construction
- Multiple authentication methods
- HTML and plain text support
- File attachment support
- Reply-To header support

### SIMPLE_SMTP_QUICK
**Purpose**: Zero-configuration facade for common providers
**Responsibilities**:
- Pre-configure popular SMTP servers
- Simplify single-recipient sending
- Provide one-liner API

**Provider Methods**:
- `gmail`: smtp.gmail.com:587
- `outlook`: smtp.office365.com:587
- `yahoo`: smtp.mail.yahoo.com:587
- `server`: Custom configuration

**Send Methods**:
- `send`: Plain text
- `send_html`: HTML content
- `send_to_many`: Multiple recipients
- `send_with_attachment`: File attachment
