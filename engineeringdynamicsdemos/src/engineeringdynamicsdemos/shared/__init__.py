"""Shared utility functions used across chapter demos.

Direction-cosine-matrix functionality (originally ``Public/Shared/DCMs.m``)
is not ported here: use the ``angutils`` package's ``rotMat`` function
instead (https://pypi.org/project/angutils/), which computes identical
matrices under the same :math:`{}^{B}C^{A}` convention.
"""

from .draw_spring import draw_spring

__all__ = ["draw_spring"]
