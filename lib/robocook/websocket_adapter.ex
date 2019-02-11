defmodule Robocook.WebsocketAdapter do
  @behaviour :cowboy_websocket
  @idle_timeout 60 * 60 * 1000
  @max_frame_size 4 * 1024

  @protocol_version 1

  def start(opts) do
    port = Keyword.fetch!(opts, :port)
    mod = Keyword.fetch!(opts, :protocol)
    args = Keyword.get(opts, :args, [])

    routes = [
      {:_,
       [
         {"/", __MODULE__, {mod, args}}
       ]}
    ]

    router = :cowboy_router.compile(routes)

    :cowboy.start_clear(:http, [port: port], %{env: %{dispatch: router}})
  end

  def init(req, params) do
    {:cowboy_websocket, req, params,
     %{idle_timeout: @idle_timeout, max_frame_size: @max_frame_size}}
  end

  def websocket_init({mod, args}) do
    {:ok, {:wait_for_handshake, mod, args}}
  end

  def websocket_handle({:binary, _}, state) do
    {:reply, {:close, 1003, "Unsupported Data"}, state}
  end

  def websocket_handle({:ping, _}, state) do
    {:ok, state}
  end

  def websocket_handle({:pong, _}, state) do
    {:ok, state}
  end

  def websocket_handle({:text, text}, s = {:wait_for_handshake, mod, args}) do
    case decode_json(text) do
      {:ok, ["handshake", vsn]} when is_integer(vsn) ->
        if vsn == @protocol_version do
          {:ok, state} = mod.init(args)
          {:reply, {:text, encode_json(["handshake", "ok"])}, {mod, state}}
        else
          msg = encode_json(["handshake", "unsupported"])
          {:reply, [{:text, msg}, {:close, 1000, ""}], s}
        end

      {:ok, _} ->
        {:reply, {:close, 1002, "Protocol Error"}, s}

      _ ->
        {:reply, {:close, 1003, "Unsupported Data"}, s}
    end
  end

  def websocket_handle({:text, text}, s = {mod, state}) do
    case decode_json(text) do
      {:ok, ["call", id, name, params]} when is_binary(id) and is_binary(name) ->
        case mod.handle_call(name, params, state) do
          {:reply, reply, new_state} ->
            {:reply, {:text, encode_json(["reply", id, reply])}, {mod, new_state}}

          {:stop, reply, new_state} ->
            {:reply, [{:text, encode_json(["reply", id, reply])}, {:close, 1000, ""}],
             {mod, new_state}}
        end

      {:ok, ["cast", name, params]} when is_binary(name) ->
        case mod.handle_cast(name, params, state) do
          {:noreply, new_state} ->
            {:ok, {mod, new_state}}

          {:event, name, params, new_state} ->
            {:reply, [{:text, encode_json(["event", name, params])}], {mod, new_state}}

          {:stop, new_state} ->
            {:stop, new_state}
        end

      {:ok, _} ->
        {:reply, {:close, 1002, "Protocol Error"}, s}

      {:error, _} ->
        {:reply, {:close, 1003, "Unsupported Data"}, s}
    end
  end

  def websocket_info(term, {mod, state}) do
    case mod.handle_info(term, state) do
      {:noreply, new_state} ->
        {:ok, {mod, new_state}}

      {:event, name, params, new_state} ->
        {:reply, [{:text, encode_json(["event", name, params])}], {mod, new_state}}

      {:stop, new_state} ->
        {:stop, new_state}
    end
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp encode_json(term) do
    Poison.encode!(term)
  end

  defp decode_json(text) do
    Poison.decode(text)
  end
end
