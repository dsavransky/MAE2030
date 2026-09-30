"""Compare the Ch6 trajectory functions against the MATLAB originals."""

import unittest

import numpy as np

from engineeringdynamicsdemos.ch6 import cart_pendulum_trajectory

from ..matlab_test_case import MatlabEngineTestCase


class TestCh6AgainstMatlab(MatlabEngineTestCase):
    """Compares Python trajectories with MATLAB ``ode45`` results.

    ``cartPendulumAnimation.m`` integrates with ``ode45`` at its default
    tolerances (RelTol 1e-3), where the two implementations' truncation errors
    diverge unpredictably. As for the Ch3 pendulums, the comparison instead
    runs the same equations of motion in MATLAB and Python at matching tight
    tolerances.
    """

    MATLAB_RELATIVE_PATHS = ["Shared", "Ch6"]

    def test_cart_pendulum(self) -> None:
        """cart_pendulum_trajectory matches cartPendulumAnimation.m's ODE."""
        import matlab

        t = np.linspace(0, 5, 101)
        y0 = [0.0, 0.0, np.pi / 4, 0.0]
        self.eng.workspace["t"] = matlab.double(t.tolist())
        self.eng.workspace["y0"] = matlab.double(y0)
        self.eng.eval(
            "g=9.81; l=1; M=2; m=1; options=odeset('RelTol',1e-12,'AbsTol',1e-14);"
            "xdd=@(y)(m*l*y(4)^2*cos(y(3))-m*g*sin(y(3))*cos(y(3)))"
            "/(M+m*cos(y(3))^2);"
            "f=@(t,y)[y(2);xdd(y);y(4);-g/l*cos(y(3))+xdd(y)*sin(y(3))/l];"
            "[~,res]=ode45(f,t,y0,options);",
            nargout=0,
        )
        expected = np.array(self.eng.workspace["res"])
        np.testing.assert_allclose(
            cart_pendulum_trajectory(t, y0, method="DOP853", rtol=1e-12, atol=1e-14),
            expected,
            atol=1e-6,
        )


if __name__ == "__main__":
    unittest.main()
