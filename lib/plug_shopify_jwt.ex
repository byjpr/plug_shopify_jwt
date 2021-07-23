defmodule PlugShopifyEmbeddedJWTAuth do
  @moduledoc """
    This plug validates Shopify JWT - also known as session token authentication.
    Session tokens/JWT are a replacement for cookie based authentication in embedded apps.

    PlugShopifyJwt is architected to support Session tokens whilst allowing you to
    verify with URL parameters (validation of URL parameters is not included in this plug) should you decide.

    ### Usage
    Grab you app secret, and crack open your router.ex file, insert
    `plug PlugShopifyEmbeddedJWTAuth, [secret: "your-secret"]`. A basic setup looks something similar to this:

    ```elixir
      pipeline :embedded do
        plug PlugShopifyEmbeddedJWTAuth, [secret: "224e5146-4f1e-4a1d-a64a-2732df659542"]
      end

      scope "/api", HelloPhoenixWeb do
        pipe_through :embedded

        get "/show", PageController, :show
      end
    ```

    ### Installation
    The package can be installed by adding `plug_shopify_jwt` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:plug_shopify_jwt, "~> 0.1.0"}
      ]
    end
    ```
  """
  import Plug.Conn

  @typedoc """
  ### Plug configuration

  - algorithm (Default: `"HS256"`) - "HS256", "HS384", "HS512", "RS256", "RS384", "RS512", "ES256", "ES384", "ES512", "PS256", "PS384", "PS512", "Ed25519", "Ed25519ph", "Ed448".
  - secret (**Required** the plug will throw an error if you do not set this) - from your Shopify Partner Dashboard.
  - halt_on_error (Default: `true`) - either `true` or `false`
  - signer (App only) - this is set by the Plug, you do not need to set this item.
  """
  @type config :: [
          algorithm: String.t(),
          secret: String.t() | nil,
          signer: Joken.Signer.t() | nil,
          halt_on_error: true | false
        ]

  @doc """
  Protects a route with JWT. Plug will automatically call `call/2` for each connection.

  ### Config
  See the documentation for the `config` type for details on the available options.

  ### Usage:
    ```elixir
      pipeline :embedded do
        plug PlugShopifyEmbeddedJWTAuth, [secret: "224e5146-4f1e-4a1d-a64a-2732df659542"]
      end

      scope "/api", HelloPhoenixWeb do
        pipe_through :embedded

        get "/show", PageController, :show
      end
    ```
  """
  @spec init(config) :: config
  def init(opts) do
    opts
    |> prepare_cfg(Application.get_all_env(:plug_shopify_jwt))
    |> validate_secret()
    |> set_signer()
  end

  @doc """
  Pass in a `Plug.Conn` and `Config` and it will take the auth header, authenticate the request, and the result will be one of the following:

  1. *Return a 401*: `halt_on_error` must be set to `true`, and the authentication fails.
  2. *Allow the connection to continue*: When authentication passes we will set `conn.private[:shopify_jwt_claims]` to the full decoded JWT, and `conn.private[:current_shop_name]` - will be the myshopify.com domain for the current store, e.g. `example.shopify.com`
  3. *Fail, but allow the connection to continue*: When `halt_on_error` is set to `false` instead of halting the connection the plug will set `conn.private[:ps_jwt_success]` to `false` assuming you will be doing error handling in another place.
  """
  @spec call(Plug.Conn.t(), config) :: Plug.Conn.t()
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
