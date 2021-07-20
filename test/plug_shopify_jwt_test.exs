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

  test "config should set `HS256` as a default if not set" do
    config = [secret: "asdnflajsfdnljasdf"]
    init_conf = PlugShopifyEmbeddedJWTAuth.init(config)

    assert init_conf[:algorithm] == "HS256"
  end

  test "config should not modify secret content" do
    config = [secret: "asdnflajsfdnljasdf"]
    init_conf = PlugShopifyEmbeddedJWTAuth.init(config)

    assert init_conf[:secret] == "asdnflajsfdnljasdf"
  end

  test "config should have Joken.Signer configured as we expect" do
    config = [secret: "asdnflajsfdnljasdf"]
    init_conf = PlugShopifyEmbeddedJWTAuth.init(config)

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
    config = [secret: "asdnflajsfdnljasdf"]
    init_conf = PlugShopifyEmbeddedJWTAuth.init(config)

    assert init_conf == [
             algorithm: "HS256",
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
  end

  test "plug should raise without secret" do
    assert_raise RuntimeError, fn ->
      init_conf = PlugShopifyEmbeddedJWTAuth.init([])
    end
  end
end
