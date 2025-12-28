---
title: "Go vs Scala: Two Philosophies of Parallelism"
date: 2024-01-15
---

When building concurrent systems, the choice of language shapes not just your code, but your entire mental model. Go and Scala represent two fundamentally different philosophies: **velocity** versus **expressivity**.

I recently built the same tool in both languages, a parallel HTTP endpoint checker, and the experience revealed fascinating trade-offs worth exploring.

## The Task

Both implementations verify a list of web endpoints, checking whether paths are correctly configured as public or private. Simple enough, but the approaches couldn't be more different.

## Go: Velocity Through Simplicity

Go's concurrency model is elegantly minimal. Goroutines are lightweight threads managed by the runtime, and launching one requires just the `go` keyword:

```go
type Config struct {
    BaseURL     string
    PublicPath  []string
    PrivatePath []string
}

var wg sync.WaitGroup
wg.Add(len(config.PublicPath))

for _, path := range config.PublicPath {
    go func(p string) {
        defer wg.Done()
        checkEndpoint(p, true)
    }(path)
}

wg.Wait()
```

The `sync.WaitGroup` coordinates completion: increment before launching, decrement when done, wait for zero. That's it.

What makes Go remarkable is what it *doesn't* require: no external dependencies, no complex type signatures, no build tool configuration. The standard library handles HTTP, synchronisation, and everything else.

The Go runtime scheduler automatically distributes goroutines across CPU cores. You don't manage threads; you describe work. This abstraction lets developers focus on program structure rather than low-level threading.

## Scala: Expressivity Through Composition

Scala with Cats Effect takes a radically different approach. Instead of imperative coordination, you compose effects:

```scala
def checkStatusCode(client: Client[IO], url: String): IO[Status] =
  IO.fromEither(Uri.fromString(url))
    .flatMap(uri => client.run(Request[IO](GET, uri = uri)).use(resp => IO.pure(resp.status)))
    .handleError(_ => Status.ServiceUnavailable)

def isPublic(config: Config, path: String)(client: Client[IO]): IO[Endpoint] =
  checkStatusCode(client, config.baseUrl + path).map { statusCode =>
    if (statusCode == Status.Ok) Endpoint.CheckSuccess(path, statusCode.code)
    else Endpoint.CheckError(path, statusCode.code, expectedStatus = 200)
  }
```

Parallelism is expressed through `parTraverse` and `parMapN`:

```scala
val privatePathValidation = config.privatePath.parTraverse(path =>
  isPrivate(config, path)(client))
val publicPathValidation = config.publicPath.parTraverse(path =>
  isPublic(config, path)(client))

(privatePathValidation, publicPathValidation).parMapN(_ ++ _)
```

The `parTraverse` function applies an effectful operation to each element in parallel, while `parMapN` combines results from independent parallel computations. Error handling, resource management, and cancellation are all handled by the type system.

## The Numbers

Running both on CI revealed the velocity gap:

```
Implementation       Build + Run Time
─────────────────────────────────────
Go                          5 seconds
Scala                      51 seconds
Scala (cached)             39 seconds
```

Go is **10x faster**. Zero dependencies means no download time, no resolution, no compilation of external libraries. It just builds and runs.

## When Each Wins

**Go excels** when you need fast iteration cycles and deployment simplicity. It's perfect for CLI tools, microservices, and DevOps tooling where a single binary matters. Teams with mixed experience levels can be productive quickly thanks to Go's deliberately simple design.

**Scala shines** in complex distributed systems where type safety prevents entire categories of bugs. When you need sophisticated error handling, resource management, and your domain benefits from functional composition, Scala's expressivity pays dividends. It's also the natural choice for Big Data workloads with Spark or Flink, or when you need deep JVM ecosystem access.

## The Trade-off

Go optimises for **getting things done quickly**. The language is deliberately simple: you can learn it in a weekend and be productive immediately. The cost is repetitive patterns and less abstraction power.

Scala with Cats Effect optimises for **correctness and composition**. The type system catches errors at compile time, and effects compose beautifully. The cost is a steeper learning curve and slower feedback loops.

Neither is universally better. Go wins on velocity; Scala wins on expressivity. The right choice depends on what you're building, who's building it, and how long you'll maintain it.

For a quick endpoint checker? Go, every time. For a distributed event processing pipeline? Scala's type safety and composition become invaluable.

The best engineers know both philosophies and reach for the right tool.
