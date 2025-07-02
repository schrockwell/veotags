defmodule VeotagsWeb.TagLiveTest do
  use VeotagsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Veotags.MappingFixtures

  @create_attrs %{
    address: "some address",
    comment: "some comment",
    latitude: 120.5,
    longitude: 120.5,
    radius: 42,
    email: "some email",
    approved_at: "2025-07-01T23:34:00Z"
  }
  @update_attrs %{
    address: "some updated address",
    comment: "some updated comment",
    latitude: 456.7,
    longitude: 456.7,
    radius: 43,
    email: "some updated email",
    approved_at: "2025-07-02T23:34:00Z"
  }
  @invalid_attrs %{
    address: nil,
    comment: nil,
    latitude: nil,
    longitude: nil,
    radius: nil,
    email: nil,
    approved_at: nil
  }
  defp create_tag(_) do
    tag = tag_fixture()

    %{tag: tag}
  end

  describe "Index" do
    setup [:create_tag]

    test "lists all tags", %{conn: conn, tag: tag} do
      {:ok, _index_live, html} = live(conn, ~p"/tags")

      assert html =~ "Listing Tags"
      assert html =~ tag.address
    end

    test "saves new tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Tag")
               |> render_click()
               |> follow_redirect(conn, ~p"/tags/new")

      assert render(form_live) =~ "New Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tag-form", tag: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tags")

      html = render(index_live)
      assert html =~ "Tag created successfully"
      assert html =~ "some address"
    end

    test "updates tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tags-#{tag.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tags/#{tag}/edit")

      assert render(form_live) =~ "Edit Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tag-form", tag: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tags")

      html = render(index_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated address"
    end

    test "deletes tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tags-#{tag.id}")
    end
  end

  describe "Show" do
    setup [:create_tag]

    test "displays tag", %{conn: conn, tag: tag} do
      {:ok, _show_live, html} = live(conn, ~p"/tags/#{tag}")

      assert html =~ "Show Tag"
      assert html =~ tag.address
    end

    test "updates tag and returns to show", %{conn: conn, tag: tag} do
      {:ok, show_live, _html} = live(conn, ~p"/tags/#{tag}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tags/#{tag}/edit?return_to=show")

      assert render(form_live) =~ "Edit Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tag-form", tag: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tags/#{tag}")

      html = render(show_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated address"
    end
  end
end
