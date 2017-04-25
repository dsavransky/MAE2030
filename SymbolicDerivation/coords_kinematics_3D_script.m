%% 3D Coordinates and Kinematics Derivations
% This script demonstrates how to derive the direction cosine (rotation) matrices 
% and angular velocities associated with standard Euler Angle sets.

syms theta(t) phi(t) psi(t); %define three angles as functions of time
%define the standard three rotation matrices about
rotMatE3 = @(ang) [cos(ang) sin(ang) 0;-sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 -sin(ang);0 1 0;sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) sin(ang);0 -sin(ang) cos(ang)];
rotMats = {rotMatE1,rotMatE2,rotMatE3};
%% Spherical Frame - $\theta$ rotation about $\mathbf{e}_3$ followed by a $\phi$ rotation about $\mathbf{c}_2$

cCi = rotMats{3}(theta)
sCc = rotMats{2}(phi)
%% 
% $${}^\mathcal{B}C^{\mathcal{I}} ={}^\mathcal{B}C^{\mathcal{C}}{}^\mathcal{C}C^{\mathcal{A}}{}^\mathcal{A}C^{\mathcal{I}}$$

sCi = sCc*cCi
%% 
% Angular Velocity ${}^{\mathcal{I}}{\omega}^\mathcal{S} =  \dot\phi \mathbf{e}_\theta 
% + \dot\theta \mathbf{e}_3$

iWs = sCi*[0;0;diff(theta,t)] + [0;diff(phi,t);0]
%% 3-2-3 $(\psi,\theta,\phi)^{\mathcal{I}}_{\mathcal{B}}$ Euler Angles - $\psi$ rotation about $\mathbf{e}_3$ followed by a $\theta$ rotation about $\mathbf{a}_2$ followed by a $\phi$ rotation about $\mathbf{c}_3$

aCi = rotMats{3}(psi)
cCa = rotMats{2}(theta)
bCc = rotMats{3}(phi)
%% 
% $${}^\mathcal{B}C^{\mathcal{I}} ={}^\mathcal{B}C^{\mathcal{C}}{}^\mathcal{C}C^{\mathcal{A}}{}^\mathcal{A}C^{\mathcal{I}}$$

bCi = bCc*cCa*aCi
%% 
% 3-2-3 $(\psi,\theta,\phi)^{\mathcal{I}}_{\mathcal{B}}$ Euler Angles - 
% Angular velocity  ${}^{\mathcal{I}}{\omega}^\mathcal{B} =  \dot\psi \mathbf{a}_3 
% + \dot\theta \mathbf{c}_2 + \dot\phi \mathbf{b}_3$, expressed in $\mathcal{B}$ 
% frame components

iWb = diff(psi,t)*bCi*[0;0;1] + diff(theta,t)*bCc*[0;1;0] +  diff(phi,t)*[0;0;1]
%% 
% Defining ${}^{\mathcal{I}}{\omega}^\mathcal{B} =  \omega_1 \mathbf{b}_1 
% + \omega_2 \mathbf{b}_2 + \omega_3 \mathbf{b}_3$ And solving for $\dot\psi,\dot\theta,\dot\phi$ 
% in terms of $\omega_1,\omega_2\omega_3$

syms psid thd phd omega_1 omega_2 omega_3 'real'
anglerates = solve(subs((iWb==[omega_1;omega_2;omega_3]),[diff(psi,t),diff(theta,t),diff(phi,t)],[psid,thd,phd]),[psid,thd,phd],'ReturnConditions',true)
simplify(anglerates.psid)
simplify(anglerates.thd)
simplify(anglerates.phd)