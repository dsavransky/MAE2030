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


def compare_simple_pendulum_sho() -> Tuple[Figure, Figure]:
    """Plot numerical simple pendulum trajectories against the SHO solution.

    Reproduces Example 3.9: for a large (pi/3 rad) and a small (0.1 rad) initial
    angle, compares the numerically integrated pendulum equations of motion with
    the analytical solution of the linearized equations.

    Returns:
        tuple:
            fig_large (matplotlib.figure.Figure):
                Figure for the large initial angle.
            fig_small (matplotlib.figure.Figure):
                Figure for the small initial angle.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> figs = compare_simple_pendulum_sho()
        >>> plt.show()
    """
    t = np.linspace(0, 10, 150)

    def make_figure(num: int, y0: Tuple[float, float]) -> Figure:
        """Draw the comparison figure for one set of initial conditions.

        Args:
            num (int):
                Matplotlib figure number.
            y0 (tuple):
                Initial state ``(theta(0), thetadot(0))``.

        Returns:
            matplotlib.figure.Figure:
                The populated figure.
        """
        thsho, thdsho = simple_pendulum_sho_trajectory(t, y0)
        res = simple_pendulum_trajectory(t, y0)

        fig = plt.figure(num, figsize=(5.75, 7))
        fig.clf()
        ax1, ax2 = fig.subplots(2, 1)
        ax1.plot(t, thsho, linewidth=2, label="SHO Equations")
        ax1.plot(t, res[:, 0], "--", linewidth=2, label="Numerical Integration")
        ax1.legend()
        ax1.tick_params(labelsize=18)
        ax1.set_ylabel(r"$\theta$ (rad)", fontsize=18)
        ax1.set_title(
            rf"$\theta(0) = {y0[0]:g}$, $\dot\theta(0) = {y0[1]:g}$", fontsize=18
        )
        ax2.plot(t, thdsho, linewidth=2)
        ax2.plot(t, res[:, 1], "--", linewidth=2)
        ax2.tick_params(labelsize=18)
        ax2.set_xlabel("Time (s)", fontsize=18)
        ax2.set_ylabel(r"$\dot\theta$ (rad/s)", fontsize=18)
        fig.tight_layout()
        return fig

    return make_figure(1, (np.pi / 3, 0.0)), make_figure(2, (0.1, 0.0))
