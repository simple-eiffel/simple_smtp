# S01: PROJECT INVENTORY
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Project Structure

```
simple_smtp/
├── src/
│   ├── simple_smtp.e          # Full SMTP implementation
│   └── simple_smtp_quick.e    # Zero-config facade
├── testing/
│   ├── test_app.e             # Test runner
│   └── lib_tests.e            # Test suite
├── docs/
│   └── index.html             # API documentation
├── research/                   # 7S research documents
├── specs/                      # Specification documents
└── simple_smtp.ecf            # Project configuration
```

## Source Files

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| simple_smtp.e | Core | 1055 | Full SMTP client |
| simple_smtp_quick.e | Facade | 290 | Quick setup wrapper |

## Dependencies

### Internal (simple_*)
- simple_base64
- simple_uuid
- simple_datetime
- simple_logger (quick facade only)

### External
- EiffelNet (NETWORK_STREAM_SOCKET)
- EiffelBase (standard library)

### Test Dependencies
- None (basic test harness)
