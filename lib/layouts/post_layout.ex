defmodule Dieman.PostLayout do
  use Dieman.Component
  use Tableau.Layout, layout: Dieman.RootLayout

  def template(assigns) do
    ~H"""
    <div class="single">
      <nav>
        <div class="nav-top">
          <a href="/"><img src="/images/avatar.jpeg" alt="Alessandro Buonerba" class="nav-avatar" /></a>
          <h1><a href="/" class="glitch-text" data-text="dieman.dev">dieman.dev</a></h1>
          <p>
            Senior Software Engineer<br />
            SRE & DevOps Engineer<br />
            IAM Specialist
          </p>
          <p><a href="/posts">/posts</a></p>
          <p><a href="/projects">/projects</a></p>
          <p><a href="/cv">/cv</a></p>
        </div>
        <div class="nav-bottom">
          <a href="https://github.com/Dieman89">GitHub</a>
          <a href="https://linkedin.com/in/buonerba">LinkedIn</a>
          <a href="mailto:a.buonerba@proton.me">a.buonerba@proton.me</a>
        </div>
      </nav>
      <article>
        <header>
          <%= if not is_nil(assigns[:page][:date]) do %>
            <p class="date"><%= Calendar.strftime(@page.date, "%b %d, %Y") %></p>
          <% end %>
          <h1><%= @page.title %></h1>
        </header>
        <.inner_content content={render(@inner_content)} />
      </article>
    </div>
    """
  end
end
