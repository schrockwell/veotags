
# mix run priv/repo/reddit_seeds.exs

alias Veotags.Mapping

{:ok, _} = Mapping.create_tag(%{
  address: "634 Franklin Ave, Hartford, CT",
  latitude: 41.7309577,
  longitude: -72.674264,
  radius: 0,
  photo: "https://i.redd.it/zacuftbmgiaf1.jpeg",
})

{:ok, _} = Mapping.create_tag(%{
  address: "Toledo, Ohio",
  latitude: 41.5434109,
  longitude: -83.5895818,
  radius: 10_000,
  photo: "https://i.redd.it/4stbqf8b3daf1.jpeg",
})

{:ok, _} = Mapping.create_tag(%{
  address: "Oakwood Ave & Park Rd, West Hartford, CT",
  latitude: 41.7578489,
  longitude: -72.7225853,
  radius: 0,
  photo: "https://i.redd.it/8d68wto5kx9f1.jpeg",
})

{:ok, _} = Mapping.create_tag(%{
  address: "Brewster, NY Rest Area",
  latitude: 41.3620114,
  longitude: -73.630862,
  radius: 0,
  photo: "https://i.redd.it/1qt18q98h4te1.jpeg",
})
