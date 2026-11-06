"""Print the Aider repository map: ranked files with their key definitions."""

import argparse
import contextlib
import os
import subprocess
import sys
from pathlib import Path

from aider import repomap
from aider.repomap import RepoMap, find_src_files


class IO:
    """The part of aider.io.InputOutput that RepoMap calls."""

    def tool_output(self, *args, **_):
        print(*args, file=sys.stderr)

    tool_warning = tool_error = tool_output

    def read_text(self, fname):
        try:
            return Path(fname).read_text(errors="replace")
        except OSError:
            return None


class Model:
    """Count 4 characters as 1 token, so no LLM client loads."""

    def token_count(self, text):
        return len(text) / 4


def source_files(root):
    cmd = ["git", "-C", root, "ls-files", "-z", "--cached", "--others", "--exclude-standard"]
    try:
        out = subprocess.run(cmd, capture_output=True, check=True).stdout.decode()
    except (OSError, subprocess.CalledProcessError):
        return find_src_files(root)
    return [os.path.join(root, name) for name in out.split("\0") if name]


def main():
    parser = argparse.ArgumentParser(prog="repo-map", description=__doc__)
    parser.add_argument("root", nargs="?", default=".", help="repository directory")
    parser.add_argument("-t", "--tokens", type=int, default=2048, help="token budget")
    parser.add_argument("-f", "--focus", action="append", default=[], help="file (relative to root) to rank higher")
    parser.add_argument("-i", "--ident", action="append", default=[], help="identifier to rank higher")
    args = parser.parse_args()

    root = os.path.abspath(args.root)
    cache = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "repo-map"
    RepoMap.TAGS_CACHE_DIR = str(cache / f"tags.v{repomap.CACHE_VERSION}")  # not in the repo
    rmap = RepoMap(map_tokens=args.tokens, root=root, main_model=Model(), io=IO())
    with contextlib.redirect_stdout(sys.stderr):  # keep the Aider spinner out of the map
        text = rmap.get_repo_map([], source_files(root), set(args.focus), set(args.ident))
    if not text:
        sys.exit(f"repo-map: no supported source files in {root}")
    sys.stdout.write(text)


if __name__ == "__main__":
    main()
