defmodule Veotags.MappingTest do
  use Veotags.DataCase

  alias Veotags.Mapping

  describe "tags" do
    alias Veotags.Mapping.Tag

    import Veotags.MappingFixtures

    @invalid_attrs %{
      address: nil,
      comment: nil,
      latitude: nil,
      longitude: nil,
      radius: nil,
      email: nil,
      approved_at: nil
    }

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Mapping.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Mapping.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{
        address: "some address",
        comment: "some comment",
        latitude: 120.5,
        longitude: 120.5,
        radius: 42,
        email: "some email",
        approved_at: ~U[2025-07-01 23:34:00Z]
      }

      assert {:ok, %Tag{} = tag} = Mapping.create_tag(valid_attrs)
      assert tag.address == "some address"
      assert tag.comment == "some comment"
      assert tag.latitude == 120.5
      assert tag.longitude == 120.5
      assert tag.radius == 42
      assert tag.email == "some email"
      assert tag.approved_at == ~U[2025-07-01 23:34:00Z]
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mapping.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()

      update_attrs = %{
        address: "some updated address",
        comment: "some updated comment",
        latitude: 456.7,
        longitude: 456.7,
        radius: 43,
        email: "some updated email",
        approved_at: ~U[2025-07-02 23:34:00Z]
      }

      assert {:ok, %Tag{} = tag} = Mapping.update_tag(tag, update_attrs)
      assert tag.address == "some updated address"
      assert tag.comment == "some updated comment"
      assert tag.latitude == 456.7
      assert tag.longitude == 456.7
      assert tag.radius == 43
      assert tag.email == "some updated email"
      assert tag.approved_at == ~U[2025-07-02 23:34:00Z]
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Mapping.update_tag(tag, @invalid_attrs)
      assert tag == Mapping.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Mapping.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Mapping.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Mapping.change_tag(tag)
    end
  end
end
