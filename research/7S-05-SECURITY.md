# 7S-05: SECURITY
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Security Considerations

### Threat Model

1. **Credential Exposure**: Passwords in memory/code
2. **Man-in-the-Middle**: Unencrypted SMTP
3. **Header Injection**: Malicious content in headers
4. **Relay Abuse**: Open relay exploitation

### Mitigations

#### Transport Security
- STARTTLS support (port 587)
- SSL/TLS support (port 465)
- Credential encoding for AUTH

#### Credential Handling
- Passwords stored in memory only during send
- Base64 encoding for transmission
- No credential persistence

#### Message Integrity
- RFC-compliant header formatting
- Proper escaping of special characters
- MIME boundary isolation

### Current Limitations

1. **No TLS Verification**: Trusts server certificate
2. **Plaintext on Port 25**: No encryption option
3. **Password in Memory**: String not wiped after use
4. **No Timeout Handling**: Socket default timeouts

### Recommendations

1. Always use port 587 or 465 for encryption
2. Use App Passwords (not main account passwords)
3. Store credentials in environment variables
4. Consider adding certificate validation
5. Implement connection timeout handling
