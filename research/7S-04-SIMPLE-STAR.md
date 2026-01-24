# 7S-04: SIMPLE-STAR ECOSYSTEM
**Library**: simple_smtp
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Ecosystem Dependencies

### Uses (Dependencies)
- **simple_base64** - Attachment and auth encoding
- **simple_uuid** - MIME boundary generation
- **simple_datetime** - RFC 5322 date headers
- **simple_logger** - Debug logging (quick facade)
- **EiffelNet** - Socket communication

### Used By (Dependents)
- **simple_showcase** - Contact form notifications
- Any application needing email capability

## Integration Points

### Basic Usage
```eiffel
create smtp.make ("smtp.gmail.com", 587)
smtp.set_credentials ("user@gmail.com", "app-password")
smtp.set_from ("user@gmail.com", "Sender Name")
smtp.add_to ("recipient@example.com", "Recipient")
smtp.set_subject ("Hello!")
smtp.set_body ("This is my message.")
if smtp.send then
    print ("Sent!")
end
```

### Quick Facade Usage
```eiffel
create mail.make
mail.gmail ("user@gmail.com", "app-password")
mail.send ("recipient@example.com", "Subject", "Body")
```

### With Attachments
```eiffel
smtp.add_attachment ("report.pdf", file_content, "application/pdf")
```

## Ecosystem Role

simple_smtp is a **service layer** library providing email capability to any application in the ecosystem.
