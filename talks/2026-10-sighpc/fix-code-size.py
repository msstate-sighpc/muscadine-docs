#!/usr/bin/env python3
"""Normalise code typography in a pandoc-generated pptx.

Pandoc's pptx writer hard-codes Courier for every code span, with no
font size: fenced blocks inherit the oversized body default (and wrap
mid-line), while inline code sits at full body size next to Century
Gothic text, where Courier looks jumbo and dated. This pass:

  1. renames Courier -> Consolas (ships with Office; compact monospace
     that sits well beside Century Gothic),
  2. sizes whole-code paragraphs (fenced blocks, code-only table cells)
     to a fixed size, splitting the single run pandoc emits under
     --syntax-highlighting=none into one run per line with breaks,
  3. sizes inline code runs inside prose to ~85% of the paragraph's
     body level (Century Gothic and Consolas share an x-height ratio,
     but monospace at body size still reads visually larger).

Usage: ./fix-code-size.py deck.pptx [block_size_points]
"""
import re
import shutil
import sys
import zipfile

MONO = "Consolas"
COURIER = f'<a:latin typeface="{MONO}"'
MONO_TAG = f'typeface="{MONO}"'
# master bodyStyle defRPr sizes, per list level (see slideMaster1.xml)
BODY = {0: 2800, 1: 2400, 2: 2000, 3: 1800}
PARA = re.compile(r"<a:p(?:\s[^>]*)?>.*?</a:p>", re.DOTALL)
RUN = re.compile(r"<a:rPr([^>]*)>")
RPR_FULL = re.compile(
    # (?<!/) so self-closing <a:rPr /> tags don't swallow runs up to the
    # next non-empty </a:rPr>
    r"<a:rPr([^>]*)(?<!/)>((?:(?!</a:rPr>).)*?)</a:rPr>",
    re.DOTALL,
)
# With --no-highlight pandoc emits a whole code block as ONE run containing
# literal newlines; PowerPoint/LO render those inconsistently. Split them
# back into one run per line joined by explicit breaks.
RUN_FULL = re.compile(
    r'<a:r><a:rPr([^>]*)>((?:<a:solidFill>.*?</a:solidFill>)?'
    rf'<a:latin typeface="{MONO}" */>)</a:rPr><a:t>([^<]*)</a:t></a:r>',
    re.DOTALL,
)


def split_lines(attrs: str, rpr_inner: str, text: str) -> str:
    if "\n" not in text:
        return f"<a:r><a:rPr{attrs}>{rpr_inner}</a:rPr><a:t>{text}</a:t></a:r>"
    lines = [
        f"<a:r><a:rPr{attrs}>{rpr_inner}</a:rPr><a:t>{line}</a:t></a:r>"
        for line in text.split("\n")
    ]
    return "<a:br />".join(lines)


def size_inline(xml: str) -> str:
    """Size Consolas runs in a mixed code+prose paragraph to 85% of the
    level's body size (table-cell paragraphs already carry sz=, so the
    guard below leaves them alone)."""
    lvl = re.search(r'<a:pPr[^>]*\blvl="(\d+)"', xml)
    base = BODY.get(int(lvl.group(1)), 1800) if lvl else BODY[0]
    target = str(int(round(base * 0.85 / 50) * 50))

    def fix(m: re.Match) -> str:
        attrs, inner = m.groups()
        if MONO_TAG not in inner or "sz=" in attrs:
            return m.group(0)
        return f'<a:rPr{attrs} sz="{target}">{inner}</a:rPr>'

    return RPR_FULL.sub(fix, xml)


def shrink_paragraph(xml: str, sz: str) -> tuple[str, str]:
    """Return (new_xml, kind) where kind is 'block', 'inline' or ''."""
    if COURIER not in xml:
        return xml, ""
    runs = xml.count("<a:rPr")
    if xml.count(COURIER) < runs:  # mixed code + prose: inline sizing
        return size_inline(xml), "inline"
    xml = RUN_FULL.sub(
        lambda m: split_lines(m.group(1), m.group(2), m.group(3)), xml
    )
    xml = RUN.sub(
        lambda m: "<a:rPr{}{}>".format(
            m.group(1), "" if "sz=" in m.group(1) else f' sz="{sz}"'
        ),
        xml,
    )
    return xml, "block"


def main(path: str, size: float) -> None:
    sz = str(int(size * 100))
    tmp = path + ".tmp"
    with zipfile.ZipFile(path) as zin, zipfile.ZipFile(
        tmp, "w", zipfile.ZIP_DEFLATED
    ) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if re.fullmatch(r"ppt/slides/slide\d+\.xml", item.filename):
                xml = data.decode("utf-8")
                # pandoc hard-codes Courier; normalise the family first
                xml = xml.replace('typeface="Courier"', f'typeface="{MONO}"')
                blocks = inline = 0

                def repl(m: re.Match) -> str:
                    nonlocal blocks, inline
                    out, kind = shrink_paragraph(m.group(0), sz)
                    blocks += kind == "block"
                    inline += kind == "inline"
                    return out

                xml = PARA.sub(repl, xml)
                if blocks or inline:
                    print(
                        f"{item.filename}: {blocks} code block(s) at "
                        f"{size}pt, {inline} inline-code paragraph(s) sized"
                    )
                data = xml.encode("utf-8")
            zout.writestr(item, data)
    shutil.move(tmp, path)


if __name__ == "__main__":
    main(sys.argv[1], float(sys.argv[2]) if len(sys.argv) > 2 else 14)
