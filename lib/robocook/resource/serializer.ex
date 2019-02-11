defmodule Robocook.Serializer do
  def serialize_level_status({primary, secondaries}) do
    %{
      primary: primary,
      secondaries: secondaries
    }
  end

  def serialize_level_status(nil) do
    nil
  end
end
