# 7S-03: SOLUTIONS
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Existing Solutions Analyzed

### 1. EiffelNet SMTP
- **Pros**: Part of standard library
- **Cons**: Basic, no TLS, limited features

### 2. External Process (curl, sendmail)
- **Pros**: Proven implementations
- **Cons**: Process overhead, platform dependency

### 3. Commercial Libraries
- **Pros**: Full-featured, supported
- **Cons**: Cost, licensing, external dependency

### 4. Web Services (SendGrid, Mailgun)
- **Pros**: Deliverability, analytics
- **Cons**: External dependency, cost, API changes

## Why Build Custom?

1. **Native Eiffel**: No external process required
2. **Modern Features**: AUTH PLAIN, attachments, HTML
3. **Simple API**: Fluent builder pattern
4. **Provider Presets**: Gmail, Outlook, Yahoo configured

## Key Differentiators

- Pure Eiffel socket implementation
- Pre-configured popular providers
- Both builder API and one-liner facade
- RFC-compliant message formatting
- Design by Contract throughout
