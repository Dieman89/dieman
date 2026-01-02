(function () {
  "use strict";

  const searchOverlay = document.getElementById("search-overlay");
  const searchInput = document.getElementById("search-input");
  const searchResults = document.getElementById("search-results");
  if (!searchOverlay || !searchInput || !searchResults) return;

  let searchIndex = null;
  let documents = {};
  let isLoading = false;
  let selectedIndex = -1;

  // Open/close modal
  function openSearch() {
    searchOverlay.classList.add("visible");
    document.body.style.overflow = "hidden";
    loadSearchIndex();
    // Delay focus to ensure modal is visible
    setTimeout(() => searchInput.focus(), 50);
  }

  function closeSearch() {
    searchOverlay.classList.remove("visible");
    document.body.style.overflow = "";
    searchInput.value = "";
    searchResults.innerHTML = "";
    selectedIndex = -1;
  }

  // Debounce
  function debounce(fn, delay) {
    let timeout;
    return function (...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => fn.apply(this, args), delay);
    };
  }

  // Load search index
  async function loadSearchIndex() {
    if (searchIndex || isLoading) return;
    isLoading = true;

    try {
      const response = await fetch("/search-index.json");
      const data = await response.json();

      data.documents.forEach((doc) => {
        documents[doc.id] = doc;
      });

      searchIndex = lunr(function () {
        this.ref("id");
        this.field("title", { boost: 10 });
        this.field("body");
        this.field("tags", { boost: 5 });

        data.documents.forEach((doc) => {
          this.add(doc);
        });
      });
    } catch (error) {
      console.error("Failed to load search index:", error);
    } finally {
      isLoading = false;
    }
  }

  // Perform search
  function performSearch(query) {
    if (!query.trim()) {
      searchResults.innerHTML = "";
      return;
    }

    if (!searchIndex) {
      searchResults.innerHTML = '<div class="search-loading">Loading...</div>';
      return;
    }

    try {
      const results = searchIndex.search(query + "*");
      displayResults(results.slice(0, 8), query);
    } catch (e) {
      try {
        const results = searchIndex.search(query);
        displayResults(results.slice(0, 8), query);
      } catch (e2) {
        displayResults([], query);
      }
    }
  }

  // Display results
  function displayResults(results, query) {
    if (results.length === 0) {
      searchResults.innerHTML =
        '<div class="search-no-results">No results for "' +
        escapeHtml(query) +
        '"</div>';
      return;
    }

    const html = results
      .map((result) => {
        const doc = documents[result.ref];
        if (!doc) return "";

        const typeIcon = doc.type === "post" ? ">" : "#";
        const snippet = getSnippet(doc.body, query, 80);

        return (
          '<a href="' +
          doc.url +
          '" class="search-result-item" role="option">' +
          '<span class="search-result-type">' +
          typeIcon +
          "</span>" +
          '<div class="search-result-content">' +
          '<span class="search-result-title">' +
          highlightMatch(doc.title, query) +
          "</span>" +
          '<span class="search-result-snippet">' +
          highlightMatch(snippet, query) +
          "</span>" +
          "</div>" +
          "</a>"
        );
      })
      .join("");

    searchResults.innerHTML = html;
  }

  function getSnippet(text, query, length) {
    const lowerText = text.toLowerCase();
    const lowerQuery = query.toLowerCase();
    const index = lowerText.indexOf(lowerQuery);

    if (index === -1) {
      return text.slice(0, length) + (text.length > length ? "..." : "");
    }

    const start = Math.max(0, index - length / 2);
    const end = Math.min(text.length, index + query.length + length / 2);
    let snippet = text.slice(start, end);

    if (start > 0) snippet = "..." + snippet;
    if (end < text.length) snippet = snippet + "...";

    return snippet;
  }

  function highlightMatch(text, query) {
    if (!query.trim()) return escapeHtml(text);
    const escaped = escapeHtml(text);
    const regex = new RegExp("(" + escapeRegex(query) + ")", "gi");
    return escaped.replace(regex, '<mark class="search-highlight">$1</mark>');
  }

  function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  // Keyboard navigation
  function handleKeydown(e) {
    const items = searchResults.querySelectorAll(".search-result-item");

    if (e.key === "ArrowDown" && items.length) {
      e.preventDefault();
      selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
      updateSelection(items);
    } else if (e.key === "ArrowUp" && items.length) {
      e.preventDefault();
      selectedIndex = Math.max(selectedIndex - 1, -1);
      updateSelection(items);
    } else if (e.key === "Enter" && selectedIndex >= 0 && items.length) {
      e.preventDefault();
      items[selectedIndex].click();
    } else if (e.key === "Escape") {
      closeSearch();
    }
  }

  function updateSelection(items) {
    items.forEach((item, i) => {
      item.classList.toggle("selected", i === selectedIndex);
      if (i === selectedIndex) {
        item.scrollIntoView({ block: "nearest" });
      }
    });
  }

  // Event listeners
  searchInput.addEventListener(
    "input",
    debounce((e) => {
      selectedIndex = -1;
      performSearch(e.target.value);
    }, 150)
  );

  searchInput.addEventListener("keydown", handleKeydown);

  // Click overlay to close
  searchOverlay.addEventListener("click", (e) => {
    if (e.target === searchOverlay) {
      closeSearch();
    }
  });

  // CMD+K / Ctrl+K to open
  document.addEventListener("keydown", (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === "k") {
      e.preventDefault();
      if (searchOverlay.classList.contains("visible")) {
        closeSearch();
      } else {
        openSearch();
      }
    }
  });
})();
