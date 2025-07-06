# mix run priv/repo/reddit_seeds.exs

alias Veotags.Mapping

tags_params = [
  %{
    address: "634 Franklin Ave, Hartford, CT",
    latitude: 41.7309577,
    longitude: -72.674264,
    photo: "https://i.redd.it/zacuftbmgiaf1.jpeg",
    reporter: "u/Immoracle",
    source_url: "https://www.reddit.com/r/veotags/comments/1lq4oda/veo_hartford/",
    accuracy: "exact"
  },
  %{
    address: "Toledo, Ohio",
    latitude: 41.5434109,
    longitude: -83.5895818,
    photo: "https://i.redd.it/4stbqf8b3daf1.jpeg",
    reporter: "u/FlightOfBrian",
    source_url:
      "https://www.reddit.com/r/veotags/comments/1lpizqs/spotted_in_central_ohio_in_2021/",
    accuracy: "approximate"
  },
  %{
    address: "Oakwood Ave & Park Rd, West Hartford, CT",
    latitude: 41.7578489,
    longitude: -72.7225853,
    photo: "https://i.redd.it/8d68wto5kx9f1.jpeg",
    reporter: "u/Alkali13",
    source_url:
      "https://www.reddit.com/r/veotags/comments/1lnpfs7/corner_of_oakwood_and_park_in_weha_ct/",
    accuracy: "exact"
  },
  %{
    address: "Brewster, NY Rest Area",
    latitude: 41.3620114,
    longitude: -73.630862,
    photo: "https://i.redd.it/1qt18q98h4te1.jpeg",
    reporter: "u/schrockwell",
    source_url: "https://www.reddit.com/r/veotags/comments/1lq4oda/veo_hartford/",
    accuracy: "exact"
  }
]

Enum.each(tags_params, fn tag_params ->
  {:ok, tag} = Mapping.submit_tag(tag_params)
  Mapping.approve_tag(tag)
end)
