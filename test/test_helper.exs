defmodule PlugShopifyEmbeddedJWTAuthTest.JWTHelper do
  @moduledoc """
  Helper data
  """

  def api_key, do: "1r30mrvCFMfq2DLGuIXyY2veEJVgTtDD"
  def api_secret, do: "TBB5wltKarRtKn5mUVZck9RxHePNN6Jo"

  def jwt_header,
    do: %{
      "alg" => "HS256",
      "typ" => "JWT"
    }

  def jwt_payload,
    do: %{
      "iss" => "https://example.myshopify.com/admin",
      "dest" => "https://example.myshopify.com",
      "aud" => "#{api_key()}",
      "sub" => "42",
      "exp" => 1_591_765_058,
      "nbf" => 1_591_764_998,
      "iat" => 1_591_764_998,
      "jti" => "f8912129-1af6-4cad-9ca3-76b0f7621087",
      "sid" => "aaea182f2732d44c23057c0fea584021a4485b2bd25d3eb7fd349313ad24c685"
    }

  def valid_encoded_jwt_payload(:valid_signature),
    do:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImRlc3QiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbSIsImF1ZCI6IjFyMzBtcnZDRk1mcTJETEd1SVh5WTJ2ZUVKVmdUdEREIiwic3ViIjoiNDIiLCJleHAiOjE1OTE3NjUwNTgsIm5iZiI6MTU5MTc2NDk5OCwiaWF0IjoxNTkxNzY0OTk4LCJqdGkiOiJmODkxMjEyOS0xYWY2LTRjYWQtOWNhMy03NmIwZjc2MjEwODciLCJzaWQiOiJhYWVhMTgyZjI3MzJkNDRjMjMwNTdjMGZlYTU4NDAyMWE0NDg1YjJiZDI1ZDNlYjdmZDM0OTMxM2FkMjRjNjg1In0.LHsgca-qu6Sbtk8T7cbfoave7U3f6G2STWc5QK7MDBo"

  def valid_encoded_jwt_payload(:mismatch_signature),
    do:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImRlc3QiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbSIsImF1ZCI6IjFyMzBtcnZDRk1mcTJETEd1SVh5WTJ2ZUVKVmdUdEREIiwic3ViIjoiNDIiLCJleHAiOjE1OTE3NjUwNTgsIm5iZiI6MTU5MTc2NDk5OCwiaWF0IjoxNTkxNzY0OTk4LCJqdGkiOiJmODkxMjEyOS0xYWY2LTRjYWQtOWNhMy03NmIwZjc2MjEwODciLCJzaWQiOiJhYWVhMTgyZjI3MzJkNDRjMjMwNTdjMGZlYTU4NDAyMWE0NDg1YjJiZDI1ZDNlYjdmZDM0OTMxM2FkMjRjNjg1In0.kIdllbhkxtP9eZBWI3FYoJB8ERTsp6e5vph3Jd90s3Q"

  def valid_encoded_jwt_payload(:mismatch_api_key),
    do:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImRlc3QiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbSIsImF1ZCI6Ijg5ZTMxMTE2LTkzMmUtNGNiNC05YzAxLTlmZTk1MWQ0NWI0YiIsInN1YiI6IjQyIiwiZXhwIjoxNTkxNzY1MDU4LCJuYmYiOjE1OTE3NjQ5OTgsImlhdCI6MTU5MTc2NDk5OCwianRpIjoiZjg5MTIxMjktMWFmNi00Y2FkLTljYTMtNzZiMGY3NjIxMDg3Iiwic2lkIjoiYWFlYTE4MmYyNzMyZDQ0YzIzMDU3YzBmZWE1ODQwMjFhNDQ4NWIyYmQyNWQzZWI3ZmQzNDkzMTNhZDI0YzY4NSJ9.dIVBG0WnISDRYPS3VfwbOYhkhiJLL7m7uQWG6138ZV0"

  def valid_encoded_jwt_payload(:mismatch_jwt_signature_mismatch_api_key),
    do:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImRlc3QiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbSIsImF1ZCI6Ijg5ZTMxMTE2LTkzMmUtNGNiNC05YzAxLTlmZTk1MWQ0NWI0YiIsInN1YiI6IjQyIiwiZXhwIjoxNTkxNzY1MDU4LCJuYmYiOjE1OTE3NjQ5OTgsImlhdCI6MTU5MTc2NDk5OCwianRpIjoiZjg5MTIxMjktMWFmNi00Y2FkLTljYTMtNzZiMGY3NjIxMDg3Iiwic2lkIjoiYWFlYTE4MmYyNzMyZDQ0YzIzMDU3YzBmZWE1ODQwMjFhNDQ4NWIyYmQyNWQzZWI3ZmQzNDkzMTNhZDI0YzY4NSJ9.JekrMfGSm-gMvXScNUaOfVQepCEuUbDhRpV1qgGs1F4"

  @doc """
    If we were a norfarious actor we might be inclined to intercept the JWT decode the payload portion (`header.payload.signature`) and send
    the signature as it is hoping that the service does not validate that the signature contents doesn't validate against the payload.

    Merging the output of the 1&2 (`header1.payload2.signature1`) below would generate
    `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUyLm15c2hvcGlmeS5jb20vYWRtaW4iLCJkZXN0IjoiaHR0cHM6Ly9leGFtcGxlMi5teXNob3BpZnkuY29tIiwiYXVkIjoiMXIzMG1ydkNGTWZxMkRMR3VJWHlZMnZlRUpWZ1R0REQiLCJzdWIiOiI0MiIsImV4cCI6MTU5MTc2NTA1OCwibmJmIjoxNTkxNzY0OTk4LCJpYXQiOjE1OTE3NjQ5OTgsImp0aSI6ImY4OTEyMTI5LTFhZjYtNGNhZC05Y2EzLTc2YjBmNzYyMTA4NyIsInNpZCI6ImFhZWExODJmMjczMmQ0NGMyMzA1N2MwZmVhNTg0MDIxYTQ0ODViMmJkMjVkM2ViN2ZkMzQ5MzEzYWQyNGM2ODUifQ.LHsgca-qu6Sbtk8T7cbfoave7U3f6G2STWc5QK7MDBo`

    1. JWT for https://example.myshopify.com
      ```json
      {
        "iss": "https://example.myshopify.com/admin",
        "dest": "https://example.myshopify.com",
        "aud": "1r30mrvCFMfq2DLGuIXyY2veEJVgTtDD",
        "sub": "42",
        "exp": 1591765058,
        "nbf": 1591764998,
        "iat": 1591764998,
        "jti": "f8912129-1af6-4cad-9ca3-76b0f7621087",
        "sid": "aaea182f2732d44c23057c0fea584021a4485b2bd25d3eb7fd349313ad24c685"
      }
      ```
      Outputs: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbS9hZG1pbiIsImRlc3QiOiJodHRwczovL2V4YW1wbGUubXlzaG9waWZ5LmNvbSIsImF1ZCI6IjFyMzBtcnZDRk1mcTJETEd1SVh5WTJ2ZUVKVmdUdEREIiwic3ViIjoiNDIiLCJleHAiOjE1OTE3NjUwNTgsIm5iZiI6MTU5MTc2NDk5OCwiaWF0IjoxNTkxNzY0OTk4LCJqdGkiOiJmODkxMjEyOS0xYWY2LTRjYWQtOWNhMy03NmIwZjc2MjEwODciLCJzaWQiOiJhYWVhMTgyZjI3MzJkNDRjMjMwNTdjMGZlYTU4NDAyMWE0NDg1YjJiZDI1ZDNlYjdmZDM0OTMxM2FkMjRjNjg1In0.LHsgca-qu6Sbtk8T7cbfoave7U3f6G2STWc5QK7MDBo`

    2. JWT for https://example2.myshopify.com
      ```json
      {
        "iss": "https://example2.myshopify.com/admin",
        "dest": "https://example2.myshopify.com",
        "aud": "1r30mrvCFMfq2DLGuIXyY2veEJVgTtDD",
        "sub": "42",
        "exp": 1591765058,
        "nbf": 1591764998,
        "iat": 1591764998,
        "jti": "f8912129-1af6-4cad-9ca3-76b0f7621087",
        "sid": "aaea182f2732d44c23057c0fea584021a4485b2bd25d3eb7fd349313ad24c685"
      }
      ```
      Outputs: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUyLm15c2hvcGlmeS5jb20vYWRtaW4iLCJkZXN0IjoiaHR0cHM6Ly9leGFtcGxlMi5teXNob3BpZnkuY29tIiwiYXVkIjoiMXIzMG1ydkNGTWZxMkRMR3VJWHlZMnZlRUpWZ1R0REQiLCJzdWIiOiI0MiIsImV4cCI6MTU5MTc2NTA1OCwibmJmIjoxNTkxNzY0OTk4LCJpYXQiOjE1OTE3NjQ5OTgsImp0aSI6ImY4OTEyMTI5LTFhZjYtNGNhZC05Y2EzLTc2YjBmNzYyMTA4NyIsInNpZCI6ImFhZWExODJmMjczMmQ0NGMyMzA1N2MwZmVhNTg0MDIxYTQ0ODViMmJkMjVkM2ViN2ZkMzQ5MzEzYWQyNGM2ODUifQ.x_h8p4GgEacP-7VkE1nZlE-Hvha3Ut0ZTeCdfqPJHik`
  """
  def valid_encoded_jwt_payload(:valid_signature_modified_payload),
    do:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUyLm15c2hvcGlmeS5jb20vYWRtaW4iLCJkZXN0IjoiaHR0cHM6Ly9leGFtcGxlMi5teXNob3BpZnkuY29tIiwiYXVkIjoiMXIzMG1ydkNGTWZxMkRMR3VJWHlZMnZlRUpWZ1R0REQiLCJzdWIiOiI0MiIsImV4cCI6MTU5MTc2NTA1OCwibmJmIjoxNTkxNzY0OTk4LCJpYXQiOjE1OTE3NjQ5OTgsImp0aSI6ImY4OTEyMTI5LTFhZjYtNGNhZC05Y2EzLTc2YjBmNzYyMTA4NyIsInNpZCI6ImFhZWExODJmMjczMmQ0NGMyMzA1N2MwZmVhNTg0MDIxYTQ0ODViMmJkMjVkM2ViN2ZkMzQ5MzEzYWQyNGM2ODUifQ.LHsgca-qu6Sbtk8T7cbfoave7U3f6G2STWc5QK7MDBo"
end

ExUnit.start()
