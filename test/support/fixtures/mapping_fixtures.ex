defmodule Veotags.MappingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Veotags.Mapping` context.
  """

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        address: "some address",
        approved_at: ~U[2025-07-01 23:34:00Z],
        comment: "some comment",
        email: "some email",
        latitude: 120.5,
        longitude: 120.5,
        radius: 42
      })
      |> Veotags.Mapping.create_tag()

    tag
  end
end
