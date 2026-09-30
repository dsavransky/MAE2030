"""Kepler elliptical orbit computation and interactive animation. See Tutorial 4.2."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Tuple

import numpy as np
import numpy.typing as npt

if TYPE_CHECKING:
    import ipywidgets as widgets
    import plotly.graph_objects as go

# ``ipywidgets``/``plotly`` (the ``notebook`` extra) are only required by
# ``kepler_orbit_widget`` - importing this module, or calling
# ``kepler_orbit_trajectory``, must not require them.


def kepler_orbit_trajectory(
    e: float = 0.5,
    a: float = 1.0,
    n_steps: int = 250,
    max_iter: int = 1000,
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Solve Kepler's equation over one orbit period at fixed mean-anomaly steps.

    Args:
        e (float):
            Orbital eccentricity, in [0, 1). Defaults to 0.5.
        a (float):
            Semi-major axis. Defaults to 1.0.
        n_steps (int):
            Number of equally spaced mean-anomaly samples over one period.
            Defaults to 250.
        max_iter (int):
            Maximum Newton iterations for the Kepler-equation solve.
            Defaults to 1000.

    Returns:
        tuple:
            r (npt.NDArray[np.float64]):
                Array of shape ``(2, n_steps)``, position ``[x, y]`` at each
                mean-anomaly step. The ellipse is centered at the origin, not
                at the focus.
            v (npt.NDArray[np.float64]):
                Array of shape ``(2, n_steps)``, velocity ``[vx, vy]`` at each
                step, in arbitrary units such that the mean motion is 1.
            E (npt.NDArray[np.float64]):
                Array of shape ``(n_steps,)``, eccentric anomaly (rad) at
                each step.
    """
    M = np.linspace(0, 2 * np.pi - 2 * np.pi / n_steps, n_steps)
    b = a * np.sqrt(1 - e**2)

    if e > 0:
        E = M / (1 - e)
        inds = E > np.sqrt(6 * (1 - e) / e)
        E[inds] = (6 * M[inds] / e) ** (1 / 3)

        counter = 0
        del_ = 1.0
        eps_2pi = np.nextafter(2 * np.pi, np.inf) - 2 * np.pi
        while del_ > eps_2pi and counter < max_iter:
            E = E - (M - E + e * np.sin(E)) / (e * np.cos(E) - 1)
            del_ = np.max(np.abs(M - (E - e * np.sin(E))))
            counter += 1
    else:
        E = M.copy()

    r = np.array([a * np.cos(E), b * np.sin(E)])
    rad = a * (1 - e * np.cos(E))
    v = np.array([-(a**2) / rad * np.sin(E), b * a / rad * np.cos(E)])

    return r, v, E


def _arrow_xy(
    r: npt.NDArray[np.float64], v: npt.NDArray[np.float64], i: int
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Build the shaft+barbs velocity-arrow line data at step ``i``.

    A single line trace with ``None`` gaps draws the shaft and the two
    arrowhead barbs as one Plotly trace.

    Args:
        r (npt.NDArray[np.float64]):
            Position array of shape ``(2, n_steps)``.
        v (npt.NDArray[np.float64]):
            Velocity array of shape ``(2, n_steps)``.
        i (int):
            Step index to draw the arrow at.

    Returns:
        tuple:
            x (npt.NDArray[np.float64]):
                x-coordinates of the shaft and barb segments, with ``None``
                gaps between segments.
            y (npt.NDArray[np.float64]):
                y-coordinates of the shaft and barb segments, with ``None``
                gaps between segments.
    """
    tip = r[:, i] + 0.4 * v[:, i]
    th = np.arctan2(v[1, i], v[0, i]) + np.pi / 4
    ar = np.linalg.norm(v[:, i]) * 0.1
    barb1 = tip - np.array([np.cos(th), np.sin(th)]) * ar
    barb2 = tip - np.array([np.sin(th), -np.cos(th)]) * ar
    x = [r[0, i], tip[0], None, tip[0], barb1[0], None, tip[0], barb2[0]]
    y = [r[1, i], tip[1], None, tip[1], barb1[1], None, tip[1], barb2[1]]
    return x, y


def _require_jupyter_kernel() -> None:
    """Raise if not running inside a live Jupyter kernel.

    ``go.FigureWidget``/``ipywidgets`` only render through an actual Jupyter
    comm channel - unlike a plain ``plotly.graph_objects.Figure`` (used by
    an earlier version of this widget), there is no static-HTML/browser-tab
    fallback available, since nothing about a bare browser tab could drive
    ``ipywidgets.Play`` or a live eccentricity recompute without a kernel on
    the other end. Without this check, calling :func:`kepler_orbit_widget`
    outside Jupyter would silently do nothing rather than erroring.

    Raises:
        RuntimeError:
            If no live Jupyter kernel is detected.
    """
    try:
        from IPython import get_ipython
    except ImportError:
        get_ipython = None

    ip = get_ipython() if get_ipython is not None else None
    if ip is None or type(ip).__name__ != "ZMQInteractiveShell":
        raise RuntimeError(
            "kepler_orbit_widget() requires a live Jupyter kernel (e.g. a Jupyter "
            "notebook or JupyterLab) - its controls are ipywidgets/Plotly "
            "FigureWidget objects that only render and respond through a kernel "
            "comm channel, which a plain Python session or IPython terminal does "
            "not provide. kepler_orbit_trajectory() has no such requirement."
        )


def _build_figure_widget(
    r: npt.NDArray[np.float64], v: npt.NDArray[np.float64], e: float, a: float
) -> go.FigureWidget:
    """Build the live orbit figure for a given initial trajectory.

    Unlike a Play/Pause loop driven by Plotly's own ``frames``/``animate``
    (which only the static ``Figure`` class supports, not ``FigureWidget``),
    time-stepping here is driven entirely from Python (see
    :func:`kepler_orbit_widget`), so this figure is built once and only ever
    restyled in place - never rebuilt - which is what lets an eccentricity
    change take effect without interrupting an in-progress animation.

    Args:
        r (npt.NDArray[np.float64]):
            Initial position array of shape ``(2, n_steps)``, from
            :func:`kepler_orbit_trajectory`.
        v (npt.NDArray[np.float64]):
            Initial velocity array of shape ``(2, n_steps)``, from
            :func:`kepler_orbit_trajectory`.
        e (float):
            Initial orbital eccentricity, in [0, 1).
        a (float):
            Semi-major axis.

    Returns:
        plotly.graph_objects.FigureWidget:
            The live orbit figure, with traces
            ``[orbit_line, star, planet, arrow]`` in that order.
    """
    import plotly.graph_objects as go

    axlim = a * 1.15
    arrow_x, arrow_y = _arrow_xy(r, v, 0)

    fig_widget = go.FigureWidget(
        data=[
            go.Scatter(
                x=r[0], y=r[1], mode="lines", line=dict(color="black", dash="dash")
            ),
            go.Scatter(
                x=[a * e], y=[0.0], mode="markers", marker=dict(color="gold", size=14)
            ),
            go.Scatter(
                x=[r[0, 0]],
                y=[r[1, 0]],
                mode="markers",
                marker=dict(color="blue", size=14),
            ),
            go.Scatter(
                x=arrow_x,
                y=arrow_y,
                mode="lines",
                line=dict(color="red", width=2),
                visible=True,
            ),
        ]
    )
    fig_widget.update_layout(
        showlegend=False,
        width=500,
        height=500,
        margin=dict(t=20, b=20),
        xaxis=dict(range=[-axlim, axlim], showticklabels=False, zeroline=False),
        yaxis=dict(
            range=[-axlim, axlim],
            showticklabels=False,
            zeroline=False,
            scaleanchor="x",
            scaleratio=1,
        ),
    )
    return fig_widget


@dataclass
class KeplerOrbitWidget:
    """Container bundling an interactive Kepler-orbit widget and its live objects.

    All controls are ``ipywidgets`` (not Plotly's own ``updatemenus``/
    ``sliders``), so the layout is fully under our control and time-stepping
    (via ``play``) is independent of the eccentricity control - changing
    eccentricity while playing just restyles the live figure in place and
    does not interrupt or reset the animation. Holding a reference to this
    object (not just its ``box``) is required for the controls to keep
    working, since ``ipywidgets`` callbacks are only kept alive by external
    references.

    Attributes:
        box (ipywidgets.VBox):
            The full widget tree (controls above the orbit figure) -
            display this in a notebook cell.
        fig_widget (plotly.graph_objects.FigureWidget):
            The live orbit figure.
        e_slider (ipywidgets.FloatSlider):
            The eccentricity slider.
        e_textbox (ipywidgets.BoundedFloatText):
            The eccentricity numeric entry, linked to the slider.
        play (ipywidgets.Play):
            The Play/Pause control, also linked to ``step_slider``.
        step_slider (ipywidgets.IntSlider):
            The mean-anomaly step, scrubbable independently of ``play``.
        show_vvec_checkbox (ipywidgets.Checkbox):
            Toggles the velocity-vector arrow's visibility.
    """

    box: widgets.VBox
    fig_widget: go.FigureWidget
    e_slider: widgets.FloatSlider
    e_textbox: widgets.BoundedFloatText
    play: widgets.Play
    step_slider: widgets.IntSlider
    show_vvec_checkbox: widgets.Checkbox


def kepler_orbit_widget(
    e0: float = 0.5, a: float = 1.0, n_steps: int = 250, frame_duration_ms: int = 30
) -> KeplerOrbitWidget:
    """Interactive widget animating a 2D Kepler elliptical orbit. See Tutorial 4.2.

    An eccentricity slider (with a linked numeric entry) reshapes the orbit;
    a Play/Pause control with a linked step slider drives the animation; and
    a checkbox toggles the velocity-vector arrow. All controls are
    ``ipywidgets``, restyling one persistent Plotly ``FigureWidget`` from
    Python rather than driving Plotly's own client-side ``frames``/
    ``animate`` mechanism (which ``FigureWidget`` does not support, and
    which cannot survive being rebuilt mid-animation). Changing eccentricity
    while playing does not interrupt playback - the current step is owned
    entirely by ``play``/``step_slider``, independent of eccentricity.
    Requires ``ipywidgets``/``plotly`` and a live Jupyter kernel connection
    (e.g. a Jupyter notebook or JupyterLab) - unlike earlier chapters'
    figures, this raises ``RuntimeError`` rather than displaying or
    responding in a plain script.

    Args:
        e0 (float):
            Initial eccentricity, in [0, 1). Defaults to 0.5.
        a (float):
            Semi-major axis. Defaults to 1.0.
        n_steps (int):
            Number of mean-anomaly samples per orbit. Defaults to 250.
        frame_duration_ms (int):
            Milliseconds per animation frame while playing. Defaults to 30.

    Returns:
        KeplerOrbitWidget:
            Container bundling the widget tree, figure and controls. Callers
            must keep a reference to the returned object alive (not just its
            ``box``) for the controls to keep working.

    Raises:
        RuntimeError:
            If called outside a live Jupyter kernel.

    Example:
        >>> orbit = kepler_orbit_widget()
        >>> orbit.box
    """
    _require_jupyter_kernel()

    import ipywidgets as widgets

    r0, v0, _ = kepler_orbit_trajectory(e0, a, n_steps)
    fig_widget = _build_figure_widget(r0, v0, e0, a)
    state = {"e": e0, "r": r0, "v": v0}

    def _redraw(i: int) -> None:
        """Restyle the planet/arrow traces to mean-anomaly step ``i``.

        Args:
            i (int):
                Index into the current eccentricity's trajectory arrays.
        """
        r, v = state["r"], state["v"]
        arrow_x, arrow_y = _arrow_xy(r, v, i)
        with fig_widget.batch_update():
            fig_widget.data[2].x, fig_widget.data[2].y = [r[0, i]], [r[1, i]]
            fig_widget.data[3].x, fig_widget.data[3].y = arrow_x, arrow_y

    e_slider = widgets.FloatSlider(
        value=e0, min=0.0, max=0.9999, step=0.001, description="e", readout=False
    )
    e_textbox = widgets.BoundedFloatText(
        value=e0, min=0.0, max=0.9999, step=0.01, layout=widgets.Layout(width="80px")
    )
    # A kernel-side link (not jslink): recomputing the orbit already requires
    # a round trip to Python, so there is no benefit to a client-side-only
    # link here, and this one keeps both widgets' values correct even before
    # any frontend has connected.
    widgets.link((e_slider, "value"), (e_textbox, "value"))

    play = widgets.Play(
        value=0, min=0, max=n_steps - 1, interval=frame_duration_ms, repeat=True
    )
    step_slider = widgets.IntSlider(value=0, min=0, max=n_steps - 1, description="Step")
    widgets.jslink((play, "value"), (step_slider, "value"))
    show_vvec_checkbox = widgets.Checkbox(
        value=True, description="Show Velocity Vector"
    )

    def on_e_changed(change: dict) -> None:
        """Recompute the orbit and restyle the figure in place.

        Does not touch ``play``/``step_slider`` - an in-progress animation
        keeps running, uninterrupted, at its current step.

        Args:
            change (dict):
                The ``traitlets`` change event; ``change["new"]`` is the new
                eccentricity.
        """
        new_e = change["new"]
        r, v, _ = kepler_orbit_trajectory(new_e, a, n_steps)
        state["e"], state["r"], state["v"] = new_e, r, v
        with fig_widget.batch_update():
            fig_widget.data[0].x, fig_widget.data[0].y = r[0], r[1]
            fig_widget.data[1].x, fig_widget.data[1].y = [a * new_e], [0.0]
        _redraw(play.value)

    def on_step_changed(change: dict) -> None:
        """Restyle the figure for a new animation/scrub step.

        Args:
            change (dict):
                The ``traitlets`` change event; ``change["new"]`` is the new
                step index.
        """
        _redraw(change["new"])

    def on_show_vvec_toggled(change: dict) -> None:
        """Toggle the velocity-arrow trace's visibility.

        Args:
            change (dict):
                The ``traitlets`` change event; ``change["new"]`` is the new
                checkbox state.
        """
        fig_widget.data[3].visible = change["new"]

    e_slider.observe(on_e_changed, names="value")
    play.observe(on_step_changed, names="value")
    show_vvec_checkbox.observe(on_show_vvec_toggled, names="value")

    controls = widgets.VBox(
        [
            widgets.HBox([e_slider, e_textbox]),
            widgets.HBox([play, step_slider, show_vvec_checkbox]),
        ]
    )
    box = widgets.VBox([controls, fig_widget])

    return KeplerOrbitWidget(
        box=box,
        fig_widget=fig_widget,
        e_slider=e_slider,
        e_textbox=e_textbox,
        play=play,
        step_slider=step_slider,
        show_vvec_checkbox=show_vvec_checkbox,
    )
