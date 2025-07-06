export default {
  mounted() {
    this.handleEvent("submit", () => {
      this.el.requestSubmit();
    });
  },
};
