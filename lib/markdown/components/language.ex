defmodule Dieman.Markdown.Components.Language do
  @moduledoc """
  Renders programming language names with their icon and brand color.

  ## Example

      ::lang[Rust]
      ::lang[Go]
      ::lang[Elixir]

  Supports:
  - Languages: Rust, Go, Python, TypeScript, JavaScript, Elixir, Java, Scala,
    Ruby, Swift, Kotlin, C#, C++, C, PHP, Haskell, Clojure, Erlang, Zig
  - DevOps: Docker, Kubernetes, Terraform, Ansible, Helm, Prometheus, Grafana, Nginx
  - Databases: Redis, PostgreSQL, MySQL, MongoDB, Elasticsearch, RabbitMQ
  - Cloud: AWS, Azure, GCP
  """

  alias Dieman.Assets

  # Language metadata: {icon_key, color, display_name}
  @languages %{
    "rust" => {:rust, "#CE422B", "Rust"},
    "go" => {:go, "#00ADD8", "Go"},
    "golang" => {:go, "#00ADD8", "Go"},
    "python" => {:python, "#3776AB", "Python"},
    "typescript" => {:typescript, "#3178C6", "TypeScript"},
    "ts" => {:typescript, "#3178C6", "TypeScript"},
    "javascript" => {:javascript, "#F7DF1E", "JavaScript"},
    "js" => {:javascript, "#F7DF1E", "JavaScript"},
    "elixir" => {:elixir, "#9580FF", "Elixir"},
    "java" => {:java, "#ED8B00", "Java"},
    "scala" => {:scala, "#DC322F", "Scala"},
    "ruby" => {:ruby, "#CC342D", "Ruby"},
    "swift" => {:swift, "#F05138", "Swift"},
    "kotlin" => {:kotlin, "#7F52FF", "Kotlin"},
    "csharp" => {:csharp, "#512BD4", "C#"},
    "c#" => {:csharp, "#512BD4", "C#"},
    "cpp" => {:cpp, "#00599C", "C++"},
    "c++" => {:cpp, "#00599C", "C++"},
    "c" => {:c, "#A8B9CC", "C"},
    "php" => {:php, "#777BB4", "PHP"},
    "haskell" => {:haskell, "#5D4F85", "Haskell"},
    "clojure" => {:clojure, "#5881D8", "Clojure"},
    "erlang" => {:erlang, "#A90533", "Erlang"},
    "zig" => {:zig, "#F7A41D", "Zig"},
    # DevOps & Infrastructure
    "docker" => {:docker, "#2496ED", "Docker"},
    "kubernetes" => {:kubernetes, "#326CE5", "Kubernetes"},
    "k8s" => {:kubernetes, "#326CE5", "K8s"},
    "terraform" => {:terraform, "#844FBA", "Terraform"},
    "ansible" => {:ansible, "#EE0000", "Ansible"},
    "helm" => {:helm, "#0F1689", "Helm"},
    "prometheus" => {:prometheus, "#E6522C", "Prometheus"},
    "grafana" => {:grafana, "#F46800", "Grafana"},
    "nginx" => {:nginx, "#009639", "Nginx"},
    # Databases
    "redis" => {:redis, "#FF4438", "Redis"},
    "postgresql" => {:postgresql, "#4169E1", "PostgreSQL"},
    "postgres" => {:postgresql, "#4169E1", "PostgreSQL"},
    "mysql" => {:mysql, "#4479A1", "MySQL"},
    "mongodb" => {:mongodb, "#47A248", "MongoDB"},
    "mongo" => {:mongodb, "#47A248", "MongoDB"},
    "elasticsearch" => {:elasticsearch, "#005571", "Elasticsearch"},
    "rabbitmq" => {:rabbitmq, "#FF6600", "RabbitMQ"},
    # Cloud Providers
    "gcp" => {:gcp, "#4285F4", "GCP"},
    "googlecloud" => {:gcp, "#4285F4", "Google Cloud"},
    "aws" => {:aws, "#FF9900", "AWS"},
    "amazonwebservices" => {:aws, "#FF9900", "AWS"},
    "azure" => {:azure, "#0078D4", "Azure"},
    "microsoftazure" => {:azure, "#0078D4", "Azure"}
  }

  # Languages to exclude from auto-detection
  @excluded ~w(markdown md shell sh bash zsh text txt plaintext console terminal diff mermaid)

  @doc "Process ::lang[Name] shortcodes in HTML"
  def process(html) do
    Regex.replace(~r/::lang\[([^\]]+)\]/, html, fn _, lang_name ->
      render_badge(lang_name)
    end)
  end

  @doc "Extract unique programming languages from markdown code blocks"
  def extract_languages(markdown) when is_binary(markdown) do
    ~r/```(\w+)/
    |> Regex.scan(markdown)
    |> Enum.map(fn [_, lang] -> String.downcase(lang) end)
    |> Enum.reject(&(&1 in @excluded))
    |> Enum.map(&normalize_language/1)
    |> Enum.uniq()
    |> Enum.filter(&supported?/1)
  end

  def extract_languages(_), do: []

  @doc "Render HTML badges for a list of language keys"
  def render_badges(languages) when is_list(languages) do
    Enum.map_join(languages, " ", &render_badge/1)
  end

  @doc "Check if a language is supported"
  def supported?(lang) do
    Map.has_key?(@languages, String.downcase(lang))
  end

  @doc "Get language metadata"
  def get_language(lang) do
    Map.get(@languages, String.downcase(lang))
  end

  # Normalize language aliases to canonical form
  defp normalize_language("golang"), do: "go"
  defp normalize_language("ts"), do: "typescript"
  defp normalize_language("js"), do: "javascript"
  defp normalize_language("c#"), do: "csharp"
  defp normalize_language("c++"), do: "cpp"
  defp normalize_language(lang), do: lang

  defp render_badge(lang_name) do
    key = String.downcase(String.trim(lang_name))

    case Map.get(@languages, key) do
      {icon_key, color, display} ->
        icon = Assets.lang_icon(icon_key)

        ~s(<span class="lang-badge" style="--lang-color: #{color}"><span class="lang-icon">#{icon}</span>#{display}</span>)

      nil ->
        # Fallback: just show the name without icon
        ~s(<span class="lang-badge">#{lang_name}</span>)
    end
  end
end
