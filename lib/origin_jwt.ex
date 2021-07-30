defmodule PlugShopifyEmbeddedJWTAuth.OriginJWT do
  @moduledoc """
  Add to a pipeline to set `shop_origin_type` to `jwt` which will allow `PlugShopifyEmbeddedJWTAuth` to run.
  """
  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    conn
    |> put_private(:shop_origin_type, :jwt)
  end
end
