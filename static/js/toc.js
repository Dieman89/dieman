(function () {
  const article = document.querySelector("article");
  if (!article) return;

  const headings = Array.from(article.querySelectorAll("h2, h3"));
  if (headings.length < 2) return;

  const toc = document.createElement("div");
  toc.className = "toc";
  toc.setAttribute("role", "navigation");
  toc.setAttribute("aria-label", "Table of Contents");

  const tocTitle = document.createElement("span");
  tocTitle.className = "toc-title";
  tocTitle.textContent = "Contents";
  toc.appendChild(tocTitle);

  const tocList = document.createElement("ul");
  tocList.className = "toc-list";

  headings.forEach((heading) => {
    if (!heading.id) {
      heading.id = heading.textContent
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/(^-|-$)/g, "");
    }

    const li = document.createElement("li");
    li.className = `toc-item toc-${heading.tagName.toLowerCase()}`;

    const a = document.createElement("a");
    a.href = `#${heading.id}`;
    a.textContent = heading.textContent;
    a.className = "toc-link";

    a.addEventListener("click", (e) => {
      e.preventDefault();
      heading.scrollIntoView({ behavior: "smooth", block: "start" });
      history.pushState(null, "", `#${heading.id}`);
    });

    li.appendChild(a);
    tocList.appendChild(li);
  });

  toc.appendChild(tocList);
  document.body.appendChild(toc);

  const tocLinks = toc.querySelectorAll(".toc-link");
  let lastActiveLink = null;

  function isInViewportTopHalf(rect) {
    return rect.top > 0 && rect.bottom < window.innerHeight / 2;
  }

  function getActiveHeading() {
    const lastHeading = headings[headings.length - 1];
    const lastRect = lastHeading.getBoundingClientRect();
    const secondToLast = headings[headings.length - 2];
    const secondToLastRect = secondToLast ? secondToLast.getBoundingClientRect() : null;
    const atBottom = window.innerHeight + window.scrollY >= document.body.scrollHeight - 10;

    const secondToLastPassed = secondToLastRect && secondToLastRect.top < 100;
    const lastVisible = lastRect.top < window.innerHeight && lastRect.top > 0;

    if ((secondToLastPassed && lastVisible) || (atBottom && lastRect.top < window.innerHeight)) {
      return lastHeading;
    }

    const nextVisibleHeading = headings.find((heading) => {
      const rect = heading.getBoundingClientRect();
      return rect.top >= 0;
    });

    if (nextVisibleHeading) {
      const rect = nextVisibleHeading.getBoundingClientRect();
      if (isInViewportTopHalf(rect)) {
        return nextVisibleHeading;
      }
      const index = headings.indexOf(nextVisibleHeading);
      return headings[index - 1] || null;
    }

    return lastHeading;
  }

  function scrollTocToActive(link) {
    const linkIndex = Array.from(tocLinks).indexOf(link);

    // If first item, scroll ToC to top to show "Contents" title
    if (linkIndex === 0) {
      toc.scrollTo({ top: 0, behavior: "smooth" });
      return;
    }

    const tocRect = toc.getBoundingClientRect();
    const linkRect = link.getBoundingClientRect();

    // Check if link is outside visible area of ToC
    if (linkRect.top < tocRect.top || linkRect.bottom > tocRect.bottom) {
      link.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  function updateActiveLink() {
    const activeHeading = getActiveHeading();

    tocLinks.forEach((link) => {
      const isActive =
        activeHeading && link.getAttribute("href") === `#${activeHeading.id}`;

      if (isActive) {
        if (lastActiveLink && lastActiveLink !== link) {
          lastActiveLink.classList.remove("active");
        }
        link.classList.add("active");
        lastActiveLink = link;
        scrollTocToActive(link);
      } else {
        link.classList.remove("active");
      }
    });
  }

  window.addEventListener("scroll", updateActiveLink, { passive: true });
  window.addEventListener("resize", updateActiveLink, { passive: true });
  updateActiveLink();
})();
