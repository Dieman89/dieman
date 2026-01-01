defmodule Mix.Tasks.Dieman.Build do
  use Mix.Task

  @shortdoc "Build site with CV protection"
  @moduledoc "Builds the site and renames CV to hashed filename based on content"

  @doc false
  def run(_argv) do
    Mix.Task.run("tableau.build")
    protect_cv()
  end

  defp protect_cv do
    source = "site/cv.pdf"

    if File.exists?(source) do
      content = File.read!(source)
      hash = :crypto.hash(:sha256, content) |> Base.encode16(case: :lower) |> String.slice(0, 16)
      target = "site/cv-#{hash}.pdf"
      hash_file = "site/_d.txt"

      File.rename!(source, target)
      File.write!(hash_file, hash)
      Mix.shell().info("CV protected: /cv-#{hash}.pdf")
    else
      Mix.shell().info("Warning: #{source} not found")
    end
  end
end
