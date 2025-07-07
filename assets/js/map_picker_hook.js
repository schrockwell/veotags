import L from "../vendor/leaflet";

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

    this.map.on("click", (e) => {
      const lat = e.latlng.lat.toFixed(6);
      const lng = e.latlng.lng.toFixed(6);
      const target = this.el.getAttribute("phx-target");
      this.pushEventTo(target, "map_clicked", { lat, lng });
    });

    this._updateMarker({ focus: true });
  },

  updated() {
    this._updateMarker();
  },

  _updateMarker(opts = {}) {
    if (this.el.dataset.lat && this.el.dataset.lng) {
      const lat = parseFloat(this.el.dataset.lat);
      const lng = parseFloat(this.el.dataset.lng);

      if (!this.marker) {
        this.marker = L.marker([lat, lng], {
          icon: this.icon,
        }).addTo(this.map);
      }

      this.marker.setLatLng([lat, lng]);
      if (opts.focus) {
        this.map.setView([lat, lng], 15);
      }
    } else {
      if (this.marker) {
        this.map.removeLayer(this.marker);
        this.marker = null;
      }
      // this.map.setView([41.7652445, -72.6913845], 8);
    }
  },
};
