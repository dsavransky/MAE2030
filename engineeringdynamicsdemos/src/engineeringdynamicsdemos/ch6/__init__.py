"""Chapter 6 demos: systems of particles, center of mass and collisions."""

from .cart_pendulum_animation import cart_pendulum_animation, cart_pendulum_trajectory
from .com_demo import com_demo_animation, com_demo_trajectories
from .rebound_box import rebound_box_animation, rebound_box_trajectory

__all__ = [
    "cart_pendulum_animation",
    "cart_pendulum_trajectory",
    "com_demo_animation",
    "com_demo_trajectories",
    "rebound_box_animation",
    "rebound_box_trajectory",
]
