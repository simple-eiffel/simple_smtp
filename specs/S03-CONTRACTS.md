# S03: CONTRACTS
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Design by Contract Summary

### SIMPLE_SMTP Contracts

```eiffel
make (a_host: STRING; a_port: INTEGER)
    require
        host_not_void: a_host /= Void
        host_not_empty: not a_host.is_empty
        valid_port: a_port > 0 and a_port < 65536
    ensure
        host_set: host = a_host
        port_set: port = a_port

set_from (a_email: STRING; a_name: detachable STRING)
    require
        email_not_void: a_email /= Void
        email_not_empty: not a_email.is_empty
    ensure
        has_from: has_sender

add_to (a_email: STRING; a_name: detachable STRING)
    require
        email_not_void: a_email /= Void
        email_not_empty: not a_email.is_empty
    ensure
        recipient_added: to_count = old to_count + 1

send: BOOLEAN
    require
        has_from: has_sender
        has_recipients: has_recipients
        has_subject: has_subject_set
        has_body: has_body_set
    ensure
        error_on_failure: not Result implies has_error
```

### Class Invariants

```eiffel
invariant
    host_exists: host /= Void
    host_not_empty: not host.is_empty
    valid_port: port > 0 and port < 65536
    to_lists_match: to_emails.count = to_names.count
    cc_lists_match: cc_emails.count = cc_names.count
    bcc_lists_match: bcc_emails.count = bcc_names.count
    attachments_consistent: attachment_names.count = attachment_contents.count
    base64_exists: base64 /= Void
    uuid_gen_exists: uuid_gen /= Void
    timeout_positive: timeout_seconds > 0
    tls_modes_exclusive: not (use_tls and use_starttls)
```

### SIMPLE_SMTP_QUICK Contracts

```eiffel
gmail (a_email, a_app_password: STRING)
    require
        email_not_empty: not a_email.is_empty
        password_not_empty: not a_app_password.is_empty
    ensure
        is_configured: is_configured

send (a_to, a_subject, a_body: STRING): BOOLEAN
    require
        is_configured: is_configured
        to_not_empty: not a_to.is_empty
        subject_not_empty: not a_subject.is_empty
```
