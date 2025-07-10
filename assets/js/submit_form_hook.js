export default {
  mounted() {
    const identity = this.getIdentity();

    ["name", "email"].forEach((field) => {
      const input = this.el.querySelector(
        `input[name='tag[reporters][0][${field}]']`
      );

      if (input) {
        input.value = identity[field] || "";
        input.addEventListener("input", (event) => {
          this.putIdentity(field, event.target.value);
        });
      }
    });
  },

  putIdentity(key, value) {
    const identity = this.getIdentity();
    identity[key] = value;
    localStorage.setItem("identity", JSON.stringify(identity));
  },

  getIdentity() {
    return JSON.parse(localStorage.getItem("identity") || "{}");
  },
};
