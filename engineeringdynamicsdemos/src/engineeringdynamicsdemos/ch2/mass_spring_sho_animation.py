"""Mass-spring simple-harmonic-oscillator animation. See Tutorial 2.3."""

from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation

from ..shared.draw_spring import draw_spring


def mass_spring_trajectory(
    t: npt.ArrayLike,
    w0: float = 10.0,
    x0: float = 1.0,
    p0: float = 1.5,
    v0: float = 0.0,
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Closed-form position/velocity trajectory of an undamped mass-spring SHO.

    Args:
        t (npt.ArrayLike):
            Time values (s) at which to evaluate the trajectory.
        w0 (float):
            Natural frequency (rad/s). Defaults to 10.0.
        x0 (float):
            Spring rest length (m), which is also the equilibrium position
            of the mass. Defaults to 1.0.
        p0 (float):
            Initial position (m) of the mass at t=0. Defaults to 1.5.
        v0 (float):
            Initial velocity (m/s) of the mass at t=0. Defaults to 0.0.

    Returns:
        tuple:
            x (npt.NDArray[np.float64]):
                Position trajectory (m) evaluated at each time in ``t``.
            xd (npt.NDArray[np.float64]):
                Velocity trajectory (m/s) evaluated at each time in ``t``.
    """
    t = np.asarray(t, dtype=np.float64)
    x = x0 + (p0 - x0) * np.cos(w0 * t) + v0 / w0 * np.sin(w0 * t)
    xd = -(x0 - p0) * w0 * np.sin(w0 * t) + v0 * np.cos(w0 * t)

    return x, xd


def mass_spring_sho_animation(
    w0: float = 10.0,
    x0: float = 1.0,
    p0: float = 1.5,
    v0: float = 0.0,
    dt: float = 1.0 / 40.0,
    t_max: float = 60.0,
) -> FuncAnimation:
    """Animate a mass-spring simple-harmonic-oscillator system.

    Reproduces Tutorial 2.3: a schematic panel showing the block (mass),
    table (ground), and spring (drawn via
    :func:`engineeringdynamicsdemos.shared.draw_spring`), alongside live
    position and velocity traces, animated using the closed-form
    trajectory from :func:`mass_spring_trajectory`.

    Args:
        w0 (float):
            Natural frequency (rad/s). Defaults to 10.0.
        x0 (float):
            Spring rest length (m). Defaults to 1.0.
        p0 (float):
            Initial position (m). Defaults to 1.5.
        v0 (float):
            Initial velocity (m/s). Defaults to 0.0.
        dt (float):
            Animation time step (s). Defaults to 1/40.
        t_max (float):
            Total animation duration (s). Defaults to 60.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a
            reference to the returned object alive for the animation to
            play (matplotlib does not retain it internally), and should
            call ``plt.show()`` to display it interactively.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = mass_spring_sho_animation()
        >>> plt.show()
    """
    # Build a time vector that includes t_max exactly, regardless of
    # floating-point rounding in t_max / dt.
    n_steps = int(round(t_max / dt)) + 1
    t = np.arange(n_steps) * dt
    x, xd = mass_spring_trajectory(t, w0=w0, x0=x0, p0=p0, v0=v0)

    fig = plt.figure(1, figsize=(12, 7))
    fig.clf()
    gs = fig.add_gridspec(2, 2, wspace=0.35, hspace=0.35)
    ax_pos = fig.add_subplot(gs[0, 0])
    ax_vel = fig.add_subplot(gs[1, 0])
    ax_schematic = fig.add_subplot(gs[:, 1])

    # Schematic panel: a small square block (the mass), a black table
    # (ground) sized to the trajectory's maximum extent, and the spring
    # connecting the wall (at the origin) to the block.
    block_x0 = np.array([0.0, 2.0, 2.0, 0.0, 0.0]) / 10.0
    block_y = np.array([1.0, 1.0, -1.0, -1.0, 1.0]) / 10.0
    (block,) = ax_schematic.fill(block_x0 + x[0], block_y, "b")
    table_x = np.array([0.0, x.max() + 0.5, x.max() + 0.5, 0.0, 0.0])
    table_y = np.array([-0.1, -0.1, -1.0, -1.0, -0.1])
    ax_schematic.fill(table_x, table_y, "k")
    sprng0 = draw_spring((0.0, 0.0), (x[0], 0.0), 10, 0.05)
    (spring_line,) = ax_schematic.plot(sprng0[0, :], sprng0[1, :])
    ax_schematic.set_aspect("equal")
    ax_schematic.set_xlim(0, x.max() + 0.5)
    ax_schematic.set_ylim(-0.5, 0.5)
    ax_schematic.tick_params(labelsize=18)
    ax_schematic.set_xlabel(r"$\mathbf{\hat{e}}_1 \rightarrow$", fontsize=18)
    ax_schematic.set_ylabel(r"$\mathbf{\hat{e}}_2 \rightarrow$", fontsize=18)

    # Position and velocity traces, drawn incrementally as the animation
    # progresses. The y-limits are fixed up front from the full trajectory
    # (rather than left to autoscale) so the traces are never truncated and
    # don't jump around as the animation plays.
    (pos_line,) = ax_pos.plot(t[:1], x[:1], linewidth=2)
    ax_pos.tick_params(labelsize=18)
    ax_pos.set_ylabel("Position (m)", fontsize=18)
    x_margin = 0.1 * (x.max() - x.min())
    ax_pos.set_ylim(x.min() - x_margin, x.max() + x_margin)

    (vel_line,) = ax_vel.plot(t[:1], xd[:1], linewidth=2)
    ax_vel.tick_params(labelsize=18)
    ax_vel.set_xlabel("Time (s)", fontsize=18)
    ax_vel.set_ylabel("Velocity (m/s)", fontsize=18)
    xd_margin = 0.1 * (xd.max() - xd.min())
    ax_vel.set_ylim(xd.min() - xd_margin, xd.max() + xd_margin)

    def update(frame: int):
        """Advance the animation to time step ``frame``.

        Args:
            frame (int):
                Index into ``t``/``x``/``xd`` for the animation frame to
                draw.

        Returns:
            tuple:
                block (matplotlib.patches.Polygon):
                    The updated mass patch.
                spring_line (matplotlib.lines.Line2D):
                    The updated spring line.
                pos_line (matplotlib.lines.Line2D):
                    The updated position trace.
                vel_line (matplotlib.lines.Line2D):
                    The updated velocity trace.
        """
        block.set_xy(np.column_stack((block_x0 + x[frame], block_y)))
        sprng = draw_spring((0.0, 0.0), (x[frame], 0.0), 10, 0.05)
        spring_line.set_data(sprng[0, :], sprng[1, :])
        pos_line.set_data(t[: frame + 1], x[: frame + 1])
        vel_line.set_data(t[: frame + 1], xd[: frame + 1])
        # Fix the x-axis to [0, 5] for the first 5 seconds, then grow it to
        # track the elapsed time. Set directly from the data rather than via
        # relim()/autoscale_view(): calling set_xlim() (above) disables that
        # axis's autoscaling by default, which would make a later
        # autoscale_view() call silently do nothing.
        if t[frame] < 5:
            ax_pos.set_xlim(0, 5)
            ax_vel.set_xlim(0, 5)
        else:
            ax_pos.set_xlim(0, t[frame])
            ax_vel.set_xlim(0, t[frame])
        return block, spring_line, pos_line, vel_line

    anim = FuncAnimation(
        fig, update, frames=range(1, len(t)), interval=dt * 1000, blit=False
    )

    return anim
