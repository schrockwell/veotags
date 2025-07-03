import L from "leaflet";
import "leaflet.markercluster";

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

    this.clusterGroup = L.markerClusterGroup();
    this.map.addLayer(this.clusterGroup);

    this.handleEvent("put_markers", ({ markers }) => {
      this.clusterGroup.clearLayers();

      markers.forEach((marker) => {
        this.clusterGroup.addLayer(
          L.marker([marker.lat, marker.lng], { icon: this.icon })
            .bindPopup(marker.address)
            .on("popupopen", () => {
              this.pushEvent("marker_selected", { id: marker.id });
            })
            .on("popupclose", () => {
              this.pushEvent("marker_deselected", { id: marker.id });
            })
        );
      });
    });

    this.handleEvent("close_popups", () => {
      this.clusterGroup.eachLayer((layer) => {
        if (layer.getPopup()) {
          layer.closePopup();
        }
      });
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
