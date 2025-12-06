note
	description: "Tests for SIMPLE_SMTP"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_SMTP_TEST_SET

inherit
	TEST_SET_BASE

feature -- Test: Initialization

	test_make
			-- Test basic initialization.
		note
			testing: "covers/{SIMPLE_SMTP}.make"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_false ("no error initially", smtp.has_error)
			assert_false ("no sender initially", smtp.has_sender)
			assert_false ("no recipients initially", smtp.has_recipients)
		end

	test_make_with_tls_port
			-- Test initialization with TLS port 465.
		note
			testing: "covers/{SIMPLE_SMTP}.make"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 465)
			assert_false ("no error", smtp.has_error)
		end

	test_make_with_standard_port
			-- Test initialization with standard port 25.
		note
			testing: "covers/{SIMPLE_SMTP}.make"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 25)
			assert_false ("no error", smtp.has_error)
		end

feature -- Test: Configuration

	test_set_credentials
			-- Test setting authentication credentials.
		note
			testing: "covers/{SIMPLE_SMTP}.set_credentials"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_credentials ("user@example.com", "password123")
			assert_false ("no error", smtp.has_error)
		end

	test_set_from
			-- Test setting sender.
		note
			testing: "covers/{SIMPLE_SMTP}.set_from"
			testing: "covers/{SIMPLE_SMTP}.has_sender"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_false ("no sender before", smtp.has_sender)
			smtp.set_from ("sender@example.com", "Sender Name")
			assert_true ("has sender after", smtp.has_sender)
		end

	test_set_from_no_name
			-- Test setting sender without display name.
		note
			testing: "covers/{SIMPLE_SMTP}.set_from"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@example.com", Void)
			assert_true ("has sender", smtp.has_sender)
		end

	test_set_timeout
			-- Test setting timeout.
		note
			testing: "covers/{SIMPLE_SMTP}.set_timeout"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_timeout (60)
			assert_false ("no error", smtp.has_error)
		end

	test_enable_tls
			-- Test enabling TLS mode.
		note
			testing: "covers/{SIMPLE_SMTP}.enable_tls"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.enable_tls
			assert_false ("no error", smtp.has_error)
		end

	test_enable_starttls
			-- Test enabling STARTTLS mode.
		note
			testing: "covers/{SIMPLE_SMTP}.enable_starttls"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 465)
			smtp.enable_starttls
			assert_false ("no error", smtp.has_error)
		end

feature -- Test: Recipients

	test_add_to
			-- Test adding To recipient.
		note
			testing: "covers/{SIMPLE_SMTP}.add_to"
			testing: "covers/{SIMPLE_SMTP}.to_count"
			testing: "covers/{SIMPLE_SMTP}.has_recipients"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_integers_equal ("0 recipients", 0, smtp.to_count)
			assert_false ("no recipients", smtp.has_recipients)
			smtp.add_to ("recipient@example.com", "Recipient Name")
			assert_integers_equal ("1 recipient", 1, smtp.to_count)
			assert_true ("has recipients", smtp.has_recipients)
		end

	test_add_multiple_to
			-- Test adding multiple To recipients.
		note
			testing: "covers/{SIMPLE_SMTP}.add_to"
			testing: "covers/{SIMPLE_SMTP}.to_count"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.add_to ("first@example.com", "First")
			smtp.add_to ("second@example.com", "Second")
			smtp.add_to ("third@example.com", Void)
			assert_integers_equal ("3 recipients", 3, smtp.to_count)
		end

	test_add_cc
			-- Test adding Cc recipient.
		note
			testing: "covers/{SIMPLE_SMTP}.add_cc"
			testing: "covers/{SIMPLE_SMTP}.cc_count"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_integers_equal ("0 cc", 0, smtp.cc_count)
			smtp.add_cc ("cc@example.com", "CC Person")
			assert_integers_equal ("1 cc", 1, smtp.cc_count)
		end

	test_add_bcc
			-- Test adding Bcc recipient.
		note
			testing: "covers/{SIMPLE_SMTP}.add_bcc"
			testing: "covers/{SIMPLE_SMTP}.bcc_count"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_integers_equal ("0 bcc", 0, smtp.bcc_count)
			smtp.add_bcc ("bcc@example.com", "BCC Person")
			assert_integers_equal ("1 bcc", 1, smtp.bcc_count)
		end

	test_clear_recipients
			-- Test clearing recipients.
		note
			testing: "covers/{SIMPLE_SMTP}.clear_recipients"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.add_to ("to@example.com", Void)
			smtp.add_cc ("cc@example.com", Void)
			smtp.add_bcc ("bcc@example.com", Void)
			smtp.clear_recipients
			assert_integers_equal ("0 to", 0, smtp.to_count)
			assert_integers_equal ("0 cc", 0, smtp.cc_count)
			assert_integers_equal ("0 bcc", 0, smtp.bcc_count)
		end

feature -- Test: Content

	test_set_subject
			-- Test setting subject.
		note
			testing: "covers/{SIMPLE_SMTP}.set_subject"
			testing: "covers/{SIMPLE_SMTP}.has_subject_set"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_false ("no subject before", smtp.has_subject_set)
			smtp.set_subject ("Test Email Subject")
			assert_true ("has subject after", smtp.has_subject_set)
		end

	test_set_body
			-- Test setting plain text body.
		note
			testing: "covers/{SIMPLE_SMTP}.set_body"
			testing: "covers/{SIMPLE_SMTP}.has_body_set"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_false ("no body before", smtp.has_body_set)
			smtp.set_body ("This is the email body.")
			assert_true ("has body after", smtp.has_body_set)
		end

	test_set_html_body
			-- Test setting HTML body.
		note
			testing: "covers/{SIMPLE_SMTP}.set_html_body"
			testing: "covers/{SIMPLE_SMTP}.has_body_set"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_html_body ("<html><body><h1>Hello</h1></body></html>")
			assert_true ("has body", smtp.has_body_set)
		end

	test_set_body_with_html
			-- Test setting both text and HTML body.
		note
			testing: "covers/{SIMPLE_SMTP}.set_body_with_html"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_body_with_html ("Plain text", "<html><body>HTML</body></html>")
			assert_true ("has body", smtp.has_body_set)
		end

	test_add_attachment
			-- Test adding attachment.
		note
			testing: "covers/{SIMPLE_SMTP}.add_attachment"
			testing: "covers/{SIMPLE_SMTP}.attachment_count"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_integers_equal ("0 attachments", 0, smtp.attachment_count)
			smtp.add_attachment ("test.txt", "Hello World", "text/plain")
			assert_integers_equal ("1 attachment", 1, smtp.attachment_count)
		end

	test_add_multiple_attachments
			-- Test adding multiple attachments.
		note
			testing: "covers/{SIMPLE_SMTP}.add_attachment"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.add_attachment ("doc1.txt", "Content 1", "text/plain")
			smtp.add_attachment ("doc2.pdf", "PDF content", "application/pdf")
			assert_integers_equal ("2 attachments", 2, smtp.attachment_count)
		end

	test_clear_attachments
			-- Test clearing attachments.
		note
			testing: "covers/{SIMPLE_SMTP}.clear_attachments"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.add_attachment ("test.txt", "Content", "text/plain")
			smtp.clear_attachments
			assert_integers_equal ("0 attachments", 0, smtp.attachment_count)
		end

feature -- Test: Message Building

	test_build_simple_message
			-- Test building simple text email.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", Void)
			smtp.add_to ("recipient@test.com", Void)
			smtp.set_subject ("Test Subject")
			smtp.set_body ("Test body content")
			msg := smtp.build_message
			assert ("has from", msg.has_substring ("From:"))
			assert ("has to", msg.has_substring ("To:"))
			assert ("has subject", msg.has_substring ("Subject: Test Subject"))
			assert ("has body", msg.has_substring ("Test body content"))
			assert ("has mime", msg.has_substring ("MIME-Version: 1.0"))
		end

	test_build_message_with_name
			-- Test building message with display names.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", "Sender Name")
			smtp.add_to ("recipient@test.com", "Recipient Name")
			smtp.set_subject ("Test")
			smtp.set_body ("Body")
			msg := smtp.build_message
			assert ("has sender name", msg.has_substring ("Sender Name"))
		end

	test_build_message_with_cc
			-- Test building message with Cc.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", Void)
			smtp.add_to ("to@test.com", Void)
			smtp.add_cc ("cc@test.com", Void)
			smtp.set_subject ("Test")
			smtp.set_body ("Body")
			msg := smtp.build_message
			assert ("has cc header", msg.has_substring ("Cc:"))
			assert ("has cc email", msg.has_substring ("cc@test.com"))
		end

	test_build_html_message
			-- Test building HTML email.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", Void)
			smtp.add_to ("recipient@test.com", Void)
			smtp.set_subject ("HTML Test")
			smtp.set_html_body ("<html><body><h1>Hello</h1></body></html>")
			msg := smtp.build_message
			assert ("has html content-type", msg.has_substring ("text/html"))
			assert ("has html body", msg.has_substring ("<h1>Hello</h1>"))
		end

	test_build_multipart_message
			-- Test building multipart message with text and HTML.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", Void)
			smtp.add_to ("recipient@test.com", Void)
			smtp.set_subject ("Multipart Test")
			smtp.set_body_with_html ("Plain text version", "<html><body>HTML version</body></html>")
			msg := smtp.build_message
			assert ("has boundary", msg.has_substring ("boundary="))
			assert ("has text part", msg.has_substring ("text/plain"))
			assert ("has html part", msg.has_substring ("text/html"))
			assert ("has plain content", msg.has_substring ("Plain text version"))
			assert ("has html content", msg.has_substring ("HTML version"))
		end

	test_build_message_with_attachment
			-- Test building message with attachment.
		note
			testing: "covers/{SIMPLE_SMTP}.build_message"
		local
			smtp: SIMPLE_SMTP
			msg: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_from ("sender@test.com", Void)
			smtp.add_to ("recipient@test.com", Void)
			smtp.set_subject ("Attachment Test")
			smtp.set_body ("See attachment")
			smtp.add_attachment ("test.txt", "Attachment content", "text/plain")
			msg := smtp.build_message
			assert ("has multipart/mixed", msg.has_substring ("multipart/mixed"))
			assert ("has content-disposition", msg.has_substring ("Content-Disposition: attachment"))
			assert ("has filename", msg.has_substring ("filename=%"test.txt%""))
			assert ("has base64", msg.has_substring ("Content-Transfer-Encoding: base64"))
		end

feature -- Test: Status

	test_has_error_initially_false
			-- Test has_error is False initially.
		note
			testing: "covers/{SIMPLE_SMTP}.has_error"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_false ("no error initially", smtp.has_error)
			assert_true ("last_error empty", smtp.last_error.is_empty)
		end

	test_last_response_initially_empty
			-- Test last_response is empty initially.
		note
			testing: "covers/{SIMPLE_SMTP}.last_response"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			assert_true ("response empty", smtp.last_response.is_empty)
		end

feature -- Test: Complete Email Setup

	test_complete_email_setup
			-- Test setting up a complete email.
		note
			testing: "covers/{SIMPLE_SMTP}"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_credentials ("user@example.com", "password")
			smtp.set_from ("sender@example.com", "Sender")
			smtp.add_to ("to1@example.com", "Recipient 1")
			smtp.add_to ("to2@example.com", Void)
			smtp.add_cc ("cc@example.com", "CC Person")
			smtp.add_bcc ("bcc@example.com", Void)
			smtp.set_subject ("Complete Test")
			smtp.set_body_with_html ("Text body", "<html><body>HTML body</body></html>")
			smtp.add_attachment ("doc.pdf", "PDF data", "application/pdf")
			-- Verify all setup worked without error
			assert_false ("no error", smtp.has_error)
			assert_true ("has sender", smtp.has_sender)
			assert_true ("has recipients", smtp.has_recipients)
			assert_true ("has subject", smtp.has_subject_set)
			assert_true ("has body", smtp.has_body_set)
			assert_integers_equal ("2 to", 2, smtp.to_count)
			assert_integers_equal ("1 cc", 1, smtp.cc_count)
			assert_integers_equal ("1 bcc", 1, smtp.bcc_count)
			assert_integers_equal ("1 attachment", 1, smtp.attachment_count)
		end

feature -- Test: AUTH PLAIN Support

	test_set_auth_method_plain
			-- Test setting AUTH method to PLAIN.
		note
			testing: "covers/{SIMPLE_SMTP}.set_auth_method"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_auth_method ("PLAIN")
			assert_false ("no error", smtp.has_error)
		end

	test_set_auth_method_login
			-- Test setting AUTH method to LOGIN.
		note
			testing: "covers/{SIMPLE_SMTP}.set_auth_method"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_auth_method ("LOGIN")
			assert_false ("no error", smtp.has_error)
		end

	test_prefer_auth_plain
			-- Test prefer_auth_plain convenience method.
		note
			testing: "covers/{SIMPLE_SMTP}.prefer_auth_plain"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.prefer_auth_plain
			assert_false ("no error", smtp.has_error)
		end

	test_build_auth_plain_credentials
			-- Test building AUTH PLAIN credentials string.
		note
			testing: "covers/{SIMPLE_SMTP}.build_auth_plain_credentials"
		local
			smtp: SIMPLE_SMTP
			creds: STRING
			base64: SIMPLE_BASE64
			decoded: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			creds := smtp.build_auth_plain_credentials ("user@test.com", "password123")
			-- Verify it's valid base64 that can be decoded
			create base64.make
			decoded := base64.decode (creds)
			-- Format is \0username\0password
			assert ("starts with nul", decoded [1].code = 0)
			assert ("has username", decoded.has_substring ("user@test.com"))
			assert ("has password", decoded.has_substring ("password123"))
			-- Count NUL characters (should be 2)
			assert_integers_equal ("two nul chars", 2, decoded.occurrences ('%U'))
		end

	test_auth_plain_credentials_format
			-- Test AUTH PLAIN credentials format exactly.
		note
			testing: "covers/{SIMPLE_SMTP}.build_auth_plain_credentials"
		local
			smtp: SIMPLE_SMTP
			creds: STRING
			base64: SIMPLE_BASE64
			decoded: STRING
			expected: STRING
		do
			create smtp.make ("smtp.example.com", 587)
			creds := smtp.build_auth_plain_credentials ("alice", "secret")
			-- Decode and verify format: \0alice\0secret
			create base64.make
			decoded := base64.decode (creds)
			create expected.make (13)
			expected.append_character ('%U')
			expected.append ("alice")
			expected.append_character ('%U')
			expected.append ("secret")
			assert_strings_equal ("correct format", expected, decoded)
		end

	test_complete_email_with_auth_plain
			-- Test complete email setup with AUTH PLAIN.
		note
			testing: "covers/{SIMPLE_SMTP}"
		local
			smtp: SIMPLE_SMTP
		do
			create smtp.make ("smtp.example.com", 587)
			smtp.set_credentials ("user@example.com", "password")
			smtp.prefer_auth_plain
			smtp.set_from ("sender@example.com", "Sender")
			smtp.add_to ("recipient@example.com", "Recipient")
			smtp.set_subject ("AUTH PLAIN Test")
			smtp.set_body ("Testing AUTH PLAIN authentication")
			-- Verify setup is valid (we can't test actual sending without server)
			assert_false ("no error", smtp.has_error)
			assert_true ("has sender", smtp.has_sender)
			assert_true ("has recipients", smtp.has_recipients)
			assert_true ("has subject", smtp.has_subject_set)
			assert_true ("has body", smtp.has_body_set)
		end

end
