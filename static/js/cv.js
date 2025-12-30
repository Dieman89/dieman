async function unlockCV() {
  const password = document.getElementById('cv-password').value;
  const hash = await sha256(password);

  if (hash === window.CV_HASH) {
    document.querySelector('.cv-locked').style.display = 'none';
    document.querySelector('.cv-unlocked').style.display = 'flex';
    sessionStorage.setItem('cv-unlocked', 'true');
  } else {
    document.getElementById('cv-error').textContent = 'Incorrect password';
    document.getElementById('cv-password').value = '';
  }
}

async function sha256(str) {
  const buffer = new TextEncoder().encode(str);
  const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

document.addEventListener('DOMContentLoaded', function() {
  const input = document.getElementById('cv-password');
  if (input) {
    input.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') unlockCV();
    });
  }

  if (sessionStorage.getItem('cv-unlocked') === 'true') {
    const locked = document.querySelector('.cv-locked');
    const unlocked = document.querySelector('.cv-unlocked');
    if (locked) locked.style.display = 'none';
    if (unlocked) unlocked.style.display = 'flex';
  }
});
