defmodule Robocook.Client do
  use Robocook.Protocol
  require Logger
  alias Robocook.{Resource, User, Serializer, Room, RoomRegistry, GameServer, Level}

  @impl true
  def init(_args) do
    {:ok, %{status: :unauthenticated, user: nil, room: nil, game: nil, level: nil, player: nil}}
  end

  @impl true
  def handle_call("register", [username, password], state = %{status: :unauthenticated})
      when is_binary(username) and is_binary(password) do
    # TODO: input validation
    case User.register(username, password) do
      :ok ->
        Logger.info("A user registered the account '#{username}'")
        {:reply, "ok", state}

      :error ->
        {:reply, "error", state}
    end
  end

  @impl true
  def handle_call("login", [username, password], s = %{status: :unauthenticated})
      when is_binary(username) and is_binary(password) do
    # TODO: prevent double login
    case User.authenticate(username, password) do
      true -> {:reply, "ok", %{s | status: :authenticated, user: username}}
      false -> {:reply, "error", s}
    end
  end

  @impl true
  def handle_call("change_password", [old_password, new_password], s = %{status: :authenticated})
      when is_binary(old_password) and is_binary(new_password) do
    case User.authenticate(s.user, old_password) do
      true ->
        :ok = User.change_password(s.user, new_password)
        {:reply, :ok, s}

      false ->
        {:reply, :error, s}
    end
  end

  @impl true
  def handle_call("list_chapters", nil, s = %{status: :authenticated}) do
    reply =
      s.user
      |> available_chapters()
      |> Enum.map(fn ref ->
        %{ref: ref, name: name} = Resource.get!(ref)
        %{ref: ref, name: name}
      end)

    {:reply, reply, s}
  end

  @impl true
  def handle_call("list_levels", [ref], s = %{status: :authenticated}) do
    case Resource.get(ref) do
      {:ok, %{type: :chapter, levels: levels}} ->
        result =
          Enum.map(levels, fn %{ref: level_ref} ->
            level = Resource.get!(level_ref)

            status =
              s.user
              |> User.get_level_status(level_ref)
              |> Serializer.serialize_level_status()

            %{
              ref: level_ref,
              title: level.title,
              status: status,
              multiplayer: level.num_players > 1
            }
          end)

        {:reply, %{status: :ok, result: result}, s}

      {:ok, _} ->
        {:reply, %{status: :error}, s}

      :error ->
        {:reply, %{status: :error}, s}
    end
  end

  @impl true
  def handle_call("create_room", [ref], s = %{status: :authenticated}) do
    # TODO: check this level indeed already unclocked
    {:ok, room_pid} = Room.create(ref, self(), s.user)
    info = Room.get_status(room_pid)
    {:reply, %{status: :ok, info: info}, %{s | status: :room, room: room_pid}}
  end

  @impl true
  def handle_call("join_room", [id], s = %{status: :authenticated}) do
    case RoomRegistry.lookup(id) do
      {:ok, pid} ->
        case Room.join(pid, self(), s.user) do
          {:ok, players} ->
            info = Room.get_status(pid)

            {:reply, %{status: :ok, info: info, players: players},
             %{s | status: :room, room: pid}}

          :error ->
            {:reply, %{status: :error, reason: :full}, s}
        end

      :error ->
        {:reply, %{status: :error, reason: :nonexist}, s}
    end
  end

  @impl true
  def handle_call("search_room", [id], s = %{status: :authenticated}) do
    case RoomRegistry.lookup(id) do
      {:ok, pid} ->
        {:reply, %{status: :ok, info: Room.get_status(pid)}, s}

      :error ->
        {:reply, %{status: :error, reason: :nonexist}, s}
    end
  end

  @impl true
  def handle_cast("leave", nil, s = %{status: :room}) do
    Room.leave(s.room, self())
    {:noreply, s}
  end

  @impl true
  def handle_cast("kick", [player_name], s = %{status: :room}) when is_binary(player_name) do
    %{owner: owner_name} = Room.get_status(s.room)

    if s.user === owner_name do
      Room.kick(s.room, player_name)
    end

    {:noreply, s}
  end

  @impl true
  def handle_cast("start_game", [], s = %{status: :room}) do
    %{owner: owner_name} = Room.get_status(s.room)

    if s.user === owner_name do
      Room.start_game(s.room)
    end

    {:noreply, s}
  end

  @impl true
  def handle_cast("send_text", [text], s = %{status: :game}) when is_binary(text) do
    GameServer.send_text(s.game, text)
    {:noreply, s}
  end

  @impl true
  def handle_cast("send_emoji", [text], s = %{status: :game}) when is_binary(text) do
    GameServer.send_emoji(s.game, text)
    {:noreply, s}
  end

  @impl true
  def handle_cast("change_speed", [speed], s = %{status: :game}) do
    if speed in ["slow", "normal", "fast", "very_fast"] do
      GameServer.change_speed(s.game, String.to_existing_atom(speed))
    end

    {:noreply, s}
  end

  @impl true
  def handle_cast("update_code", [robot_no, ast], s = %{status: :game}) do
    if Enum.at(s.level.robot_controls, robot_no) == s.player do
      case Serializer.deserialize_ast(ast) do
        {:ok, ast} ->
          GameServer.update_code(s.game, robot_no, ast)

        :error ->
          nil
      end
    end

    {:noreply, s}
  end

  @impl true
  def handle_cast("play_scene", [], s = %{status: :game}) do
    GameServer.play_scene(s.game)
    {:noreply, s}
  end

  @impl true
  def handle_cast("pause_scene", [], s = %{status: :game}) do
    GameServer.pause_scene(s.game)
    {:noreply, s}
  end

  @impl true
  def handle_cast("stop_scene", [], s = %{status: :game}) do
    GameServer.stop_scene(s.game)
    {:noreply, s}
  end

  @impl true
  def handle_info({:joined, player}, s = %{status: :room}) do
    {:event, :joined, player, s}
  end

  @impl true
  def handle_info({:left, player}, s = %{status: :room, user: player}) do
    {:event, :left, player, %{s | status: :authenticated}}
  end

  @impl true
  def handle_info({:left, player}, s = %{status: :room}) do
    {:event, :left, player, s}
  end

  @impl true
  def handle_info({:kicked, player}, s = %{status: :room, user: player}) do
    {:event, :kicked, player, %{s | status: :authenticated}}
  end

  @impl true
  def handle_info({:kicked, player}, s = %{status: :room}) do
    {:event, :kicked, player, s}
  end

  @impl true
  def handle_info(:dismissed, s = %{status: :room}) do
    {:event, :dismissed, nil, %{s | status: :authenticated}}
  end

  @impl true
  def handle_info({:game_started, game_pid, level_ref, player_no}, s = %{status: :room}) do
    level = Resource.get!(level_ref)

    notification = %{
      player: player_no,
      goal: Serializer.serialize_goal(level),
      scenes: Serializer.serialize_scenes(level),
      controls: level.robot_controls,
      asts: level |> Level.generate_initial_asts() |> Enum.map(&Serializer.serialize_ast/1)
    }

    {:event, :game_started, notification,
     %{s | status: :game, game: game_pid, level: level, player: player_no}}
  end

  @impl true
  def handle_info({:text_sent, name, text}, s = %{status: :game}) do
    {:event, :text_sent, %{player: name, text: text}, s}
  end

  @impl true
  def handle_info({:emoji_sent, name, emoji}, s = %{status: :game}) do
    {:event, :emoji_sent, %{player: name, emoji: emoji}, s}
  end

  @impl true
  def handle_info({:speed_changed, new_speed}, s = %{status: :game}) do
    {:event, :speed_changed, new_speed, s}
  end

  @impl true
  def handle_info({:code_changed, no, ast}, s = %{status: :game}) do
    {:event, :code_changed, %{robot: no, ast: Serializer.serialize_ast(ast)}, s}
  end

  @impl true
  def handle_info({:scene_played, index}, s = %{status: :game}) do
    {:event, :scene_played, index, s}
  end

  @impl true
  def handle_info(:scene_paused, s = %{status: :game}) do
    {:event, :scene_paused, nil, s}
  end

  @impl true
  def handle_info(:scene_resumed, s = %{status: :game}) do
    {:event, :scene_resumed, nil, s}
  end

  @impl true
  def handle_info(:scene_stopped, s = %{status: :game}) do
    {:event, :scene_stopped, nil, s}
  end

  @impl true
  def handle_info({:game_tick, tick, updates}, s = %{status: :game}) do
    updates = Enum.map(updates, &Serializer.serialize_game_update/1)
    {:event, :game_tick, %{tick: tick, updates: updates}, s}
  end

  @impl true
  def handle_info({:game_result, result, status}, s = %{status: :game}) do
    User.update_level_status(s.user, s.level.ref, status)
    status = Serializer.serialize_level_status(status)

    new_state =
      case result do
        :success -> :authenticated
        :failed -> :game
      end

    {:event, :game_result, status, %{s | status: new_state}}
  end

  def available_chapters(username) do
    [game] = Resource.find_by_type(:game)
    [first_chapter | rest_chapters] = game.chapters

    available_chapters_loop(username, [first_chapter], rest_chapters)
    |> Enum.reverse()
  end

  def chapter_unlocked?(username, ref) do
    chapter = Resource.get!(ref)

    chapter.levels
    |> Enum.filter(fn %{type: t} -> t == :required end)
    |> Enum.all?(fn %{ref: ref} -> level_completed?(username, ref) end)
  end

  def level_completed?(username, ref) do
    case User.get_level_status(username, ref) do
      {:complete, _} -> true
      _ -> false
    end
  end

  defp available_chapters_loop(_username, chapters, []) do
    chapters
  end

  defp available_chapters_loop(username, chapters = [last | _], [next | rest]) do
    if chapter_unlocked?(username, last) do
      available_chapters_loop(username, [next | chapters], rest)
    else
      chapters
    end
  end
end
