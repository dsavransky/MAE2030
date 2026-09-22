"""Compare a simple pendulum with its linearized (SHO) approximation. See Ex. 3.9."""

from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.figure import Figure

from .simple_pendulum_animation import simple_pendulum_trajectory


def simple_pendulum_sho_trajectory(
    t: npt.ArrayLike,
    y0: npt.ArrayLike,
    g: float = 9.81,
    l: float = 1.0,
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Analytical solution of the linearized simple pendulum equations.

    Args:
        t (npt.ArrayLike):
            Time values (s) at which to evaluate the solution.
        y0 (npt.ArrayLike):
            Initial state ``[theta(0), thetadot(0)]`` (rad, rad/s).
        g (float):
            Acceleration due to gravity (m/s^2). Defaults to 9.81.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.

    Returns:
        tuple:
            theta (npt.NDArray[np.float64]):
                Angle (rad) at each time in ``t``.
            thetad (npt.NDArray[np.float64]):
                Angular rate (rad/s) at each time in ``t``.
    """
    t = np.asarray(t, dtype=np.float64)
    w0 = np.sqrt(g / l)
    a = y0[0]
    b = y0[1] / w0
    theta = a * np.cos(w0 * t) + b * np.sin(w0 * t)
    thetad = -a * w0 * np.sin(w0 * t) + b * w0 * np.cos(w0 * t)
    return theta, thetad


def compare_simple_pendulum_sho() -> Figure:
    """Plot numerical simple pendulum trajectories against the SHO solution.

    Reproduces Example 3.9: for a large (pi/3 rad) and a small (0.1 rad) initial
    angle, shown side by side, compares the numerically integrated pendulum
    equations of motion with the analytical solution of the linearized
    equations.

    Returns:
        matplotlib.figure.Figure:
            Figure with a 2x2 grid of subplots: one column per initial angle
            (large, then small), theta above thetadot.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> fig = compare_simple_pendulum_sho()
        >>> plt.show()
    """
    t = np.linspace(0, 10, 150)

    fig = plt.figure(1, figsize=(11, 7))
    fig.clf()
    axes = fig.subplots(2, 2, sharex=True)

    def make_figure(ax_th, ax_thd, y0: Tuple[float, float]) -> None:
        """Draw the comparison plots for one set of initial conditions.

        Args:
            ax_th (matplotlib.axes.Axes):
                Axes to draw the theta trace on.
            ax_thd (matplotlib.axes.Axes):
                Axes to draw the thetadot trace on.
            y0 (tuple):
                Initial state ``(theta(0), thetadot(0))``.
        """
        thsho, thdsho = simple_pendulum_sho_trajectory(t, y0)
        res = simple_pendulum_trajectory(t, y0)

        ax_th.plot(t, thsho, linewidth=2, label="SHO Equations")
        ax_th.plot(t, res[:, 0], "--", linewidth=2, label="Numerical Integration")
        ax_th.legend()
        ax_th.tick_params(labelsize=18)
        ax_th.set_ylabel(r"$\theta$ (rad)", fontsize=18)
        ax_th.set_title(
            rf"$\theta(0) = {y0[0]:g}$, $\dot\theta(0) = {y0[1]:g}$", fontsize=18
        )
        ax_thd.plot(t, thdsho, linewidth=2)
        ax_thd.plot(t, res[:, 1], "--", linewidth=2)
        ax_thd.tick_params(labelsize=18)
        ax_thd.set_xlabel("Time (s)", fontsize=18)
        ax_thd.set_ylabel(r"$\dot\theta$ (rad/s)", fontsize=18)

    make_figure(axes[0, 0], axes[1, 0], (np.pi / 3, 0.0))
    make_figure(axes[0, 1], axes[1, 1], (0.1, 0.0))
    fig.tight_layout()
    return fig
