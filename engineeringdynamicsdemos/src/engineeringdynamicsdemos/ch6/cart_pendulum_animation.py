"""Inverted pendulum on a sliding cart. See Example 6.2 and Problem 6.12."""

from typing import Optional, Type, Union

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation
from scipy.integrate import OdeSolver, solve_ivp


def cart_pendulum_trajectory(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    upright: bool = False,
    method: Union[str, Type[OdeSolver]] = "RK45",
    rtol: float = 1e-3,
    atol: float = 1e-6,
    g: float = 9.81,
    l: float = 1.0,
    M: float = 2.0,
    m: float = 1.0,
) -> npt.NDArray[np.float64]:
    """Numerically integrate the equations of motion of a pendulum on a cart.

    The cart (mass ``M``) slides frictionlessly along e1. The pendulum bob (mass
    ``m``) is attached to the cart by a massless arm of length ``l``, with
    theta measured from e1 towards e2 (so theta = pi/2 is the pendulum pointing
    straight up).

    The defaults (``RK45``, ``rtol=1e-3``, ``atol=1e-6``) correspond to
    MATLAB's ``ode45`` with its default tolerances: both use the Dormand-Prince
    5(4) pair. Any other :func:`scipy.integrate.solve_ivp` method (e.g.
    ``"DOP853"``, the closest analog to MATLAB's ``ode89``) and tolerance can be
    selected instead. Note that ``solve_ivp`` clips any ``rtol`` below
    ``100 * eps`` (about 2.2e-14) to that value, with a warning.

    The vertical (``upright=True``) configuration is an equilibrium of the
    equations of motion, but an unstable one. Because ``cos(pi/2)`` evaluates
    to about 6e-17 in floating point rather than exactly zero, and every
    integrator introduces its own truncation error, the explicit Runge-Kutta
    solutions (``RK45``, ``DOP853``, ...) and ``LSODA`` eventually depart from
    the equilibrium at any tolerance - tightening the tolerance only changes
    when. The implicit ``Radau`` and ``BDF`` methods, by contrast, happen to
    stay at the equilibrium indefinitely: their round-off dithers theta by
    one unit in the last place on either side of pi/2 (where ``cos`` changes
    sign) rather than growing coherently. Any genuine perturbation of the
    initial state (e.g. 1e-12 rad) makes them fall as well.

    Args:
        t (npt.ArrayLike, optional):
            Time values (s) at which to evaluate the solution. Defaults to
            ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[x(t0), xdot(t0), theta(t0), thetadot(t0)]`` (m,
            m/s, rad, rad/s). Defaults to ``[0, 0, pi/3, 0]``. Must not be
            given if ``upright`` is True.
        upright (bool):
            If True, start at rest in the vertical unstable equilibrium,
            ``y0 = [0, 0, pi/2, 0]``. Defaults to False.
        method (str or scipy.integrate.OdeSolver subclass):
            Integration method passed to :func:`scipy.integrate.solve_ivp`.
            Defaults to ``"RK45"``.
        rtol (float):
            Relative integration tolerance. Defaults to 1e-3.
        atol (float):
            Absolute integration tolerance. Defaults to 1e-6.
        g (float):
            Acceleration due to gravity (m/s^2). Defaults to 9.81.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.
        M (float):
            Mass of the cart (kg). Defaults to 2.0.
        m (float):
            Mass of the pendulum bob (kg). Defaults to 1.0.

    Returns:
        npt.NDArray[np.float64]:
            Array of shape ``(len(t), 4)`` whose columns are x (m), xdot (m/s),
            theta (rad) and thetadot (rad/s) at each time in ``t``.

    Raises:
        ValueError:
            If both ``y0`` and ``upright=True`` are given.

    Examples:
        >>> t = np.arange(0, 15, 1 / 40)
        >>> res = cart_pendulum_trajectory(t, [0, 0, np.pi / 4, 0])
        >>> res = cart_pendulum_trajectory(upright=True, method="DOP853", rtol=1e-13)
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    if upright:
        if y0 is not None:
            raise ValueError("Specify either y0 or upright=True, not both.")
        y0 = [0.0, 0.0, np.pi / 2, 0.0]
    elif y0 is None:
        y0 = [0.0, 0.0, np.pi / 3, 0.0]
    t = np.asarray(t, dtype=np.float64)

    def cart_pendulum_ode(_t: float, y: npt.NDArray[np.float64]):
        """Right-hand side of the cart-pendulum equations of motion.

        Args:
            _t (float):
                Time (s). Unused; the system is autonomous.
            y (npt.NDArray[np.float64]):
                State ``[x, xdot, theta, thetadot]``.

        Returns:
            list:
                Time derivative ``[xdot, xddot, thetadot, thetaddot]`` of the
                state.
        """
        th, thd = y[2], y[3]
        xdd = (m * l * thd**2 * np.cos(th) - m * g * np.sin(th) * np.cos(th)) / (
            M + m * np.cos(th) ** 2
        )
        return [y[1], xdd, thd, -g / l * np.cos(th) + xdd * np.sin(th) / l]

    sol = solve_ivp(
        cart_pendulum_ode,
        (t[0], t[-1]),
        np.asarray(y0, dtype=np.float64),
        t_eval=t,
        method=method,
        rtol=rtol,
        atol=atol,
    )
    return sol.y.T


def cart_pendulum_animation(
    t: Optional[npt.ArrayLike] = None,
    y0: Optional[npt.ArrayLike] = None,
    upright: bool = False,
    method: Union[str, Type[OdeSolver]] = "RK45",
    rtol: float = 1e-3,
    atol: float = 1e-6,
    l: float = 1.0,
) -> FuncAnimation:
    """Integrate and animate the motion of a pendulum on a sliding cart.

    Reproduces Example 6.2: the cart slides along a track in the e1
    direction while the pendulum swings, using the trajectory from
    :func:`cart_pendulum_trajectory` (see there for the integrator and
    tolerance options and the behavior of the ``upright`` equilibrium).

    Args:
        t (npt.ArrayLike, optional):
            Time values (s) of the animation frames. Defaults to
            ``0:1/40:60``.
        y0 (npt.ArrayLike, optional):
            Initial state ``[x(t0), xdot(t0), theta(t0), thetadot(t0)]``.
            Defaults to ``[0, 0, pi/3, 0]``. Must not be given if ``upright``
            is True.
        upright (bool):
            If True, start at rest in the vertical unstable equilibrium.
            Defaults to False.
        method (str or scipy.integrate.OdeSolver subclass):
            Integration method passed to :func:`scipy.integrate.solve_ivp`.
            Defaults to ``"RK45"``.
        rtol (float):
            Relative integration tolerance. Defaults to 1e-3.
        atol (float):
            Absolute integration tolerance. Defaults to 1e-6.
        l (float):
            Length of the pendulum arm (m). Defaults to 1.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play, and call ``plt.show()`` to display it
            interactively.

    Examples:
        >>> import matplotlib.pyplot as plt
        >>> # Cart at rest, pendulum inverted at 45 degrees:
        >>> t = np.arange(0, 15, 1 / 40)
        >>> anim = cart_pendulum_animation(t, [0, 0, np.pi / 4, 0])
        >>> # Cart at rest, pendulum pointing straight up:
        >>> anim = cart_pendulum_animation(t, upright=True)
        >>> plt.show()
    """
    if t is None:
        t = np.arange(0, 60 + 1 / 80, 1 / 40)
    t = np.asarray(t, dtype=np.float64)
    res = cart_pendulum_trajectory(
        t, y0, upright=upright, method=method, rtol=rtol, atol=atol, l=l
    )
    x = res[:, 0]
    th = res[:, 2]
    # Pendulum bob e1 and e2 positions.
    mx = x + l * np.cos(th)
    my = l * np.sin(th)

    circ_ang = np.linspace(0, 2 * np.pi, 201)
    circrad = l / 10
    xcirc = circrad * np.sin(circ_ang)
    ycirc = circrad * np.cos(circ_ang)
    xbox = np.array([-l / 2, l / 2, l / 2, -l / 2, -l / 2])
    ybox = np.array([0, 0, -l / 2, -l / 2, 0])

    xlim = (
        min(np.min(x - l / 2), np.min(mx - circrad)),
        max(np.max(x + l / 2), np.max(mx + circrad)),
    )
    ylim = (
        min(-l / 2, np.min(my - circrad)),
        max(l / 2, np.max(my + circrad)),
    )

    # Size the figure to the (equal-aspect) data extents, as these depend on
    # how far the cart travels.
    height = 5.0
    width = float(np.clip(height * np.ptp(xlim) / np.ptp(ylim) + 1.5, 5.0, 16.0))
    fig = plt.figure(1, figsize=(width, height))
    fig.clf()
    ax = fig.add_subplot(1, 1, 1)
    (bob,) = ax.fill(xcirc + mx[0], ycirc + my[0], "b")
    ax.plot(xlim, [-l / 4, -l / 4], "k", linewidth=7)
    (cart,) = ax.fill(xbox + x[0], ybox, "b")
    (link,) = ax.plot([x[0], mx[0]], [0, my[0]], "r", linewidth=2)
    ax.set_aspect("equal")
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.tick_params(labelsize=18)
    ax.set_xlabel(r"$\mathbf{\hat{e}}_1 \rightarrow$", fontsize=18)
    ax.set_ylabel(r"$\mathbf{\hat{e}}_2 \rightarrow$", fontsize=18)
    fig.tight_layout()

    def update(frame: int):
        """Advance the animation to time step ``frame``.

        Args:
            frame (int):
                Index into ``t`` of the animation frame to draw.

        Returns:
            tuple:
                bob (matplotlib.patches.Polygon):
                    The updated pendulum bob.
                cart (matplotlib.patches.Polygon):
                    The updated cart.
                link (matplotlib.lines.Line2D):
                    The updated pendulum arm.
        """
        bob.set_xy(np.column_stack((xcirc + mx[frame], ycirc + my[frame])))
        cart.set_xy(np.column_stack((xbox + x[frame], ybox)))
        link.set_data([x[frame], mx[frame]], [0, my[frame]])
        return bob, cart, link

    dt = float(np.mean(np.diff(t)))
    return FuncAnimation(
        fig, update, frames=range(1, len(t)), interval=dt * 1000, blit=False
    )
