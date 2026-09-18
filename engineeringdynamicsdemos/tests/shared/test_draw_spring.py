"""Tests for engineeringdynamicsdemos.shared.draw_spring against drawSpring.m."""

import unittest

import matlab
import numpy as np

from engineeringdynamicsdemos.shared.draw_spring import draw_spring

from ..matlab_test_case import MatlabEngineTestCase

_CASES = [
    # (p1, p2, nlink, ht)
    ((0.0, 0.0), (10.0, 10.0), 10, 1.0),  # defaults, diagonal
    ((0.0, 0.0), (5.0, 0.0), 10, 1.0),  # horizontal
    ((1.0, 2.0), (-3.0, 4.0), 6, 0.5),  # arbitrary, non-default ht
    ((0.0, 0.0), (1.0, 0.0), 7, 1.0),  # odd nlink -> forced even
    ((0.0, 0.0), (1.0, 0.0), 2, 1.0),  # nlink below min -> forced to 4
]


class TestDrawSpring(MatlabEngineTestCase):
    """Compares Python ``draw_spring`` against MATLAB ``drawSpring.m`` for a
    range of endpoint/nlink/ht combinations, including nlink edge cases.
    """

    MATLAB_RELATIVE_PATHS = ["Shared"]

    def test_matches_matlab_for_all_cases(self) -> None:
        """draw_spring(p1, p2, nlink, ht) matches drawSpring.m numerically.

        Asserts both exact shape agreement (catches off-by-one link-count
        translation bugs) and element-wise numeric agreement to within
        1e-9 absolute tolerance (tight, since both sides perform the same
        closed-form scale/rotate/translate arithmetic, so any larger
        discrepancy would indicate an actual formula bug rather than
        floating-point noise between MATLAB's and NumPy's libm).
        """
        for p1, p2, nlink, ht in _CASES:
            with self.subTest(p1=p1, p2=p2, nlink=nlink, ht=ht):
                expected = np.array(
                    self.eng.drawSpring(
                        matlab.double(p1), matlab.double(p2), nlink, ht
                    )
                )
                actual = draw_spring(p1, p2, nlink, ht)
                self.assertEqual(actual.shape, expected.shape)
                np.testing.assert_allclose(actual, expected, atol=1e-9)


if __name__ == "__main__":
    unittest.main()
