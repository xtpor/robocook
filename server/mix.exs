defmodule Robocook.MixProject do
  use Mix.Project

  def project do
    [
      app: :robocook,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      included_applications: [:mnesia],
      mod: {Robocook, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:poison, "~> 4.0"},
      {:cowboy, "~> 2.6"},
      {:ranch, "~> 1.7.1"},
      {:pbkdf2_elixir, "~> 0.12.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
