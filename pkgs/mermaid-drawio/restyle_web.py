"""Apply the draw.io web Mermaid theme to a .drawio file that the draw.io CLI converted from Mermaid.

Usage: restyle_web.py IN.drawio OUT.drawio [--keep-points]

The draw.io desktop CLI keeps the Mermaid colours. The draw.io web import applies its own theme.
This script copies the web theme and fixes the line layout. See CHANGELOG.md for the history.
"""
import re
import sys
import xml.etree.ElementTree as ET

FONT = "fontFamily=Recursive;fontSize=11;fontSource=https%3A%2F%2Ffonts.googleapis.com%2Fcss%3Ffamily%3DRecursive;"
SHADOW = "shadow=1;shadowColor=#000000;shadowOffsetX=4;shadowOffsetY=4;shadowBlur=0;shadowOpacity=6;"
NODE = "html=1;whiteSpace=wrap;strokeWidth=2;fillColor=#ffffff;strokeColor=#28253D;fontColor=#28253D;" + SHADOW + FONT
CONTAINER = "html=1;whiteSpace=nowrap;strokeWidth=1;verticalAlign=top;fillColor={fill};strokeColor={stroke};fontColor=#000000;" + SHADOW + FONT
PALETTE = [("#FDF4FF", "#E879F9"), ("#F0FDFA", "#2DD4BF"), ("#FFF7ED", "#FB923C"), ("#ECFEFF", "#22D3EE")]
EDGE = ("edgeStyle=orthogonalEdgeStyle;rounded=1;curved=0;endArrow=block;endSize=8;jumpStyle=arc;jumpSize=12;"
        "strokeColor=#000000;strokeWidth=2;targetPerimeterSpacing=4;")
LABEL = "html=1;labelBackgroundColor=#cccccc;fontColor=#28253D;" + FONT
SEQ_EDGE = "endArrow=block;endSize=8;strokeColor=#000000;strokeWidth=2;"
LANE = 16  # Minimum vertical distance between two horizontal line segments in a layer gap.

src, dst = sys.argv[1], sys.argv[2]
KEEP_POINTS = "--keep-points" in sys.argv
tree = ET.parse(src)
is_sequence = any("shape=umlLifeline" in (c.get("style") or "") for c in tree.iter("mxCell"))
containers = 0
for obj in tree.iter("UserObject"):
    cell = obj.find("mxCell")
    if cell is None:
        continue
    old = cell.get("style") or ""
    if is_sequence:
        new = re.sub(r"fillColor=light-dark\([^)]*\);", "fillColor=#ffffff;", old)
        new = re.sub(r"lifelineColor=light-dark\([^)]*\);", "lifelineColor=#28253D;", new)
        new = re.sub(r"(stroke|font)Color=light-dark\([^)]*\);", r"\1Color=#28253D;", new)
        new = re.sub(r"fontFamily=[^;]*;", "", new)
        new = re.sub(r"fontSize=\d+;", "", new)
        new = re.sub(r"strokeWidth=\d+;", "", new)
        extra = "strokeWidth=2;" + FONT + (SHADOW if cell.get("vertex") == "1" else "")
        if cell.get("edge") == "1" and obj.get("label"):
            # A white label background hides the lifelines that pass behind the message text.
            extra += "labelBackgroundColor=#ffffff;"
        cell.set("style", new + extra)
        obj.set("mermaidBaseStyle", cell.get("style"))
        continue
    if cell.get("edge") == "1":
        if "endArrow=none" in old and "startArrow=block" not in old and not is_sequence:
            new = "endArrow=none;startArrow=none;strokeColor=none;html=1;"
        else:
            dashed = "dashed=1;dashPattern=2 2;fixDash=1;" if "dashed=1" in old else ""
            start = "startArrow=block;startSize=8;sourcePerimeterSpacing=4;" if "startArrow=block" in old else "startArrow=none;"
            ports = "".join(re.findall(r"(?:exit|entry)[XY]=[^;]+;", old))
            base = SEQ_EDGE if is_sequence else EDGE
            new = base + dashed + start + ports + (LABEL if obj.get("label") else "")
            geo = cell.find("mxGeometry")
            if geo is not None and not (KEEP_POINTS or is_sequence):
                for arr in [a for a in geo if a.tag == "Array"]:
                    geo.remove(arr)
        cell.set("style", new)
    elif cell.get("vertex") == "1":
        if "verticalAlign=top" in old and not is_sequence:
            fill, stroke = PALETTE[containers % len(PALETTE)]
            containers += 1
            new = CONTAINER.format(fill=fill, stroke=stroke)
        elif "endArrow" in old or "line" in old or "dashed=1" in old:
            new = old.replace("light-dark(#333333,#cccccc)", "#28253D").replace("light-dark(#9370DB,#cccccc)", "#28253D")
        else:
            new = NODE
        cell.set("style", new)
    obj.set("mermaidBaseStyle", cell.get("style"))
if is_sequence:
    # Free text cells, for example the label of a self-message, are plain mxCells.
    for cell in tree.find(".//root").findall("mxCell"):
        st = cell.get("style") or ""
        if st.startswith("text;"):
            st = re.sub(r"fontFamily=[^;]*;|fontSize=\d+;|fontColor=[^;]*;|fillColor=[^;]*;", "", st)
            cell.set("style", st + "fillColor=#ffffff;fontColor=#28253D;" + FONT)


def spread_ports() -> None:
    """Give each top-to-bottom edge its own exit and entry point, like the draw.io web layout."""
    cells = {}
    for obj in tree.iter("UserObject"):
        c = obj.find("mxCell")
        if c is not None:
            cells[obj.get("id")] = c
    for c in tree.iter("mxCell"):
        if c.get("id"):
            cells.setdefault(c.get("id"), c)

    def box(cid):
        x = y = 0.0
        w = h = 0.0
        first = True
        while cid in cells:
            g = cells[cid].find("mxGeometry")
            if g is None:
                break
            x += float(g.get("x", 0))
            y += float(g.get("y", 0))
            if first:
                w, h, first = float(g.get("width", 0)), float(g.get("height", 0)), False
            cid = cells[cid].get("parent")
        return x, y, w, h

    edges = []
    for eid, c in cells.items():
        st = c.get("style") or ""
        if c.get("edge") != "1" or "strokeColor=none" in st or "dashed=1" in st:
            continue
        s, t = c.get("source"), c.get("target")
        if s not in cells or t not in cells:
            continue
        sb, tb = box(s), box(t)
        if sb[1] + sb[3] <= tb[1]:
            edges.append((c, s, t, sb, tb))
            g = c.find("mxGeometry")
            if g is not None and "labelBackgroundColor" in st:
                g.set("x", "0.6")
    out, inn = {}, {}
    for c, s, t, sb, tb in edges:
        out.setdefault(s, []).append((tb[0] + tb[2] / 2, c))
        inn.setdefault(t, []).append((sb[0] + sb[2] / 2, c))

    def assign(groups, prefix):
        for lst in groups.values():
            lst.sort(key=lambda p: p[0])
            n = len(lst)
            for i, (_, c) in enumerate(lst):
                frac = round((i + 1) / (n + 1), 2)
                st = re.sub(rf"{prefix}[XY]=[^;]+;", "", c.get("style"))
                yv = 1 if prefix == "exit" else 0
                c.set("style", st + f"{prefix}X={frac};{prefix}Y={yv};")

    assign(out, "exit")
    assign(inn, "entry")

    def frac(c, prefix):
        m = re.search(rf"{prefix}X=([0-9.]+);", c.get("style"))
        return float(m.group(1)) if m else 0.5

    def outer(cid):
        """Return the ID of the top-level container of a cell, or the cell itself."""
        top = cid
        while cells.get(top) is not None and cells[top].get("parent") not in (None, "1"):
            top = cells[top].get("parent")
        return top

    def band(s, t):
        """Return the free space for the horizontal lanes of an edge, and if it lies between two layers."""
        sb, tb = box(s), box(t)
        so, to = outer(s), outer(t)
        if so != to:
            ob, tob = box(so), box(to)
            top, bottom = ob[1] + ob[3], tob[1]
            if bottom - top > 0:
                return top, bottom, True
        return sb[1] + sb[3], tb[1], False

    # Make room: each gap between two layers must hold one lane for each edge.
    # Some draw.io versions ignore the Mermaid rankSpacing, so move the lower layers down when the gap is too small.
    for _ in range(len(cells)):
        gaps = {}
        for c, s, t, _sb, _tb in edges:
            top, bottom, between = band(s, t)
            if between:
                gaps.setdefault((top, bottom), []).append(c)
        short = [(k, len(v)) for k, v in gaps.items() if k[1] - k[0] < LANE * (len(v) + 1) - 0.5]
        if not short:
            break
        (top, bottom), n = min(short)
        shift = LANE * (n + 1) - (bottom - top)
        for c in cells.values():
            g = c.find("mxGeometry")
            if c.get("vertex") == "1" and c.get("parent") == "1" and g is not None:
                if float(g.get("y", 0)) >= bottom - 0.5:
                    g.set("y", str(round(float(g.get("y", 0)) + shift, 1)))

    # One horizontal lane per edge, so that lines to the same target do not share a segment.
    bands = {}
    for c, s, t, _sb, _tb in edges:
        sb, tb = box(s), box(t)
        top, bottom, between = band(s, t)
        if not between and bottom - top < 24:
            top, bottom = sb[1] + sb[3], tb[1]
        ex = sb[0] + frac(c, "exit") * sb[2]
        nx = tb[0] + frac(c, "entry") * tb[2]
        bands.setdefault((round(top), round(bottom)), []).append((nx, ex, c, sb[1] + sb[3], tb[1]))

    def crossings(order, lanes):
        segs = []
        for (nx, ex, _c, sy, ty), y in zip(order, lanes):
            segs.append(((ex, sy, y), (min(ex, nx), max(ex, nx), y), (nx, y, ty)))
        n = 0
        for i, a in enumerate(segs):
            for j, b in enumerate(segs):
                if i == j:
                    continue
                x0, x1, hy = a[1]
                for vx, y0, y1 in (b[0], b[2]):
                    if x0 < vx < x1 and min(y0, y1) < hy < max(y0, y1):
                        n += 1
        return n

    for (top, bottom), lst in bands.items():
        left = sorted([p for p in lst if p[0] < p[1]], key=lambda p: p[1])
        right = sorted([p for p in lst if p[0] >= p[1]], key=lambda p: -p[1])
        step = (bottom - top) / (len(lst) + 1)
        lanes = [round(top + step * (i + 1), 1) for i in range(len(lst))]
        order = min((left + right, right + left), key=lambda o: crossings(o, lanes))
        for (nx, ex, c, sy, ty), lane in zip(order, lanes):
            g = c.find("mxGeometry")
            for arr in [a for a in g if a.tag == "Array"]:
                g.remove(arr)
            arr = ET.SubElement(g, "Array", {"as": "points"})
            par = c.get("parent")
            ox, oy = (box(par)[0], box(par)[1]) if par in cells and par != "1" else (0.0, 0.0)
            ET.SubElement(arr, "mxPoint", {"x": str(round(ex - ox, 1)), "y": str(round(lane - oy, 1))})
            ET.SubElement(arr, "mxPoint", {"x": str(round(nx - ox, 1)), "y": str(round(lane - oy, 1))})
            if "labelBackgroundColor" in (c.get("style") or ""):
                # Put the label in the middle of its own horizontal lane, so labels do not collide.
                v1, h, v2 = abs(lane - sy), abs(nx - ex), abs(ty - lane)
                total = v1 + h + v2 or 1
                g.set("x", str(round(2 * (v1 + h / 2) / total - 1, 3)))


if not is_sequence:
    spread_ports()
    for obj in tree.iter("UserObject"):
        c = obj.find("mxCell")
        if c is not None:
            obj.set("mermaidBaseStyle", c.get("style"))


def keep_text_above_lines() -> None:
    """Draw group titles and edge labels on top of all lines, with an opaque background."""
    root = tree.find(".//root")
    byid = {o.get("id"): o for o in root}

    def absxy(cid):
        x = y = 0.0
        while cid in byid:
            el = byid[cid]
            c = el.find("mxCell") if el.tag == "UserObject" else el
            g = c.find("mxGeometry") if c is not None else None
            if g is None:
                break
            x += float(g.get("x", 0))
            y += float(g.get("y", 0))
            cid = c.get("parent")
        return x, y

    titles, labelled = [], []
    for el in list(root):
        c = el.find("mxCell") if el.tag == "UserObject" else None
        if c is None:
            continue
        st = c.get("style") or ""
        if c.get("vertex") == "1" and "verticalAlign=top" in st and el.get("label"):
            titles.append((el, c, st))
        elif c.get("edge") == "1" and el.get("label"):
            labelled.append(el)
    # 1. Edges with a label move to the end of the list, so other lines do not cross their label.
    for el in labelled:
        root.remove(el)
        root.append(el)
    # 2. Each group title becomes a separate text box on top of everything, in the top-left corner.
    for n, (el, c, st) in enumerate(titles):
        fill = re.search(r"fillColor=([^;]+);", st).group(1)
        x, y = absxy(el.get("id"))
        text = el.get("label")
        el.set("label", "")
        width = 7 * len(text) + 14
        t = ET.SubElement(root, "mxCell", {
            "id": f"title-{n}-{el.get('id')}", "parent": "1", "vertex": "1", "value": text,
            "style": "text;html=1;align=center;verticalAlign=middle;whiteSpace=nowrap;strokeColor=none;"
                     f"fillColor={fill};fontColor=#000000;" + FONT,
        })
        ET.SubElement(t, "mxGeometry", {"x": str(round(x + 8, 1)), "y": str(round(y + 4, 1)),
                                         "width": str(width), "height": "18", "as": "geometry"})


if not is_sequence:
    keep_text_above_lines()
tree.write(dst, encoding="utf-8", xml_declaration=False)
print(dst)
