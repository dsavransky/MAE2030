"""Rigid body fixed in a rotating frame, animated in the inertial frame. See 3.4.2."""

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

# Approximate MATLAB ``parula`` colours at the colour indices used for the cube
# faces in the original (0, 0.5 and 1 on a [0, 1] colour axis).
_PARULA = {
    0.0: (0.2422, 0.1504, 0.6603),
    0.5: (0.1300, 0.7200, 0.6200),
    1.0: (0.9769, 0.9839, 0.0805),
}


def rotate_about_e3(points: npt.ArrayLike, angle_deg: float) -> npt.NDArray[np.float64]:
    """Rotate points about the (plot) x axis, i.e. the rotation axis e3.

    Applies a right-handed rotation about the x axis through the origin, like
    MATLAB's ``rotate(h, [1 0 0], angle, [0 0 0])``.

    Args:
        points (npt.ArrayLike):
            Array of shape ``(..., 3)`` of x, y, z coordinates.
        angle_deg (float):
            Rotation angle (degrees).

    Returns:
        npt.NDArray[np.float64]:
            Rotated points, same shape as ``points``.
    """
    c = np.cos(np.deg2rad(angle_deg))
    s = np.sin(np.deg2rad(angle_deg))
    rot = np.array([[1.0, 0.0, 0.0], [0.0, c, -s], [0.0, s, c]])
    return np.asarray(points, dtype=np.float64) @ rot.T


def rotating_frame_animation(step_deg: float = 1.0) -> FuncAnimation:
    """Animate a rigid body fixed in a frame rotating about e3.

    Reproduces the figure of Sec. 3.4.2: the inertial frame (blue/orange/yellow
    axes), a rotating frame B (red axes) and a cube fixed in B, which rotates
    through 360 degrees about the e3 axis as seen in the inertial frame.

    Args:
        step_deg (float):
            Rotation increment (degrees) between animation frames. Larger
            values give a shorter, faster-to-render animation. Defaults to 1.0.

    Returns:
        matplotlib.animation.FuncAnimation:
            The animation driving the figure. Callers must keep a reference
            to it alive for it to play.

    Example:
        >>> import matplotlib.pyplot as plt
        >>> anim = rotating_frame_animation()
        >>> plt.show()
    """
    th0 = 30.0  # initial angle of frame B relative to the inertial frame (deg)
    th0r = np.deg2rad(th0)
    fig = plt.figure(1, figsize=(8.5, 7))
    fig.clf()
    ax = fig.add_subplot(projection="3d")

    # Inertial frame axes: e3 along x, e1 along y, e2 along z.
    ax.plot([0, 0], [0, 0], [0, 1], linewidth=2)
    ax.plot([0, 0], [0, 1], [0, 0], linewidth=2)
    ax.plot([0, 1], [0, 0], [0, 0], linewidth=2)

    # Rotating frame axes at their initial orientation (th0 about e3).
    b1_end = np.array([0.0, -np.sin(th0r), np.cos(th0r)])  # drawn, labelled b2
    b2_end = np.array([0.0, np.cos(th0r), np.sin(th0r)])  # drawn, labelled b1
    (b1_line,) = ax.plot([0, 0], [0, 0], [0, 1], "r", linewidth=2)
    (b2_line,) = ax.plot([0, 0], [0, 0], [0, 1], "r", linewidth=2)

    # Cube, oriented by -th0 about its own centre, then carried with frame B.
    scale = 0.075
    x_f = np.array([[-1, -1, -1, -1, -1, 1], [1, -1, 1, 1, 1, 1],
                    [1, -1, 1, 1, 1, 1], [-1, -1, -1, -1, -1, 1]])  # fmt: skip
    y_f = np.array([[-1, -1, -1, -1, 1, -1], [-1, 1, -1, -1, 1, 1],
                    [-1, 1, 1, 1, 1, 1], [-1, -1, 1, 1, 1, -1]])  # fmt: skip
    z_f = np.array([[-1, -1, 1, -1, -1, -1], [-1, -1, 1, -1, -1, -1],
                    [1, 1, 1, -1, 1, 1], [1, 1, 1, -1, 1, 1]])  # fmt: skip
    faces_local = np.stack((x_f, y_f, z_f), axis=-1).transpose(1, 0, 2) * scale
    face_colors = [_PARULA[c] for c in (0.5, 1.0, 0.0, 0.0, 0.5, 1.0)]
    box_center = np.array([0.8, 0.5, 0.6])
    faces0 = rotate_about_e3(faces_local, -th0) + box_center
    cube = Poly3DCollection(
        faces0, facecolors=face_colors, edgecolors="k", linewidths=0.5
    )
    ax.add_collection3d(cube)
    (bvec,) = ax.plot([0, box_center[0]], [0, box_center[1]], [0, box_center[2]], "k")

    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    ax.set_zlim(-1.1, 1.1)
    ax.set_box_aspect((1, 1, 1), zoom=1.3)
    ax.set_position((0.0, 0.0, 1.0, 1.0))
    ax.view_init(elev=10, azim=20)  # MATLAB view(110, 10)
    ax.set_axis_off()

    # Fixed labels (inertial frame), then labels carried with frame B.
    fs = 18
    ax.text(1, -0.05, 0.05, r"$\mathbf{\hat{e}}_3$", fontsize=fs)
    ax.text(1, 0.07, 0, r"$\mathbf{\hat{b}}_3$", fontsize=fs)
    ax.text(0, 0.99, 0.03, r"$\mathbf{\hat{e}}_1$", fontsize=fs)
    ax.text(0, 0.02, 0.98, r"$\mathbf{\hat{e}}_2$", fontsize=fs)
    ax.text(0, -0.08, 1.01, r"$\mathcal{I}$", fontsize=fs)
    lb1_pos = np.array([0.0, np.cos(th0r), np.sin(th0r)])
    lb2_pos = np.array([0.0, -np.sin(th0r) + 0.025, np.cos(th0r)])
    lB_pos = np.array([0.0, -np.sin(th0r) - 0.075, np.cos(th0r) + 0.01])
    lb1 = ax.text(*lb1_pos, r"$\mathbf{\hat{b}}_1$", fontsize=fs)
    lb2 = ax.text(*lb2_pos, r"$\mathbf{\hat{b}}_2$", fontsize=fs)
    lB = ax.text(*lB_pos, r"$\mathcal{B}$", fontsize=fs)

    def update(angle: float):
        """Rotate frame B and everything fixed in it by ``angle`` degrees.

        Args:
            angle (float):
                Rotation (degrees) about e3 relative to the initial state.

        Returns:
            tuple:
                artists (tuple):
                    The updated matplotlib artists.
        """
        for line, end in ((b1_line, b1_end), (b2_line, b2_end)):
            e = rotate_about_e3(end, angle)
            line.set_data_3d([0, e[0]], [0, e[1]], [0, e[2]])
        cube.set_verts(rotate_about_e3(faces0, angle))
        e = rotate_about_e3(box_center, angle)
        bvec.set_data_3d([0, e[0]], [0, e[1]], [0, e[2]])
        for label, pos in ((lb1, lb1_pos), (lb2, lb2_pos), (lB, lB_pos)):
            label.set_position_3d(rotate_about_e3(pos, angle))
        return b1_line, b2_line, cube, bvec, lb1, lb2, lB

    angles = np.arange(0.0, 360.0 + step_deg / 2, step_deg)
    update(0.0)
    return FuncAnimation(fig, update, frames=angles, interval=20, blit=False)
