note
	description: "[
		A one-session fake SMTP server on loopback, for the integration test.
		Create it as `separate' so it runs on its own SCOOP processor while
		SIMPLE_SMTP.send talks to it through simple_net's real CLIENT_SOCKET.

		Replies 220 on connect, 250 to EHLO/MAIL/RCPT, 354 to DATA, 250 after
		the message's terminating "<CRLF>.<CRLF>", 221 to QUIT. `transcript'
		records the command lines; `message' the DATA content.
	]"
	author: "simple_smtp team"
	date: "2026-10-08"

class
	SMTP_TEST_PEER

create
	make

feature {NONE} -- Initialization

	make
			-- Listen on a free loopback port in 48100..48999.
		local
			l_port: INTEGER
			l_server: SERVER_SOCKET
		do
			from
				l_port := 48100
			until
				is_listening or l_port > 48999
			loop
				create l_server.make_for_address (create {ADDRESS}.make_for_localhost_port (l_port))
				l_server.set_timeout (10.0)
				if l_server.listen (2) then
					server := l_server
					port := l_port
					is_listening := True
				end
				l_port := l_port + 1
			variant
				48999 - l_port + 1
			end
		end

feature -- Access

	port: INTEGER
			-- Port listened on (0 if none was free)

	transcript: STRING
			-- Command lines received, each followed by "%N"
		attribute
			create Result.make_empty
		end

	message: STRING
			-- DATA content received (without the terminating ".")
		attribute
			create Result.make_empty
		end

	failure: STRING
			-- What went wrong on this side, if anything
		attribute
			create Result.make_empty
		end

feature -- Status report

	is_listening: BOOLEAN
			-- Is the peer listening?

	is_done: BOOLEAN
			-- Has `serve' finished?

	saw_quit: BOOLEAN
			-- Did the client end with QUIT?

feature -- Basic operations

	serve
			-- Run one SMTP session.
		local
			l_buffer, l_line: STRING
			l_in_data, l_stop: BOOLEAN
			l_end: INTEGER
		do
			if attached server as al_server and then attached al_server.accept as al_c then
				al_c.set_timeout (10.0)
				reply (al_c, "220 fake.smtp ready")
				create l_buffer.make_empty
				from
				until
					l_stop
				loop
					if l_in_data then
						l_end := l_buffer.substring_index ("%R%N.%R%N", 1)
						if l_end > 0 then
							message := l_buffer.substring (1, l_end + 1)
							l_buffer.remove_head (l_end + 4)
							l_in_data := False
							reply (al_c, "250 queued")
						else
							l_stop := not read_more (al_c, l_buffer)
						end
					else
						l_end := l_buffer.substring_index ("%R%N", 1)
						if l_end > 0 then
							l_line := l_buffer.substring (1, l_end - 1)
							l_buffer.remove_head (l_end + 1)
							transcript.append (l_line + "%N")
							if l_line.starts_with ("DATA") then
								l_in_data := True
								reply (al_c, "354 go ahead")
							elseif l_line.starts_with ("QUIT") then
								saw_quit := True
								reply (al_c, "221 bye")
								l_stop := True
							else
								reply (al_c, "250 ok")
							end
						else
							l_stop := not read_more (al_c, l_buffer)
						end
					end
				end
				al_c.close
				al_server.close
			else
				failure := "no client"
			end
			is_done := True
		end

feature {NONE} -- Implementation

	server: detachable SERVER_SOCKET
			-- Listening socket

	reply (a_c: CONNECTION; a_line: STRING)
			-- Send `a_line' + CRLF.
		do
			if not a_c.send_string (a_line + "%R%N") then
				failure := "reply failed"
			end
		end

	read_more (a_c: CONNECTION; a_buffer: STRING): BOOLEAN
			-- Append what arrives to `a_buffer'; False at end of stream or error.
		local
			l_chunk: STRING
		do
			l_chunk := a_c.receive_string
			if l_chunk.is_empty then
				if a_c.is_error then
					failure := "receive error " + a_c.last_error_code.out
				end
			else
				a_buffer.append (l_chunk)
				Result := True
			end
		end

end
