import L from "../vendor/leaflet";
import "../vendor/leaflet.markercluster";

export default {
  mounted() {
    this.map = L.map(this.el, { maxZoom: 18 }).setView(
      [41.7652445, -72.6913845],
      8
    );

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(this.map);

    this.icon = L.icon({
      iconUrl: "/images/leaflet/marker-icon.png",
      shadowUrl: "/images/leaflet/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    });

    // this.clusterGroup = L.markerClusterGroup();
    // this.map.addLayer(this.clusterGroup);
    this.markers = {};

    this.handleEvent("put_markers", ({ markers }) => {
      // this.clusterGroup.clearLayers();
      Object.values(this.markers).forEach((marker) => {
        this.map.removeLayer(marker);
      });

      this.markers = {};

      markers.forEach((marker) => {
        this.markers[marker.id] = L.marker([marker.lat, marker.lng], {
          icon: this.icon,
        })
          .bindPopup(marker.title)
          .on("click", () => {
            // Normally when select_marker is handled, we want to zoom in on the marker. But if the user
            // just clicked the marker, we don't want the map panning and zooming around under their cursor.
            this.ignoreNextMove = true;

            clearTimeout(this.deselectTimer);
            this.pushEvent("tag_selected", { id: marker.id });
          })
          .on("popupclose", () => {
            // Don't deselect immediately - when the user clicks another marker, let its click event trigger
            this.deselectTimer = setTimeout(() => {
              this.pushEvent("tag_deselected", { id: marker.id });
            }, 200);
          });

        // this.clusterGroup.addLayer(this.markers[marker.id]);
        this.markers[marker.id].addTo(this.map);
      });
    });

    this.handleEvent("deselect_marker", ({ marker_id }) => {
      if (this.markers[marker_id]) {
        this.markers[marker_id].closePopup();
      }
    });

    this.handleEvent("select_marker", ({ marker_id }) => {
      if (this.markers[marker_id]) {
        if (this.ignoreNextMove) {
          this.ignoreNextMove = false;
        } else {
          this.map.setView(this.markers[marker_id].getLatLng()); //, 14);
        }
        this.markers[marker_id].openPopup();
      }
    });
  },

  updated() {
    // This hook is called when the LiveView is updated
    console.log("MapHook updated");
  },

  destroyed() {
    // This hook is called when the LiveView is destroyed
    console.log("MapHook destroyed");
  },
};
