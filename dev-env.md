# Your dev environment, everywhere

- direnv
- devenv
- flox


| Feature / Tool      | **direnv**                        | **devenv**                     | **flox**                       |
|---------------------|-----------------------------------|--------------------------------|--------------------------------|
| **Purpose**         | Manages environment variables per directory | Full-fledged development environment manager | Containerized, language-specific environments (Haskell focus) |
| **Configuration**   | `.envrc` files                    | Config files for full environment | Config files for containers and dependencies |
| **Use Case**        | Simple, quick environment setups | Complex, repeatable dev environments (Docker-based) | Specialized dev environments, particularly for Haskell |
| **Learning Curve**  | Low                               | Medium to High                 | Medium to High                 |
| **Containerization**| No                                | Yes (Docker)                   | Yes (Docker)                   |
| **Language Focus**  | Any                               | Any                            | Primarily Haskell              |
| **Environment Scope**| Environment variables             | Complete development setup (tools, dependencies, etc.) | Containerized environments for specific languages |
