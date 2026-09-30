# engineeringdynamicsdemos

Python port of the MATLAB demo/animation functions in this repository
(`Ch2` ... `Ch11`, `Shared`, `Tutorials`,
`SlideFigures`) for Cornell MAE 2030 / Princeton MAE 206 (Engineering
Dynamics, based on Kasdin & Paley's *Engineering Dynamics*). 

## Installation

From this directory:

```
pip install .
```

or, for development (editable install):

```
pip install -e .
```

## Testing

Unit tests use Python's built-in `unittest` and, where the original MATLAB
function produces an explicit, checkable numeric output (as opposed to only
a figure or animation), compare the Python port's output against real MATLAB
output via the MATLAB Engine API for Python. Running these tests requires a
licensed MATLAB installation and the `test` extra:

```
pip install -e '.[test]'
MATLAB_ROOT=/Applications/MATLAB_R2025b.app python -m unittest discover -t . -s tests
```

`MATLAB_ROOT` should point at your MATLAB installation. If it is unset, or
`matlabengine` is not installed, the MATLAB-comparison tests are skipped
(with an explanatory message) rather than failing.

## Package layout

- `shared/` - Python ports of `Shared/*.m`. Note that
  `Shared/DCMs.m`'s direction-cosine-matrix functionality is not
  reimplemented here; the `angutils` package's `rotMat` function is used
  instead (https://pypi.org/project/angutils/), which computes identical
  matrices under the same convention.
- `ch2/` ... `ch11/` - Python ports of `Ch2` ... `Ch11`
  (subpackages are added as each chapter is ported).
- `tutorials/`, `slide_figures/` - Python ports of `Tutorials` and
  `SlideFigures` (added in a later iteration).

## Demo notebooks

`Notebooks/` (at the top level of this directory, not part of the installed package)
contains one Jupyter notebook per ported chapter - e.g. `Notebooks/Ch2.ipynb` - that
imports every plotting/animation function in that chapter's subpackage, so
the demos can be viewed without writing any code. Running them requires Jupyter and
this package installed (`pip install -e .`):

```
jupyter notebook Notebooks/Ch2.ipynb
```

Most animations are displayed via matplotlib's `to_jshtml()` (an embedded, interactive JS
player). To keep the notebooks small, the animation cells are saved unexecuted - run them
locally to view the animations - while cells producing static plots are saved with their
outputs.

Some chapters (starting with Ch4) instead use an interactive widget - a `plotly` figure
restyled in place by `ipywidgets` controls (sliders, a Play/Pause control, checkboxes) -
rather than a pre-rendered animation player. These require a live Jupyter kernel
connection (they will not display or respond in a plain script) and the `notebook`
extra:

```
pip install -e '.[notebook]'
```

Their figure cells are always saved unexecuted, since the widget only renders inside a
live kernel and can't be pre-rendered into a static, saved output.

## Conventions

- Unit vectors are typeset with hats, e.g. `\mathbf{\hat{e}}_1` for a bold, hatted
  $\hat{\mathbf{e}}_1$ - used wherever a chapter's original MATLAB source labeled a
  frame's unit vectors (`e_1`, `e_2`, ...). Note the ordering: matplotlib's mathtext
  (no system LaTeX is used anywhere in this package) renders `\mathbf{\hat{e}}_1`
  correctly, but silently drops the hat entirely for `\hat{\mathbf{e}}_1` - the hat
  must wrap the bare letter first, then get bolded around that.

## Generative AI Acknowledgement

The original MATLAB code is 100% human-written.  The ported Python code has made extensive use of Claude Code, an AI coding assistant by Anthropic (https://claude.ai/) utilzing multiple different models including Opus 5, 5.5 and Sonnet 4.5, 5.  The final code and all outputs were reviewed and tested by the original author. 
