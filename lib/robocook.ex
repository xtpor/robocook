defmodule Robocook do
  use Application

  def start(_type, _args) do
    {:ok, _} = Robocook.WebsocketAdapter.start(port: 5657, protocol: Robocook.Client)

    children = [
      Robocook.RoomRegistry,
      {DynamicSupervisor, strategy: :one_for_one, name: Robocook.RoomSupervisor},
      Robocook.Resource,
      {Task, fn -> Robocook.Resource.FileLoader.load() end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
