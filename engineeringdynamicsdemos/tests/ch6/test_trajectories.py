"""Analytic sanity tests for the Ch6 trajectory functions (no MATLAB needed)."""

import unittest

import numpy as np

from engineeringdynamicsdemos.ch6 import (
    cart_pendulum_trajectory,
    com_demo_trajectories,
    rebound_box_trajectory,
)


class TestCartPendulum(unittest.TestCase):
    """Checks the cart pendulum against its conserved quantities."""

    g, l, M, m = 9.81, 1.0, 2.0, 1.0

    def setUp(self) -> None:
        """Integrate a large-amplitude swing at tight tolerance."""
        self.t = np.linspace(0, 20, 400)
        self.res = cart_pendulum_trajectory(
            self.t,
            [0.0, 0.3, np.pi / 4, -0.5],
            method="DOP853",
            rtol=1e-11,
            atol=1e-12,
        )

    def test_conserves_energy(self) -> None:
        """Total mechanical energy is constant."""
        g, l, M, m = self.g, self.l, self.M, self.m
        _, xd, th, thd = self.res.T
        energy = (
            0.5 * M * xd**2
            + 0.5 * m * (xd**2 - 2 * l * xd * thd * np.sin(th) + l**2 * thd**2)
            + m * g * l * np.sin(th)
        )
        np.testing.assert_allclose(energy, energy[0], atol=1e-8)

    def test_conserves_horizontal_momentum(self) -> None:
        """Linear momentum along e1 is constant (no horizontal external force)."""
        l, M, m = self.l, self.M, self.m
        _, xd, th, thd = self.res.T
        momentum = (M + m) * xd - m * l * thd * np.sin(th)
        np.testing.assert_allclose(momentum, momentum[0], atol=1e-8)

    def test_upright_initial_condition(self) -> None:
        """upright=True starts at rest in the vertical position."""
        res = cart_pendulum_trajectory(np.linspace(0, 1, 11), upright=True)
        np.testing.assert_allclose(res[0], [0.0, 0.0, np.pi / 2, 0.0])
        np.testing.assert_allclose(res[:, 2], np.pi / 2, atol=1e-6)

    def test_upright_and_y0_conflict(self) -> None:
        """Passing both y0 and upright=True raises ValueError."""
        with self.assertRaises(ValueError):
            cart_pendulum_trajectory(y0=[0, 0, 0, 0], upright=True)


class TestComDemo(unittest.TestCase):
    """Checks the center-of-mass demo trajectories."""

    def test_shapes_and_centers_of_mass(self) -> None:
        """Outputs have the documented shapes and rg is the particle mean."""
        r1, rg1, r2, rg2 = com_demo_trajectories(n=50, n_steps=20, seed=1)
        self.assertEqual(r1.shape, (21, 3, 50))
        self.assertEqual(r2.shape, (21, 3, 50))
        self.assertEqual(rg1.shape, (21, 3))
        self.assertEqual(rg2.shape, (21, 3))
        np.testing.assert_allclose(rg1, r1.mean(axis=2))
        np.testing.assert_allclose(rg2, r2.mean(axis=2))

    def test_rigid_translation(self) -> None:
        """Without relative motion, the CoM moves in a straight line."""
        r1, rg1, _, _ = com_demo_trajectories(n_steps=150, seed=2)
        steps = np.arange(151)[:, None]
        np.testing.assert_allclose(rg1, rg1[0] + steps * np.ones(3) / 45)
        # Particle positions relative to the CoM never change.
        np.testing.assert_allclose(
            r1 - rg1[:, :, None],
            (r1 - rg1[:, :, None])[:1].repeat(151, axis=0),
            atol=1e-12,
        )

    def test_initial_cloud_in_unit_sphere(self) -> None:
        """Both systems start from the same cloud inside the unit sphere."""
        r1, _, r2, _ = com_demo_trajectories(seed=3)
        self.assertTrue(np.all(np.linalg.norm(r1[0], axis=0) <= 1))
        np.testing.assert_allclose(r2[0], r1[0] + np.array([[1.0], [0.0], [0.0]]))

    def test_seed_reproducible(self) -> None:
        """The same seed gives identical results."""
        for a, b in zip(com_demo_trajectories(seed=4), com_demo_trajectories(seed=4)):
            np.testing.assert_array_equal(a, b)


class TestReboundBox(unittest.TestCase):
    """Checks the collision sequence of the rebounding particle."""

    def test_collisions_on_wall(self) -> None:
        """Every collision point lies on the boundary of the box."""
        _, pos, _ = rebound_box_trajectory(e=0.8, n_bounces=20, L=5.0)
        np.testing.assert_allclose(np.max(np.abs(pos[1:]), axis=1), 5.0)

    def test_elastic_conserves_speed(self) -> None:
        """With e = 1 the speed is unchanged by every collision."""
        _, _, vel = rebound_box_trajectory(e=1.0)
        np.testing.assert_allclose(np.linalg.norm(vel, axis=1), np.hypot(10, 14))

    def test_restitution(self) -> None:
        """Normal velocity scales by -e; tangential velocity is unchanged."""
        e = 0.6
        _, pos, vel = rebound_box_trajectory(e=e, n_bounces=10)
        for k in range(1, 11):
            normal = int(np.argmax(np.abs(pos[k])))
            np.testing.assert_allclose(vel[k, normal], -e * vel[k - 1, normal])
            np.testing.assert_allclose(vel[k, 1 - normal], vel[k - 1, 1 - normal])

    def test_straight_line_segments(self) -> None:
        """Consecutive collisions are connected by constant-velocity motion."""
        times, pos, vel = rebound_box_trajectory()
        np.testing.assert_allclose(
            pos[1:], pos[:-1] + vel[:-1] * np.diff(times)[:, None], atol=1e-12
        )


if __name__ == "__main__":
    unittest.main()
