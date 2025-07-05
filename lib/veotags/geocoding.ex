defmodule Veotags.Geocoding do
  # {
  #   "place_id": 315505378,
  #   "licence": "Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright",
  #   "osm_type": "node",
  #   "osm_id": 8526781361,
  #   "lat": "41.7577272",
  #   "lon": "-72.7226187",
  #   "display_name": "175, Park Road, West Hartford, Capitol Planning Region, 06119, United States",
  #   "address": {
  #     "house_number": "175",
  #     "road": "Park Road",
  #     "town": "West Hartford",
  #     "county": "Capitol Planning Region",
  #     "postcode": "06119",
  #     "country": "United States",
  #     "country_code": "us"
  #   },
  #   "boundingbox": ["41.7576772", "41.7577772", "-72.7226687", "-72.7225687"]
  # }
  def reverse_geocode(lat, lng) when is_number(lat) and is_number(lng) do
    api_key = System.fetch_env!("GEOCODING_API_KEY")

    _url = "https://geocode.maps.co/reverse?lat=#{lat}&lon=#{lng}&api_key=#{api_key}"
    # TODO
  end
end
