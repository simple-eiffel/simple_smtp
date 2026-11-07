note
	description: "[
		End-to-end: SIMPLE_SMTP.send over simple_net's real TCP socket to a fake
		SMTP server (SMTP_TEST_PEER) on its own SCOOP processor; and a send to
		a port nobody listens on.
	]"
	author: "simple_smtp team"
	date: "2026-10-08"

class
	TEST_SMTP_SESSION

inherit
	TEST_SET_BASE

feature -- Tests

	test_send_full_session
			-- A complete SMTP conversation succeeds and the server sees every command.
		local
			l_peer: separate SMTP_TEST_PEER
			l_smtp: SIMPLE_SMTP
			l_transcript: STRING
		do
			create l_peer.make
			create l_smtp.make ("127.0.0.1", peer_port (l_peer))
			l_smtp.set_timeout (10)
			l_smtp.set_from ("sender@example.com", "Sender")
			l_smtp.add_to ("rcpt@example.com", "Rcpt")
			l_smtp.set_subject ("Hello over a real socket")
			l_smtp.set_body ("Body line one.")
			start_peer (l_peer)
			assert ("send succeeded: " + l_smtp.last_error, l_smtp.send)
			l_transcript := peer_transcript (l_peer)
			assert ("EHLO sent", l_transcript.has_substring ("EHLO 127.0.0.1"))
			assert ("MAIL FROM sent", l_transcript.has_substring ("MAIL FROM:<sender@example.com>"))
			assert ("RCPT TO sent", l_transcript.has_substring ("RCPT TO:<rcpt@example.com>"))
			assert ("DATA sent", l_transcript.has_substring ("DATA"))
			assert ("QUIT sent", peer_saw_quit (l_peer))
			assert ("subject delivered", peer_message (l_peer).has_substring ("Subject: Hello over a real socket"))
			assert ("body delivered", peer_message (l_peer).has_substring ("Body line one."))
		end

	test_send_connection_refused
			-- No server: send fails and says why.
		local
			l_smtp: SIMPLE_SMTP
		do
			create l_smtp.make ("127.0.0.1", 48099)
			l_smtp.set_timeout (10)
			l_smtp.set_from ("sender@example.com", Void)
			l_smtp.add_to ("rcpt@example.com", Void)
			l_smtp.set_subject ("s")
			l_smtp.set_body ("b")
			refute ("send fails", l_smtp.send)
			assert ("error explains", l_smtp.last_error.has_substring ("Failed to connect"))
		end

	test_credentials_never_cross_a_plain_connection
			-- With no encryption, send refuses: the server never sees AUTH or a password.
		local
			l_peer: separate SMTP_TEST_PEER
			l_smtp: SIMPLE_SMTP
			l_transcript: STRING
		do
			create l_peer.make
			create l_smtp.make ("127.0.0.1", peer_port (l_peer))
			l_smtp.set_timeout (10)
			l_smtp.set_credentials ("user@example.com", "secret-value")
			l_smtp.set_from ("sender@example.com", Void)
			l_smtp.add_to ("rcpt@example.com", Void)
			l_smtp.set_subject ("s")
			l_smtp.set_body ("b")
			start_peer (l_peer)
			refute ("send refused", l_smtp.send)
			assert ("says why: " + l_smtp.last_error, l_smtp.last_error.has_substring ("not encrypted"))
			l_transcript := peer_transcript (l_peer)
			refute ("no AUTH reached the server", l_transcript.has_substring ("AUTH"))
			refute ("no mail reached the server", l_transcript.has_substring ("MAIL FROM"))
		end

	test_no_fallback_when_starttls_is_not_offered
			-- STARTTLS asked for and not offered: fail, never carry on in clear.
		local
			l_peer: separate SMTP_TEST_PEER
			l_smtp: SIMPLE_SMTP
			l_transcript: STRING
		do
			create l_peer.make
			create l_smtp.make ("127.0.0.1", peer_port (l_peer))
			l_smtp.set_timeout (10)
			l_smtp.enable_starttls
			l_smtp.set_from ("sender@example.com", Void)
			l_smtp.add_to ("rcpt@example.com", Void)
			l_smtp.set_subject ("s")
			l_smtp.set_body ("b")
			start_peer (l_peer)
			refute ("send refused", l_smtp.send)
			assert ("says why: " + l_smtp.last_error, l_smtp.last_error.has_substring ("STARTTLS"))
			l_transcript := peer_transcript (l_peer)
			refute ("no mail reached the server", l_transcript.has_substring ("MAIL FROM"))
		end

feature {NONE} -- SCOOP helpers

	peer_port (a_peer: separate SMTP_TEST_PEER): INTEGER
		do
			Result := a_peer.port
			assert ("peer listening", a_peer.is_listening)
		end

	start_peer (a_peer: separate SMTP_TEST_PEER)
		do
			a_peer.serve
		end

	peer_transcript (a_peer: separate SMTP_TEST_PEER): STRING
		require
			finished: a_peer.is_done
		do
			create Result.make_from_separate (a_peer.transcript)
			assert ("peer had no failure", a_peer.failure.is_empty)
		end

	peer_message (a_peer: separate SMTP_TEST_PEER): STRING
		require
			finished: a_peer.is_done
		do
			create Result.make_from_separate (a_peer.message)
		end

	peer_saw_quit (a_peer: separate SMTP_TEST_PEER): BOOLEAN
		require
			finished: a_peer.is_done
		do
			Result := a_peer.saw_quit
		end

end
