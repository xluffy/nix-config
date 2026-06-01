# Pi Coding Agent

Multi-provider setup with automatic provider selection by directory. All configs managed via Home Manager (`home-manager/config/pi/`).

## How it works

Running `pi` in a directory auto-selects the provider:

| Directory | Provider | Model |
|---|---|---|
| `~/code/me/*` | DeepSeek | `deepseek-chat` |
| `~/code/work/*` | Anthropic | `claude-sonnet-4-20250514` |
| Anywhere else | `settings.json` default | DeepSeek |

Override with flags: `pi --provider openai --model gpt-4o`.

The magic is a shell wrapper in `function.sh`:

```bash
pi() {
  case "$PWD" in
    "$HOME/code/me"*)   command pi --provider deepseek --model deepseek-chat "$@";;
    "$HOME/code/work"*) command pi --provider anthropic --model claude-sonnet-4-20250514 "$@";;
    *)                  command pi "$@";;
  esac
}
```

## Providers

Two kinds:

| Type | Config file | Example |
|---|---|---|
| **Custom** — pi doesn't ship with it | `models.json` | DeepSeek, Ollama, OpenRouter |
| **Built-in** — pi knows all its models | `auth.json` | Anthropic, OpenAI, Gemini, Mistral, Groq |

Both pull API keys from 1Password via `cached-op.sh`, which caches keys for the day under `~/.cache/pi-op/`. No secrets in nix-config.

## Switching models at runtime

- **`/model`** — open model picker (any provider/model)
- **`Ctrl+P`** — cycle through `enabledModels` (defined in `settings.json`)
- **`Ctrl+T`** — cycle thinking level (off → minimal → low → medium → high → xhigh)

Currently in the cycle: `deepseek-*`, `claude-sonnet-*`, `claude-opus-*`.

## Adding a provider

### Built-in (OpenAI, Gemini, etc.)

1. Store key in 1Password: `op://private/openai-api-key/credential`
2. Add to `home-manager/config/pi/auth.json`:
   ```json
   "openai": {
     "type": "api_key",
     "key": "!~/.pi/agent/cached-op.sh 'op://private/openai-api-key/credential'"
   }
   ```
3. Optionally add to `enabledModels` in `settings.json` and add a directory rule in `function.sh`.
4. `just switch`

### Custom (Ollama, OpenRouter, company proxy, etc.)

1. Add to `home-manager/config/pi/models.json`:
   ```json
   "openrouter": {
     "baseUrl": "https://openrouter.ai/api/v1",
     "api": "openai-completions",
     "apiKey": "!~/.pi/agent/cached-op.sh 'op://private/openrouter-api-key/credential'",
     "models": [{ "id": "openrouter/anthropic/claude-sonnet-4", "name": "..." }]
   }
   ```
2. `just switch`

### Per-project override

Create `.pi/settings.json` in a project root (not managed by nix-config):

```json
{ "defaultProvider": "openai", "defaultModel": "gpt-4o" }
```

## Useful commands

```bash
pi                        # new session
pi --resume               # resume last session
pi --resume -n 2          # resume 2nd most recent
pi --list-sessions        # list all sessions
pi --thinking off         # disable thinking
```

In-session: `/tree` (branches), `/new`, `/fork`, `/compact`, `/review`, `/git-ci`, `/skill:<name>`.

## Troubleshooting

- **No API key:** verify 1Password path with `op read 'op://...'`; clear cache `rm -rf ~/.cache/pi-op/`
- **Wrapper not active:** `type pi` should show "function"; new terminal or `source ~/.config/nix-config/function.sh`
- **Bypass wrapper:** `command pi` runs pi directly
