defmodule PlugShopifyEmbeddedJWTAuth do
  @moduledoc """
  Validate Shopify JWT
  """
  import Plug.Conn

  @spec init(keyword) :: keyword
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
    |> respond
  end

  def call(conn, _), do: conn

  @spec respond(
          {:ok, nil | maybe_improper_list | map, Plug.Conn.t()}
          | {:error, any, any, nil | keyword | map}
        ) :: Plug.Conn.t()
  def respond({:ok, claims, conn}) do
    success(conn, claims)
  end

  def respond({:error, error, conn, opts}) do
    halt = Access.get(opts, :halt_on_error, true)
    error(conn, halt, %{message: error})
  end

  #
  # Auth session
  #

  defp authenticate({conn, "Bearer " <> jwt}, opts) do
    with {:ok, jwt} <- valid_jwt?(jwt),
         {:ok, jwt_claims} <- Joken.verify(jwt, opts[:signer]) do
      {:ok, jwt_claims, conn}
    else
      {:error, reason} -> {:error, "#{inspect(reason)}", conn, opts}
      error -> {:error, error, conn, opts}
    end
  end

  defp authenticate({conn, _}, opts) do
    {:error, %{message: "Missing authenticate header"}, conn, opts}
  end

  defp authenticate(conn, opts) do
    {:error, %{message: "Missing authenticate header"}, conn, opts}
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> {conn, token}
      _ -> conn
    end
  end

  # Split the string on the dot
  defp valid_jwt?(jwt) do
    jwt |> String.split(".") |> valid_jwt?(jwt)
  end

  # Make sure there are three parts to that string
  defp valid_jwt?(split_jwt, jwt)
       when is_list(split_jwt) and (length(split_jwt) == 2 or length(split_jwt) == 3) do
    {:ok, jwt}
  end

  # Make sure there are three parts to that string
  defp valid_jwt?(split_jwt, _jwt)
       when is_list(split_jwt) and not (length(split_jwt) == 2 or length(split_jwt) == 3) do
    {:error, "jwt malformed"}
  end

  #
  # Callbacks
  #
  defp success(conn, claims) do
    conn
    |> attach_success_private(claims)
    |> put_private(:ps_jwt_success, true)
  end

  defp error(conn, true, reason) do
    conn
    |> send_401(Map.merge(%{message: "Validation error"}, reason))
    |> halt
  end

  defp error(conn, false, _reason) do
    conn
    |> put_private(:ps_jwt_success, false)
  end

  #
  # Responses
  #
  defp attach_success_private(conn, claims) do
    conn
    |> put_private(:shopify_jwt_claims, claims)
    |> put_private(:current_shop_name, String.replace_prefix(claims["dest"], "https://", ""))
  end

  defp send_401(conn, reason) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(reason))
  end

  # Plug setup
  defp defaults,
    do: [
      algorithm: "HS256",
      secret: nil,
      signer: nil,
      halt_on_error: true
    ]

  defp prepare_cfg(opts, env) do
    defaults()
    |> Keyword.merge(env)
    |> Keyword.merge(opts)
  end

  defp set_signer(opts),
    do: Keyword.merge(opts, signer: Joken.Signer.create(opts[:algorithm], opts[:secret]))

  defp validate_secret(opts) do
    if opts[:secret] == nil do
      raise(
        "NO_SECRET: Error starting PlugShopifyEmbeddedJWTAuth. You must include the configuration item `secret`."
      )
    else
      opts
    end
  end
end
