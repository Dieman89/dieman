defmodule Dieman.Settings do
  @moduledoc "Site settings and configuration values."

  # Date/Time
  @date_format "%b %d, %Y"
  @default_post_time "01:00:00 -04:00"

  # Reading time
  @words_per_minute 200

  # Assets
  @stylesheet "/css/site.css"
  @glitch_script "/js/glitch.js"

  # Fonts
  @font_preconnect ["https://fonts.googleapis.com", "https://fonts.gstatic.com"]
  @font_stylesheet "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap"

  # Icons - read from static/svg at compile time
  @svg_dir Path.expand("../static/svg", __DIR__)
  @external_resource Path.join(@svg_dir, "github.svg")
  @external_resource Path.join(@svg_dir, "linkedin.svg")
  @external_resource Path.join(@svg_dir, "rss.svg")
  @external_resource Path.join(@svg_dir, "email.svg")

  @icons %{
    github: File.read!(Path.join(@svg_dir, "github.svg")),
    linkedin: File.read!(Path.join(@svg_dir, "linkedin.svg")),
    rss: File.read!(Path.join(@svg_dir, "rss.svg")),
    email: File.read!(Path.join(@svg_dir, "email.svg"))
  }

  # Accessors
  def date_format, do: @date_format
  def default_post_time, do: @default_post_time
  def words_per_minute, do: @words_per_minute
  def stylesheet, do: @stylesheet
  def glitch_script, do: @glitch_script
  def font_preconnect, do: @font_preconnect
  def font_stylesheet, do: @font_stylesheet
  def icon(name), do: @icons[name]
end
