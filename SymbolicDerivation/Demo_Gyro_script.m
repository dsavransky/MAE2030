%% Demo Gyro Equations of Motion
% Symbolic derivation of equations in Example 11.13
% 
% First we set up all the variables

syms m M g I_1 I_2 I_p_1 h l l_p l_G 'positive' 
syms theta(t) psi(t) 
%% 
% Now the kinematics, all in the $\mathcal B$ frame

iWb_B = [diff(theta,t);diff(psi,t)*sin(theta);diff(psi,t)*cos(theta)]
r_QP_B = [0;-l;0]
r_Qm_B = [0;l_p;0]
r_QG_B = [0;-l_G;0]
%% 
% Now we find the total moment of inertia about $Q$

I_Q_B = diag([I_1,I_2,I_1]) +  M*((transpose(r_QP_B)*r_QP_B)*eye(3) - r_QP_B*transpose(r_QP_B))+m*((transpose(r_Qm_B)*r_Qm_B)*eye(3) - r_Qm_B*transpose(r_Qm_B))
I_Q_B = subs(I_Q_B,I_1+M*l^2 + m*l_p^2,I_p_1)
%% 
% We Calculate the moment about $Q$

M_Q_B = cross(-r_QG_B,[0; -(m+M)*g*sin(theta); -(m+M)*g*cos(theta)])
%% 
% And put together the final equation

h_Q_B = I_Q_B*iWb_B + [0;h;0]
eom1 = diff(h_Q_B)+ cross(iWb_B,h_Q_B) == M_Q_B
%% 
% And finally, solve for the scalar eoms

syms thdd psidd
eom2 = subs(eom1,[diff(psi,t,t),diff(theta,t,t)],[psidd,thdd])
eom3 = eom2(t)
psiddeq = solve(eom3(3),psidd,'ReturnConditions',true);
psiddeq = psiddeq.psidd
thddeq = solve(eom3(1),thdd,'ReturnConditions',true);
thddeq = thddeq.thdd
%% 
%