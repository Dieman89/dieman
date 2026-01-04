(function () {
  const gists = document.querySelectorAll('.gist-embed');
  if (!gists.length) return;

  // Read CSS variables from parent document
  const style = getComputedStyle(document.documentElement);
  const get = (v) => style.getPropertyValue(v).trim();

  const colors = {
    bg: get('--bg'),
    bg1: get('--bg-1'),
    bg2: get('--bg-2'),
    fg: get('--fg'),
    fgSoft: get('--fg-soft'),
    fgMuted: get('--fg-muted'),
    fgDim: get('--fg-dim'),
    comment: get('--comment'),
    red: get('--red'),
    orange: get('--orange'),
    yellow: get('--yellow'),
    green: get('--green'),
    blue: get('--blue'),
    purple: get('--purple')
  };

  gists.forEach(container => {
    const gistPath = container.dataset.gist;
    if (!gistPath) return;

    const [author, gistId] = gistPath.split('/');
    const gistUrl = `https://gist.github.com/${gistPath}`;

    const iframe = document.createElement('iframe');
    iframe.className = 'gist-iframe';
    iframe.setAttribute('frameborder', '0');
    iframe.setAttribute('scrolling', 'no');

    // Create header with filename and copy button
    const header = document.createElement('div');
    header.className = 'gist-header';
    header.innerHTML = `
      <span class="gist-header-filename"></span>
      <button class="gist-copy" title="Copy code">
        <svg class="copy-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"/><path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"/></svg>
        <svg class="check-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:none"><path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"/></svg>
      </button>
    `;

    // Create custom footer
    const footer = document.createElement('div');
    footer.className = 'gist-footer';
    footer.innerHTML = `
      <span class="gist-author">Gist by <a href="https://gist.github.com/${author}" target="_blank">${author}</a></span>
      <a class="gist-link" href="${gistUrl}" target="_blank">View on GitHub <svg width="12" height="12" viewBox="0 0 16 16" fill="currentColor"><path d="M3.75 2h3.5a.75.75 0 0 1 0 1.5h-3.5a.25.25 0 0 0-.25.25v8.5c0 .138.112.25.25.25h8.5a.25.25 0 0 0 .25-.25v-3.5a.75.75 0 0 1 1.5 0v3.5A1.75 1.75 0 0 1 12.25 14h-8.5A1.75 1.75 0 0 1 2 12.25v-8.5C2 2.784 2.784 2 3.75 2Zm6.854-1h4.146a.25.25 0 0 1 .25.25v4.146a.25.25 0 0 1-.427.177L13.03 4.03 9.28 7.78a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042l3.75-3.75-1.543-1.543A.25.25 0 0 1 10.604 1Z"/></svg></a>
    `;

    // Create HTML content for iframe with theme colors
    const html = `
      <html>
        <head>
          <base target="_parent">
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { background: ${colors.bg} !important; overflow: hidden; }
            body { padding: 4px; }
            .gist .gist-file {
              border: none !important;
              margin: 0 !important;
              background: ${colors.bg} !important;
            }
            .gist .gist-data {
              background: ${colors.bg} !important;
              border: none !important;
            }
            .gist .blob-wrapper {
              background: ${colors.bg} !important;
            }
            .gist .blob-wrapper table {
              border-collapse: collapse !important;
            }
            .gist table {
              font-family: 'JetBrains Mono', monospace !important;
              font-size: 12px !important;
            }
            .gist .gist-meta {
              position: absolute !important;
              opacity: 0 !important;
              pointer-events: none !important;
              height: 0 !important;
              overflow: hidden !important;
            }
            .gist .blob-code,
            .gist .blob-num {
              background: ${colors.bg} !important;
              color: ${colors.fgSoft} !important;
              line-height: 1.5 !important;
              padding: 0 10px !important;
            }
            .gist .blob-num {
              color: ${colors.fgDim} !important;
              padding-right: 15px !important;
            }
            .gist .blob-num:hover { color: ${colors.fgMuted} !important; }
            /* Syntax highlighting */
            .gist .pl-c { color: ${colors.comment} !important; font-style: italic; }
            .gist .pl-c1 { color: ${colors.purple} !important; }
            .gist .pl-e { color: ${colors.green} !important; }
            .gist .pl-en { color: ${colors.green} !important; }
            .gist .pl-k { color: ${colors.red} !important; }
            .gist .pl-s { color: ${colors.yellow} !important; }
            .gist .pl-s1 { color: ${colors.yellow} !important; }
            .gist .pl-pds { color: ${colors.yellow} !important; }
            .gist .pl-v { color: ${colors.orange} !important; }
            .gist .pl-smi { color: ${colors.fgSoft} !important; }
            .gist .pl-sr { color: ${colors.orange} !important; }
            .gist .pl-mh { color: ${colors.green} !important; }
            .gist .pl-mi { color: ${colors.red} !important; font-style: italic; }
            .gist .pl-mb { color: ${colors.yellow} !important; font-weight: bold; }
            .gist .pl-md { color: ${colors.red} !important; }
            .gist .pl-mi1 { color: ${colors.green} !important; }
          </style>
        </head>
        <body>
          <script src="https://gist.github.com/${gistPath}.js"><\/script>
        </body>
      </html>
    `;

    iframe.srcdoc = html;
    container.appendChild(header);
    container.appendChild(iframe);
    container.appendChild(footer);

    // Copy button functionality
    const copyBtn = header.querySelector('.gist-copy');
    const copyIcon = copyBtn.querySelector('.copy-icon');
    const checkIcon = copyBtn.querySelector('.check-icon');

    copyBtn.addEventListener('click', () => {
      try {
        const doc = iframe.contentDocument || iframe.contentWindow.document;
        const codeLines = doc.querySelectorAll('.blob-code-inner');
        const code = Array.from(codeLines).map(line => line.textContent).join('\n');

        navigator.clipboard.writeText(code).then(() => {
          copyIcon.style.display = 'none';
          checkIcon.style.display = 'block';
          copyBtn.classList.add('copied');
          setTimeout(() => {
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            copyBtn.classList.remove('copied');
          }, 2000);
        });
      } catch (e) {}
    });

    // Auto-resize iframe to content height and extract filename
    iframe.onload = () => {
      try {
        const updateGist = () => {
          const doc = iframe.contentDocument || iframe.contentWindow.document;
          const height = doc.body.scrollHeight;
          if (height > 0) {
            iframe.style.height = height + 'px';
            container.classList.add('loaded');
          }

          // Extract filename from gist meta link (usually the first link in gist-meta)
          const metaLinks = doc.querySelectorAll('.gist-meta a');
          let filename = '';
          for (const link of metaLinks) {
            const href = link.getAttribute('href') || '';
            const text = link.textContent?.trim() || '';
            // Look for filename pattern (has extension like .ex, .js, etc)
            if (text.match(/\.\w+$/) && !text.includes('/')) {
              filename = text;
              break;
            }
          }
          if (filename) {
            header.querySelector('.gist-header-filename').textContent = filename;
          }
        };
        updateGist();
        // Retry a few times as gist loads async
        setTimeout(updateGist, 500);
        setTimeout(updateGist, 1000);
        setTimeout(updateGist, 2000);
      } catch (e) {}
    };
  });
})();
