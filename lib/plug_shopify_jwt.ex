defmodule PlugShopifyVerifyTimestamp do
  @moduledoc """
  Validate Shopify JWT
  """

  import Plug.Conn

  @spec init(any) :: any
  def init(options), do: options

  def call(conn, opts),
    do: conn
end
