"""Stationary vs. accelerating-frame simple pendulum animation. See Example 3.14."""

from typing import Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation
from scipy.integrate import solve_ivp


def accel_pendulum_trajectories(
    stationary: bool = False,
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    g: float = 9.81,
    l: float = 1.0,
    a: float = 15.0,
    rtol: float = 1e-9,
    atol: float = 1e-12,
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Integrate a stationary and an accelerating simple pendulum.

    Args:
        stationary (bool):
            If True, ``y0`` is overridden with ``[-atan(a/g), 0]``, so that the
            accelerating pendulum is at rest in the accelerating frame.
            Defaults to False.
        t (npt.ArrayLike, optional):
            Time values (s). Defaults to ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[theta(t0), thetadot(t0)]``. Defaults to
            ``[pi/3, 0]``.
        g (float):
            Acceleration due to gravity (m/s^2). Defaults to 9.81.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.
        a (float):
            Acceleration of the pendulum frame (m/s^2). Defaults to 15.0.
        rtol (float):
            Relative integration tolerance. Defaults to 1e-9.
        atol (float):
            Absolute integration tolerance. Defaults to 1e-12.

    Returns:
        tuple:
            res_simp (npt.NDArray[np.float64]):
                Array of shape ``(len(t), 2)`` of ``[theta, thetadot]`` for the
                stationary pendulum.
            res_accel (npt.NDArray[np.float64]):
                Array of shape ``(len(t), 2)`` of ``[theta, thetadot]`` for the
                accelerating pendulum.
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    if y0 is None:
        y0 = [np.pi / 3, 0.0]
    if stationary:
        y0 = [-np.arctan(a / g), 0.0]
    t = np.asarray(t, dtype=np.float64)
    y0 = np.asarray(y0, dtype=np.float64)

    def simple_pendulum_ode(_t: float, y: npt.NDArray[np.float64]):
        """Equations of motion of the stationary pendulum.

        Args:
            _t (float):
                Time (s). Unused.
            y (npt.NDArray[np.float64]):
                State ``[theta, thetadot]``.

        Returns:
            list:
                Time derivative of the state.
        """
        return [y[1], -g / l * np.sin(y[0])]

    def accel_pendulum_ode(_t: float, y: npt.NDArray[np.float64]):
        """Equations of motion of the pendulum in an accelerating frame.

        Args:
            _t (float):
                Time (s). Unused.
            y (npt.NDArray[np.float64]):
                State ``[theta, thetadot]``.

        Returns:
            list:
                Time derivative of the state.
        """
        return [y[1], -g / l * np.sin(y[0]) - a / l * np.cos(y[0])]

    results = []
    for ode in (simple_pendulum_ode, accel_pendulum_ode):
        sol = solve_ivp(
            ode,
            (t[0], t[-1]),
            y0,
            t_eval=t,
            method="DOP853",
            rtol=rtol,
            atol=atol,
        )
        results.append(sol.y.T)

    return results[0], results[1]


def accel_pendulum_animation(
    stationary: bool = False,
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    l: float = 1.0,
) -> FuncAnimation:
    """Animate a stationary pendulum beside one in an accelerating box.

    Reproduces Example 3.14. See :func:`accel_pendulum_trajectories`.

    Args:
        stationary (bool):
            If True, the accelerating pendulum starts at rest in the
            accelerating frame. Defaults to False.
        t (npt.ArrayLike, optional):
            Time values (s) of the frames. Defaults to ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[theta(t0), thetadot(t0)]``. Defaults to
            ``[pi/3, 0]``.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = accel_pendulum_animation(stationary=True)
        >>> plt.show()
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    t = np.asarray(t, dtype=np.float64)
    res_simp, res_accel = accel_pendulum_trajectories(stationary, t, y0, l=l)
    xs = l * np.sin(res_simp[:, 0])
    ys = l * np.cos(res_simp[:, 0])
    xa = l * np.sin(res_accel[:, 0])
    ya = l * np.cos(res_accel[:, 0])

    fig = plt.figure(1, figsize=(12, 7))
    fig.clf()
    ax_simp, ax_accel = fig.subplots(1, 2, gridspec_kw={"wspace": 0.6})
    fig.subplots_adjust(top=0.78)

    circ_ang = np.linspace(0, 2 * np.pi, 201)
    circrad = l / 15
    xcirc = circrad * np.sin(circ_ang)
    ycirc = circrad * np.cos(circ_ang)

    def setup_panel(ax, x, y, frame_letter: str, title: str):
        """Draw the initial pendulum and format one schematic panel.

        Args:
            ax (matplotlib.axes.Axes):
                Axes to draw on.
            x (npt.NDArray[np.float64]):
                Bob horizontal positions (m) over all frames.
            y (npt.NDArray[np.float64]):
                Bob vertical positions (m) over all frames.
            frame_letter (str):
                Letter naming the frame's unit vectors (``e`` or ``b``).
            title (str):
                Panel title.

        Returns:
            tuple:
                bob (matplotlib.patches.Polygon):
                    The pendulum bob patch.
                link (matplotlib.lines.Line2D):
                    The pendulum arm line.
        """
        (bob,) = ax.fill(xcirc + x[0], ycirc + y[0], "b")
        (link,) = ax.plot([0, x[0]], [0, y[0]])
        ax.set_aspect("equal")
        ax.set_xlim(
            np.min(np.append(x - circrad, 0.0)), np.max(np.append(x + circrad, 0.0))
        )
        ax.set_ylim(
            np.max(np.append(y + circrad, 0.0)), np.min(np.append(y - circrad, 0.0))
        )
        ax.xaxis.tick_top()
        ax.xaxis.set_label_position("top")
        ax.tick_params(labelsize=18)
        ax.set_ylabel(rf"$\leftarrow \mathbf{{\hat{{{frame_letter}}}}}_1$", fontsize=18)
        ax.set_xlabel(
            rf"$\mathbf{{\hat{{{frame_letter}}}}}_2 \rightarrow$", fontsize=18
        )
        ax.set_title(title, fontsize=18, pad=45)
        return bob, link

    bob_s, link_s = setup_panel(ax_simp, xs, ys, "e", "Stationary")
    bob_a, link_a = setup_panel(ax_accel, xa, ya, "b", "Accelerating")

    def update(frame: int):
        """Advance the animation to time step ``frame``.

        Args:
            frame (int):
                Index into ``t`` of the animation frame to draw.

        Returns:
            tuple:
                bob_s (matplotlib.patches.Polygon):
                    Stationary pendulum bob.
                link_s (matplotlib.lines.Line2D):
                    Stationary pendulum arm.
                bob_a (matplotlib.patches.Polygon):
                    Accelerating pendulum bob.
                link_a (matplotlib.lines.Line2D):
                    Accelerating pendulum arm.
        """
        bob_s.set_xy(np.column_stack((xcirc + xs[frame], ycirc + ys[frame])))
        link_s.set_data([0, xs[frame]], [0, ys[frame]])
        bob_a.set_xy(np.column_stack((xcirc + xa[frame], ycirc + ya[frame])))
        link_a.set_data([0, xa[frame]], [0, ya[frame]])
        return bob_s, link_s, bob_a, link_a

    dt = float(np.mean(np.diff(t)))
    return FuncAnimation(
        fig, update, frames=range(1, len(t)), interval=dt * 1000, blit=False
    )
