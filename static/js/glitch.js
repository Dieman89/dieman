document.addEventListener('DOMContentLoaded', function() {
  const glitchText = document.querySelector('.glitch-text');
  if (!glitchText) return;

  function triggerGlitch() {
    glitchText.classList.add('active');
    setTimeout(() => {
      glitchText.classList.remove('active');
    }, Math.random() * 300 + 200);
    setTimeout(triggerGlitch, Math.random() * 2000 + 3000);
  }

  setTimeout(triggerGlitch, Math.random() * 2000 + 1000);
});
