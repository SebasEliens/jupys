# jupys

Notebook experiments, each a standalone `uv` project, published as a live
in-browser [JupyterLite](https://jupyterlite.readthedocs.io/) site via GitHub Pages.

## Projects

- [`content/piketty-complex-systems/`](content/piketty-complex-systems/) — reproducing Piketty's wealth-concentration claims with complex-systems models
- [`content/colonial-extraction-gis/`](content/colonial-extraction-gis/) — GIS analysis of colonial resource extraction

Each project has its own `pyproject.toml` / `.venv` for local development with `uv`:

```bash
cd content/piketty-complex-systems
uv sync
uv run jupyter lab
```

## Browser version (JupyterLite)

Notebooks and their local data files are bundled into a static site that runs
entirely in the browser via Pyodide/WASM — no server, no install. It auto-deploys
to GitHub Pages on every push to `main` (see
[.github/workflows/deploy-pages.yml](.github/workflows/deploy-pages.yml)).

To build and preview locally:

```bash
uv sync
./scripts/build-lite.sh
uv run jupyter lite serve --output-dir dist
```

`scripts/build-lite.sh` builds directly from [`content/`](content/) into
`dist/`, then overlays the custom [index.html](index.html) landing page.
[`jupyter_lite_config.json`](jupyter_lite_config.json) excludes `.venv`,
lockfiles, and other dev-only files from the built site (via
`extra_ignore_contents` regexes) — those don't apply inside the WASM runtime.

The root [jupyter-lite.json](jupyter-lite.json) sets
`kernelBootstrapMode: eager`, so the Pyodide kernel starts loading as soon as
`/lab/` renders rather than waiting for a cell to run. Clicking a notebook
link on the landing page shows a loading overlay while `/lab/` navigates in —
the first open still has to download the Python runtime itself, which can
take the better part of a minute; later visits are cached and much faster.

(An earlier version of this page also pre-warmed Pyodide via a hidden
background `/lab/` iframe on page load. That created a second live JupyterLite
instance sharing the same IndexedDB-backed state as the one you'd navigate to,
and tearing it down right before navigating could leave the real page hung on
a lock that never released — showing up as a blank page. Removed.)

### One-time GitHub setup

After pushing this repo to GitHub: **Settings → Pages → Source → GitHub Actions**.
The workflow handles the rest.

### Pyodide compatibility

`colonial-extraction-gis` fetches data over the network (a GeoJSON file and a
CSV) and uses `geopandas`. Plain `urllib` sockets don't work inside Pyodide
(no TLS support in the WASM sandbox), so the fetch helper branches on
`sys.platform == "emscripten"` and uses `pyodide.http.pyfetch` there, falling
back to `urllib.request` for a normal local kernel. `geopandas` itself loads
and runs fine under Pyodide. Verified end-to-end (network fetch, GeoJSON
parsing, all cells) against a real `jupyterlite-pyodide-kernel`-equivalent
Pyodide run, not just locally.
