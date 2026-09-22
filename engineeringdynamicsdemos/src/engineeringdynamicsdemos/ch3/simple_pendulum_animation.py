"""Simple pendulum numerical integration and animation. See Example 3.11."""

from typing import Optional

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation
from scipy.integrate import solve_ivp


def simple_pendulum_trajectory(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    g: float = 9.81,
    l: float = 1.0,
    rtol: float = 1e-9,
    atol: float = 1e-12,
) -> npt.NDArray[np.float64]:
    """Numerically integrate the equations of motion of a simple pendulum.

    Args:
        t (npt.ArrayLike, optional):
            Time values (s) at which to evaluate the solution. Defaults to
            ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[theta(t0), thetadot(t0)]`` (rad, rad/s), where theta
            is measured from the downward vertical. Defaults to ``[pi/3, 0]``.
        g (float):
            Acceleration due to gravity (m/s^2). Defaults to 9.81.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.
        rtol (float):
            Relative integration tolerance. Defaults to 1e-9.
        atol (float):
            Absolute integration tolerance. Defaults to 1e-12.

    Returns:
        npt.NDArray[np.float64]:
            Array of shape ``(len(t), 2)`` whose columns are theta (rad) and
            thetadot (rad/s) at each time in ``t``.
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    if y0 is None:
        y0 = [np.pi / 3, 0.0]
    t = np.asarray(t, dtype=np.float64)

    def simple_pendulum_ode(_t: float, y: npt.NDArray[np.float64]):
        """Right-hand side of the simple pendulum equations of motion.

        Args:
            _t (float):
                Time (s). Unused; the system is autonomous.
            y (npt.NDArray[np.float64]):
                State ``[theta, thetadot]``.

        Returns:
            list:
                Time derivative ``[thetadot, thetaddot]`` of the state.
        """
        return [y[1], -g / l * np.sin(y[0])]

    sol = solve_ivp(
        simple_pendulum_ode,
        (t[0], t[-1]),
        np.asarray(y0, dtype=np.float64),
        t_eval=t,
        method="DOP853",
        rtol=rtol,
        atol=atol,
    )
    return sol.y.T


def simple_pendulum_animation(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    l: float = 1.0,
) -> FuncAnimation:
    """Integrate and animate the motion of a simple pendulum.

    Reproduces Example 3.11: a schematic of the pendulum (with e1 pointing
    down and e2 pointing right) alongside live traces of the angle and
    angular rate, using the trajectory from
    :func:`simple_pendulum_trajectory`.

    Args:
        t (npt.ArrayLike, optional):
            Time values (s) of the animation frames. Defaults to
            ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[theta(t0), thetadot(t0)]``. Defaults to
            ``[pi/3, 0]``.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play, and call ``plt.show()`` to display it
            interactively.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = simple_pendulum_animation()
        >>> plt.show()
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    t = np.asarray(t, dtype=np.float64)
    res = simple_pendulum_trajectory(t, y0, l=l)
    theta = res[:, 0]
    thetad = res[:, 1]
    x = l * np.sin(theta)
    y = l * np.cos(theta)

    fig = plt.figure(1, figsize=(12, 7))
    fig.clf()
    gs = fig.add_gridspec(2, 2, wspace=0.35, hspace=0.35)
    ax_th = fig.add_subplot(gs[0, 0])
    ax_thd = fig.add_subplot(gs[1, 0])
    ax_pend = fig.add_subplot(gs[:, 1])

    # Schematic panel: e1 points down (y axis reversed), e2 points right.
    circ_ang = np.linspace(0, 2 * np.pi, 201)
    circrad = l / 15
    xcirc = circrad * np.sin(circ_ang)
    ycirc = circrad * np.cos(circ_ang)
    (bob,) = ax_pend.fill(xcirc + x[0], ycirc + y[0], "b")
    (link,) = ax_pend.plot([0, x[0]], [0, y[0]])
    ax_pend.set_aspect("equal")
    ax_pend.set_xlim(np.min(x - circrad), np.max(x + circrad))
    ax_pend.set_ylim(
        np.max(np.append(y + circrad, 0.0)), np.min(np.append(y - circrad, 0.0))
    )
    ax_pend.tick_params(labelsize=18)
    ax_pend.set_ylabel(r"$\leftarrow \mathbf{\hat{e}}_1$", fontsize=18)
    ax_pend.set_xlabel(r"$\mathbf{\hat{e}}_2 \rightarrow$", fontsize=18)

    # Angle and rate traces, y-limits fixed from the full trajectory.
    (th_line,) = ax_th.plot(t[:1], theta[:1], linewidth=2)
    ax_th.tick_params(labelsize=18)
    ax_th.set_xlabel("Time (s)", fontsize=18)
    ax_th.set_ylabel(r"$\theta$ (rad)", fontsize=18)
    margin = 0.1 * np.ptp(theta)
    ax_th.set_ylim(theta.min() - margin, theta.max() + margin)

    (thd_line,) = ax_thd.plot(t[:1], thetad[:1], linewidth=2)
    ax_thd.tick_params(labelsize=18)
    ax_thd.set_xlabel("Time (s)", fontsize=18)
    ax_thd.set_ylabel(r"$\dot\theta$ (rad/s)", fontsize=18)
    margin = 0.1 * np.ptp(thetad)
    ax_thd.set_ylim(thetad.min() - margin, thetad.max() + margin)

    def update(frame: int):
        """Advance the animation to time step ``frame``.

        Args:
            frame (int):
                Index into ``t`` of the animation frame to draw.

        Returns:
            tuple:
                bob (matplotlib.patches.Polygon):
                    The updated pendulum bob.
                link (matplotlib.lines.Line2D):
                    The updated pendulum arm.
                th_line (matplotlib.lines.Line2D):
                    The updated angle trace.
                thd_line (matplotlib.lines.Line2D):
                    The updated angular rate trace.
        """
        bob.set_xy(np.column_stack((xcirc + x[frame], ycirc + y[frame])))
        link.set_data([0, x[frame]], [0, y[frame]])
        th_line.set_data(t[: frame + 1], theta[: frame + 1])
        thd_line.set_data(t[: frame + 1], thetad[: frame + 1])
        # Fixed [0, 5] window for the first 5 s, then track elapsed time.
        xmax = 5 if t[frame] < 5 else t[frame]
        ax_th.set_xlim(0, xmax)
        ax_thd.set_xlim(0, xmax)
        return bob, link, th_line, thd_line

    dt = float(np.mean(np.diff(t)))
    return FuncAnimation(
        fig, update, frames=range(1, len(t)), interval=dt * 1000, blit=False
    )
