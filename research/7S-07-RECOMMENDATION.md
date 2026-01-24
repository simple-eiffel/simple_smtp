# 7S-07: RECOMMENDATION
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Assessment Summary

simple_smtp is a **comprehensive SMTP client** with good API design but incomplete TLS support.

## Strengths

1. **Clean API**: Fluent builder pattern
2. **Quick Facade**: One-liner for common cases
3. **Provider Presets**: Gmail, Outlook, Yahoo
4. **RFC Compliant**: Proper message formatting
5. **Full Features**: Attachments, HTML, Cc/Bcc
6. **Strong Contracts**: 15+ invariants

## Weaknesses

1. **No Actual TLS**: Flags set but not implemented
2. **Blocking I/O**: No async support
3. **No Retry Logic**: Single attempt only
4. **No Connection Pooling**: New socket per send

## Recommendations

### Critical
- Implement actual STARTTLS/TLS support
- Add connection timeout handling
- Secure credential wiping after use

### Short-term
- Add retry with exponential backoff
- Implement connection pooling
- Add send timeout

### Medium-term
- Async sending support
- DKIM signing
- Better error categorization

### Long-term
- Connection keep-alive
- Queue-based sending
- Delivery status notification

## Verdict

**PRODUCTION-READY WITH CAVEATS** - Works well for basic sending through providers that handle TLS at the connection layer. Full TLS support needed for direct SMTP with untrusted networks.
