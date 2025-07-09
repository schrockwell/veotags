defmodule Veotags.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :veotags

  alias Veotags.Mapping

  def migrate do
    load_app()

    for repo <- repos() do
      # `mix `ecto.create` equivalent. You must run `ALTER DATABASE veotags_prod OWNER TO veotags;`
      repo.__adapter__().storage_up(repo.config)

      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # Many platforms require SSL when connecting to the database
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end

  def seed_from_reddit do
    tags_params = [
      %{
        title: "634 Franklin Ave, Hartford, CT",
        latitude: 41.7309577,
        longitude: -72.674264,
        photo: "https://i.redd.it/zacuftbmgiaf1.jpeg",
        reporter: "u/Immoracle",
        source_url: "https://www.reddit.com/r/veotags/comments/1lq4oda/veo_hartford/",
        accuracy: "exact"
      },
      %{
        title: "Toledo, Ohio",
        latitude: 41.5434109,
        longitude: -83.5895818,
        photo: "https://i.redd.it/4stbqf8b3daf1.jpeg",
        reporter: "u/FlightOfBrian",
        source_url:
          "https://www.reddit.com/r/veotags/comments/1lpizqs/spotted_in_central_ohio_in_2021/",
        accuracy: "approximate"
      },
      %{
        title: "Oakwood Ave & Park Rd, West Hartford, CT",
        latitude: 41.7578489,
        longitude: -72.7225853,
        photo: "https://i.redd.it/8d68wto5kx9f1.jpeg",
        reporter: "u/Alkali13",
        source_url:
          "https://www.reddit.com/r/veotags/comments/1lnpfs7/corner_of_oakwood_and_park_in_weha_ct/",
        accuracy: "exact"
      },
      %{
        title: "Brewster, NY Rest Area",
        latitude: 41.3620114,
        longitude: -73.630862,
        photo: "https://i.redd.it/1qt18q98h4te1.jpeg",
        reporter: "u/schrockwell",
        source_url: "https://www.reddit.com/r/veotags/comments/1lq4oda/veo_hartford/",
        accuracy: "exact"
      },
      %{
        title: "Mohegan Sun parking garage",
        latitude: 41.4918012,
        longitude: -72.0929669,
        photo: "https://i.redd.it/nv3qyknovite1.jpeg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/1ju35ca/mohegan_sun_parking_garage/",
        accuracy: "approximate"
      },
      %{
        title: "Vieques, PR",
        latitude: 18.1215945,
        longitude: -65.5054732,
        photo: "https://i.redd.it/ys5it94fblge1.jpeg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/1ifg006/went_to_the_island_of_vieques_pr/",
        accuracy: "approximate"
      },
      %{
        title: "Hartford Medical Society",
        latitude: 41.7836564,
        longitude: -72.7109136,
        photo: "https://i.redd.it/l904tiwgftee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i8f9ew/veo_medical_edition/",
        accuracy: "exact"
      },
      %{
        photo: "https://i.redd.it/smuzu0gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/nbm8j0gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/ov1841gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/ga8qe0gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/yv0ra0gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/zh4nz1gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/23usr4gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/i9quh7gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/x1zui1gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/akivk1gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/burl12gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/htnrc1gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/iu7s87gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/xc6gy1gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/g8i719gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/vk2e83gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/gcqdw7gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/3zebl8gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/2pr8y4gr20ee1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/1i56cm0/veo/",
        reporter: "u/PorkIsAVerySweetMeat",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/erd0hrurfesb1.jpg",
        source_url: "https://www.reddit.com/r/veotags/comments/170ka8i/snack_bar_in_boston/",
        latitude: 42.3588785,
        longitude: -71.0504673,
        title: "Central Snack Bar",
        accuracy: "exact",
        reporter: "u/TerminusBandit"
      },
      %{
        photo: "https://i.redd.it/jn8wh6fhxbjb1.jpg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/15wmu6f/center_framing_and_art_west_hartford/",
        latitude: 41.7617958,
        longitude: -72.7434618,
        title: "Central Framing & Art",
        accuracy: "exact",
        reporter: "u/schrockwell"
      },
      %{
        photo: "https://i.redd.it/czwcuwxfjzhb1.jpg",
        source_url:
          "https://www.reddit.com/r/Connecticut/comments/15qhhof/paused_my_movie_for_this/",
        latitude: 30.0525472,
        longitude: -89.9362459,
        title: "From the Netflix documentary 'Closed For Storm'",
        accuracy: "approximate",
        reporter: "u/HarryMcButtcheeks"
      },
      %{
        photo: "https://i.imgur.com/PRcELn3.jpg",
        source_url:
          "https://www.reddit.com/r/Connecticut/comments/122r02o/visiting_some_family_in_san_juan_cant_get_away/",
        latitude: 18.4106574,
        longitude: -66.094542,
        title: "San Juan",
        accuracy: "approximate",
        reporter: "u/Fullcabflip"
      },
      %{
        photo: "https://i.imgur.com/KSPBjO8.jpg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/12a8k9i/mens_room_wendys_manchester_ct/",
        latitude: 41.79964,
        longitude: -72.5508506,
        title: "Wendy's bathroom, Manchester",
        accuracy: "exact",
        reporter: "u/schrockwell"
      },
      %{
        photo: "https://i.redd.it/78artmhlrrqa1.jpg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/125xtsm/cant_escape_veo_even_at_home/",
        reporter: "u/LizzieBordensPetRock",
        accuracy: "unknown"
      },
      %{
        photo: "https://i.redd.it/yl8nt7p4wqp71.jpg",
        source_url:
          "https://www.reddit.com/r/veotags/comments/pvjcro/noble_gas_and_convenience_new_britain_ct/",
        latitude: 41.6725279,
        longitude: -72.755775,
        title: "Noble Gas, New Britain",
        accuracy: "exact",
        reporter: "u/schrockwell"
      }
    ]

    tags_params
    |> Enum.each(fn tag_params ->
      {:ok, tag} = Mapping.submit_tag(tag_params)
      Mapping.approve_tag(tag)
    end)
  end
end
