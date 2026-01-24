# 7S-06: SIZING
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Current Size

### Source Files
- **Classes**: 2 Eiffel classes
- **Lines**: ~1350 lines of Eiffel code
- **Test Classes**: 2

### Class Breakdown
| Class | Lines | Responsibility |
|-------|-------|----------------|
| SIMPLE_SMTP | 1055 | Full SMTP implementation |
| SIMPLE_SMTP_QUICK | 290 | Zero-config facade |

## Complexity Assessment

- **SIMPLE_SMTP Features**: 50+ methods
- **State Variables**: 20+ attributes
- **Invariants**: 15+ class invariants
- **Protocol States**: Connect, EHLO, AUTH, MAIL, RCPT, DATA, QUIT

## Memory Usage

- Base instance: ~2KB
- Per recipient: ~100 bytes
- Per attachment: size + 33% (Base64)
- Message buffer: varies with content

## Feature Completeness

| Feature | Status |
|---------|--------|
| Plain SMTP | Complete |
| STARTTLS | Flag only (no actual TLS) |
| SSL/TLS | Flag only |
| AUTH LOGIN | Complete |
| AUTH PLAIN | Complete |
| Multiple Recipients | Complete |
| HTML Bodies | Complete |
| Attachments | Complete |
| Reply-To | Complete |

## Growth Projections

- Potential: Actual TLS implementation
- Potential: Async sending
- Potential: DKIM signing
- Otherwise stable
