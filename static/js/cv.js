async function onCaptchaSuccess(token) {
  try {
    const response = await fetch('/_d.txt');
    const hash = (await response.text()).trim();
    const cvUrl = `/cv-${hash}.pdf`;
    showCV(cvUrl);
    sessionStorage.setItem('cv-url', cvUrl);
  } catch (e) {
    showCV('/cv.pdf');
  }
}

function showCV(cvUrl) {
  document.getElementById('cv-locked').style.display = 'none';
  document.getElementById('cv-unlocked').style.display = 'flex';
  const embed = document.querySelector('.cv-embed');
  const downloadLink = document.querySelector('.cv-download');
  if (embed) embed.data = cvUrl;
  if (downloadLink) downloadLink.href = cvUrl;
}

document.addEventListener('DOMContentLoaded', async function() {
  const savedUrl = sessionStorage.getItem('cv-url');
  if (savedUrl) {
    try {
      const response = await fetch(savedUrl, { method: 'HEAD' });
      if (response.ok) {
        showCV(savedUrl);
      } else {
        sessionStorage.removeItem('cv-url');
      }
    } catch (e) {
      sessionStorage.removeItem('cv-url');
    }
  }
});
