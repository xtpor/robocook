defmodule Robocook.Resource.FileLoader do
  require Logger

  @otp_app :robocook

  def load do
    priv_dir = @otp_app |> :code.priv_dir() |> to_string()

    "#{priv_dir}/res/**/*.exs"
    |> Path.wildcard()
    |> Enum.each(fn file ->
      {term, _} =
        file
        |> File.read!()
        |> Code.eval_string()

      Logger.debug("Loading resource #{file}")
      Robocook.Resource.put(term)
      Logger.info("Loaded #{term.type} resource #{term.ref}")
    end)
  end
end
