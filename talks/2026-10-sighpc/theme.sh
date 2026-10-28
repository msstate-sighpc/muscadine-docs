#!/usr/bin/env bash
# Build reference.pptx for pandoc from the club's PowerPoint template
# (template.pptx = 0_template_16x9.pptx).
#
# The template keeps its branding (paper texture, maroon footer band,
# MSU + SIGHPC logos, Century Gothic / maroon #5D1625 type) on hand-built
# sample slides. Pandoc's pptx writer only reads the reference document's
# master, layouts, and theme, and discards sample slides -- so this script
# relocates the branding onto the master and layouts, where every slide
# pandoc generates will inherit it.
set -euo pipefail
cd "$(dirname "$0")"

[[ -f template.pptx ]] || { echo "template.pptx missing" >&2; exit 1; }

out="$PWD/reference.pptx"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

unzip -q -d "$tmp/x" template.pptx

python3 - "$tmp/x" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])

MAROON = "5D1625"
EMU = 914400
SLIDE_CX, SLIDE_CY = 12192000, 6858000


def rel_media(rels_path: pathlib.Path, start_id: int, targets):
    """Append image relationships to a .rels file, returning their rIds."""
    s = rels_path.read_text(encoding="utf-8")
    ids = []
    add = ""
    for i, target in enumerate(targets):
        rid = f"rId{start_id + i}"
        ids.append(rid)
        add += (
            f'<Relationship Id="{rid}" '
            'Type="http://schemas.openxmlformats.org/officeDocument/'
            '2006/relationships/image" '
            f'Target="../media/{target}"/>'
        )
    if "</Relationships>" not in s:
        sys.exit(f"bad rels file: {rels_path}")
    rels_path.write_text(s.replace("</Relationships>", add + "</Relationships>"),
                         encoding="utf-8")
    return ids


def patch(rel, pairs):
    path = root / rel
    s = path.read_text(encoding="utf-8")
    for old, new in pairs:
        if old not in s:
            sys.exit(f"anchor missing in {rel}: {old[:70]}")
        s = s.replace(old, new)
    path.write_text(s, encoding="utf-8")


# ---------------------------------------------------------------- theme ----
# Century Gothic everywhere (the template's typeface); maroon accent so
# pandoc's built-in table style renders maroon headers.
t = (root / "ppt/theme/theme1.xml").read_text(encoding="utf-8")
t = t.replace('<a:accent1><a:srgbClr val="4472C4"/>', f'<a:accent1><a:srgbClr val="{MAROON}"/>')
major = re.search(r"<a:majorFont>.*?</a:majorFont>", t, re.DOTALL)
minor = re.search(r"<a:minorFont>.*?</a:minorFont>", t, re.DOTALL)
for block in (major, minor):
    t = t.replace(
        block.group(0),
        re.sub(r'(<a:latin typeface=")[^"]*(")', r"\g<1>Century Gothic\g<2>",
               block.group(0)),
    )
(root / "ppt/theme/theme1.xml").write_text(t, encoding="utf-8")

# ------------------------------------------------------------- master ------
# 1) crumpled-paper background on every slide
mrel = root / "ppt/slideMasters/_rels/slideMaster1.xml.rels"
bg_id, script_id, msu_id, sig_id = rel_media(mrel, 100, [
    "image1.jpeg", "image2.png", "image3.emf", "image5.png"])
patch("ppt/slideMasters/slideMaster1.xml", [
    ('<p:bg><p:bgRef idx="1001"><a:schemeClr val="bg1"/></p:bgRef></p:bg>',
     f'<p:bg><p:bgPr><a:blipFill><a:blip r:embed="{bg_id}"/>'
     '<a:stretch><a:fillRect/></a:stretch></a:blipFill>'
     '<a:effectLst/></p:bgPr></p:bg>'),
])

# 2) titles: Century Gothic bold maroon, sized for content headers
patch("ppt/slideMasters/slideMaster1.xml", [
    ('<a:defRPr sz="4400" kern="1200"><a:solidFill>'
     '<a:schemeClr val="tx1"/></a:solidFill>',
     f'<a:defRPr sz="3200" b="1" kern="1200"><a:solidFill>'
     f'<a:srgbClr val="{MAROON}"/></a:solidFill>'),
    # 3) date/footer/slide-number text -> white: it sits on the maroon band
    ('<a:solidFill><a:schemeClr val="tx1"><a:tint val="75000"/></a:schemeClr></a:solidFill>',
     '<a:solidFill><a:srgbClr val="FFFFFF"><a:alpha val="85000"/></a:srgbClr></a:solidFill>'),
])


def pic(shape_id, name, rid, x, y, cx, cy):
    return (
        f'<p:pic><p:nvPicPr><p:cNvPr id="{shape_id}" name="{name}"/>'
        '<p:cNvPicPr><a:picLocks noChangeAspect="1"/></p:cNvPicPr><p:nvPr/></p:nvPicPr>'
        f'<p:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></p:blipFill>'
        f'<p:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></p:spPr></p:pic>'
    )


# 4) the maroon footer band + script + MSU/SIGHPC logos, as master shapes
#    (geometry copied 1:1 from the template's sample slides)
band = (
    '<p:sp><p:nvSpPr><p:cNvPr id="900" name="SIG-HPC Footer Band"/>'
    '<p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr>'
    '<a:xfrm><a:off x="-1" y="5918199"/><a:ext cx="12191999" cy="939800"/></a:xfrm>'
    '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>'
    f'<a:solidFill><a:srgbClr val="{MAROON}"/></a:solidFill>'
    '<a:ln><a:noFill/></a:ln><a:effectLst/></p:spPr>'
    '<p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr lang="en-US"/></a:p></p:txBody></p:sp>'
)
footer = band
footer += pic(901, "SIG-HPC Footer Script", script_id, 3983110, 5808067,
              5562614, 1150298)
footer += pic(902, "MSU Logo", msu_id, 407389, 6220126, 1998652, 425244)
footer += pic(903, "SIGHPC Logo Small", sig_id, 11122796, 6107472,
              661816, 561256)
sp = root / "ppt/slideMasters/slideMaster1.xml"
s = sp.read_text(encoding="utf-8")
if "</p:spTree>" not in s:
    sys.exit("master spTree not found")
sp.write_text(s.replace("</p:spTree>", footer + "</p:spTree>"),
              encoding="utf-8")

# ------------------------------------------------- layout1: Title Slide ----
# Centered composition like the template's "Centered Title Slide":
# big SIGHPC emblem on top, title and subtitle beneath it.
l1 = root / "ppt/slideLayouts/slideLayout1.xml"
l1rel = root / "ppt/slideLayouts/_rels/slideLayout1.xml.rels"
(logo_id,) = rel_media(l1rel, 100, ["image4.png"])
s = l1.read_text(encoding="utf-8")

logo_cy, logo_cx = int(2.75 * EMU), int(2.75 * 3541 / 3000 * EMU)
logo_x = (SLIDE_CX - logo_cx) // 2
logo = pic(910, "SIGHPC Logo", logo_id, logo_x, int(0.35 * EMU),
           logo_cx, logo_cy)
s = s.replace("</p:spTree>", logo + "</p:spTree>")

for old, new in [
    ('<a:off x="1524000" y="1122363"/><a:ext cx="9144000" cy="2387600"/>',   # ctrTitle
     f'<a:off x="1524000" y="{int(3.30 * EMU)}"/><a:ext cx="9144000" cy="{int(1.35 * EMU)}"/>'),
    ('<a:off x="1524000" y="3602038"/><a:ext cx="9144000" cy="1655762"/>',   # subTitle
     f'<a:off x="1524000" y="{int(4.75 * EMU)}"/><a:ext cx="9144000" cy="{int(0.9 * EMU)}"/>'),
    ('<a:lvl1pPr algn="ctr"><a:defRPr sz="6000"/>',
     '<a:lvl1pPr algn="ctr"><a:defRPr sz="4400"/>'),
]:
    if old not in s:
        sys.exit(f"layout1 anchor missing: {old[:60]}")
    s = s.replace(old, new)
l1.write_text(s, encoding="utf-8")

# -------------------------------------------- layout3: Section Header ------
# Centered maroon section titles, like the "Centered Section Slide".
l3 = root / "ppt/slideLayouts/slideLayout3.xml"
s = l3.read_text(encoding="utf-8")
m = re.search(r"<p:sp>(?:(?!</p:sp>).)*?type=\"title\".*?</p:sp>", s, re.DOTALL)
if not m:
    sys.exit("layout3 title not found")
title_sp = m.group(0)
new_title = title_sp
for old, new in [
    # geometry: centered band at vertical middle of the slide
    ('<a:off x="831850" y="1709738"/><a:ext cx="10515600" cy="2852737"/>',
     f'<a:off x="831850" y="{int(2.35 * EMU)}"/><a:ext cx="10515600" cy="{int(1.4 * EMU)}"/>'),
    ('<a:bodyPr anchor="b"/>', '<a:bodyPr anchor="ctr"/>'),
    # centered 40pt title (color/weight from master: maroon bold Century Gothic)
    ('<a:lvl1pPr><a:defRPr sz="6000"/>', '<a:lvl1pPr algn="ctr"><a:defRPr sz="4000"/>'),
]:
    if old not in new_title:
        sys.exit(f"layout3 title anchor missing: {old[:60]}")
    new_title = new_title.replace(old, new, 1)
s = s.replace(title_sp, new_title)
l3.write_text(s, encoding="utf-8")
print("template branding moved onto master + layouts")
PY

( cd "$tmp/x" && zip -qrX "$out" '[Content_Types].xml' _rels docProps ppt )
echo "wrote reference.pptx"
