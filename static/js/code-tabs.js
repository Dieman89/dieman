// Code tabs switching
(function () {
  const tabButtons = document.querySelectorAll(".code-tab");
  if (!tabButtons.length) return;

  tabButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const tabId = button.dataset.tab;
      const container = button.closest(".code-tabs");

      // Update buttons
      container.querySelectorAll(".code-tab").forEach((btn) => {
        btn.classList.remove("active");
      });
      button.classList.add("active");

      // Update panels
      container.querySelectorAll(".code-panel").forEach((panel) => {
        panel.classList.remove("active");
      });
      container
        .querySelector(`[data-panel="${tabId}"]`)
        .classList.add("active");
    });
  });
})();
