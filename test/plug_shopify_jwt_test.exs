defmodule PlugShopifyEmbeddedJWTAuthTest do
  @moduledoc """
  Test the plug that validate Shopify JWT.
  """

  use ExUnit.Case
  use Timex
  use Plug.Test

  doctest PlugShopifyEmbeddedJWTAuth

  defp parse(conn, opts \\ []) do
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  describe "config" do
    test "init should raise without secret set" do
      assert_raise RuntimeError, fn ->
        PlugShopifyEmbeddedJWTAuth.init([])
      end
    end

    test "init should set `algorithm: HS256` as a default if not set" do
      init_conf = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")

      assert init_conf[:algorithm] == "HS256"
    end

    test "init should set `halt_on_error: true` as a default if not set" do
      init_conf = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")

      assert init_conf[:halt_on_error] == true
    end

    test "`halt_on_error` default should respect config" do
      init_conf =
        PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf", halt_on_error: false)

      assert init_conf[:halt_on_error] == false
    end

    test "Secret should not be modified in anyway" do
      init_conf = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")

      assert init_conf[:secret] == "asdnflajsfdnljasdf"
    end

    test "Init should have Joken.Signer configured as we expect" do
      init_conf = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")

      expected_signer = %Joken.Signer{
        alg: "HS256",
        jwk: %JOSE.JWK{
          fields: %{},
          keys: :undefined,
          kty: {:jose_jwk_kty_oct, "asdnflajsfdnljasdf"}
        },
        jws: %JOSE.JWS{
          alg: {:jose_jws_alg_hmac, :HS256},
          b64: :undefined,
          fields: %{"typ" => "JWT"}
        }
      }

      assert init_conf[:signer] == expected_signer
    end

    test "strict match config" do
      init_conf = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")

      exppected_conf = [
        algorithm: "HS256",
        halt_on_error: true,
        secret: "asdnflajsfdnljasdf",
        signer: %Joken.Signer{
          alg: "HS256",
          jwk: %JOSE.JWK{
            fields: %{},
            keys: :undefined,
            kty: {:jose_jwk_kty_oct, "asdnflajsfdnljasdf"}
          },
          jws: %JOSE.JWS{
            alg: {:jose_jws_alg_hmac, :HS256},
            b64: :undefined,
            fields: %{"typ" => "JWT"}
          }
        }
      ]

      assert init_conf == exppected_conf
    end
  end

  describe "authentication hard failures" do
    test "call with `shop_origin_type` not set should pass conn through and do nothing" do
      init = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf")
      conn = conn(:get, "/new") |> parse() |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "call with `shop_origin_type: :jwt`, and valid JWT headers should run with success" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      jwt = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(:valid_signature)

      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      assert Map.has_key?(conn.private, :shopify_jwt_claims)
      assert Map.has_key?(conn.private, :current_shop_name)
    end

    test "call with `shop_origin_type: :jwt`, valid secret, but mismatched/modified payload" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()

      jwt =
        PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(
          :valid_signature_modified_payload
        )

      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "invalid token should fail" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer Q3L8aO4syyVlvXKsr4dqtO3u0yCDvWMX"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "token with mismatched signature should fail" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      jwt =
        PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(:mismatch_signature)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "authorization header with missing token should fail" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer "
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "authorization header with empty value" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          ""
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "authorization header with single space as value" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          " "
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end

    test "missing authorization header" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      assert conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
    end
  end

  describe "authentication soft failures" do
    test "call with `shop_origin_type` not set should pass conn through and do nothing" do
      init = PlugShopifyEmbeddedJWTAuth.init(secret: "asdnflajsfdnljasdf", halt_on_error: false)
      conn = conn(:get, "/new") |> parse() |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      refute Map.has_key?(conn.private, :ps_jwt_success)
    end

    test "call with `shop_origin_type: :jwt`, and valid JWT headers should run with success and set :ps_jwt_success to true" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      jwt = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(:valid_signature)

      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      assert Map.has_key?(conn.private, :shopify_jwt_claims)
      assert Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == true
    end

    test "call with `shop_origin_type: :jwt`, valid secret, but mismatched/modified payload should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()

      jwt =
        PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(
          :valid_signature_modified_payload
        )

      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "invalid token should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer Q3L8aO4syyVlvXKsr4dqtO3u0yCDvWMX"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "token with mismatched signature should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      jwt =
        PlugShopifyEmbeddedJWTAuthTest.JWTHelper.valid_encoded_jwt_payload(:mismatch_signature)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer #{jwt}"
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "authorization header with missing token should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          "Bearer "
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "authorization header with empty value should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          ""
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "authorization header with single space as value should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> put_req_header(
          "authorization",
          " "
        )
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end

    test "missing authorization header should set :ps_jwt_success to false" do
      api_secret = PlugShopifyEmbeddedJWTAuthTest.JWTHelper.api_secret()
      init = PlugShopifyEmbeddedJWTAuth.init(secret: api_secret, halt_on_error: false)

      conn =
        conn(:get, "/new")
        |> parse()
        |> put_private(:shop_origin_type, :jwt)
        |> PlugShopifyEmbeddedJWTAuth.call(init)

      refute conn.halted
      refute Map.has_key?(conn.private, :shopify_jwt_claims)
      refute Map.has_key?(conn.private, :current_shop_name)
      assert conn.private[:ps_jwt_success] == false
    end
  end
end
