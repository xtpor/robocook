defmodule Robocook.User do
  @user_table :user_info
  @savedata_table :user_savedata

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
end
