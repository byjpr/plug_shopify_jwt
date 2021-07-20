defmodule PlugShopifyVerifyTimestampTest do
  @moduledoc """
  Test the plug that verifies time difference supplied in URL Parameters by Shopify.
  """

  use ExUnit.Case
  use Timex
  use Plug.Test

  doctest PlugShopifyVerifyTimestamp

  defp parse(conn, opts \\ []) do
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  test "halts connections without parameter" do
    config = [max_delta: 5, halt_on_error: true]

    conn =
      conn(:get, "/new")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    assert conn.halted
  end

  test "halts connections with time delay" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -6) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    assert conn.halted
  end

  test "1 second delay with a max delta of 5 should not be halted" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -1) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    refute conn.halted
  end

  test "2 second delay with a max delta of 5 should not be halted" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -2) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    refute conn.halted
  end

  test "3 second delay with a max delta of 5 should not be halted" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -3) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    refute conn.halted
  end

  test "4 second delay with a max delta of 5 should not be halted" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -4) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    refute conn.halted
  end

  test "5 second delay with a max delta of 5 should be halted" do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -5) |> Timex.to_unix()

    conn =
      conn(:get, "/new?test_param=param&timestamp=#{datetime}")
      |> parse()
      |> put_private(:shop_origin_type, :url)
      |> PlugShopifyVerifyTimestamp.call(config)

    assert conn.halted
  end
end
