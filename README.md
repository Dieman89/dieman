<p align="center">
  <a href="https://dieman.dev">
    <img src="static/images/avatar.jpeg" width="150" alt="dieman.dev" />
  </a>
  <br>
  <a href="https://dieman.dev"><strong>dieman.dev</strong></a>
  <br>
  <code>:posts |> Enum.concat(:cv) |> deploy_to_web()</code>
  <br>
  <center>
  A personal site brewed with <a href="https://github.com/elixir-tools/tableau">Tableau</a> and <a href="https://github.com/mhanberg/temple">Temple</a>
</p></center>

## Setup

```bash
mix deps.get
pre-commit install
```

## Development

```bash
mix tableau.server
```

Site available at http://localhost:4999

## Code Quality

```bash
# Format code
mix format

# Check formatting (CI)
mix format --check-formatted

# Lint
mix credo

# Lint strict mode
mix credo --strict

# Compile with warnings as errors
mix compile --warnings-as-errors
```

## Production Build

```bash
MIX_ENV=prod mix build
```

Output goes to `site/`. Deployment to GitHub Pages is automatic on push to `main`.

## Writing Posts

```bash
mix dieman.gen.post "My Post Title"
```

Or manually create `content/posts/2025-01-15-my-post.md`:

```markdown
---
title: My Post Title
date: 2025-01-15
---

Your content here with **markdown** support.
```

| Directory | Visibility |
|-----------|------------|
| `content/posts/` | Published (dev + prod) |
| `content/drafts/` | Draft (dev only) |

## Structure

```
lib/
├── data.ex        # Site configuration
├── components.ex  # Reusable UI components
├── layout.ex      # Page layouts
├── home.ex        # Home page
├── posts.ex       # Posts list
├── projects.ex    # Projects page
└── cv.ex          # CV page
content/
├── posts/         # Published posts
└── drafts/        # Draft posts (dev only)
static/
├── css/           # Styles
├── images/        # Images
└── js/            # JavaScript
```
