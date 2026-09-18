"""Shared unittest base class for tests comparing Python output against
MATLAB ground truth via the MATLAB Engine API for Python.
"""

import os
import unittest
from pathlib import Path
from typing import ClassVar, List, Optional

# Repository root (Public/), computed relative to this file's location:
# Public/engineeringdynamicsdemos/tests/matlab_test_case.py -> parents[2]
_PUBLIC_ROOT = Path(__file__).resolve().parents[2]


class MatlabEngineTestCase(unittest.TestCase):
    """Base class for tests that need a running MATLAB engine.

    Subclasses set ``MATLAB_RELATIVE_PATHS`` to the list of directories
    (relative to the repository's ``Public/`` root) that must be on the
    MATLAB path for the ``.m`` functions under test to run (e.g.
    ``["Shared"]``). Starting the MATLAB engine is expensive, so one
    shared engine instance is started per test class in ``setUpClass``
    rather than per test.

    If the ``MATLAB_ROOT`` environment variable is unset, does not point
    to an existing directory, ``matlabengine`` is not installed, or the
    MATLAB engine otherwise fails to start, the whole test class is
    skipped with a message explaining how to fix the environment, rather
    than failing with an opaque error.
    """

    MATLAB_RELATIVE_PATHS: ClassVar[List[str]] = []
    eng: ClassVar[Optional[object]] = None

    @classmethod
    def setUpClass(cls) -> None:
        """Start a shared MATLAB engine and add required paths.

        Reads ``MATLAB_ROOT`` from the environment to locate the MATLAB
        installation, skipping the test class (via ``unittest.SkipTest``)
        if it is unset/invalid or the engine fails to start.
        """
        matlab_root = os.environ.get("MATLAB_ROOT")
        if not matlab_root:
            raise unittest.SkipTest(
                "MATLAB_ROOT environment variable is not set; skipping "
                "MATLAB-engine-based tests. Set MATLAB_ROOT to your "
                "MATLAB installation, e.g. "
                "MATLAB_ROOT=/Applications/MATLAB_R2025b.app"
            )
        if not Path(matlab_root).is_dir():
            raise unittest.SkipTest(
                f"MATLAB_ROOT={matlab_root!r} does not exist; skipping "
                "MATLAB-engine-based tests."
            )
        try:
            import matlab.engine
        except ImportError as exc:
            raise unittest.SkipTest(
                "matlabengine is not installed; install the 'test' extra "
                "(pip install '.[test]') to run MATLAB-engine-based tests."
            ) from exc
        try:
            cls.eng = matlab.engine.start_matlab()
        except Exception as exc:
            raise unittest.SkipTest(
                f"Failed to start MATLAB engine using MATLAB_ROOT="
                f"{matlab_root!r}: {exc}"
            ) from exc
        for rel in cls.MATLAB_RELATIVE_PATHS:
            cls.eng.addpath(str(_PUBLIC_ROOT / rel), nargout=0)

    @classmethod
    def tearDownClass(cls) -> None:
        """Shut down the shared MATLAB engine started in ``setUpClass``."""
        if cls.eng is not None:
            cls.eng.quit()
