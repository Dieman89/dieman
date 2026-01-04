(async function () {
  const mermaidDivs = document.querySelectorAll('.mermaid');
  if (!mermaidDivs.length) return;

  const { default: mermaid } = await import('https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs');

  const style = getComputedStyle(document.documentElement);
  const get = (v) => style.getPropertyValue(v).trim();

  mermaid.initialize({
    startOnLoad: true,
    theme: 'base',
    flowchart: { curve: 'basis', padding: 20 },
    themeVariables: {
      // Base
      background: get('--bg'),
      fontFamily: 'JetBrains Mono, monospace',
      fontSize: '14px',

      // Flowchart nodes
      primaryColor: get('--bg-1'),
      primaryTextColor: get('--fg'),
      primaryBorderColor: get('--fg-muted'),
      secondaryColor: get('--bg-1'),
      secondaryTextColor: get('--fg'),
      secondaryBorderColor: get('--fg-muted'),
      tertiaryColor: get('--bg-1'),
      tertiaryTextColor: get('--fg'),
      tertiaryBorderColor: get('--fg-muted'),

      // Lines & edges
      lineColor: get('--fg-muted'),
      textColor: get('--fg-soft'),
      edgeLabelBackground: get('--bg'),

      // Sequence diagram
      actorBorder: get('--fg-muted'),
      actorBkg: get('--bg-1'),
      actorTextColor: get('--fg'),
      actorLineColor: get('--fg-muted'),
      signalColor: get('--fg-muted'),
      signalTextColor: get('--fg-soft'),
      labelBoxBkgColor: get('--bg-1'),
      labelBoxBorderColor: get('--fg-muted'),
      labelTextColor: get('--fg'),
      loopTextColor: get('--fg-soft'),
      activationBorderColor: get('--orange'),
      activationBkgColor: 'rgba(243, 141, 112, 0.1)',

      // Notes
      noteBorderColor: get('--yellow'),
      noteBkgColor: 'rgba(249, 204, 108, 0.1)',
      noteTextColor: get('--yellow'),

      // Other
      titleColor: get('--orange'),
      nodeTextColor: get('--fg'),
      clusterBkg: get('--bg'),
      clusterBorder: get('--fg-muted'),
      sequenceNumberColor: get('--bg')
    }
  });
})();
