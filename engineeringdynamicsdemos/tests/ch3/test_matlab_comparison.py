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

    ``simplePendulumAnimation.m`` and ``accelPendulumAnimation.m`` call ``ode45``
    with its default tolerances (RelTol 1e-3), which lets the two nonlinear
    pendulum ODEs accumulate on the order of 1e-2 rad of phase-drift error over
    just a few seconds - confirmed by rerunning those exact equations in MATLAB
    at tight tolerances and finding *that* result agrees with the default-
    tolerance one only to ~2e-2, while agreeing with the Python (tight-
    tolerance) trajectory to ~1e-8. So a numerically meaningful comparison has
    to hold both sides to the same (tight) tolerance rather than comparing
    Python against MATLAB's own default-tolerance integration error; the tests
    below do that via ``odeset`` on the same equations those two files define,
    rather than calling the default-tolerance ``ode45`` invocation inside them.
    """

    MATLAB_RELATIVE_PATHS = ["Shared", "Ch3"]

    def test_simple_pendulum(self) -> None:
        """simple_pendulum_trajectory matches simplePendulumAnimation.m's ODE.

        Compared at tight tolerance (see class docstring) rather than via a
        direct call to ``simplePendulumAnimation.m``, which only integrates at
        ``ode45`` default tolerances.
        """
        import matlab

        t = np.linspace(0, 5, 101)
        y0 = [np.pi / 3, 0.0]
        self.eng.workspace["t"] = matlab.double(t.tolist())
        self.eng.workspace["y0"] = matlab.double(y0)
        self.eng.eval(
            "g=9.81; l=1; options=odeset('RelTol',1e-12,'AbsTol',1e-14);"
            "[~,res]=ode45(@(t,y)[y(2);-g/l*sin(y(1))],t,y0,options);",
            nargout=0,
        )
        expected = np.array(self.eng.workspace["res"])
        np.testing.assert_allclose(
            simple_pendulum_trajectory(t, y0), expected, atol=1e-6
        )

    def test_accel_pendulum(self) -> None:
        """accel_pendulum_trajectories matches ode45 on the original ODEs.

        ``accelPendulumAnimation.m`` returns nothing (and always draws), so
        the reference is ``ode45`` run on the same ODEs directly, at tight
        tolerance (see class docstring).
        """
        import matlab

        t = np.linspace(0, 5, 101)
        y0 = [np.pi / 3, 0.0]
        self.eng.workspace["t"] = matlab.double(t.tolist())
        self.eng.workspace["y0"] = matlab.double(y0)
        self.eng.eval(
            "g=9.81; l=1; a=15; options=odeset('RelTol',1e-12,'AbsTol',1e-14);"
            "[~,rs]=ode45(@(t,y)[y(2);-g/l*sin(y(1))],t,y0,options);"
            "[~,ra]=ode45(@(t,y)[y(2);-g/l*sin(y(1))-a/l*cos(y(1))],t,y0,options);",
            nargout=0,
        )
        exp_s = np.array(self.eng.workspace["rs"])
        exp_a = np.array(self.eng.workspace["ra"])
        res_s, res_a = accel_pendulum_trajectories(False, t, y0)
        np.testing.assert_allclose(res_s, exp_s, atol=1e-6)
        np.testing.assert_allclose(res_a, exp_a, atol=1e-6)

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
