%% Derivation of equations of motion for Kasdin & Paley Problem 11.11
%% Set up all constant and time varying values

syms R g l m_r 'positive'
syms N1 N2 N3 tau J psidd thdd 'real'
syms theta(t) psi(t) phi(t)
%% Set up standard DCMs

rotMatE3 = @(ang) [cos(ang) sin(ang) 0;-sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 -sin(ang);0 1 0;sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) sin(ang);0 -sin(ang) cos(ang)];
rotMats = {rotMatE1,rotMatE2,rotMatE3};
%% Define direction cosine matrices and angular velocities for $\psi$ rotation about $\mathbf{e}_3$ and $-\theta$  rotation about $\mathbf{b}_2$

bCi = rotMats{3}(psi) % I->B
cCb = rotMats{2}(-theta) % B->C
iWb = [0;0;diff(psi,t)] %B frame
bWc = [0;-diff(theta,t);0] %C frame
%% Apply Euler's second law to the disk, assuming planar moment of inertia $J$ about $\mathbf{b}_3$ - all in $\mathcal{B}$ frame

h_O = J*iWb
M_O = cross([0;R;0],[-N1;-N2;N3])
eq1 = (diff(h_O,t)+cross(iWb,h_O) ==  M_O)
eq1 = eq1(t)
psiddeom = solve(subs(eq1(3),diff(psi,t,t),psidd),psidd)
%% Rod kinematics in $\mathcal{B}$ frame components

r_GO = [0;R;0] + transpose(cCb)*[0;0;l/2]
v_GO = diff(r_GO,t)+cross(iWb,r_GO)
a_GO = simplify(diff(v_GO,t)+cross(iWb,v_GO))
%% Solve for Normal forces

a = a_GO(t)
Ns = solve(m_r*a == [N1;N2;m_r*g-N3],[N1,N2,N3],'ReturnConditions',true)
%% Parallel axis theorem to get MOI matrix for the rod about $Q$

r_QG = [0;0;-l/2]
I_Q = m_r*l^2/12*(eye(3) - diag([0,0,1])) + m_r*((transpose(r_QG)*r_QG)*eye(3) - r_QG*transpose(r_QG))
%% Calculate angular velocity and momentum about $Q$ in $\mathcal C$ frame components

iWc = bWc + cCb*iWb
h_Q = I_Q*iWc
%% Now apply Euler's second law for rod about $Q$ (all in $\mathcal C$ frame)

dh_Q = diff(h_Q,t)+ cross(iWc,h_Q)
M_Q = [tau;m_r*g*l/2*sin(theta);0]
r_QO = cCb*[0;R;0]
v_QO = diff(r_QO,t)+cross(iWc,r_QO)
a_QO = simplify(diff(v_QO,t)+cross(iWc,v_QO))
r_QG = [0;0;-l/2]
eq2 = dh_Q == (M_Q + m_r*cross(r_QG,a_QO))
eq2 = eq2(t)
tmp = solve(subs(eq2(2),diff(theta,t,t),thdd),thdd,'ReturnConditions',true)
thddeom = tmp.thdd
%% Final Equations of motion

tmp = subs([diff(psi,t,t) == subs(psiddeom,N1,Ns.N1);diff(theta,t,t)==thddeom],[diff(psi,t,t),diff(theta,t,t)],[psidd,thdd])
sol = solve(tmp,[psidd,thdd],'ReturnConditions',true)
%% As a last step, let's do some numerical integration
% We define the ODE state vector as $z = [\theta, \dot\theta, \psi, \dot\psi]^T$ 
% and will use the following values: $R = 2, l = 1.5, m_r = 3, J = 12, \theta(0) 
% = \pi/3, \dot\theta(0) = \dot\psi(0) = \psi(0) = 0.1$

syms th ps thd psd
dz = subs([thd;simplify(sol.thdd);psd;sol.psidd],[g,theta(t),diff(theta(t),t),psi(t),diff(psi(t),t)],[9.81,th,thd,ps,psd])
f1 = matlabFunction(dz,'vars',{th,thd,ps,psd,R,l,m_r,J})
f2 = @(t,z) f1(z(1),z(2),z(3),z(4),2.,1.5,3.,12)
[T,Z] = ode45(f2,linspace(0,10,1000),[pi/3,0,0,0.1]);
plot(T,Z(:,[1,3]))
grid on
ylabel('radians')
xlabel('Time (s)')
legend({'\theta','\psi'},'FontSize',16,'Location','best')