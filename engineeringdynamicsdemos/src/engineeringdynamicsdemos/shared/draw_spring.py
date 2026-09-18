"""Coordinate generator for plotting a schematic zig-zag spring."""

import numpy as np
import numpy.typing as npt


def draw_spring(
    p1: npt.ArrayLike,
    p2: npt.ArrayLike,
    nlink: int = 10,
    ht: float = 1.0,
) -> npt.NDArray[np.float64]:
    """Compute (x, y) coordinates for plotting a zig-zag spring.

    Traces a spring shape from ``p2`` to ``p1``, scaled to the Euclidean
    distance between the two endpoints and rotated to align with the
    p1-p2 direction, for use as ``matplotlib`` line-plot coordinates.

    Args:
        p1 (npt.ArrayLike):
            (x, y) coordinates of the spring endpoint the zig-zag pattern
            terminates at, as a length-2 sequence.
        p2 (npt.ArrayLike):
            (x, y) coordinates of the spring endpoint the zig-zag pattern
            originates from, as a length-2 sequence.
        nlink (int):
            Number of links in the spring. Values below 4 are clipped up
            to 4, and odd values are incremented by 1 to the nearest even
            number. Defaults to 10.
        ht (float):
            Half-height (in data/plot units) of each zig-zag link.
            Defaults to 1.0.

    Returns:
        npt.NDArray[np.float64]:
            2xN array of (x, y) coordinates describing the spring shape.
            N depends on ``nlink`` (N = 7 + 3*(nlink/2 - 2); N = 16 for the
            default ``nlink=10``).

    Example:
        >>> import matplotlib.pyplot as plt
        >>> sprng = draw_spring([0, 0], [10, 10])
        >>> plt.plot(sprng[0, :], sprng[1, :])
        >>> plt.axis("equal")
    """
    p1 = np.asarray(p1, dtype=np.float64).flatten()
    p2 = np.asarray(p2, dtype=np.float64).flatten()

    # Clip nlink to a minimum of 4 and round up to the nearest even number.
    if nlink < 4:
        nlink = 4
    if nlink % 2 != 0:
        nlink = nlink + 1

    # Length and orientation of the line from p2 to p1.
    dp = p1 - p2
    length = np.sqrt(np.sum(dp**2))
    th = np.arctan2(dp[1], dp[0])
    R = np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])

    # One zig-zag "tooth": a 2x3 block of (x, y) offsets spanning an x-width
    # of 2, with the y-coordinate alternating +ht, -ht, +ht.
    tri = np.array([[0.0, 1.0, 2.0], [ht, -ht, ht]])

    # Build the spring in an unscaled local frame: a short straight lead-in
    # stub starting at local x = -1, followed by zig-zag teeth tiled
    # left-to-right, followed by a straight lead-out stub.
    sprng = np.hstack((np.array([[-1.0, -np.tan(np.pi / 6)], [0.0, 0.0]]), tri))
    for _ in range(nlink // 2 - 2):
        shift = np.array([[sprng[0, -1]], [0.0]])
        sprng = np.hstack((sprng, tri + shift))
    sprng = np.hstack(
        (
            sprng,
            np.array([[sprng[0, -1] + np.tan(np.pi / 6), sprng[0, -1] + 1.0], [0.0, 0.0]]),
        )
    )

    # Rescale the local x-axis (which runs from -1 to sprng[0, -1]) onto
    # [0, length], then rotate to align with the p2->p1 direction and
    # translate so the spring starts exactly at p2.
    sprng[0, :] = (sprng[0, :] + 1) / (sprng[0, -1] + 1) * length
    sprng = R @ sprng
    sprng = sprng + p2.reshape(2, 1)

    return sprng
