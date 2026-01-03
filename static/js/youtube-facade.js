// YouTube facade - loads iframe on click for better performance and cleaner look
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".video-facade").forEach((facade) => {
    facade.addEventListener("click", () => {
      const videoId = facade.dataset.videoId;
      const iframe = document.createElement("iframe");
      iframe.src = `https://www.youtube-nocookie.com/embed/${videoId}?autoplay=1&modestbranding=1&rel=0`;
      iframe.allow =
        "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture";
      iframe.allowFullscreen = true;
      facade.innerHTML = "";
      facade.appendChild(iframe);
      facade.classList.remove("video-facade");
    });
  });
});
