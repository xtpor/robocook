defmodule Robocook.Protocol do
  @type state :: term()
  @type name :: string()
  @type params :: term()
  @type reason :: term()

  @callback init(opts :: term()) :: {:ok, state()}

  @callback handle_cast(name(), params(), state()) ::
              {:noreply, state()}
              | {:event, name(), params(), state()}
              | {:stop, reason(), state()}

  @callback handle_call(name :: string(), params, state()) ::
              {:reply, reply :: term(), state()}
              | {:stop, reply :: term(), reason(), state()}

  @callback handle_info(term(), state()) ::
              {:noreply, state()}
              | {:event, name(), params(), state()}
              | {:stop, state()}

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Robocook.Protocol
    end
  end
end
