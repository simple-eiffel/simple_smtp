note
	description: "[
		Zero-configuration email facade for beginners.

		One-liner email sending - pre-configured for popular providers.
		For full control, use SIMPLE_SMTP directly.

		Quick Start Examples:
			create mail.make

			-- Configure for Gmail
			mail.gmail ("your.email@gmail.com", "your-app-password")

			-- Or Outlook
			mail.outlook ("your.email@outlook.com", "your-password")

			-- Or any SMTP server
			mail.server ("smtp.example.com", 587, "user", "password")

			-- Send simple email
			mail.send ("recipient@example.com", "Hello!", "This is my message.")

			-- Send HTML email
			mail.send_html ("recipient@example.com", "Newsletter", "<h1>Hello</h1>")

			-- Check status
			if mail.has_error then
				print ("Error: " + mail.last_error)
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_SMTP_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick email facade.
		do
			create logger.make ("smtp_quick")
		end

feature -- Provider Configuration

	gmail (a_email, a_app_password: STRING)
			-- Configure for Gmail.
			-- Note: Requires App Password (not regular password).
			-- Enable at: https://myaccount.google.com/apppasswords
		require
			email_not_empty: not a_email.is_empty
			password_not_empty: not a_app_password.is_empty
		do
			logger.info ("Configuring Gmail for " + a_email)
			create smtp.make ("smtp.gmail.com", 587)
			smtp.set_credentials (a_email, a_app_password)
			smtp.set_from (a_email, Void)
			from_email := a_email
		ensure
			is_configured: is_configured
		end

	outlook (a_email, a_password: STRING)
			-- Configure for Outlook/Hotmail.
		require
			email_not_empty: not a_email.is_empty
			password_not_empty: not a_password.is_empty
		do
			logger.info ("Configuring Outlook for " + a_email)
			create smtp.make ("smtp.office365.com", 587)
			smtp.set_credentials (a_email, a_password)
			smtp.set_from (a_email, Void)
			from_email := a_email
		ensure
			is_configured: is_configured
		end

	yahoo (a_email, a_app_password: STRING)
			-- Configure for Yahoo Mail.
			-- Note: Requires App Password.
		require
			email_not_empty: not a_email.is_empty
			password_not_empty: not a_app_password.is_empty
		do
			logger.info ("Configuring Yahoo for " + a_email)
			create smtp.make ("smtp.mail.yahoo.com", 587)
			smtp.set_credentials (a_email, a_app_password)
			smtp.set_from (a_email, Void)
			from_email := a_email
		ensure
			is_configured: is_configured
		end

	server (a_host: STRING; a_port: INTEGER; a_username, a_password: STRING)
			-- Configure for any SMTP server.
			-- Port 587 = STARTTLS, Port 465 = SSL/TLS, Port 25 = Plain
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
			username_not_empty: not a_username.is_empty
		do
			logger.info ("Configuring SMTP server " + a_host + ":" + a_port.out)
			create smtp.make (a_host, a_port)
			smtp.set_credentials (a_username, a_password)
			smtp.set_from (a_username, Void)
			from_email := a_username
		ensure
			is_configured: is_configured
		end

feature -- Sender Configuration

	set_from (a_email: STRING; a_name: detachable STRING)
			-- Set sender email and optional display name.
		require
			is_configured: is_configured
			email_not_empty: not a_email.is_empty
		do
			if attached smtp as s then
				s.set_from (a_email, a_name)
			end
			from_email := a_email
		end

feature -- Status

	is_configured: BOOLEAN
			-- Is SMTP server configured?
		do
			Result := attached smtp and attached from_email
		end

	has_error: BOOLEAN
			-- Did last send fail?
		do
			Result := attached smtp as s and then s.has_error
		end

	last_error: STRING
			-- Error message from last failed send.
		do
			if attached smtp as s and then attached s.last_error as err then
				Result := err
			else
				Result := ""
			end
		ensure
			result_exists: Result /= Void
		end

	last_sent: BOOLEAN
			-- Was last email sent successfully?

feature -- Sending (One-liners)

	send (a_to, a_subject, a_body: STRING): BOOLEAN
			-- Send plain text email.
			-- Returns True on success.
		require
			is_configured: is_configured
			to_not_empty: not a_to.is_empty
			subject_not_empty: not a_subject.is_empty
		do
			logger.info ("Sending email to " + a_to + ": " + a_subject)
			if attached smtp as s then
				s.clear_recipients
				s.add_to (a_to, Void)
				s.set_subject (a_subject)
				s.set_body (a_body)
				s.send
				last_sent := not s.has_error
				Result := last_sent
				if Result then
					logger.info ("Email sent successfully")
				else
					logger.error ("Send failed: " + last_error)
				end
			end
		end

	send_html (a_to, a_subject, a_html_body: STRING): BOOLEAN
			-- Send HTML email.
		require
			is_configured: is_configured
			to_not_empty: not a_to.is_empty
			subject_not_empty: not a_subject.is_empty
		do
			logger.info ("Sending HTML email to " + a_to + ": " + a_subject)
			if attached smtp as s then
				s.clear_recipients
				s.add_to (a_to, Void)
				s.set_subject (a_subject)
				s.set_html_body (a_html_body)
				s.send
				last_sent := not s.has_error
				Result := last_sent
				if Result then
					logger.info ("HTML email sent successfully")
				else
					logger.error ("Send failed: " + last_error)
				end
			end
		end

	send_to_many (a_recipients: ARRAY [STRING]; a_subject, a_body: STRING): BOOLEAN
			-- Send email to multiple recipients.
		require
			is_configured: is_configured
			has_recipients: a_recipients.count > 0
			subject_not_empty: not a_subject.is_empty
		do
			logger.info ("Sending email to " + a_recipients.count.out + " recipients: " + a_subject)
			if attached smtp as s then
				s.clear_recipients
				across a_recipients as r loop
					s.add_to (r, Void)
				end
				s.set_subject (a_subject)
				s.set_body (a_body)
				s.send
				last_sent := not s.has_error
				Result := last_sent
			end
		end

feature -- Advanced Sending

	send_with_attachment (a_to, a_subject, a_body, a_attachment_path: STRING): BOOLEAN
			-- Send email with file attachment.
		require
			is_configured: is_configured
			to_not_empty: not a_to.is_empty
			subject_not_empty: not a_subject.is_empty
			attachment_exists: (create {RAW_FILE}.make_with_name (a_attachment_path)).exists
		local
			l_file: RAW_FILE
			l_content: STRING
			l_name: STRING
		do
			logger.info ("Sending email with attachment to " + a_to)
			if attached smtp as s then
				-- Read file
				create l_file.make_open_read (a_attachment_path)
				create l_content.make (l_file.count)
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				l_file.close

				-- Extract filename
				l_name := a_attachment_path.twin
				if l_name.has ('/') then
					l_name := l_name.substring (l_name.last_index_of ('/', l_name.count) + 1, l_name.count)
				elseif l_name.has ('\') then
					l_name := l_name.substring (l_name.last_index_of ('\', l_name.count) + 1, l_name.count)
				end

				s.clear_recipients
				s.add_to (a_to, Void)
				s.set_subject (a_subject)
				s.set_body (a_body)
				s.add_attachment (l_name, l_content, "application/octet-stream")
				s.send
				last_sent := not s.has_error
				Result := last_sent
			end
		end

feature -- Advanced Access

	smtp: detachable SIMPLE_SMTP
			-- Access underlying SMTP client for advanced operations.

feature {NONE} -- Implementation

	logger: SIMPLE_LOGGER
			-- Logger for debugging.

	from_email: detachable STRING
			-- Configured sender email.

invariant
	logger_exists: logger /= Void

end
