defmodule PlugShopifyEmbeddedJWTAuth do
  @moduledoc """
  Validate Shopify JWT
  """
  import Plug.Conn

  def init(opts) do
    opts
    |> prepare_cfg(Application.get_all_env(:plug_shopify_jwt))
    |> validate_secret()
    |> set_signer()
  end

  def call(conn = %{private: %{shop_origin_type: :jwt}}, opts) do
    conn
    |> get_auth_header
    |> authenticate(opts)
  end

  def call(conn, _), do: conn

  #
  # Auth session
  #
  defp authenticate({conn, "Bearer " <> jwt}, opts) do
    case Joken.verify(jwt, opts[:signer]) do
      {:ok, claims} -> success(conn, claims)
      {:error, err} -> error(conn, %{error: err})
    end
  end

  defp authenticate({conn, _}, _) do
    error(conn)
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> {conn, token}
      _ -> {conn}
    end
  end

  #
  # Callbacks
  #
  defp success(conn, claims) do
    conn
    |> put_private(:shopify_jwt_claims, claims)
    |> put_private(:current_shop_name, String.replace_prefix(claims["dest"], "https://", ""))
  end

  defp error(
         conn,
         data \\ %{message: "Missing authentication header"}
       ) do
    conn
  end

  defp send_401(
         conn,
         data \\ %{message: "Please make sure you have authentication header"}
       ) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Poison.encode!(data))
    |> halt
  end

  # Plug setup
  defp defaults,
    do: [
      algorithm: "HS256",
      secret: nil,
      signer: nil
    ]

  defp prepare_cfg(opts, env) do
    defaults()
    |> Keyword.merge(env)
    |> Keyword.merge(opts)
  end

  defp set_signer(opts),
    do: Keyword.merge(opts, signer: Joken.Signer.create(opts[:algorithm], opts[:secret]))

  defp validate_secret(opts) do
    if(opts[:secret] == nil) do
      raise(
        "NO_SECRET: Error starting PlugShopifyEmbeddedJWTAuth. You must include the configuration item `secret`"
      )
    else
      opts
    end
  end
end
