// Copy code button for code blocks
(function () {
  const codeBlocks = document.querySelectorAll("article pre");
  if (!codeBlocks.length) return;

  codeBlocks.forEach((pre) => {
    pre.style.position = "relative";

    const button = document.createElement("button");
    button.className = "copy-code-btn";
    button.setAttribute("aria-label", "Copy code");
    button.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>`;

    button.addEventListener("click", async () => {
      const code = pre.querySelector("code");
      const text = code ? code.textContent : pre.textContent;

      try {
        await navigator.clipboard.writeText(text);
        button.classList.add("copied");
        button.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>`;

        setTimeout(() => {
          button.classList.remove("copied");
          button.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>`;
        }, 2000);
      } catch (err) {
        console.error("Failed to copy:", err);
      }
    });

    pre.appendChild(button);
  });
})();
