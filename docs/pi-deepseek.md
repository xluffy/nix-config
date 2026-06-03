# Configuring DeepSeek API Keys Securely in Pi

To avoid storing your DeepSeek API key in plaintext within your public Nix configuration (`models.json`), you can use one of several simple, native credential resolution methods supported by `@earendil-works/pi-coding-agent`.

---

## Solution 1: Dynamic Shell Command Execution (`!` Prefix) — Recommended

If an `apiKey` value in `models.json` is prefixed with an exclamation mark (`!`), `pi` will execute that command at runtime to dynamically retrieve your key. This keeps the configuration clean and secure.

### Option A: Local Key File (Simplest)

Store your key in a plain-text file on your local machine that is not tracked by Git or managed by Nix.

1. **Create the local key file** in your home directory:

   ```bash
   mkdir -p ~/.pi/agent
   echo "your-deepseek-api-key" > ~/.pi/agent/deepseek.key
   chmod 600 ~/.pi/agent/deepseek.key
   ```

2. **Update your `models.json`** to read the key:

   ```json
   "apiKey": "!cat ~/.pi/agent/deepseek.key"
   ```

### Option B: macOS Keychain (Native & Secure)

Use the native macOS Keychain to store the secret securely with zero plaintext files on disk.

1. **Save the key to the macOS Keychain**:

   ```bash
   security add-generic-password -a "$USER" -s "deepseek-api-key" -w "your-deepseek-api-key"
   ```

2. **Update your `models.json`**:

   ```json
   "apiKey": "!security find-generic-password -s 'deepseek-api-key' -w"
   ```

   *(Note: The first time `pi` runs, macOS will ask you to approve terminal/application access to the Keychain item, which is a one-time prompt.)*

### Option C: 1Password CLI (`op`) with TTL Caching

If you use 1Password to manage secrets, use the `cached-op.sh` wrapper to avoid hitting 1Password on every single API call:

1. **Update your `models.json`**:

   ```json
   "apiKey": "!~/.pi/agent/cached-op.sh 'op://private/deepseek-api-key/credential' 4"
   ```
   This caches the key for 4 hours (configurable). Subsequent calls within the TTL use the cache.

### Option D: Plaintext File (Ubuntu Server, No 1Password CLI)

For headless Ubuntu servers or environments where the 1Password CLI is not available, use a local plaintext file with the `--file` flag:

1. **Create a plaintext key file**:

   ```bash
   mkdir -p ~/.cache/pi-op
   echo "your-deepseek-api-key" > ~/.cache/pi-op/deepseek.key
   chmod 600 ~/.cache/pi-op/deepseek.key
   ```

2. **Update your `models.json`**:

   ```json
   "apiKey": "!~/.pi/agent/cached-op.sh --file ~/.cache/pi-op/deepseek.key 4"
   ```

   The script reads the key from the file and caches it in memory for the TTL duration, just like the 1Password mode.

---

## Solution 2: Built-in `auth.json` (Separation of Concerns)

`pi` can separate your models/providers structure from your secrets using a local, un-tracked `auth.json` file.

1. **Create a local `auth.json`** at `~/.pi/agent/auth.json`:
   ```json
   {
     "deepseek": {
       "type": "api_key",
       "key": "your-deepseek-api-key"
     }
   }
   ```
2. **Update your `models.json`** to omit `"apiKey"` entirely (or set it to `null`):
   ```json
   "providers": {
     "deepseek": {
       "baseUrl": "https://api.deepseek.com",
       "api": "openai-completions",
       // apiKey omitted or set to null here
       "models": [ ... ]
     }
   }
   ```

`pi` will match the provider named `"deepseek"` and automatically retrieve the matching key from your local `auth.json`.

---

## Solution 3: Direct Environment Variable Resolution

If you prefer to load keys via your environment (e.g., using `direnv` and `.envrc.local`):

1. **Update your `models.json`**:
   ```json
   "apiKey": "DEEPSEEK_API_KEY"
   ```
   *(Note the lack of `$` or `{}`. `pi` will check if the string corresponds to an environment variable name and load its value.)*
2. Define the key in your local, un-tracked shell variables (e.g., `.envrc.local` or a local shell setup):
   ```bash
   export DEEPSEEK_API_KEY="your-deepseek-api-key"
   ```

---

## Work Setup (macOS only)

### One-time setup

Create `~/code/work/.envrc.local` with your company proxy info:

```bash
cat > ~/code/work/.envrc.local << 'EOF'
export SKM_BASE_URL=https://lite.llm.skymavis.services
export SKM_ANTHROPIC_KEY=sk-ant-<your-key>
EOF
chmod 600 ~/code/work/.envrc.local
```

Then apply the nix config:

```bash
just switch
```

### Usage

```bash
# Personal — DeepSeek
cd ~/code/me
pi "hello"

# Work — Opus via company proxy (auto-detected)
cd ~/code/work/some-repo
pi "review this PR"
```
