"""Particle undergoing repeated collisions inside a square box."""

from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation


def rebound_box_trajectory(
    e: float = 0.8,
    n_bounces: int = 20,
    L: float = 5.0,
    vel0: npt.ArrayLike = (10.0, 14.0),
    pos0: npt.ArrayLike = (0.0, 0.0),
) -> Tuple[npt.NDArray[np.float64], npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    """Compute the sequence of wall collisions of a particle in a square box.

    The particle moves in a straight line at constant velocity between
    collisions with the walls of the box ``[-L, L] x [-L, L]``. At each
    collision, the velocity component normal to the wall (the e_n direction
    of the collision frame) is reversed and scaled by the coefficient of
    restitution ``e``, and the tangential component is unchanged.

    Small values of ``e`` shrink the velocity geometrically with each bounce,
    so the time between collisions (and hence the length of any animation of
    it) grows rapidly - keep ``n_bounces`` modest in that case.

    Args:
        e (float):
            Coefficient of restitution. Defaults to 0.8.
        n_bounces (int):
            Number of collisions to compute. Defaults to 20.
        L (float):
            Half-width of the box. Defaults to 5.0.
        vel0 (npt.ArrayLike):
            Initial velocity components in the inertial frame. Defaults to
            ``(10, 14)``.
        pos0 (npt.ArrayLike):
            Initial position components in the inertial frame. Defaults to
            ``(0, 0)``.

    Returns:
        tuple:
            times (npt.NDArray[np.float64]):
                Array of shape ``(n_bounces + 1,)`` of the initial time (0)
                followed by the time of each collision.
            positions (npt.NDArray[np.float64]):
                Array of shape ``(n_bounces + 1, 2)`` of the initial position
                followed by the position of each collision.
            velocities (npt.NDArray[np.float64]):
                Array of shape ``(n_bounces + 1, 2)`` of the initial velocity
                followed by the velocity immediately after each collision.
    """
    pos = np.array(pos0, dtype=np.float64)
    vel = np.array(vel0, dtype=np.float64)
    times = np.zeros(n_bounces + 1)
    positions = np.zeros((n_bounces + 1, 2))
    velocities = np.zeros((n_bounces + 1, 2))
    positions[0] = pos
    velocities[0] = vel
    for k in range(1, n_bounces + 1):
        # Time to reach each pair of walls; a zero component never gets there.
        with np.errstate(divide="ignore", invalid="ignore"):
            t_wall = np.where(vel != 0, (L * np.sign(vel) - pos) / vel, np.inf)
        en_ind = int(np.argmin(t_wall))
        dt = t_wall[en_ind]
        if not np.isfinite(dt):
            raise ValueError("Particle is at rest and never reaches a wall.")
        pos = pos + vel * dt
        pos[en_ind] = L * np.sign(vel[en_ind])
        vel[en_ind] = -e * vel[en_ind]
        times[k] = times[k - 1] + dt
        positions[k] = pos
        velocities[k] = vel
    return times, positions, velocities


def rebound_box_animation(
    e: float = 0.8,
    n_bounces: int = 20,
    fps: float = 23.0,
    L: float = 5.0,
) -> FuncAnimation:
    """Animate a particle bouncing around inside a square box.

    Uses the collision sequence from :func:`rebound_box_trajectory`, starting
    from the center of the box with velocity ``(10, 14)``, and traces the
    particle's path with a dashed line.

    Args:
        e (float):
            Coefficient of restitution. Defaults to 0.8. With ``e = 1`` no
            energy is lost in the collisions.
        n_bounces (int):
            Number of collisions to animate. Defaults to 20.
        fps (float):
            Animation frame rate (frames per second of simulated time).
            Each straight segment between collisions gets
            ``max(1, floor(fps * duration))`` frames, so the total frame count
            (and rendering time) scales with ``fps``. Defaults to 23.
        L (float):
            Half-width of the box. Defaults to 5.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play, and call ``plt.show()`` to display it
            interactively.

    Examples:
        >>> import matplotlib.pyplot as plt
        >>> anim = rebound_box_animation()  # e = 0.8
        >>> anim = rebound_box_animation(1)  # no energy loss
        >>> plt.show()
    """
    times, positions, velocities = rebound_box_trajectory(e, n_bounces, L)

    # Sample each segment between collisions, ending exactly on the wall.
    path = [positions[:1]]
    for k in range(n_bounces):
        dt = times[k + 1] - times[k]
        nframes = max(1, int(fps * dt))
        tseg = np.linspace(0, dt, nframes + 1)[1:]
        path.append(positions[k] + np.outer(tseg, velocities[k]))
    path = np.vstack(path)

    fig = plt.figure(1, figsize=(7, 7))
    fig.clf()
    ax = fig.add_subplot(1, 1, 1)
    Ld = L + 0.2
    ax.plot([-Ld, Ld, Ld, -Ld, -Ld], [Ld, Ld, -Ld, -Ld, Ld], "b", linewidth=4)
    (trail,) = ax.plot(path[:1, 0], path[:1, 1], "k--")
    (particle,) = ax.plot(
        path[:1, 0], path[:1, 1], "o", markerfacecolor="r", markersize=16
    )
    ax.set_aspect("equal")
    ax.set_xlim(-Ld * 1.1, Ld * 1.1)
    ax.set_ylim(-Ld * 1.1, Ld * 1.1)
    ax.set_axis_off()

    def update(frame: int):
        """Advance the animation to frame ``frame``.

        Args:
            frame (int):
                Index into the sampled path of the frame to draw.

        Returns:
            tuple:
                particle (matplotlib.lines.Line2D):
                    The updated particle marker.
                trail (matplotlib.lines.Line2D):
                    The updated path trace.
        """
        particle.set_data(path[frame : frame + 1, 0], path[frame : frame + 1, 1])
        trail.set_data(path[: frame + 1, 0], path[: frame + 1, 1])
        return particle, trail

    return FuncAnimation(
        fig, update, frames=range(1, len(path)), interval=1000 / fps, blit=False
    )
