defmodule Dieman.Data do
  @moduledoc "Site configuration and content data."

  # Site
  @site_title "dieman.dev"
  @name "Alessandro Buonerba"
  @avatar "/images/avatar.jpeg"

  # Display mode: :icon or :text
  @social_display :icon

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
    %{href: "mailto:a.buonerba@proton.me", label: "Email", icon: :email}
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

  # Accessors
  def site_title, do: @site_title
  def name, do: @name
  def avatar, do: @avatar
  def social_display, do: @social_display
  def taglines, do: @taglines
  def locations, do: @locations
  def no_posts, do: @no_posts
  def coming_soon, do: @coming_soon
  def nav_links, do: @nav_links
  def social_links, do: @social_links
  def keywords, do: @keywords
  def symbols, do: @symbols
end
