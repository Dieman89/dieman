defmodule Dieman.Content do
  @moduledoc "Site content: identity, links, and projects."

  # Site
  @site_title "dieman.dev"
  @name "Alessandro Buonerba"
  @avatar "/images/avatar.png"

  # Profile
  @taglines [
    "Senior Software Engineer",
    "SRE & DevOps Engineer",
    "IAM Specialist"
  ]

  # Footer locations
  @locations [
    %{city: "Puebla", flag: "&#127474;&#127485;"},
    %{city: "London", flag: "&#127468;&#127463;"}
  ]

  # Empty states
  @no_posts "No posts yet."
  @coming_soon "Coming soon."

  # Links
  @nav_links [
    %{href: "/posts", label: "/posts"},
    %{href: "/projects", label: "/projects"},
    %{href: "/cv", label: "/cv"}
  ]

  @social_links [
    %{href: "https://github.com/Dieman89", label: "GitHub", icon: :github},
    %{href: "https://linkedin.com/in/buonerba", label: "LinkedIn", icon: :linkedin},
    %{href: "/feed.xml", label: "RSS", icon: :rss},
    %{href: "https://fantastical.app/dieman/meet-with-alessandro", label: "Meet", icon: :calendar},
    %{href: "https://discord.gg/ZdRkrMx6UX", label: "Discord", icon: :discord}
  ]

  # Decorative elements
  @keywords ~w(def end fn nil true async loop pub)

  @symbols [
    %{symbol: "~>", label: "FunctionK"},
    %{symbol: ">>=", label: "flatMap"},
    %{symbol: "IO", label: "Effect"},
    %{symbol: "F[_]", label: "Higher-kinded"},
    %{symbol: "pure", label: "Lift"},
    %{symbol: "resource", label: "Infrastructure"},
    %{symbol: "module", label: "Reusable"},
    %{symbol: "=>", label: "HCL Arrow"},
    %{symbol: "plan", label: "Preview"},
    %{symbol: "state", label: "Persistence"},
    %{symbol: "var", label: "Input"},
    %{symbol: "for_each", label: "Iteration"}
  ]

  # Projects
  @projects [
    %{
      title: "Systems",
      description: "Declarative macOS configuration using nix-darwin and home-manager.",
      image: "/images/projects/systems.png",
      repo: "https://github.com/Dieman89/systems",
      date: ~D[2025-12-18],
      tags: ["macOS", "dotfiles"],
      tech: ["Nix"]
    },
    %{
      title: "Zen Monokai Ristretto",
      description:
        "A warm, coffee-inspired dark theme for Zen Browser based on the Monokai Pro Ristretto color palette.",
      image: "/images/projects/zen-monokai-ristretto.png",
      repo: "https://github.com/Dieman89/zen-monokai-ristretto",
      date: ~D[2025-12-28],
      tags: ["Theme", "Zen Browser"],
      tech: ["CSS"]
    }
  ]

  # Accessors
  def site_title, do: @site_title
  def name, do: @name
  def avatar, do: @avatar

  @syntax_theme Application.compile_env(:tableau, :config)[:markdown][:mdex][:syntax_highlight][
                  :formatter
                ]
                |> elem(1)
                |> Keyword.get(:theme)
  def syntax_theme, do: @syntax_theme
  def taglines, do: @taglines
  def locations, do: @locations
  def no_posts, do: @no_posts
  def coming_soon, do: @coming_soon
  def nav_links, do: @nav_links
  def social_links, do: @social_links
  def keywords, do: @keywords
  def projects, do: @projects
  def symbols, do: @symbols
end
