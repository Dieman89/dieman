(function () {
  const seen = JSON.parse(localStorage.getItem('seenTooltips') || '[]');

  document.querySelectorAll('.tooltip').forEach((el) => {
    const tip = el.getAttribute('data-tip');
    if (seen.includes(tip)) {
      el.classList.add('seen');
    }

    el.addEventListener('mouseenter', () => {
      if (!seen.includes(tip)) {
        seen.push(tip);
        localStorage.setItem('seenTooltips', JSON.stringify(seen));
      }
      el.classList.add('seen');
    }, { once: true });
  });
})();
