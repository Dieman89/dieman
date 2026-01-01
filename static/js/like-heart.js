(function () {
  const article = document.querySelector("article");
  if (!article) return;

  const postId = window.location.pathname;
  const storageKey = `heart-${postId}`;
  const countedKey = `heart-counted-${postId}`;
  const maxClicks = 5;
  const API_URL = "https://heart-counter.a-buonerba.workers.dev";

  let clicks = parseInt(localStorage.getItem(storageKey) || "0", 10);
  let totalCount = 0;
  let hasCounted = localStorage.getItem(countedKey) === "true";

  const heart = document.createElement("button");
  heart.className = "like-heart";
  heart.setAttribute("aria-label", "Like this article");

  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("width", "24");
  svg.setAttribute("height", "24");

  const defs = document.createElementNS("http://www.w3.org/2000/svg", "defs");
  const gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient");
  gradient.setAttribute("id", "heart-gradient");
  gradient.setAttribute("x1", "0%");
  gradient.setAttribute("y1", "0%");
  gradient.setAttribute("x2", "100%");
  gradient.setAttribute("y2", "100%");

  const stop1 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
  stop1.setAttribute("offset", "0%");
  stop1.setAttribute("stop-color", "#ff8a9e");

  const stop2 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
  stop2.setAttribute("offset", "50%");
  stop2.setAttribute("stop-color", "#fd6883");

  const stop3 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
  stop3.setAttribute("offset", "100%");
  stop3.setAttribute("stop-color", "#d44d68");

  gradient.appendChild(stop1);
  gradient.appendChild(stop2);
  gradient.appendChild(stop3);
  defs.appendChild(gradient);
  svg.appendChild(defs);

  const pathBg = document.createElementNS("http://www.w3.org/2000/svg", "path");
  pathBg.setAttribute("class", "heart-bg");
  pathBg.setAttribute("d", "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z");

  const pathFill = document.createElementNS("http://www.w3.org/2000/svg", "path");
  pathFill.setAttribute("class", "heart-fill");
  pathFill.setAttribute("d", "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z");

  svg.appendChild(pathBg);
  svg.appendChild(pathFill);
  heart.appendChild(svg);

  const countEl = document.createElement("span");
  countEl.className = "heart-count";
  heart.appendChild(countEl);

  document.body.appendChild(heart);

  async function fetchCount() {
    try {
      const res = await fetch(`${API_URL}/api/hearts${postId}`);
      const data = await res.json();
      totalCount = data.count || 0;
      updateCount();
    } catch (e) {}
  }

  async function incrementCount() {
    if (hasCounted) return;
    try {
      const res = await fetch(`${API_URL}/api/hearts${postId}`, { method: "POST" });
      const data = await res.json();
      totalCount = data.count || totalCount + 1;
      hasCounted = true;
      localStorage.setItem(countedKey, "true");
      updateCount();
    } catch (e) {}
  }

  function updateCount() {
    countEl.textContent = totalCount > 0 ? totalCount : "";
    countEl.style.display = totalCount > 0 ? "" : "none";
    if (totalCount > 0) {
      countEl.classList.remove("pop");
      void countEl.offsetWidth;
      countEl.classList.add("pop");
    }
  }

  function updateHeart() {
    const percent = Math.min((clicks / maxClicks) * 100, 100);
    pathFill.style.clipPath = `inset(${100 - percent}% 0 0 0)`;
    heart.setAttribute("data-filled", clicks >= maxClicks ? "true" : "false");
  }

  function createParticles() {
    const shapes = ["circle", "square", "triangle"];
    const colors = ["var(--red)", "var(--green)", "var(--yellow)", "var(--blue)", "var(--purple)"];
    const count = 12;
    for (let i = 0; i < count; i++) {
      const particle = document.createElement("span");
      const shape = shapes[Math.floor(Math.random() * shapes.length)];
      particle.className = `particle particle-${shape}`;
      const baseAngle = (i / count) * Math.PI * 2;
      const angle = baseAngle + (Math.random() - 0.5) * 0.5;
      const distance = 40 + Math.random() * 50;
      particle.style.setProperty("--x", Math.cos(angle) * distance + "px");
      particle.style.setProperty("--y", Math.sin(angle) * distance + "px");
      particle.style.setProperty("--color", colors[Math.floor(Math.random() * colors.length)]);
      particle.style.animationDelay = Math.random() * 0.1 + "s";
      heart.appendChild(particle);
      setTimeout(() => particle.remove(), 1600);
    }
  }

  function handleClick() {
    if (clicks < maxClicks) {
      clicks++;
      localStorage.setItem(storageKey, clicks.toString());
      updateHeart();
      heart.classList.add("pulse");
      setTimeout(() => heart.classList.remove("pulse"), 300);

      if (clicks === maxClicks) {
        heart.classList.add("complete");
        createParticles();
        incrementCount();
      }
    }
  }

  heart.addEventListener("click", handleClick);
  updateHeart();
  fetchCount();

  function checkVisibility() {
    const articleRect = article.getBoundingClientRect();
    const nearEnd = articleRect.bottom <= window.innerHeight + 100;
    heart.classList.toggle("visible", nearEnd);
  }

  window.addEventListener("scroll", checkVisibility);
  window.addEventListener("resize", checkVisibility);
  checkVisibility();
})();
