# engineeringdynamicsdemos

Python port of the MATLAB demo/animation functions in this repository
(`Public/Ch2` ... `Public/Ch11`, `Public/Shared`, `Public/Tutorials`,
`Public/SlideFigures`) for Cornell MAE 2030 / Princeton MAE 206 (Engineering
Dynamics, based on Kasdin & Paley's *Engineering Dynamics*). The port is
being done incrementally, one chapter/subdirectory at a time; see the
package's subpackages for what has been ported so far.

None of the original MATLAB source is modified by this port - this package
is purely additive, reproducing the same demos/figures/animations in Python
for students and instructors who prefer not to use MATLAB.

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

- `shared/` - Python ports of `Public/Shared/*.m`. Note that
  `Shared/DCMs.m`'s direction-cosine-matrix functionality is not
  reimplemented here; use the `angutils` package's `rotMat` function
  instead (https://pypi.org/project/angutils/), which computes identical
  matrices under the same convention.
- `ch2/` ... `ch11/` - Python ports of `Public/Ch2` ... `Public/Ch11`
  (subpackages are added as each chapter is ported).
- `tutorials/`, `slide_figures/` - Python ports of `Public/Tutorials` and
  `Public/SlideFigures` (added in a later iteration).

## Demo notebooks

`Notebooks/` (at the top level of this directory, not part of the installed package)
contains one Jupyter notebook per ported chapter - e.g. `Notebooks/Ch2.ipynb` - that
imports and runs every plotting/animation function in that chapter's subpackage, so
the demos can be viewed without writing any code. Running them requires Jupyter and
this package installed (`pip install -e .`):

```
jupyter notebook Notebooks/Ch2.ipynb
```

Animations are displayed via matplotlib's `to_jshtml()` (an embedded, interactive JS
player). This plays correctly when the notebook is run live, but note that GitHub's
notebook renderer strips `<script>` tags for security, so an animation's controls will
not render in a saved notebook viewed statically on GitHub - only the static plots
will.

## Conventions

- Unit vectors are typeset with hats, e.g. `\mathbf{\hat{e}}_1` for a bold, hatted
  $\hat{\mathbf{e}}_1$ - used wherever a chapter's original MATLAB source labeled a
  frame's unit vectors (`e_1`, `e_2`, ...). Note the ordering: matplotlib's mathtext
  (no system LaTeX is used anywhere in this package) renders `\mathbf{\hat{e}}_1`
  correctly, but silently drops the hat entirely for `\hat{\mathbf{e}}_1` - the hat
  must wrap the bare letter first, then get bolded around that.
