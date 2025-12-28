defmodule Dieman.HomePage do
  use Dieman.Component

  use Tableau.Page,
    layout: Dieman.RootLayout,
    permalink: "/"

  def template(assigns) do
    ~H"""
    <div class="home">
      <div>
        <img src="/images/avatar.jpeg" alt="Alessandro Buonerba" class="avatar" />
        <h1 class="glitch-text" data-text="Alessandro Buonerba">Alessandro Buonerba</h1>
        <p class="title">
          Senior Software Engineer<br />
          SRE & DevOps Engineer<br />
          IAM Specialist
        </p>
        <nav class="links">
          <a href="/posts">/posts</a>
          <a href="/projects">/projects</a>
          <a href="/cv">/cv</a>
        </nav>
      </div>
      <div class="shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
        <div class="shape shape-4"></div>
        <div class="shape shape-5"></div>
        <span class="keyword kw-1">def</span>
        <span class="keyword kw-2">end</span>
        <span class="keyword kw-3">fn</span>
        <span class="keyword kw-4">nil</span>
        <span class="keyword kw-5">true</span>
        <span class="keyword kw-6">async</span>
        <span class="keyword kw-7">loop</span>
        <span class="keyword kw-8">pub</span>
      </div>
      <footer class="social">
        <a href="https://github.com/Dieman89">GitHub</a>
        <a href="https://linkedin.com/in/buonerba">LinkedIn</a>
        <a href="mailto:a.buonerba@proton.me">a.buonerba@proton.me</a>
      </footer>
    </div>
    """
  end
end
