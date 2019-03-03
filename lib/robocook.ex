defmodule Robocook do
  use Application

  def start(_type, _args) do
    create_tables()
    {:ok, _} = Robocook.WebsocketAdapter.start(port: 5657, protocol: Robocook.Client)

    children = [
      Robocook.User,
      Robocook.RoomRegistry,
      {DynamicSupervisor, strategy: :one_for_one, name: Robocook.RoomSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Robocook.GameServerSupervisor},
      Robocook.Resource,
      {Task, fn -> Robocook.Resource.FileLoader.load() end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp create_tables do
    :mnesia.create_table(:user_info, [disc_copies: [node()], attributes: [:username, :password]])
    :mnesia.create_table(:user_savedata, [disc_copies: [node()], attributes: [:user_ref, :data]])
  end
end
