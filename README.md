<p align="center">
  <a href="https://dieman.dev">
    <img src="static/images/site.png" alt="dieman.dev" />
  </a>
  <br><br>
  <code>:posts |> Enum.concat(:cv) |> deploy_to_web()</code>
</p>

---

```bash
mix deps.get && mix start         # visit localhost:4999
MIX_ENV=prod mix build            # build to site/
CV_PASSWORD="password" mix start  # protected cv
mix dieman.gen.post "Title"       # new post
```
