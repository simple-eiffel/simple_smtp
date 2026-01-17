<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.png" alt="simple_ library logo" width="400">
</p>

# simple_smtp

**[Documentation](https://simple-eiffel.github.io/simple_smtp/)** | **[Watch the Build Video](https://youtu.be/0FRqhC2IiG8)**

Native SMTP email sending library for Eiffel. No shell commands, no external dependencies.

## Features

- **Native SMTP** protocol implementation (RFC 5321)
- **Multiple TLS modes** - STARTTLS (port 587), SSL/TLS (port 465), plain (port 25)
- **Authentication** - AUTH LOGIN and AUTH PLAIN support
- **Multiple recipients** - To, Cc, and Bcc with display names
- **Rich content** - Plain text, HTML, and multipart/alternative
- **Attachments** - Base64 encoded file attachments
- **Design by Contract** with full preconditions/postconditions

## Installation

Add to your ECF:

```xml
<library name="simple_smtp" location="$SIMPLE_EIFFEL/simple_smtp/simple_smtp.ecf"/>
```

Set environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

**Dependencies:**
- simple_foundation_api (for Base64 encoding and UUID generation)

## Quick Start (Zero-Configuration)

Use `SIMPLE_SMTP_QUICK` for the simplest possible email sending:

```eiffel
local
    mail: SIMPLE_SMTP_QUICK
do
    create mail.make

    -- Configure for Gmail (use App Password, not regular password)
    mail.gmail ("your.email@gmail.com", "your-app-password")

    -- Or Outlook/Office365
    -- mail.outlook ("your.email@outlook.com", "password")

    -- Or any SMTP server
    -- mail.server ("smtp.example.com", 587, "username", "password")

    -- Send plain text email
    if mail.send ("recipient@example.com", "Subject Line", "Email body text") then
        print ("Email sent!")
    end

    -- Send HTML email
    mail.send_html ("recipient@example.com", "Newsletter", "<h1>Hello</h1><p>Content here</p>")

    -- Send to multiple recipients
    mail.send_to_many (<<"alice@example.com", "bob@example.com">>, "Team Update", "Message body")

    -- Send with attachment
    mail.send_with_attachment ("recipient@example.com", "Report", "See attached.", "report.pdf")

    -- Error handling
    if mail.has_error then
        print ("Error: " + mail.last_error)
    end
end
```

## Standard API (Full Control)

### Basic Email

```eiffel
local
    smtp: SIMPLE_SMTP
do
    create smtp.make ("smtp.example.com", 587)
    smtp.set_credentials ("user@example.com", "password")
    smtp.set_from ("sender@example.com", "Sender Name")
    smtp.add_to ("recipient@example.com", "Recipient Name")
    smtp.set_subject ("Hello!")
    smtp.set_body ("This is a test email.")

    if smtp.send then
        print ("Email sent successfully!")
    else
        print ("Error: " + smtp.last_error)
    end
end
```

### HTML Email

```eiffel
smtp.set_html_body ("<html><body><h1>Hello!</h1><p>This is HTML.</p></body></html>")
```

### Multipart (Text + HTML)

```eiffel
smtp.set_body_with_html (
    "Plain text version for older clients",
    "<html><body><h1>HTML version</h1></body></html>"
)
```

### Multiple Recipients

```eiffel
smtp.add_to ("first@example.com", "First Recipient")
smtp.add_to ("second@example.com", "Second Recipient")
smtp.add_cc ("copy@example.com", "CC Person")
smtp.add_bcc ("hidden@example.com", Void)  -- No display name
```

### Attachments

```eiffel
smtp.add_attachment ("report.pdf", pdf_content, "application/pdf")
smtp.add_attachment ("data.csv", csv_content, "text/csv")
```

### TLS Configuration

```eiffel
-- Port 587 with STARTTLS (default for 587)
create smtp.make ("smtp.example.com", 587)
smtp.enable_starttls  -- Explicit call if needed

-- Port 465 with implicit TLS
create smtp.make ("smtp.example.com", 465)
smtp.enable_tls

-- Port 25 plain (no encryption)
create smtp.make ("smtp.example.com", 25)
```

## API Reference

### Initialization

| Feature | Description |
|---------|-------------|
| `make (host, port)` | Create SMTP client |
| `set_credentials (user, pass)` | Set auth credentials |
| `set_timeout (seconds)` | Connection timeout |
| `enable_tls` | TLS/SSL mode (port 465) |
| `enable_starttls` | STARTTLS upgrade (port 587) |

### Sender & Recipients

| Feature | Description |
|---------|-------------|
| `set_from (email, name)` | Set sender (name optional) |
| `add_to (email, name)` | Add To recipient |
| `add_cc (email, name)` | Add Cc recipient |
| `add_bcc (email, name)` | Add Bcc recipient |
| `clear_recipients` | Clear all recipients |

### Content

| Feature | Description |
|---------|-------------|
| `set_subject (text)` | Set email subject |
| `set_body (text)` | Set plain text body |
| `set_html_body (html)` | Set HTML body |
| `set_body_with_html (text, html)` | Set both (multipart) |
| `add_attachment (name, content, mime)` | Add attachment |
| `clear_attachments` | Clear all attachments |

### Sending

| Feature | Description |
|---------|-------------|
| `send: BOOLEAN` | Send email, returns success |
| `send_async (callback)` | Send with callback |

### Status

| Feature | Description |
|---------|-------------|
| `has_error: BOOLEAN` | Did last op fail? |
| `last_error: STRING` | Error message |
| `last_response: STRING` | Last server response |

### Query

| Feature | Description |
|---------|-------------|
| `has_sender: BOOLEAN` | From set? |
| `has_recipients: BOOLEAN` | Any To recipients? |
| `has_subject_set: BOOLEAN` | Subject set? |
| `has_body_set: BOOLEAN` | Body (text/html) set? |
| `to_count: INTEGER` | Number of To recipients |
| `cc_count: INTEGER` | Number of Cc recipients |
| `bcc_count: INTEGER` | Number of Bcc recipients |
| `attachment_count: INTEGER` | Number of attachments |

## Use Cases

- **Transactional emails** - Welcome, password reset, notifications
- **Reports** - Send automated reports with attachments
- **Alerts** - System monitoring notifications
- **Marketing** - HTML newsletters (with plain text fallback)
- **Forms** - Contact form submissions

## Dependencies

- EiffelBase
- EiffelNet (sockets)
- EiffelTime
- simple_foundation_api (for Base64 encoding and UUID generation)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
