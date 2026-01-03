import Config

config :tableau, :reloader,
  patterns: [
    ~r"lib/.*.ex",
    ~r"content/.*.md",
    ~r"static/.*"
  ]

config :web_dev_utils, :reload_log, true

config :tableau, :config,
  converters: [md: Dieman.Markdown.Converter],
  url: "https://dieman.dev",
  timezone: "America/Mexico_City",
  include_dir: "static",
  out_dir: "site",
  markdown: [
    mdex: [
      extension: [
        table: true,
        header_ids: "",
        tasklist: true,
        strikethrough: true,
        autolink: true,
        footnotes: true,
        alerts: true
      ],
      render: [unsafe_: true],
      syntax_highlight: [formatter: {:html_inline, theme: "monokai_pro_ristretto"}]
    ]
  ]

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.DataExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "dieman.dev",
  description: "Alessandro Buonerba - Senior Software Engineer"

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  permalink: "/posts/:title",
  layout: "Dieman.PostLayout"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

if Mix.env() in [:dev, :prod] do
  import_config "#{Mix.env()}.exs"
end
