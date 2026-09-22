"""Spring pendulum numerical integration and animation."""

from typing import Optional

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation
from scipy.integrate import solve_ivp

from ..shared.draw_spring import draw_spring


def spring_pendulum_trajectory(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    g: float = 9.81,
    x0: float = 0.1,
    m: float = 0.1,
    k: float = 2.0,
    rtol: float = 1e-12,
    atol: float = 1e-14,
) -> npt.NDArray[np.float64]:
    """Numerically integrate the equations of motion of a spring pendulum.

    Args:
        t (npt.ArrayLike, optional):
            Time values (s). Defaults to ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[r, rdot, theta, thetadot]`` (m, m/s, rad, rad/s).
            Defaults to ``[0.5, 0, pi/3, 0]``.
        g (float):
            Acceleration due to gravity (m/s^2). Defaults to 9.81.
        x0 (float):
            Spring rest length (m). Defaults to 0.1.
        m (float):
            Pendulum mass (kg). Defaults to 0.1.
        k (float):
            Spring constant (N/m). Defaults to 2.0.
        rtol (float):
            Relative integration tolerance. Defaults to 1e-12.
        atol (float):
            Absolute integration tolerance. Defaults to 1e-14.

    Returns:
        npt.NDArray[np.float64]:
            Array of shape ``(len(t), 4)`` whose columns are r, rdot, theta and
            thetadot at each time in ``t``.
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    if y0 is None:
        y0 = [0.5, 0.0, np.pi / 3, 0.0]
    t = np.asarray(t, dtype=np.float64)

    def spring_pendulum_ode(_t: float, y: npt.NDArray[np.float64]):
        """Right-hand side of the spring pendulum equations of motion.

        Args:
            _t (float):
                Time (s). Unused.
            y (npt.NDArray[np.float64]):
                State ``[r, rdot, theta, thetadot]``.

        Returns:
            list:
                Time derivative of the state.
        """
        r, rd, th, thd = y
        return [
            rd,
            r * thd**2 + g * np.cos(th) - k / m * (r - x0),
            thd,
            -2 * rd * thd / r - g * np.sin(th) / r,
        ]

    sol = solve_ivp(
        spring_pendulum_ode,
        (t[0], t[-1]),
        np.asarray(y0, dtype=np.float64),
        t_eval=t,
        method="DOP853",
        rtol=rtol,
        atol=atol,
    )
    return sol.y.T


def spring_pendulum_animation(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
) -> FuncAnimation:
    """Integrate and animate the motion of a spring pendulum.

    A schematic of the pendulum (spring drawn with
    :func:`engineeringdynamicsdemos.shared.draw_spring`; e1 points down and e2
    points right) alongside live traces of r and theta.

    Args:
        t (npt.ArrayLike, optional):
            Time values (s) of the frames. Defaults to ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[r, rdot, theta, thetadot]``. Defaults to
            ``[0.5, 0, pi/3, 0]``.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = spring_pendulum_animation()
        >>> plt.show()
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    t = np.asarray(t, dtype=np.float64)
    res = spring_pendulum_trajectory(t, y0)
    r = res[:, 0]
    theta = res[:, 2]
    x = r * np.sin(theta)
    y = r * np.cos(theta)

    fig = plt.figure(1, figsize=(12, 7))
    fig.clf()
    gs = fig.add_gridspec(2, 2, wspace=0.35, hspace=0.35)
    ax_r = fig.add_subplot(gs[0, 0])
    ax_th = fig.add_subplot(gs[1, 0])
    ax_pend = fig.add_subplot(gs[:, 1])

    circ_ang = np.linspace(0, 2 * np.pi, 201)
    circrad = r.max() / 20
    xcirc = circrad * np.sin(circ_ang)
    ycirc = circrad * np.cos(circ_ang)
    (bob,) = ax_pend.fill(xcirc + x[0], ycirc + y[0], "b")
    spr0 = draw_spring((0.0, 0.0), (x[0], y[0]), 10, 0.05)
    (spring_line,) = ax_pend.plot(spr0[0, :], spr0[1, :])
    ax_pend.set_aspect("equal")
    ax_pend.set_xlim(np.min(x - circrad), np.max(x + circrad))
    ax_pend.set_ylim(
        np.max(np.append(y + circrad, 0.0)), np.min(np.append(y - circrad, 0.0))
    )
    ax_pend.xaxis.tick_top()
    ax_pend.xaxis.set_label_position("top")
    ax_pend.tick_params(labelsize=18)
    ax_pend.set_ylabel(r"$\leftarrow \mathbf{\hat{e}}_1$", fontsize=18)
    ax_pend.set_xlabel(r"$\mathbf{\hat{e}}_2 \rightarrow$", fontsize=18)

    (r_line,) = ax_r.plot(t[:1], r[:1], linewidth=2)
    ax_r.tick_params(labelsize=18)
    ax_r.set_xlabel("Time (s)", fontsize=18)
    ax_r.set_ylabel(r"$r$ (m)", fontsize=18)
    margin = 0.1 * np.ptp(r)
    ax_r.set_ylim(r.min() - margin, r.max() + margin)

    (th_line,) = ax_th.plot(t[:1], theta[:1], linewidth=2)
    ax_th.tick_params(labelsize=18)
    ax_th.set_xlabel("Time (s)", fontsize=18)
    ax_th.set_ylabel(r"$\theta$ (rad)", fontsize=18)
    margin = 0.1 * np.ptp(theta)
    ax_th.set_ylim(theta.min() - margin, theta.max() + margin)

    def update(frame: int):
        """Advance the animation to time step ``frame``.

        Args:
            frame (int):
                Index into ``t`` of the animation frame to draw.

        Returns:
            tuple:
                bob (matplotlib.patches.Polygon):
                    The updated pendulum bob.
                spring_line (matplotlib.lines.Line2D):
                    The updated spring.
                r_line (matplotlib.lines.Line2D):
                    The updated r trace.
                th_line (matplotlib.lines.Line2D):
                    The updated theta trace.
        """
        bob.set_xy(np.column_stack((xcirc + x[frame], ycirc + y[frame])))
        spr = draw_spring((0.0, 0.0), (x[frame], y[frame]), 10, 0.05)
        spring_line.set_data(spr[0, :], spr[1, :])
        r_line.set_data(t[: frame + 1], r[: frame + 1])
        th_line.set_data(t[: frame + 1], theta[: frame + 1])
        xmax = 5 if t[frame] < 5 else t[frame]
        ax_r.set_xlim(0, xmax)
        ax_th.set_xlim(0, xmax)
        return bob, spring_line, r_line, th_line

    dt = float(np.mean(np.diff(t)))
    return FuncAnimation(
        fig, update, frames=range(1, len(t)), interval=dt * 1000, blit=False
    )
