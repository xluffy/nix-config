_log() {
  printf "\x1B[2;32m"
  echo "[LOG]" "[$(date)]:" "$*"
  printf "\x1B[0m"
}

_die() {
  printf "\x1B[2;31m"
  echo "[ERROR]" "[$(date +'%Y-%m-%d %H:%M:%S')]:" "$*" >&2
  exit 1
  printf "\x1B[0m"
}

lint() {
  yamllint -c ~/.yamllint .
}

enc() {
  if [[ $# -eq 1 ]]; then
    if [[ -d "$1" ]]; then
      if [[ -f "$1/secrets.yaml.dec" ]]; then
        if ! grep "sops:" "$1/secrets.yaml.dec" &>/dev/null; then
          helm secrets encrypt "$1/secrets.yaml.dec" && mv "$1/secrets.yaml.dec" "$1/secrets.yaml"
        else
          mv "$1/secrets.yaml.dec" "$1/secrets.yaml"
          echo "secrets.yaml.dec is already encrypted"
        fi
      fi
    else
      echo "$1" | tr -d "\n" | base64 -w0
    fi
  elif [[ $# -eq 0 ]]; then
    if [[ -f secrets.yaml.dec ]]; then
      if ! grep "sops:" secrets.yaml.dec &>/dev/null; then
        helm secrets encrypt secrets.yaml.dec && mv secrets.yaml.dec secrets.yaml
      else
        mv secrets.yaml.dec secrets.yaml
        echo "secrets.yaml.dec is already encrypted"
      fi
    fi
  fi
}

dec() {
  if [[ $# -eq 1 ]]; then
    if [[ -d "$1" ]]; then
      if [[ -f "$1/secrets.yaml" ]]; then
        helm secrets decrypt "$1/secrets.yaml"
      fi
    else
      echo "$1" | base64 -d
    fi
  elif [[ $# -eq 0 ]]; then
    helm secrets decrypt secrets.yaml
  fi
}

bz() {
  if [[ $# -eq 0 ]]; then
    _log "Missing arg: plan or apply"
  fi

  if [[ ! -f .bazooka.yaml ]]; then
    _log "Missing bazooka.yml"
  fi

  if [[ $1 == 'plan' ]]; then
    _log "Bazooka plan $(pwd) ❯❯❯"
    _setup=$(yq '.setup[0]' .bazooka.yaml | tr -d '"')
    eval "${_setup}"
    _plan=$(yq '.tasks.plan[]' .bazooka.yaml | tr -d '"')
    eval "${_plan}"
  elif [[ $1 == 'deploy' ]] || [[ $1 == 'apply' ]]; then
    _log "Bazooka deploy $(pwd) ❯❯❯"
    _setup=$(yq '.setup[0]' .bazooka.yaml | tr -d '"')
    eval "${_setup}"
    _deploy=$(yq '.tasks.deploy[]' .bazooka.yaml | tr -d '"')
    eval "${_deploy}"
  fi
}

f() {
  commit_msg=$(git diff --cached | llm -m 4o-mini "$(cat ~/code/me/nix-config/home-manager/modules/shell/commit-prompt.txt)")
  printf "Commit message:\n %s \n" "${commit_msg}"
  read -pr "Do you want to commit with this message? [y/N]: " confirm

  if [[ ${confirm} =~ ^[Yy]$ ]]; then
    git commit -m "${commit_msg}"
  else
    git reset HEAD .
    echo "Commit aborted."
  fi
}
