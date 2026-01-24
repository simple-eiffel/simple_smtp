# S05: CONSTRAINTS
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Technical Constraints

### Protocol
- SMTP only (not SMTPS direct TLS)
- STARTTLS flag-only (not implemented)
- Socket-based I/O

### Authentication
- AUTH LOGIN supported
- AUTH PLAIN supported
- No OAuth2 support

### Message Limits
- Subject: No explicit limit
- Body: Memory-limited
- Attachments: Base64 encoded (33% overhead)

## Design Constraints

### Synchronous Operation
- `send` blocks until complete
- `send_async` uses same thread (pseudo-async)
- No connection pooling

### Single Server
- One host/port per instance
- Reconnects for each send
- No failover support

### State Management
- Recipients persist between sends
- Must call `clear_recipients` to reset
- Attachments persist similarly

## Operational Constraints

### Network
- Requires network access
- No offline queueing
- Server must be reachable

### TLS Limitation
- `use_tls` and `use_starttls` are FLAGS only
- Actual TLS not implemented in current version
- Works with servers that accept plain connection
- Use with providers that handle TLS at network layer

### Provider Requirements
- Gmail: Requires App Password
- Outlook: Requires 2FA + App Password
- Yahoo: Requires App Password
