
# mix run priv/repo/reddit_seeds.exs

alias Veotags.Mapping

tags_params = [
  %{
    address: "634 Franklin Ave, Hartford, CT",
    latitude: 41.7309577,
    longitude: -72.674264,
    radius: 0,
    photo: "https://i.redd.it/zacuftbmgiaf1.jpeg",
    reporter: "u/Immoracle",
  },
  %{
    address: "Toledo, Ohio",
    latitude: 41.5434109,
    longitude: -83.5895818,
    radius: 10_000,
    photo: "https://i.redd.it/4stbqf8b3daf1.jpeg",
    reporter: "u/FlightOfBrian",
  },
  %{
    address: "Oakwood Ave & Park Rd, West Hartford, CT",
    latitude: 41.7578489,
    longitude: -72.7225853,
    radius: 0,
    photo: "https://i.redd.it/8d68wto5kx9f1.jpeg",
    reporter: "u/Alkali13",
  },
  %{
    address: "Brewster, NY Rest Area",
    latitude: 41.3620114,
    longitude: -73.630862,
    radius: 0,
    photo: "https://i.redd.it/1qt18q98h4te1.jpeg",
    reporter: "u/schrockwell",
  },
]

Enum.each(tags_params, fn tag_params ->
  {:ok, tag} = Mapping.create_tag(tag_params)
  Mapping.approve_tag(tag)
end)
