defmodule PlugShopifyVerifyTimestamp.Helper do
  @moduledoc """
  Halt helper
  """
  import Plug.Conn

  @spec halt_on_error?(Plug.Conn.t(), boolean, atom) :: Plug.Conn.t()
  def halt_on_error?(conn, true, pass_signal) do
    case conn.private[pass_signal] do
      false ->
        conn |> halt()

      true ->
        conn
    end
  end

  def halt_on_error?(conn, false, _pass_signal) do
    conn
  end

  @spec get_param_from_url(
          atom | %{:params => nil | maybe_improper_list | map, optional(any) => any},
          any
        ) :: any
  def get_param_from_url(conn, %{param: key}), do: get_param_from_url(conn, key)

  def get_param_from_url(conn, key) when is_atom(key),
    do: get_param_from_url(conn, Atom.to_string(key))

  def get_param_from_url(conn, key), do: conn.params[key]

  @spec get_param_from_header(Plug.Conn.t(), binary) :: [binary]
  def get_param_from_header(conn, key), do: get_req_header(conn, key)
end
