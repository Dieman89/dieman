defmodule Dieman.ProjectsPage do
  use Dieman.Component

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Projects",
    permalink: "/projects"

  def template(assigns) do
    ~H"""
    <div class="projects-list">
      <p class="empty">Coming soon.</p>
    </div>
    """
  end
end
