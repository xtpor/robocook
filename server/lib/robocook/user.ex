defmodule Robocook.User do
  use GenServer
  alias Robocook.Level

  @user_table :user_info
  @savedata_table :user_savedata

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def login(username, pid \\ self()) do
    GenServer.call(__MODULE__, {:login, username, pid})
  end

  def logout(pid \\ self()) do
    GenServer.call(__MODULE__, {:logout, pid})
  end

  def register(username, password) do
    hashed_pass = Pbkdf2.hash_pwd_salt(password)

    {:atomic, result} =
      :mnesia.transaction(fn ->
        case :mnesia.read({@user_table, username}) do
          [] ->
            :mnesia.write({@user_table, username, hashed_pass})
            :ok

          [_] ->
            :error
        end
      end)

    result
  end

  def authenticate(username, password) do
    {:atomic, result} = :mnesia.transaction(fn -> :mnesia.read({@user_table, username}) end)

    case result do
      [{@user_table, ^username, hashed_password}] ->
        Pbkdf2.verify_pass(password, hashed_password)

      _ ->
        false
    end
  end

  def change_password(username, new_password) do
    hashed_pass = Pbkdf2.hash_pwd_salt(new_password)

    {:atomic, result} =
      :mnesia.transaction(fn ->
        case :mnesia.read({@user_table, username}) do
          [] ->
            :error

          [{@user_table, ^username, _}] ->
            :mnesia.write({@user_table, username, hashed_pass})
            :ok
        end
      end)

    result
  end

  def update_level_status(username, ref, status) do
    # TODO: this should be fine in most of the cases, but in order to be
    # safe please make this function thread-safe
    case get_level_status(username, ref) do
      nil ->
        set_level_status(username, ref, status)

      old_status ->
        if Level.points_earned(status) > Level.points_earned(old_status) do
          set_level_status(username, ref, status)
        else
          nil
        end
    end

    :ok
  end

  def set_level_status(username, ref, status) do
    :mnesia.transaction(fn ->
      :mnesia.write({@savedata_table, {username, ref}, %{result: status}})
    end)

    :ok
  end

  def get_level_status(username, ref) do
    {:atomic, result} =
      :mnesia.transaction(fn ->
        case :mnesia.read({@savedata_table, {username, ref}}) do
          [] -> nil
          [{_, _, %{result: status}}] -> status
        end
      end)

    result
  end

  def get_all_levels_status(username) do
    {:atomic, result} =
      :mnesia.transaction(fn ->
        :mnesia.match_object({@savedata_table, {username, :"$1"}, :"$2"})
      end)

    result
    |> Enum.map(fn {_, {_, ref}, %{result: st}} -> {ref, st} end)
  end

  @impl true
  def init(_args) do
    {:ok, %{users: %{}, monitors: %{}}}
  end

  @impl true
  def handle_call({:login, username, pid}, _from, state) do
    %{users: users, monitors: monitors} = state

    if Map.has_key?(users, username) do
      another_pid = users[username]
      Process.demonitor(monitors[another_pid], [:flush])
      send(another_pid, :doubled_login)

      {_, state} = handle_logout(another_pid, state)
      {:reply, :ok, add_login_record(username, pid, state)}
    else
      {:reply, :ok, add_login_record(username, pid, state)}
    end
  end

  @impl true
  def handle_call({:logout, pid}, _from, state) do
    {result, new_state} = handle_logout(pid, state)
    {:reply, result, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {_, new_state} = handle_logout(pid, state)
    {:noreply, new_state}
  end

  defp handle_logout(pid, state) do
    %{users: users, monitors: monitors} = state

    if Map.has_key?(users, pid) do
      username = users[pid]
      Process.demonitor(monitors[pid], [:flush])
      new_users = users |> Map.delete(username) |> Map.delete(pid)
      new_monitors = Map.delete(monitors, pid)
      {:ok, %{state | users: new_users, monitors: new_monitors}}
    else
      {:error, state}
    end
  end

  defp add_login_record(username, pid, state) do
    %{users: users, monitors: monitors} = state
    ref = Process.monitor(pid)
    new_users = users |> Map.put(username, pid) |> Map.put(pid, username)
    new_monitors = Map.put(monitors, pid, ref)
    %{state | users: new_users, monitors: new_monitors}
  end
end
