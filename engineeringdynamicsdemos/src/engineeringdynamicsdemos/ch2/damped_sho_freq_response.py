"""Frequency-response plot for a damped simple harmonic oscillator."""

import matplotlib.pyplot as plt
import numpy as np


def damped_sho_freq_response(z: float = 0.2) -> None:
    """Plot the annotated frequency-response curve of a damped SHO.

    Draws the non-dimensional amplitude response A(eta) of a damped simple
    harmonic oscillator as a function of the forcing-to-natural frequency
    ratio eta, annotated with the resonant frequency, peak amplitude, and
    half-power (-3 dB) points.

    Args:
        z (float):
            Damping ratio of the oscillator. Must satisfy
            0 < z < 1/sqrt(2) for a well-defined resonance peak (outside
            this range there is no interior amplitude peak). Defaults to
            0.2.

    Returns:
        None:
            Creates (clearing any prior contents of) a matplotlib figure
            showing the amplitude/frequency response curve; nothing is
            returned.

    Raises:
        ValueError:
            If ``z`` is not in the open interval (0, 1/sqrt(2)).
    """
    if not (0 < z < 1 / np.sqrt(2)):
        raise ValueError(
            "z must satisfy 0 < z < 1/sqrt(2) for a well-defined resonance "
            f"peak; got z={z}."
        )

    # Resonant frequency ratio and the peak amplitude reached there.
    wr = np.sqrt(1 - 2 * z**2)
    Amax = 1 / np.sqrt(1 - wr**4)

    # Amplitude response curve over a range of forcing frequency ratios.
    eta = np.linspace(0, 2, 1000)
    A = ((1 - eta**2) ** 2 + (2 * eta * z) ** 2) ** (-0.5)

    # Half-power (-3 dB) points, found as the closest sample to
    # Amax/sqrt(2) on each side of the resonance peak.
    half_power = Amax / np.sqrt(2)
    ind1 = np.argmin(np.abs(A[:500] - half_power))
    ind2 = np.argmin(np.abs(A[500:] - half_power)) + 500

    fig = plt.figure(1)
    fig.clf()
    ax = fig.add_subplot(1, 1, 1)
    ax.plot(eta, A, linewidth=2)
    ax.plot([0, 2], [Amax, Amax], "k--")
    ax.plot([0, 2], [half_power, half_power], "k--")
    ax.plot([wr, wr], [0, Amax * 1.1], "k--")
    ax.plot([eta[ind1], eta[ind1]], [0, half_power], "k--")
    ax.plot([eta[ind2], eta[ind2]], [0, half_power], "k--")

    # Place omega_1, omega_r, omega_2 as x-tick labels, unless the resonance
    # peak is narrow enough that the rendered labels would overlap, in which
    # case omega_1/omega_2 are moved into the plot area as text annotations
    # near their existing dashed vertical lines instead.
    ax.set_xticks([eta[ind1], wr, eta[ind2]])
    ax.set_xticklabels([r"$\omega_1$", r"$\omega_r$", r"$\omega_2$"])
    ax.tick_params(labelsize=18)

    # Force a draw so the tick labels have real rendered bounding boxes to
    # check for overlap against.
    fig.canvas.draw()
    renderer = fig.canvas.get_renderer()
    label1, label_r, label2 = ax.get_xticklabels()
    bbox1 = label1.get_window_extent(renderer)
    bbox_r = label_r.get_window_extent(renderer)
    bbox2 = label2.get_window_extent(renderer)
    if bbox1.overlaps(bbox_r) or bbox_r.overlaps(bbox2):
        ax.set_xticks([wr])
        ax.set_xticklabels([r"$\omega_r$"])
        label_y = 0.04 * Amax * 1.1
        # Anchor omega_1's label by its right edge and omega_2's label by its
        # left edge (rather than centering both), so the two labels are
        # pushed apart from each other even when eta[ind1] and eta[ind2] are
        # too close together for centered labels to avoid overlapping.
        ax.text(
            eta[ind1], label_y, r"$\omega_1$", ha="right", va="bottom", fontsize=18
        )
        ax.text(
            eta[ind2], label_y, r"$\omega_2$", ha="left", va="bottom", fontsize=18
        )

    ax.set_yticks([half_power, Amax])
    ax.set_yticklabels([r"$A_{max}/\sqrt{2}$", r"$A_{max}$"])
    ax.set_ylim(0, Amax * 1.1)
    ax.set_xlabel("Frequency", fontsize=18)
    ax.set_ylabel("Amplitude", fontsize=18)
