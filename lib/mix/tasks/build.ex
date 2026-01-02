defmodule Mix.Tasks.Dieman.Build do
  use Mix.Task

  @shortdoc "Build site with OG images, thumbnails, and CV protection"
  @moduledoc "Orchestrates the full site build process"

  def run(_argv) do
    :inets.start()
    :ssl.start()

    if Mix.env() == :prod do
      Dieman.OgImage.generate_all()
      Dieman.Thumbnails.generate_all()
    end

    Mix.Task.run("tableau.build")
    protect_cv()
  end

  defp protect_cv do
    source = "site/cv.pdf"

    if File.exists?(source) do
      hash =
        source
        |> File.read!()
        |> then(&:crypto.hash(:sha256, &1))
        |> Base.encode16(case: :lower)
        |> String.slice(0, 16)

      File.rename!(source, "site/cv-#{hash}.pdf")
      File.write!("site/_d.txt", hash)
      Mix.shell().info("CV protected")
    else
      Mix.shell().info("Warning: #{source} not found")
    end
  end
end
