"""Analytic sanity tests for the Ch3 trajectory functions (no MATLAB needed)."""

import unittest

import numpy as np

from engineeringdynamicsdemos.ch3 import (
    accel_pendulum_trajectories,
    simple_pendulum_sho_trajectory,
    simple_pendulum_trajectory,
    spring_pendulum_trajectory,
)


class TestTrajectories(unittest.TestCase):
    """Checks trajectory functions against analytic/physical invariants."""

    def test_small_angle_matches_sho(self) -> None:
        """A small-amplitude pendulum matches the linearized SHO solution."""
        t = np.linspace(0, 10, 150)
        y0 = [1e-3, 0.0]
        res = simple_pendulum_trajectory(t, y0)
        theta, thetad = simple_pendulum_sho_trajectory(t, y0)
        np.testing.assert_allclose(res[:, 0], theta, atol=1e-6)
        np.testing.assert_allclose(res[:, 1], thetad, atol=1e-5)

    def test_stationary_accel_pendulum_is_at_rest(self) -> None:
        """The accelerating pendulum stays at -atan(a/g) when stationary."""
        t = np.linspace(0, 10, 100)
        _, res_accel = accel_pendulum_trajectories(True, t)
        np.testing.assert_allclose(res_accel[:, 0], -np.arctan(15 / 9.81), atol=1e-8)
        np.testing.assert_allclose(res_accel[:, 1], 0.0, atol=1e-8)

    def test_spring_pendulum_conserves_energy(self) -> None:
        """Total mechanical energy of the spring pendulum is constant."""
        g, x0, m, k = 9.81, 0.1, 0.1, 2.0
        t = np.linspace(0, 10, 400)
        res = spring_pendulum_trajectory(t)
        r, rd, th, thd = res.T
        energy = (
            0.5 * m * (rd**2 + (r * thd) ** 2)
            + 0.5 * k * (r - x0) ** 2
            - m * g * r * np.cos(th)
        )
        np.testing.assert_allclose(energy, energy[0], rtol=1e-7)


if __name__ == "__main__":
    unittest.main()
