"""Motion of the center of mass of a system of particles. See Section 6.1.3."""

from typing import Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation


def com_demo_trajectories(
    n: int = 300,
    n_steps: int = 150,
    seed: Optional[int] = None,
) -> Tuple[
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
]:
    """Generate particle and center-of-mass positions for two systems.

    Both systems start from the same random cloud of ``n`` particles inside
    the unit sphere (directions uniform on the sphere, radii uniform on
    [0, 1]). In the first system, every particle moves with the same constant
    velocity, so there is no motion relative to the center of mass, which
    translates along ``[1, 1, 1]``. In the second, every particle takes an
    independent random step (motion relative to the center of mass) on top of
    a common drift around a unit circle in the e1-e2 plane.

    Args:
        n (int):
            Number of particles. Defaults to 300.
        n_steps (int):
            Number of time steps after the initial configuration. Defaults
            to 150.
        seed (int, optional):
            Seed for :func:`numpy.random.default_rng`, for reproducible
            results. Defaults to None (a different cloud on every call).

    Returns:
        tuple:
            r1 (npt.NDArray[np.float64]):
                Array of shape ``(n_steps + 1, 3, n)`` of particle positions
                for the first (rigidly translating) system at each step.
            rg1 (npt.NDArray[np.float64]):
                Array of shape ``(n_steps + 1, 3)`` of the first system's
                center-of-mass position at each step.
            r2 (npt.NDArray[np.float64]):
                Array of shape ``(n_steps + 1, 3, n)`` of particle positions
                for the second (randomly moving) system at each step.
            rg2 (npt.NDArray[np.float64]):
                Array of shape ``(n_steps + 1, 3)`` of the second system's
                center-of-mass position at each step.
    """
    rng = np.random.default_rng(seed)
    th = np.arccos(rng.random(n) * 2 - 1)
    phi = rng.random(n) * 2 * np.pi
    r = rng.random(n)
    r0 = np.vstack(
        (r * np.sin(th) * np.cos(phi), r * np.sin(th) * np.sin(phi), r * np.cos(th))
    )

    steps = np.arange(n_steps + 1)
    v1 = np.ones((3, 1)) / 45
    r1 = r0[None, :, :] + steps[:, None, None] * v1[None, :, :]

    ang = np.linspace(0, 2 * np.pi, n_steps + 1)
    circ = np.column_stack((np.cos(ang), np.sin(ang), np.zeros(n_steps + 1)))
    jitter = np.concatenate(
        (np.zeros((1, 3, n)), np.cumsum(rng.standard_normal((n_steps, 3, n)), axis=0))
    )
    r2 = r0[None, :, :] + circ[:, :, None] + jitter / 30

    return r1, r1.mean(axis=2), r2, r2.mean(axis=2)


def com_demo_animation(
    n: int = 300,
    n_steps: int = 150,
    seed: Optional[int] = None,
    interval: float = 100.0,
) -> FuncAnimation:
    """Animate center-of-mass motion with and without relative motion.

    Shows the two systems from :func:`com_demo_trajectories` side by side:
    on the left, particles moving rigidly together; on the right, particles
    moving randomly relative to one another while drifting around a circle.
    In each panel the center of mass is drawn as a large black dot, with its
    path traced by a dashed line.

    Args:
        n (int):
            Number of particles. Defaults to 300.
        n_steps (int):
            Number of animation steps. Defaults to 150.
        seed (int, optional):
            Seed for the random particle cloud and motion. Defaults to None.
        interval (float):
            Delay between frames (ms). Defaults to 100.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play, and call ``plt.show()`` to display it
            interactively.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = com_demo_animation(seed=0)
        >>> plt.show()
    """
    r1, rg1, r2, rg2 = com_demo_trajectories(n, n_steps, seed)

    fig = plt.figure(1, figsize=(16, 8))
    fig.clf()
    artists = []
    for k, (r, rg, lim) in enumerate(((r1, rg1, (-1, 4)), (r2, rg2, (-2, 2)))):
        ax = fig.add_subplot(1, 2, k + 1, projection="3d")
        pts = ax.scatter(
            r[0, 0], r[0, 1], r[0, 2], s=30, c="b", alpha=0.25, depthshade=False
        )
        (com,) = ax.plot(rg[:1, 0], rg[:1, 1], rg[:1, 2], "k.", markersize=30)
        (trail,) = ax.plot(rg[:1, 0], rg[:1, 1], rg[:1, 2], "k--")
        ax.set_xlim(lim)
        ax.set_ylim(lim)
        ax.set_zlim(lim)
        ax.set_box_aspect((1, 1, 1))
        artists.append((pts, com, trail, r, rg))
    fig.tight_layout()

    def update(frame: int):
        """Advance the animation to step ``frame``.

        Args:
            frame (int):
                Index of the step to draw.

        Returns:
            list:
                The updated scatter, center-of-mass and trail artists of both
                panels.
        """
        out = []
        for pts, com, trail, r, rg in artists:
            pts._offsets3d = (r[frame, 0], r[frame, 1], r[frame, 2])
            com.set_data_3d(rg[frame : frame + 1].T)
            trail.set_data_3d(rg[: frame + 1].T)
            out.extend((pts, com, trail))
        return out

    return FuncAnimation(
        fig, update, frames=range(1, n_steps + 1), interval=interval, blit=False
    )
