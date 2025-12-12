note
	description: "Test application for simple_smtp"
	author: "Larry Rix"

class
	SMTP_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: SIMPLE_SMTP_TEST_SET
		do
			create tests
			print ("simple_smtp test runner%N")
			print ("========================%N%N")

			passed := 0
			failed := 0

			-- Initialization
			run_test (agent tests.test_make, "test_make")
			run_test (agent tests.test_make_with_tls_port, "test_make_with_tls_port")
			run_test (agent tests.test_make_with_standard_port, "test_make_with_standard_port")

			-- Configuration
			run_test (agent tests.test_set_credentials, "test_set_credentials")
			run_test (agent tests.test_set_from, "test_set_from")
			run_test (agent tests.test_set_from_no_name, "test_set_from_no_name")
			run_test (agent tests.test_set_timeout, "test_set_timeout")
			run_test (agent tests.test_enable_tls, "test_enable_tls")
			run_test (agent tests.test_enable_starttls, "test_enable_starttls")

			-- Recipients
			run_test (agent tests.test_add_to, "test_add_to")
			run_test (agent tests.test_add_multiple_to, "test_add_multiple_to")
			run_test (agent tests.test_add_cc, "test_add_cc")
			run_test (agent tests.test_add_bcc, "test_add_bcc")
			run_test (agent tests.test_clear_recipients, "test_clear_recipients")

			-- Content
			run_test (agent tests.test_set_subject, "test_set_subject")
			run_test (agent tests.test_set_body, "test_set_body")
			run_test (agent tests.test_set_html_body, "test_set_html_body")
			run_test (agent tests.test_set_body_with_html, "test_set_body_with_html")
			run_test (agent tests.test_add_attachment, "test_add_attachment")
			run_test (agent tests.test_add_multiple_attachments, "test_add_multiple_attachments")
			run_test (agent tests.test_clear_attachments, "test_clear_attachments")

			-- Message Building
			run_test (agent tests.test_build_simple_message, "test_build_simple_message")
			run_test (agent tests.test_build_message_with_name, "test_build_message_with_name")
			run_test (agent tests.test_build_message_with_cc, "test_build_message_with_cc")
			run_test (agent tests.test_build_html_message, "test_build_html_message")
			run_test (agent tests.test_build_multipart_message, "test_build_multipart_message")
			run_test (agent tests.test_build_message_with_attachment, "test_build_message_with_attachment")

			-- Status
			run_test (agent tests.test_has_error_initially_false, "test_has_error_initially_false")
			run_test (agent tests.test_last_response_initially_empty, "test_last_response_initially_empty")

			-- Complete Email Setup
			run_test (agent tests.test_complete_email_setup, "test_complete_email_setup")

			-- AUTH PLAIN Support
			run_test (agent tests.test_set_auth_method_plain, "test_set_auth_method_plain")
			run_test (agent tests.test_set_auth_method_login, "test_set_auth_method_login")
			run_test (agent tests.test_prefer_auth_plain, "test_prefer_auth_plain")
			run_test (agent tests.test_build_auth_plain_credentials, "test_build_auth_plain_credentials")
			run_test (agent tests.test_auth_plain_credentials_format, "test_auth_plain_credentials_format")
			run_test (agent tests.test_complete_email_with_auth_plain, "test_complete_email_with_auth_plain")

			-- RFC 5322 Headers
			run_test (agent tests.test_build_message_has_date_header, "test_build_message_has_date_header")
			run_test (agent tests.test_build_message_has_message_id, "test_build_message_has_message_id")
			run_test (agent tests.test_message_id_uses_sender_domain, "test_message_id_uses_sender_domain")
			run_test (agent tests.test_date_header_format, "test_date_header_format")

			-- Reply-To Support
			run_test (agent tests.test_set_reply_to, "test_set_reply_to")
			run_test (agent tests.test_set_reply_to_no_name, "test_set_reply_to_no_name")
			run_test (agent tests.test_clear_reply_to, "test_clear_reply_to")
			run_test (agent tests.test_build_message_with_reply_to, "test_build_message_with_reply_to")
			run_test (agent tests.test_build_message_reply_to_with_name, "test_build_message_reply_to_with_name")
			run_test (agent tests.test_build_message_without_reply_to, "test_build_message_without_reply_to")

			-- Email Validation
			run_test (agent tests.test_valid_email_simple, "test_valid_email_simple")
			run_test (agent tests.test_valid_email_with_subdomain, "test_valid_email_with_subdomain")
			run_test (agent tests.test_valid_email_with_plus, "test_valid_email_with_plus")
			run_test (agent tests.test_invalid_email_empty, "test_invalid_email_empty")
			run_test (agent tests.test_invalid_email_no_at, "test_invalid_email_no_at")
			run_test (agent tests.test_invalid_email_no_local, "test_invalid_email_no_local")
			run_test (agent tests.test_invalid_email_no_domain, "test_invalid_email_no_domain")
			run_test (agent tests.test_invalid_email_no_dot_in_domain, "test_invalid_email_no_dot_in_domain")
			run_test (agent tests.test_invalid_email_dot_at_end, "test_invalid_email_dot_at_end")

			-- UUID Boundary
			run_test (agent tests.test_boundary_uses_uuid, "test_boundary_uses_uuid")
			run_test (agent tests.test_boundary_uniqueness, "test_boundary_uniqueness")

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
