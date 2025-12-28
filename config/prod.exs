import Config

config :tableau, :config, url: "https://dieman.dev"
config :tableau, Tableau.PostExtension, future: false, dir: ["content/posts"]
