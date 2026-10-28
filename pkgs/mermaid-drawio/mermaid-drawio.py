"""Render Mermaid diagrams to PNG files with the draw.io web look.

Usage:
  mermaid-drawio IN.mmd OUT.png
  mermaid-drawio DOC.md [DOC.md ...]

Markdown mode renders each Mermaid block that is inside an HTML comment and
that has an image link directly after the comment:

    <!--
    ```mermaid
    flowchart TB
      A[Web] --&gt; B[Database]
    ```
    -->
    ![Web writes to the database](images/web-database.png)

A raw "-->" closes an HTML comment. Inside the comment, write "-->" as "--&gt;".
The script decodes HTML entities before it renders the diagram.
Image paths are relative to the markdown file.

Each PNG file contains the draw.io diagram. Open the PNG file in draw.io to edit it.
"""

import html
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

RESTYLE = Path(__file__).resolve().parent / "restyle_web.py"
# draw.io is an Electron app. On macOS, Chromium reads its "draw.io Safe Storage" key from the
# Keychain at startup, and macOS asks for access again for each new Nix build of draw.io.
# A PNG export does not need stored data, so use the Chromium mock keychain.
DRAWIO = [os.environ.get("DRAWIO", "drawio"), "--use-mock-keychain"]

BLOCK = re.compile(
    r"<!--[ \t]*\n```mermaid[ \t]*\n(?P<code>.*?)\n```[ \t]*\n-->[ \t]*\n"
    r"!\[[^\]]*\]\((?P<png>[^)\s]+\.png)\)",
    re.S,
)
OPEN = re.compile(r"<!--[ \t]*\n```mermaid[ \t]*\n")


def run(cmd: list[str]) -> None:
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        # Electron prints sandbox warnings on macOS. They do not mean failure.
        errors = [line for line in result.stderr.splitlines() if line.strip() and "sandbox_extension" not in line]
        sys.exit(f"mermaid-drawio: {' '.join(cmd)} failed:\n" + "\n".join(errors))


def render(code: str, png: Path) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        mmd, raw, web = (Path(tmp) / name for name in ("diagram.mmd", "diagram.drawio", "web.drawio"))
        mmd.write_text(code.rstrip() + "\n")
        run([*DRAWIO, "-x", "-f", "xml", "-o", str(raw), str(mmd)])
        if not raw.is_file() or raw.stat().st_size == 0:
            sys.exit(f"mermaid-drawio: draw.io did not convert the Mermaid code for {png}")
        run([sys.executable, str(RESTYLE), str(raw), str(web)])
        png.parent.mkdir(parents=True, exist_ok=True)
        run([*DRAWIO, "-x", "-f", "png", "-e", "-b", "16", "-s", "2", "-o", str(png), str(web)])
        if not png.is_file():
            sys.exit(f"mermaid-drawio: draw.io did not write {png}")
    print(png)


def render_markdown(doc: Path) -> None:
    text = doc.read_text()
    found = 0
    for start in OPEN.finditer(text):
        line = text.count("\n", 0, start.start()) + 1
        block = BLOCK.match(text, start.start())
        if block is None:
            sys.exit(f"{doc}:{line}: put a '-->' line after the Mermaid fence and an image link after it")
        if "-->" in block.group("code"):
            sys.exit(f"{doc}:{line}: a raw '-->' closes the HTML comment. Write it as '--&gt;'")
        render(html.unescape(block.group("code")), doc.parent / block.group("png"))
        found += 1
    if found == 0:
        print(f"{doc}: no Mermaid block in an HTML comment", file=sys.stderr)


def main(args: list[str]) -> None:
    if len(args) == 2 and args[0].endswith(".mmd") and args[1].endswith(".png"):
        render(Path(args[0]).read_text(), Path(args[1]))
    elif args and all(a.endswith(".md") for a in args):
        for doc in args:
            render_markdown(Path(doc))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
