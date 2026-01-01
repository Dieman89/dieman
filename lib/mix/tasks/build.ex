defmodule Mix.Tasks.Dieman.Build do
  use Mix.Task

  @shortdoc "Build site with CV protection"
  @moduledoc "Builds the site and renames CV to hashed filename"

  @doc false
  def run(_argv) do
    Mix.Task.run("tableau.build")

    case System.get_env("CV_PASSWORD") do
      nil ->
        Mix.shell().info("CV_PASSWORD not set - CV will be at /cv.pdf")

      password ->
        protect_cv(password)
    end
  end

  defp protect_cv(password) do
    hash = :crypto.hash(:sha256, password) |> Base.encode16(case: :lower)
    source = "site/cv.pdf"
    target = "site/cv-#{hash}.pdf"
    hash_file = "site/_d.txt"

    if File.exists?(source) do
      File.rename!(source, target)
      File.write!(hash_file, hash)
      Mix.shell().info("CV protected: /cv-#{hash}.pdf")
    else
      Mix.shell().info("Warning: #{source} not found")
    end
  end
end
