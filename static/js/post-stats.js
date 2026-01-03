(function () {
  const footer = document.querySelector(".post-footer");
  if (!footer) return;

  const postId = window.location.pathname;
  const sessionKey = `viewed-${postId}`;
  const API_URL = "https://post-stats.a-buonerba.workers.dev";

  const viewsEl = footer.querySelector(".post-views-count");
  if (!viewsEl) return;

  async function fetchAndIncrement() {
    const hasViewed = sessionStorage.getItem(sessionKey);

    try {
      if (!hasViewed) {
        // First visit this session - increment and get count
        const res = await fetch(`${API_URL}/api/views${postId}`, { method: "POST" });
        const data = await res.json();
        sessionStorage.setItem(sessionKey, "true");
        updateViews(data.count || 0);
      } else {
        // Already viewed this session - just get count
        const res = await fetch(`${API_URL}/api/views${postId}`);
        const data = await res.json();
        updateViews(data.count || 0);
      }
    } catch (e) {
      // Silently fail
    }
  }

  function updateViews(count) {
    viewsEl.textContent = formatCount(count);
    viewsEl.closest(".post-stat").classList.add("loaded");
  }

  function formatCount(num) {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + "M";
    if (num >= 1000) return (num / 1000).toFixed(1) + "K";
    return num.toString();
  }

  fetchAndIncrement();
})();
