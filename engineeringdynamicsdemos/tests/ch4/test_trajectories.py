"""Analytic sanity tests for the Ch4 trajectory function (no MATLAB needed)."""

import unittest

import numpy as np

from engineeringdynamicsdemos.ch4 import kepler_orbit_trajectory


class TestTrajectories(unittest.TestCase):
    """Checks the Kepler-orbit trajectory against analytic/physical invariants."""

    def test_kepler_equation_residual(self) -> None:
        """The solved eccentric anomaly satisfies Kepler's equation."""
        n_steps = 250
        M = np.linspace(0, 2 * np.pi - 2 * np.pi / n_steps, n_steps)
        for e in (0.0, 0.1, 0.5, 0.9, 0.9999):
            _, _, E = kepler_orbit_trajectory(e, 1.0, n_steps)
            residual = np.max(np.abs(M - (E - e * np.sin(E))))
            self.assertLess(residual, 1e-9)

    def test_e_zero_is_circular(self) -> None:
        """With e=0 the orbit is a circle of radius a and E equals M."""
        n_steps = 100
        a = 1.0
        M = np.linspace(0, 2 * np.pi - 2 * np.pi / n_steps, n_steps)
        r, _, E = kepler_orbit_trajectory(0.0, a, n_steps)
        np.testing.assert_allclose(r[0] ** 2 + r[1] ** 2, a**2, atol=1e-12)
        np.testing.assert_allclose(E, M, atol=1e-12)

    def test_closed_ellipse_shape(self) -> None:
        """Every point lies on the ellipse of semi-axes a and b."""
        a = 1.0
        for e in (0.1, 0.5, 0.9):
            b = a * np.sqrt(1 - e**2)
            r, _, _ = kepler_orbit_trajectory(e, a, 250)
            shape = (r[0] / a) ** 2 + (r[1] / b) ** 2
            np.testing.assert_allclose(shape, 1.0, atol=1e-10)

    def test_conserves_specific_angular_momentum(self) -> None:
        """The scalar (r - focus) x v is constant along the orbit (Kepler's 2nd law).

        ``r`` is centered on the ellipse, not the focus, so angular momentum
        must be taken about the focus at ``(a*e, 0)`` for this invariant to
        hold.
        """
        a = 1.0
        for e in (0.0, 0.3, 0.7, 0.95):
            r, v, _ = kepler_orbit_trajectory(e, a, 250)
            r_focus = r - np.array([[a * e], [0.0]])
            h = r_focus[0] * v[1] - r_focus[1] * v[0]
            np.testing.assert_allclose(h, h[0], rtol=1e-8)


if __name__ == "__main__":
    unittest.main()
