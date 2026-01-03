// Image comparison slider - drag to compare before/after
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".image-compare").forEach((compare) => {
    const container = compare.querySelector(".image-compare-container");
    const beforeEl = compare.querySelector(".image-compare-before");
    const slider = compare.querySelector(".image-compare-slider");
    let isDragging = false;

    // Set container width for before image
    const updateContainerWidth = () => {
      const width = container.offsetWidth;
      beforeEl.style.setProperty("--container-width", `${width}px`);
      beforeEl.querySelector("img").style.width = `${width}px`;
    };

    updateContainerWidth();
    window.addEventListener("resize", updateContainerWidth);

    const updatePosition = (x) => {
      const rect = container.getBoundingClientRect();
      let percent = ((x - rect.left) / rect.width) * 100;
      percent = Math.max(0, Math.min(100, percent));

      beforeEl.style.width = `${percent}%`;
      slider.style.left = `${percent}%`;
    };

    const startDrag = (e) => {
      isDragging = true;
      compare.classList.add("dragging");
      e.preventDefault();
    };

    const endDrag = () => {
      isDragging = false;
      compare.classList.remove("dragging");
    };

    const drag = (e) => {
      if (!isDragging) return;
      const x = e.type.includes("touch") ? e.touches[0].clientX : e.clientX;
      updatePosition(x);
    };

    // Mouse events
    slider.addEventListener("mousedown", startDrag);
    document.addEventListener("mouseup", endDrag);
    document.addEventListener("mousemove", drag);

    // Touch events
    slider.addEventListener("touchstart", startDrag);
    document.addEventListener("touchend", endDrag);
    document.addEventListener("touchmove", drag);

    // Click to move slider
    container.addEventListener("click", (e) => {
      if (e.target === slider || e.target.closest(".image-compare-handle")) return;
      updatePosition(e.clientX);
    });
  });
});
