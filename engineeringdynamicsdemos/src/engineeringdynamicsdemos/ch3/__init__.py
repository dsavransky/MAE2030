"""Chapter 3 demos: pendulums and rotating/accelerating reference frames."""

from .accel_pendulum_animation import (
    accel_pendulum_animation,
    accel_pendulum_trajectories,
)
from .compare_simple_pendulum_sho import (
    compare_simple_pendulum_sho,
    simple_pendulum_sho_trajectory,
)
from .rotating_frame_animation import rotating_frame_animation
from .simple_pendulum_animation import (
    simple_pendulum_animation,
    simple_pendulum_trajectory,
)
from .spring_pendulum_animation import (
    spring_pendulum_animation,
    spring_pendulum_trajectory,
)

__all__ = [
    "accel_pendulum_animation",
    "accel_pendulum_trajectories",
    "compare_simple_pendulum_sho",
    "rotating_frame_animation",
    "simple_pendulum_animation",
    "simple_pendulum_sho_trajectory",
    "simple_pendulum_trajectory",
    "spring_pendulum_animation",
    "spring_pendulum_trajectory",
]
