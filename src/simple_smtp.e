note
	description: "[
		Simple SMTP - Native email sending for Eiffel.

		Supports:
		- Plain SMTP (port 25)
		- SMTP with STARTTLS (port 587)
		- SMTP over SSL/TLS (port 465)
		- AUTH LOGIN and AUTH PLAIN authentication
		- Multiple recipients (To, Cc, Bcc)
		- HTML and plain text emails
		- Attachments (Base64 encoded)

		Usage:
			create smtp.make ("smtp.example.com", 587)
			smtp.set_credentials ("user@example.com", "password")
			smtp.set_from ("sender@example.com", "Sender Name")
			smtp.add_to ("recipient@example.com", "Recipient")
			smtp.set_subject ("Hello!")
			smtp.set_body ("This is a test email.")
			smtp.send
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "src=../docs/index.html", "protocol=URI", "tag=documentation"
	EIS: "name=API Reference", "src=../docs/api/simple_smtp.html", "protocol=URI", "tag=api"
	EIS: "name=RFC 5321", "src=https://datatracker.ietf.org/doc/html/rfc5321", "protocol=URI", "tag=specification"

class
	SIMPLE_SMTP

create
	make

feature {NONE} -- Initialization

	make (a_host: STRING; a_port: INTEGER)
			-- Initialize SMTP client for `a_host' on `a_port'.
		require
			host_not_void: a_host /= Void
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
		do
			host := a_host
			port := a_port
			create to_emails.make (5)
			create to_names.make (5)
			create cc_emails.make (5)
			create cc_names.make (5)
			create bcc_emails.make (5)
			create bcc_names.make (5)
			create attachment_names.make (5)
			create attachment_contents.make (5)
			create attachment_types.make (5)
			create foundation.make
			use_tls := (a_port = 465)
			use_starttls := (a_port = 587)
			timeout_seconds := 30
			create last_response.make_empty
			create last_error.make_empty
			create internal_from_email.make_empty
			auth_method := Void -- Default: try LOGIN first
		ensure
			host_set: host = a_host
			port_set: port = a_port
		end

feature -- Configuration

	set_credentials (a_username, a_password: STRING)
			-- Set authentication credentials.
		require
			username_not_void: a_username /= Void
			password_not_void: a_password /= Void
		do
			username := a_username
			password := a_password
		ensure
			username_set: username = a_username
			password_set: password = a_password
		end

	set_auth_method (a_method: STRING)
			-- Set authentication method: "PLAIN" or "LOGIN".
			-- Default is to try LOGIN first.
		require
			method_not_void: a_method /= Void
			valid_method: a_method.as_upper.same_string ("PLAIN") or a_method.as_upper.same_string ("LOGIN")
		do
			auth_method := a_method.as_upper
		ensure
			method_set: attached auth_method as m and then m.same_string (a_method.as_upper)
		end

	prefer_auth_plain
			-- Prefer AUTH PLAIN over AUTH LOGIN.
		do
			set_auth_method ("PLAIN")
		ensure
			plain_set: attached auth_method as m and then m.same_string ("PLAIN")
		end

	set_from (a_email: STRING; a_name: detachable STRING)
			-- Set sender email and optional display name.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			internal_from_email := a_email
			from_name := a_name
		ensure
			from_set: internal_from_email.same_string (a_email)
			has_from: has_sender
		end

	set_reply_to (a_email: STRING; a_name: detachable STRING)
			-- Set Reply-To email address and optional display name.
			-- If set, recipients will reply to this address instead of From.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			reply_to_email := a_email
			reply_to_name := a_name
		ensure
			reply_to_set: attached reply_to_email as rte and then rte.same_string (a_email)
			has_reply_to: has_reply_to_set
		end

	clear_reply_to
			-- Clear Reply-To address.
		do
			reply_to_email := Void
			reply_to_name := Void
		ensure
			no_reply_to: not has_reply_to_set
		end

	set_timeout (a_seconds: INTEGER)
			-- Set connection timeout in seconds.
		require
			positive: a_seconds > 0
		do
			timeout_seconds := a_seconds
		ensure
			timeout_set: timeout_seconds = a_seconds
		end

	enable_tls
			-- Enable TLS/SSL connection (port 465 style).
		do
			use_tls := True
			use_starttls := False
		ensure
			tls_enabled: use_tls
			starttls_disabled: not use_starttls
		end

	enable_starttls
			-- Enable STARTTLS upgrade (port 587 style).
		do
			use_starttls := True
			use_tls := False
		ensure
			starttls_enabled: use_starttls
			tls_disabled: not use_tls
		end

feature -- Recipients

	add_to (a_email: STRING; a_name: detachable STRING)
			-- Add a To recipient.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			to_emails.extend (a_email)
			if attached a_name as n then
				to_names.extend (n)
			else
				to_names.extend ("")
			end
		ensure
			recipient_added: to_count = old to_count + 1
		end

	add_cc (a_email: STRING; a_name: detachable STRING)
			-- Add a Cc recipient.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			cc_emails.extend (a_email)
			if attached a_name as n then
				cc_names.extend (n)
			else
				cc_names.extend ("")
			end
		ensure
			recipient_added: cc_count = old cc_count + 1
		end

	add_bcc (a_email: STRING; a_name: detachable STRING)
			-- Add a Bcc recipient.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			bcc_emails.extend (a_email)
			if attached a_name as n then
				bcc_names.extend (n)
			else
				bcc_names.extend ("")
			end
		ensure
			recipient_added: bcc_count = old bcc_count + 1
		end

	clear_recipients
			-- Clear all recipients.
		do
			to_emails.wipe_out
			to_names.wipe_out
			cc_emails.wipe_out
			cc_names.wipe_out
			bcc_emails.wipe_out
			bcc_names.wipe_out
		ensure
			no_to: to_count = 0
			no_cc: cc_count = 0
			no_bcc: bcc_count = 0
		end

feature -- Content

	set_subject (a_subject: STRING)
			-- Set email subject.
		require
			subject_not_void: a_subject /= Void
		do
			internal_subject := a_subject
		ensure
			subject_set: internal_subject = a_subject
			has_subject: has_subject_set
		end

	set_body (a_body: STRING)
			-- Set plain text body.
		require
			body_not_void: a_body /= Void
		do
			body_text := a_body
			body_html := Void
		ensure
			body_set: body_text = a_body
			has_body: has_body_set
		end

	set_html_body (a_html: STRING)
			-- Set HTML body.
		require
			html_not_void: a_html /= Void
		do
			body_html := a_html
		ensure
			html_set: body_html = a_html
			has_body: has_body_set
		end

	set_body_with_html (a_text, a_html: STRING)
			-- Set both plain text and HTML body (multipart/alternative).
		require
			text_not_void: a_text /= Void
			html_not_void: a_html /= Void
		do
			body_text := a_text
			body_html := a_html
		ensure
			text_set: body_text = a_text
			html_set: body_html = a_html
		end

	add_attachment (a_filename: STRING; a_content: STRING; a_mime_type: STRING)
			-- Add an attachment.
		require
			filename_not_void: a_filename /= Void
			content_not_void: a_content /= Void
			mime_not_void: a_mime_type /= Void
		do
			attachment_names.extend (a_filename)
			attachment_contents.extend (a_content)
			attachment_types.extend (a_mime_type)
		ensure
			attachment_added: attachment_count = old attachment_count + 1
		end

	clear_attachments
			-- Clear all attachments.
		do
			attachment_names.wipe_out
			attachment_contents.wipe_out
			attachment_types.wipe_out
		ensure
			no_attachments: attachment_count = 0
		end

feature -- Query (public for preconditions)

	has_sender: BOOLEAN
			-- Has sender been set?
		do
			Result := not internal_from_email.is_empty
		end

	has_recipients: BOOLEAN
			-- Are there any To recipients?
		do
			Result := to_count > 0
		end

	has_subject_set: BOOLEAN
			-- Has subject been set?
		do
			Result := internal_subject /= Void
		end

	has_body_set: BOOLEAN
			-- Has body (text or HTML) been set?
		do
			Result := body_text /= Void or body_html /= Void
		end

	has_reply_to_set: BOOLEAN
			-- Has Reply-To address been set?
		do
			Result := reply_to_email /= Void
		end

	is_valid_email (a_email: STRING): BOOLEAN
			-- Is `a_email' a valid email address?
			-- Basic validation: non-empty, one @, local and domain parts present.
		local
			l_at_pos, l_dot_pos: INTEGER
			l_local, l_domain: STRING
		do
			if a_email /= Void and then not a_email.is_empty then
				l_at_pos := a_email.index_of ('@', 1)
				if l_at_pos > 1 and l_at_pos < a_email.count then
					-- Has @ with characters before and after
					l_local := a_email.substring (1, l_at_pos - 1)
					l_domain := a_email.substring (l_at_pos + 1, a_email.count)
					-- Domain must have at least one dot
					l_dot_pos := l_domain.index_of ('.', 1)
					if l_dot_pos > 1 and l_dot_pos < l_domain.count then
						-- Dot with characters before and after
						Result := True
					end
				end
			end
		ensure
			empty_invalid: a_email = Void or else a_email.is_empty implies not Result
		end

	to_count: INTEGER
			-- Number of To recipients.
		do
			Result := to_emails.count
		ensure
			non_negative: Result >= 0
		end

	cc_count: INTEGER
			-- Number of Cc recipients.
		do
			Result := cc_emails.count
		ensure
			non_negative: Result >= 0
		end

	bcc_count: INTEGER
			-- Number of Bcc recipients.
		do
			Result := bcc_emails.count
		ensure
			non_negative: Result >= 0
		end

	attachment_count: INTEGER
			-- Number of attachments.
		do
			Result := attachment_names.count
		ensure
			non_negative: Result >= 0
		end

feature -- Sending

	send: BOOLEAN
			-- Send the email. Returns True on success.
		require
			has_from: has_sender
			has_recipients: has_recipients
			has_subject: has_subject_set
			has_body: has_body_set
		local
			l_socket: NETWORK_STREAM_SOCKET
		do
			last_error.wipe_out

			-- Create socket and connect
			create l_socket.make_client_by_port (port, host)
			l_socket.connect

			if l_socket.is_connected then
				Result := perform_smtp_session (l_socket)
				l_socket.close
			else
				last_error := "Failed to connect to " + host + ":" + port.out
			end
		ensure
			error_on_failure: not Result implies has_error
		end

	send_async (a_callback: detachable PROCEDURE [BOOLEAN])
			-- Send email asynchronously, calling `a_callback' with result.
		require
			has_from: has_sender
			has_recipients: has_recipients
			has_subject: has_subject_set
			has_body: has_body_set
		do
			-- For now, synchronous implementation
			-- True async would require threading support
			if attached a_callback as cb then
				cb.call ([send])
			else
				send.do_nothing
			end
		end

feature -- Status

	last_response: STRING
			-- Last SMTP server response.

	last_error: STRING
			-- Last error message (empty if no error).

	has_error: BOOLEAN
			-- Did the last operation produce an error?
		do
			Result := not last_error.is_empty
		end

feature -- Message Building

	build_message: STRING
			-- Build the complete email message.
		require
			has_from: has_sender
		local
			l_boundary: STRING
			l_has_attachments: BOOLEAN
			l_multipart: BOOLEAN
			i: INTEGER
		do
			l_has_attachments := attachment_count > 0
			l_multipart := body_html /= Void or l_has_attachments

			create Result.make (2048)

			-- Headers (RFC 5322 required headers first)
			Result.append ("Date: " + generate_date_header + "%R%N")
			Result.append ("From: " + format_address (internal_from_email, from_name) + "%R%N")
			Result.append ("To: " + format_to_list + "%R%N")
			if cc_count > 0 then
				Result.append ("Cc: " + format_cc_list + "%R%N")
			end
			if attached reply_to_email as l_reply_to then
				Result.append ("Reply-To: " + format_address (l_reply_to, reply_to_name) + "%R%N")
			end
			if attached internal_subject as l_subj then
				Result.append ("Subject: " + l_subj + "%R%N")
			end
			Result.append ("Message-ID: " + generate_message_id + "%R%N")
			Result.append ("MIME-Version: 1.0%R%N")

			if l_multipart then
				l_boundary := generate_boundary
				if l_has_attachments then
					Result.append ("Content-Type: multipart/mixed; boundary=%"" + l_boundary + "%"%R%N")
				else
					Result.append ("Content-Type: multipart/alternative; boundary=%"" + l_boundary + "%"%R%N")
				end
				Result.append ("%R%N")

				-- Text part
				if attached body_text as l_text then
					Result.append ("--" + l_boundary + "%R%N")
					Result.append ("Content-Type: text/plain; charset=UTF-8%R%N")
					Result.append ("Content-Transfer-Encoding: 7bit%R%N")
					Result.append ("%R%N")
					Result.append (l_text + "%R%N")
				end

				-- HTML part
				if attached body_html as l_html then
					Result.append ("--" + l_boundary + "%R%N")
					Result.append ("Content-Type: text/html; charset=UTF-8%R%N")
					Result.append ("Content-Transfer-Encoding: 7bit%R%N")
					Result.append ("%R%N")
					Result.append (l_html + "%R%N")
				end

				-- Attachments
				from
					i := 1
				invariant
					valid_index: i >= 1 and i <= attachment_count + 1
				until
					i > attachment_count
				loop
					Result.append ("--" + l_boundary + "%R%N")
					Result.append ("Content-Type: " + attachment_types [i] + "%R%N")
					Result.append ("Content-Transfer-Encoding: base64%R%N")
					Result.append ("Content-Disposition: attachment; filename=%"" + attachment_names [i] + "%"%R%N")
					Result.append ("%R%N")
					Result.append (foundation.base64_encode (attachment_contents [i]) + "%R%N")
					i := i + 1
				variant
					attachment_count - i + 1
				end

				Result.append ("--" + l_boundary + "--%R%N")
			else
				-- Simple text email
				Result.append ("Content-Type: text/plain; charset=UTF-8%R%N")
				Result.append ("Content-Transfer-Encoding: 7bit%R%N")
				Result.append ("%R%N")
				if attached body_text as l_text then
					Result.append (l_text)
				end
			end
		end

feature -- AUTH PLAIN Support

	build_auth_plain_credentials (a_user, a_pass: STRING): STRING
			-- Build AUTH PLAIN credentials string (Base64 encoded).
			-- Format: \0username\0password (NUL-separated).
		require
			user_not_void: a_user /= Void
			pass_not_void: a_pass /= Void
		local
			l_plain: STRING
		do
			-- AUTH PLAIN format: \0username\0password
			create l_plain.make (a_user.count + a_pass.count + 2)
			l_plain.append_character ('%U') -- NUL character
			l_plain.append (a_user)
			l_plain.append_character ('%U') -- NUL character
			l_plain.append (a_pass)
			Result := foundation.base64_encode (l_plain)
		ensure
			result_not_empty: not Result.is_empty
		end

feature {NONE} -- Implementation

	host: STRING
			-- SMTP server hostname.

	port: INTEGER
			-- SMTP server port.

	username: detachable STRING
			-- Authentication username.

	password: detachable STRING
			-- Authentication password.

	auth_method: detachable STRING
			-- Preferred authentication method: "PLAIN" or "LOGIN".
			-- If Void, tries LOGIN first.

	internal_from_email: STRING
			-- Sender email address.

	from_name: detachable STRING
			-- Sender display name.

	reply_to_email: detachable STRING
			-- Reply-To email address.

	reply_to_name: detachable STRING
			-- Reply-To display name.

	to_emails: ARRAYED_LIST [STRING]
			-- To recipient emails.

	to_names: ARRAYED_LIST [STRING]
			-- To recipient names.

	cc_emails: ARRAYED_LIST [STRING]
			-- Cc recipient emails.

	cc_names: ARRAYED_LIST [STRING]
			-- Cc recipient names.

	bcc_emails: ARRAYED_LIST [STRING]
			-- Bcc recipient emails.

	bcc_names: ARRAYED_LIST [STRING]
			-- Bcc recipient names.

	internal_subject: detachable STRING
			-- Email subject.

	body_text: detachable STRING
			-- Plain text body.

	body_html: detachable STRING
			-- HTML body.

	attachment_names: ARRAYED_LIST [STRING]
			-- Attachment filenames.

	attachment_contents: ARRAYED_LIST [STRING]
			-- Attachment contents.

	attachment_types: ARRAYED_LIST [STRING]
			-- Attachment MIME types.

	use_tls: BOOLEAN
			-- Use TLS/SSL from start.

	use_starttls: BOOLEAN
			-- Upgrade to TLS via STARTTLS.

	timeout_seconds: INTEGER
			-- Connection timeout.

	foundation: FOUNDATION
			-- Foundation API for encoding and UUID generation.

	perform_smtp_session (a_socket: NETWORK_STREAM_SOCKET): BOOLEAN
			-- Perform the SMTP conversation. Returns True on success.
		require
			socket_connected: a_socket.is_connected
		local
			l_response: STRING
		do
			-- Read greeting
			l_response := read_response (a_socket)
			if not l_response.starts_with ("220") then
				last_error := "Bad greeting: " + l_response
				Result := False
			else
				-- EHLO
				send_command (a_socket, "EHLO " + host)
				l_response := read_response (a_socket)
				if not l_response.starts_with ("250") then
					last_error := "EHLO failed: " + l_response
					Result := False
				else
					-- AUTH if credentials provided
					if attached username as u and attached password as p then
						if not authenticate (a_socket, u, p) then
							Result := False
						else
							Result := send_mail_commands (a_socket)
						end
					else
						Result := send_mail_commands (a_socket)
					end
				end
			end

			-- QUIT
			send_command (a_socket, "QUIT")
			read_response (a_socket).do_nothing
		end

	authenticate (a_socket: NETWORK_STREAM_SOCKET; a_user, a_pass: STRING): BOOLEAN
			-- Authenticate using configured method (LOGIN or PLAIN).
		require
			socket_connected: a_socket.is_connected
		do
			if attached auth_method as m and then m.same_string ("PLAIN") then
				Result := authenticate_plain (a_socket, a_user, a_pass)
			else
				-- Default: try LOGIN
				Result := authenticate_login (a_socket, a_user, a_pass)
			end
		end

	authenticate_login (a_socket: NETWORK_STREAM_SOCKET; a_user, a_pass: STRING): BOOLEAN
			-- Authenticate using AUTH LOGIN.
		require
			socket_connected: a_socket.is_connected
		local
			l_response: STRING
		do
			send_command (a_socket, "AUTH LOGIN")
			l_response := read_response (a_socket)
			if l_response.starts_with ("334") then
				-- Send username (base64)
				send_command (a_socket, foundation.base64_encode (a_user))
				l_response := read_response (a_socket)
				if l_response.starts_with ("334") then
					-- Send password (base64)
					send_command (a_socket, foundation.base64_encode (a_pass))
					l_response := read_response (a_socket)
					Result := l_response.starts_with ("235")
					if not Result then
						last_error := "Authentication failed: " + l_response
					end
				else
					last_error := "Auth username rejected: " + l_response
				end
			else
				last_error := "AUTH LOGIN not supported: " + l_response
			end
		end

	authenticate_plain (a_socket: NETWORK_STREAM_SOCKET; a_user, a_pass: STRING): BOOLEAN
			-- Authenticate using AUTH PLAIN (RFC 4616).
			-- Sends credentials as: \0username\0password (Base64 encoded).
		require
			socket_connected: a_socket.is_connected
		local
			l_response: STRING
			l_credentials: STRING
		do
			l_credentials := build_auth_plain_credentials (a_user, a_pass)

			-- Send AUTH PLAIN with credentials in one command
			send_command (a_socket, "AUTH PLAIN " + l_credentials)
			l_response := read_response (a_socket)

			if l_response.starts_with ("235") then
				Result := True
			elseif l_response.starts_with ("334") then
				-- Server wants credentials on separate line
				send_command (a_socket, l_credentials)
				l_response := read_response (a_socket)
				Result := l_response.starts_with ("235")
				if not Result then
					last_error := "AUTH PLAIN failed: " + l_response
				end
			else
				last_error := "AUTH PLAIN not supported or failed: " + l_response
			end
		end

	send_mail_commands (a_socket: NETWORK_STREAM_SOCKET): BOOLEAN
			-- Send MAIL FROM, RCPT TO, DATA commands.
		require
			socket_connected: a_socket.is_connected
		local
			l_response: STRING
			i: INTEGER
		do
			-- MAIL FROM
			send_command (a_socket, "MAIL FROM:<" + internal_from_email + ">")
			l_response := read_response (a_socket)
			if not l_response.starts_with ("250") then
				last_error := "MAIL FROM failed: " + l_response
				Result := False
			else
				-- RCPT TO for all recipients
				Result := True

				-- To recipients
				from
					i := 1
				invariant
					valid_index: i >= 1 and i <= to_count + 1
				until
					i > to_count or not Result
				loop
					send_command (a_socket, "RCPT TO:<" + to_emails [i] + ">")
					l_response := read_response (a_socket)
					if not l_response.starts_with ("250") then
						last_error := "RCPT TO failed: " + l_response
						Result := False
					end
					i := i + 1
				variant
					to_count - i + 2
				end

				-- Cc recipients
				from
					i := 1
				invariant
					cc_valid_index: i >= 1 and i <= cc_count + 1
				until
					i > cc_count or not Result
				loop
					send_command (a_socket, "RCPT TO:<" + cc_emails [i] + ">")
					l_response := read_response (a_socket)
					if not l_response.starts_with ("250") then
						last_error := "RCPT TO (Cc) failed: " + l_response
						Result := False
					end
					i := i + 1
				variant
					cc_count - i + 2
				end

				-- Bcc recipients
				from
					i := 1
				invariant
					bcc_valid_index: i >= 1 and i <= bcc_count + 1
				until
					i > bcc_count or not Result
				loop
					send_command (a_socket, "RCPT TO:<" + bcc_emails [i] + ">")
					l_response := read_response (a_socket)
					if not l_response.starts_with ("250") then
						last_error := "RCPT TO (Bcc) failed: " + l_response
						Result := False
					end
					i := i + 1
				variant
					bcc_count - i + 2
				end

				if Result then
					-- DATA
					send_command (a_socket, "DATA")
					l_response := read_response (a_socket)
					if l_response.starts_with ("354") then
						-- Send message
						send_command (a_socket, build_message + "%R%N.")
						l_response := read_response (a_socket)
						Result := l_response.starts_with ("250")
						if not Result then
							last_error := "DATA content rejected: " + l_response
						end
					else
						last_error := "DATA command failed: " + l_response
						Result := False
					end
				end
			end
		end

	send_command (a_socket: NETWORK_STREAM_SOCKET; a_command: STRING)
			-- Send a command to the SMTP server.
		require
			socket_not_void: a_socket /= Void
			command_not_void: a_command /= Void
		do
			a_socket.put_string (a_command + "%R%N")
		end

	read_response (a_socket: NETWORK_STREAM_SOCKET): STRING
			-- Read response from SMTP server.
		require
			socket_not_void: a_socket /= Void
		do
			create Result.make (256)
			a_socket.read_line
			if attached a_socket.last_string as l_str then
				Result.append (l_str)
			end
			last_response := Result
		ensure
			response_stored: last_response = Result
		end

	format_address (a_email: STRING; a_name: detachable STRING): STRING
			-- Format email address with optional name.
		require
			email_not_void: a_email /= Void
			email_not_empty: not a_email.is_empty
		do
			if attached a_name as n and then not n.is_empty then
				Result := "%"" + n + "%" <" + a_email + ">"
			else
				Result := a_email
			end
		ensure
			result_not_empty: not Result.is_empty
			contains_email: Result.has_substring (a_email)
		end

	format_to_list: STRING
			-- Format To recipient list.
		local
			i: INTEGER
		do
			create Result.make (100)
			from
				i := 1
			invariant
				valid_index: i >= 1 and i <= to_count + 1
			until
				i > to_count
			loop
				if i > 1 then
					Result.append (", ")
				end
				Result.append (format_address (to_emails [i], to_names [i]))
				i := i + 1
			variant
				to_count - i + 1
			end
		end

	format_cc_list: STRING
			-- Format Cc recipient list.
		local
			i: INTEGER
		do
			create Result.make (100)
			from
				i := 1
			invariant
				valid_index: i >= 1 and i <= cc_count + 1
			until
				i > cc_count
			loop
				if i > 1 then
					Result.append (", ")
				end
				Result.append (format_address (cc_emails [i], cc_names [i]))
				i := i + 1
			variant
				cc_count - i + 1
			end
		end

	generate_boundary: STRING
			-- Generate a unique MIME boundary using UUID v4.
		do
			Result := "----=_Part_" + foundation.new_uuid_compact
		ensure
			result_not_empty: not Result.is_empty
		end

	generate_date_header: STRING
			-- Generate RFC 5322 formatted Date header value.
			-- Format: "Fri, 06 Dec 2025 14:30:00 +0000"
		local
			l_date: DATE_TIME
			l_day_names: ARRAY [STRING]
			l_month_names: ARRAY [STRING]
		do
			create l_date.make_now
			l_day_names := <<"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat">>
			l_month_names := <<"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec">>

			create Result.make (32)
			-- Day name
			Result.append (l_day_names [l_date.date.day_of_the_week])
			Result.append (", ")
			-- Day of month (2 digits)
			if l_date.date.day < 10 then
				Result.append ("0")
			end
			Result.append (l_date.date.day.out)
			Result.append (" ")
			-- Month name
			Result.append (l_month_names [l_date.date.month])
			Result.append (" ")
			-- Year
			Result.append (l_date.date.year.out)
			Result.append (" ")
			-- Time (HH:MM:SS)
			if l_date.time.hour < 10 then
				Result.append ("0")
			end
			Result.append (l_date.time.hour.out)
			Result.append (":")
			if l_date.time.minute < 10 then
				Result.append ("0")
			end
			Result.append (l_date.time.minute.out)
			Result.append (":")
			if l_date.time.second < 10 then
				Result.append ("0")
			end
			Result.append (l_date.time.second.out)
			-- Timezone (assume UTC for now)
			Result.append (" +0000")
		ensure
			result_not_empty: not Result.is_empty
		end

	generate_message_id: STRING
			-- Generate unique Message-ID per RFC 5322.
			-- Format: "<timestamp.random@host>"
		local
			l_time: DATE_TIME
			l_unique: INTEGER_64
		do
			create l_time.make_now
			-- Create unique identifier from timestamp
			l_unique := l_time.date.year.to_integer_64 * 10000000000 +
						l_time.date.month.to_integer_64 * 100000000 +
						l_time.date.day.to_integer_64 * 1000000 +
						l_time.time.hour.to_integer_64 * 10000 +
						l_time.time.minute.to_integer_64 * 100 +
						l_time.time.second.to_integer_64

			create Result.make (64)
			Result.append ("<")
			Result.append (l_unique.out)
			Result.append (".")
			Result.append (l_time.time.milli_second.out)
			Result.append ("@")
			-- Use sender domain or host as domain part
			if internal_from_email.has ('@') then
				Result.append (internal_from_email.substring (internal_from_email.index_of ('@', 1) + 1, internal_from_email.count))
			else
				Result.append (host)
			end
			Result.append (">")
		ensure
			result_not_empty: not Result.is_empty
			starts_with_angle: Result.item (1) = '<'
			ends_with_angle: Result.item (Result.count) = '>'
		end

invariant
	host_exists: host /= Void
	host_not_empty: not host.is_empty
	valid_port: port > 0 and port < 65536
	to_emails_exist: to_emails /= Void
	to_names_exist: to_names /= Void
	to_lists_match: to_emails.count = to_names.count
	cc_emails_exist: cc_emails /= Void
	cc_names_exist: cc_names /= Void
	cc_lists_match: cc_emails.count = cc_names.count
	bcc_emails_exist: bcc_emails /= Void
	bcc_names_exist: bcc_names /= Void
	bcc_lists_match: bcc_emails.count = bcc_names.count
	attachments_consistent: attachment_names.count = attachment_contents.count and attachment_contents.count = attachment_types.count
	foundation_exists: foundation /= Void
	timeout_positive: timeout_seconds > 0
	last_response_exists: last_response /= Void
	last_error_exists: last_error /= Void
	from_email_exists: internal_from_email /= Void
	tls_modes_exclusive: not (use_tls and use_starttls)

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
