<p align="center">
  <img src="static/images/avatar.jpeg" width="150" alt="Alessandro Buonerba" />
</p>

# dieman.dev

```elixir
:posts |> Enum.concat(:cv) |> deploy_to_web()
```

A personal site brewed with [Tableau](https://github.com/elixir-tools/tableau) and [Temple](https://github.com/mhanberg/temple).

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
