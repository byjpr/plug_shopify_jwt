# PlugShopifyJwt

[![Elixir CI](https://github.com/byjpr/plug_shopify_jwt/actions/workflows/elixir.yml/badge.svg)](https://github.com/byjpr/plug_shopify_jwt/actions/workflows/elixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/byjpr/plug_shopify_jwt/badge.svg?branch=main)](https://coveralls.io/github/byjpr/plug_shopify_jwt?branch=main)
[![Libraries.io for releases](https://img.shields.io/librariesio/release/github/byjpr/plug_shopify_jwt.svg?style=flat-square)](https://libraries.io/github/byjpr/plug_shopify_jwt)

This plug validates Shopify JWT - also known as session token authentication. Session tokens/JWT are a replacement for cookie based authentication in embedded apps.

PlugShopifyJwt is architected to support Session tokens whilst allowing you to verify with URL parameters (validation of URL parameters is not included in this plug) should you decide.

## Setup

### Usage
Grab you app secret, and crack open your router.ex file, insert `plug PlugShopifyEmbeddedJWTAuth, [secret: "your-secret"]`. A basic setup looks something similar to this:

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
    {:plug_shopify_jwt, "~> 0.1.1"}
  ]
end
```

### Conn Private:
We set the following on the conn.private object:
1. `:ps_jwt_success` - `true` indicates the plug ran, found the JWT, decoded it and placed it in `:shopify_jwt_claims` - `false` indicates that there was a failure in the pipeline.
2. `shopify_jwt_claims` - returns the full decoded JWT.
3. `current_shop_name` - returns the myshopify.com domain for the current store, e.g. `example.shopify.com`.

### Plug config:
1. `:halt_on_error` - `true` stop the conn and returns an error 401. False will set `:ps_jwt_success` to `false` on failure
and allow you to deal with the error elsewhere. Default `true`.
2. `algorithm` - one of _"HS256", "HS384", "HS512", "RS256", "RS384", "RS512", "ES256", "ES384", "ES512", "PS256", "PS384", "PS512", "Ed25519", "Ed25519ph", "Ed448", "Ed448ph"_. Shopify uses "HS256", which the plug will set as a default, however, for future proofing, we have exposed this config from Joken. Default `HS256`.
3. `secret` - the app secret you got when you created your Shopify App in the Shopify Partner portal. **Required**
4. `signer` - used by the plug to store `Joken.Signer`.