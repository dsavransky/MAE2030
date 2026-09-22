"""Compare the Ch3 trajectory functions against the MATLAB originals."""

import unittest

import numpy as np

from engineeringdynamicsdemos.ch3 import (
    accel_pendulum_trajectories,
    simple_pendulum_trajectory,
    spring_pendulum_trajectory,
)

from ..matlab_test_case import MatlabEngineTestCase


class TestCh3AgainstMatlab(MatlabEngineTestCase):
    """Compares Python trajectories with MATLAB ``ode45`` results.

    The simple and accelerating pendulum originals use ``ode45`` default
    tolerances (RelTol 1e-3), so the Python results (tight tolerances) are only
    expected to agree with them to about 1e-2 over the short spans used here.
    """

    MATLAB_RELATIVE_PATHS = ["Shared", "Ch3"]

    def test_simple_pendulum(self) -> None:
        """simple_pendulum_trajectory matches simplePendulumAnimation.m."""
        import matlab

        t = np.linspace(0, 5, 101)
        y0 = [np.pi / 3, 0.0]
        expected = np.array(
            self.eng.simplePendulumAnimation(
                matlab.double(t.tolist()), matlab.double(y0), False
            )
        )
        np.testing.assert_allclose(
            simple_pendulum_trajectory(t, y0), expected, atol=1e-2
        )

    def test_accel_pendulum(self) -> None:
        """accel_pendulum_trajectories matches ode45 on the original ODEs.

        ``accelPendulumAnimation.m`` returns nothing (and always draws), so
        the reference is ``ode45`` run on the same ODEs directly.
        """
        t = np.linspace(0, 5, 101)
        y0 = [np.pi / 3, 0.0]
        self.eng.workspace["t"] = __import__("matlab").double(t.tolist())
        self.eng.workspace["y0"] = __import__("matlab").double(y0)
        self.eng.eval(
            "g=9.81; l=1; a=15;"
            "[~,rs]=ode45(@(t,y)[y(2);-g/l*sin(y(1))],t,y0);"
            "[~,ra]=ode45(@(t,y)[y(2);-g/l*sin(y(1))-a/l*cos(y(1))],t,y0);",
            nargout=0,
        )
        exp_s = np.array(self.eng.workspace["rs"])
        exp_a = np.array(self.eng.workspace["ra"])
        res_s, res_a = accel_pendulum_trajectories(False, t, y0)
        np.testing.assert_allclose(res_s, exp_s, atol=1e-2)
        np.testing.assert_allclose(res_a, exp_a, atol=1e-2)

    def test_spring_pendulum(self) -> None:
        """spring_pendulum_trajectory matches springPendulumAnimation.m."""
        import matlab

        t = np.linspace(0, 5, 101)
        y0 = [0.5, 0.0, np.pi / 3, 0.0]
        expected = np.array(
            self.eng.springPendulumAnimation(
                matlab.double(t.tolist()), matlab.double(y0), False
            )
        )
        np.testing.assert_allclose(
            spring_pendulum_trajectory(t, y0), expected, atol=1e-6
        )


if __name__ == "__main__":
    unittest.main()
