# GEM Documentation Standards

**Version:** 2.0 — 2026-03-16
**Applies to:** All HTML documentation under `doc/`

---

## Quick Start

```bash
# Apply (or re-apply) the current theme across all docs
./bin/build_documentation.sh

# Switch themes and rebuild in one step
./bin/build_documentation.sh --theme=midnight   # Midnight Blue (default)
./bin/build_documentation.sh --theme=purple     # Royal Purple
./bin/build_documentation.sh --theme=green      # Evergreen

# CSS-only switch (no HTML processing — just swap the active theme file)
./bin/build_documentation.sh --theme=green --css-only

# Preview what would be processed without writing anything
./bin/build_documentation.sh --dry-run
```

---

## Three-Panel Layout

Every documentation section uses the classic HTML frameset structure, which the build script preserves:

```
┌──────────────────────────────────────────────────────┐
│  TOP BAR (top.htm)  — 56px                          │
│  [GEM] [Build 758] Title  |  Nav links  |  Copyright │
├────────────────┬─────────────────────────────────────┤
│ SIDEBAR        │  CONTENT                            │
│ (toc.htm)      │  (readme.htm)                       │
│ 24% width      │  76% width                          │
│                │                                     │
│ Section labels │  Section-divider banners (dark bg)  │
│ Nav links      │  Body text, tables, code, lists     │
│                │                                     │
│                │  [copyright footer]                 │
└────────────────┴─────────────────────────────────────┘
```

The frameset is in `index.htm` and is not modified (except updating the row height from 43→56px to fit the taller header).

---

## What the Build Script Does

| File | Action |
|---|---|
| `*/top.htm` | **Rebuilt** — modern HTML5 header with GEM badge, version, title, navigation links, copyright. Title and copyright text extracted from original and preserved verbatim. |
| `*/toc.htm` | **Rebuilt** — dark sidebar with muted uppercase section labels and clean link list. All `<B>` headings and `<A HREF>` links from original preserved in order. |
| `*/index.htm` | **Updated** — frameset `ROWS="43,*"` → `ROWS="56,*"` only. |
| All other `.htm/.html` | **Injected** — `<link>` to `gem.css` added to `<head>`, plus copyright footer added before `</body>` if not already present. |

Skipped directories (not part of navigable docs):
- `SalesPresentation_files/`
- `GemDatabase_files/`
- `working docs - gem/`

---

## Theme Files

Three themes are available in `doc/styles/`. The active theme is always `gem.css` — the build script copies the chosen theme file there.

| Command flag | File | Description |
|---|---|---|
| `--theme=midnight` | `gem-midnight.css` | Deep navy blue — corporate, clean |
| `--theme=purple` | `gem-purple.css` | Royal purple — distinctive, rich |
| `--theme=green` | `gem-green.css` | Forest evergreen — natural, bold |

The structural CSS rules (layout, fonts, spacing, legacy-table fixes) are **identical** across all three files. Only the `:root` color variables differ. To make a structural change, edit one file and copy it to the others, or edit all three.

---

## Color Palette

Each theme defines these CSS custom properties in `:root`. Values shown are for Midnight Blue.

### Sidebar

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-side-bg` | `#0B1929` | Sidebar background |
| `--c-side-title-bg` | `#071420` | Title strip background |
| `--c-side-border` | `#1E3A5F` | Right border, scrollbar |
| `--c-side-section` | `#5A8AAA` | Muted uppercase section labels |
| `--c-side-link` | `#B8D4E8` | Link text (light on dark) |
| `--c-side-hover-bg` | `rgba(66,165,245,0.14)` | Link hover background |
| `--c-side-hover` | `#FFFFFF` | Link hover text |
| `--c-side-title` | `#D4EAF8` | Title text |

### Header (Top Bar)

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-hdr-from` | `#0D3B8E` | Header gradient start |
| `--c-hdr-to` | `#1565C0` | Header gradient end |
| `--c-hdr-title` | `#FFFFFF` | Title text — **always white** |
| `--c-hdr-badge-bg` | `#42A5F5` | GEM logo badge background |
| `--c-hdr-badge-txt` | `#061020` | GEM logo badge text |
| `--c-hdr-nav` | `#BBDEFB` | Nav link text |
| `--c-hdr-nav-hover` | `rgba(66,165,245,0.22)` | Nav link hover background |
| `--c-hdr-copy` | `#7AAAD0` | Copyright text |

### Content Area

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-bg` | `#F7FAFF` | Page background |
| `--c-text` | `#1A2840` | Body text |
| `--c-h1` | `#0D3B8E` | h1 color |
| `--c-h2` | `#1565C0` | h2 color |
| `--c-h3` | `#1976D2` | h3 color |
| `--c-h4` | `#1E88E5` | h4–h6 color |
| `--c-accent` | `#1E88E5` | h1 underline, h2 left border |
| `--c-link` | `#1565C0` | Anchor color |
| `--c-link-hover` | `#0D3B8E` | Anchor hover color |

### Tables

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-th-bg` | `#0D3B8E` | Table header background |
| `--c-th-text` | `#E8F4FF` | Table header text |
| `--c-td-border` | `#C0D5F0` | Cell borders |
| `--c-tr-alt` | `#EEF4FF` | Alternating row background |
| `--c-tr-hover` | `#DAE8FF` | Row hover background |

### Code

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-code-bg` | `#E2EEFF` | Inline `<code>` background |
| `--c-code-text` | `#0D3B8E` | Inline `<code>` text |
| `--c-pre-bg` | `#071420` | `<pre>` block background |
| `--c-pre-text` | `#B4D0E8` | `<pre>` block text |
| `--c-pre-accent` | `#42A5F5` | `<pre>` left border color |

### Special

| Variable | Midnight Blue | Purpose |
|---|---|---|
| `--c-legacy-text` | `#E8F4FF` | Text inside old `bgcolor=#0066cc` tables |
| `--c-foot-border` | `#C0D5F0` | Footer top border |
| `--c-foot-text` | `#7A9AB8` | Footer text |

---

## Typography

Base font stack (no web font dependencies — renders on any Windows/Mac/Linux system):

```
'Segoe UI', 'Trebuchet MS', Arial, Helvetica, sans-serif   — all text
'Cascadia Code', 'Consolas', 'Courier New', monospace      — code/pre
```

Consistent sizes throughout (no more mixed big/small):

| Element | Size | Weight | Style |
|---|---|---|---|
| Body text | 14px | 400 | Normal |
| `h1` | 21px | 700 | + accent underline |
| `h2` | 16px | 600 | + accent left border |
| `h3` | 14px | 600 | Normal (no italic) |
| `h4`–`h6` | 13–12px | 600 | Normal |
| Sidebar links | 12.5px | 400 | — |
| Sidebar section labels | 9.5px | 600 | Uppercase, letter-spaced |
| Header title | 14px | 500 | White |
| Code inline | 12.5px | 400 | Monospace |
| Code block | 12.5px | 400 | Monospace |
| Footer | 11.5px | 400 | Muted |

---

## Top Bar Navigation Links

Every rebuilt `top.htm` includes these section links:

| Label | Target |
|---|---|
| Overview | `../gem/index.htm` |
| Batch Jobs | `../batchjobs/index.htm` |
| Install | `../installation_guide/index.htm` |
| Stored Procs | `../procs/index.htm` |
| Console | `../console/index.htm` |
| Lib | `../lib/index.htm` |
| FAQ | `../faq/index.htm` |

All links use `target="_top"` so clicking replaces the full frameset.

To add or remove a link, edit the `$nav` heredoc inside `process_top()` in `bin/update_doc_theme.pl`, then re-run the build.

---

## Copyright

- Copyright in **top.htm** is extracted from the original file and preserved verbatim. It is never modified.
- Content pages (readme.htm etc.) receive an injected footer:
  ```html
  <div class="gem-page-footer">Copyright © 1994–2012 SQL Technologies. All rights reserved.</div>
  ```
  The copyright text is extracted from the page itself if present; otherwise the standard line above is used.
- To change the default, edit `extract_copyright()` in `bin/update_doc_theme.pl`.

---

## Legacy HTML Compatibility

The old content files use patterns like:

```html
<TABLE BGCOLOR=#0066cc>
  <TR><TD><CENTER>
    <font color=#33ccff><H1>Section Title</H1></font>
  </CENTER></TD></TR>
</TABLE>
```

The CSS handles this with attribute selectors:

```css
/* Restyle the table as a section-divider banner */
table[bgcolor="#0066cc"] { background: gradient... }
table[bgcolor="#0066cc"] td { background: transparent; color: light; }

/* Fix: h1 inside must be light-colored (not dark-on-dark) */
table[bgcolor="#0066cc"] h1,
table[bgcolor="#0066cc"] h2 { color: var(--c-legacy-text) !important; border: none !important; }
```

**Do not change these rules** — they are the fix for invisible headings on dark backgrounds.

---

## Adding a New Documentation Section

1. Create `doc/<section>/` with four files following the standard pattern.

   **`index.htm`** (frameset — use 56px row height):
   ```html
   <HTML><HEAD><TITLE>Section Title</TITLE></HEAD>
   <FRAMESET ROWS="56,*" BORDER=NO SCROLLING=NO>
     <FRAME SRC=top.htm NAME=top NORESIZE SCROLLING=NO>
     <FRAMESET COLS="24%,*">
       <FRAME SRC=toc.htm NAME=contents>
       <FRAME SRC=readme.htm NAME=basefrm>
     </FRAMESET>
   </FRAMESET>
   </HTML>
   ```

   **`top.htm`** (stub — build script rebuilds it):
   ```html
   <BODY bgcolor=#0066cc>
   <TABLE WIDTH=100%><TR>
     <TD><font color=#33ccff>Your Section Title</font></TD>
     <TD ALIGN=RIGHT><font color=#33ccff>Copyright &#169; 1994-2012 by SQL Technologies</font></TD>
   </TR></TABLE>
   </body>
   ```

   **`toc.htm`** (navigation — build script reskins it, preserves content):
   ```html
   <HTML><HEAD><TITLE>Your Section Title</TITLE></HEAD>
   <BODY TEXT=BLACK BGCOLOR=WHITE><FONT SIZE=2>
   <B>Your Section Title</B><BR>
   <BR><B>FIRST GROUP</B><BR>
   <A HREF=readme.htm#link1 TARGET=basefrm>Topic One</A><BR>
   </FONT></BODY>
   ```

   **`readme.htm`** — your content in any HTML; build script injects CSS + footer.

2. Add the section's navigation link to `process_top()` in `bin/update_doc_theme.pl`.
3. Run `./bin/build_documentation.sh`.

---

## Updating Look and Feel

| What to change | Where | Command after |
|---|---|---|
| Colors (any theme) | Edit `:root` in `doc/styles/gem-midnight.css` (or purple/green) | `./bin/build_documentation.sh --theme=midnight` |
| Fonts, spacing, layout | Edit structural rules in `doc/styles/gem-midnight.css` (copy changes to purple/green) | `./bin/build_documentation.sh` |
| Top-bar navigation links | Edit `$nav` in `bin/update_doc_theme.pl` → `process_top()` | `./bin/build_documentation.sh` |
| Sidebar groupings | Edit source `toc.htm` files directly | `./bin/build_documentation.sh` |
| Copyright text | Edit source `top.htm` files OR `extract_copyright()` in Perl script | `./bin/build_documentation.sh` |
| Version badge | Edit `$version` in `process_top()` in Perl script | `./bin/build_documentation.sh` |
