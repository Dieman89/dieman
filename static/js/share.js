// Share buttons functionality
(function() {
  // Create modal HTML
  function createModal() {
    const modal = document.createElement('div');
    modal.className = 'mastodon-modal';
    modal.innerHTML = `
      <div class="mastodon-modal-backdrop"></div>
      <div class="mastodon-modal-content">
        <div class="mastodon-modal-header">Share on Mastodon</div>
        <p class="mastodon-modal-desc">Enter your Mastodon instance</p>
        <input type="text" class="mastodon-modal-input" placeholder="mastodon.social" autocomplete="off" spellcheck="false">
        <div class="mastodon-modal-actions">
          <button class="mastodon-modal-cancel">Cancel</button>
          <button class="mastodon-modal-confirm">Share</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    return modal;
  }

  function showModal(callback) {
    let modal = document.querySelector('.mastodon-modal');
    if (!modal) modal = createModal();

    const input = modal.querySelector('.mastodon-modal-input');
    const backdrop = modal.querySelector('.mastodon-modal-backdrop');
    const cancelBtn = modal.querySelector('.mastodon-modal-cancel');
    const confirmBtn = modal.querySelector('.mastodon-modal-confirm');

    // Pre-fill with saved instance
    const saved = localStorage.getItem('mastodon-instance');
    if (saved) input.value = saved;

    modal.classList.add('active');
    setTimeout(() => input.focus(), 100);

    function close() {
      modal.classList.remove('active');
    }

    function confirm() {
      const value = input.value.trim();
      if (value) {
        callback(value);
        close();
      }
    }

    backdrop.onclick = close;
    cancelBtn.onclick = close;
    confirmBtn.onclick = confirm;
    input.onkeydown = (e) => {
      if (e.key === 'Enter') confirm();
      if (e.key === 'Escape') close();
    };
  }

  document.addEventListener('DOMContentLoaded', function() {
    // Copy link button
    const copyBtn = document.querySelector('.share-btn-copy');
    if (copyBtn) {
      copyBtn.addEventListener('click', async function(e) {
        e.preventDefault();
        const url = window.location.href;

        try {
          await navigator.clipboard.writeText(url);
          copyBtn.classList.add('copied');
          const originalTitle = copyBtn.getAttribute('title');
          copyBtn.setAttribute('title', 'Copied!');

          setTimeout(() => {
            copyBtn.classList.remove('copied');
            copyBtn.setAttribute('title', originalTitle);
          }, 2000);
        } catch (err) {
          // Fallback for older browsers
          const textArea = document.createElement('textarea');
          textArea.value = url;
          document.body.appendChild(textArea);
          textArea.select();
          document.execCommand('copy');
          document.body.removeChild(textArea);
          copyBtn.classList.add('copied');
          setTimeout(() => copyBtn.classList.remove('copied'), 2000);
        }
      });
    }

    // Mastodon share
    const mastodonBtn = document.querySelector('.share-btn-mastodon');
    if (mastodonBtn) {
      mastodonBtn.addEventListener('click', function(e) {
        e.preventDefault();
        const h1 = document.querySelector('article h1');
        let title;
        if (h1) {
          title = h1.textContent.trim().replace(/\s+/g, ' ');
        } else {
          // Fallback: strip site name from document.title ("Post Title | dieman.dev")
          title = document.title.split(' | ')[0].trim();
        }
        const text = encodeURIComponent('I enjoyed "' + title + '" by @dieman\n\n' + window.location.href);

        const saved = localStorage.getItem('mastodon-instance');
        if (saved) {
          window.open(`https://${saved}/share?text=${text}`, '_blank', 'noopener,noreferrer');
        } else {
          showModal(function(instance) {
            const clean = instance.replace(/^https?:\/\//, '').replace(/\/$/, '');
            localStorage.setItem('mastodon-instance', clean);
            window.open(`https://${clean}/share?text=${text}`, '_blank', 'noopener,noreferrer');
          });
        }
      });
    }
  });
})();
