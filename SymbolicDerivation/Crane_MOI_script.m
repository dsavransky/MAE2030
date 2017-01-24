%% Calculating the Moment of Inertia of a Crane (Kasdin & Paley Example 11.16)
% The crane is modeled as a cab (solid cube of mass $M$and height $h$) and two 
% rigid links (rods of masses $m_1$ and $m_2$ and lengths $l_1$ and $l_2$, mounted 
% in the center of one face of the cube) that can rotate freely in plane.  The 
% entire structure can rotate about the center of the cab, so we are interested 
% in the total moment of inertia about this point.  We define a frame $\mathcal 
% A = (O, \mathbf{a}_1, \mathbf{a}_2, \mathbf{a_3})$ where $O$ is the center of 
% the cab and $\mathbf{a}_1$ points at the attachment point of the first rod ($O'$) 
% and frames $\mathcal{B}$ and $\mathcal{C}$ that rotate with the rods, with the 
% first component of each pointing along the rod length.
% 
% As usual, we start by defning all the required symbols

syms M h m_1 m_2 l_1 l_2 'positive'
syms theta_1 theta_2 'real'
%% 
% The cab is just a cube, so we can define it's MOI in frame $\mathcal A$ 
% as:

I_O_cab_A = M*2/3*h^2/4*eye(3)
%% 
% The links are rods, so we look up their MOI about the COM in their respective 
% frames, and then rotate and apply the parallel axis theorem to get them about 
% $O$ in frame $\mathcal A$ components

I_G1_m1_B = m_1*l_1^2/12*(eye(3) - diag([1,0,0]))
%% 
% We need the DCM to convert between frame $\mathcal A$ and $\mathcal B$:

aCb = [cos(theta_1),-sin(theta_1),0;sin(theta_1),cos(theta_1),0;0,0,1]
I_G1_m1_A = aCb*I_G1_m1_B*transpose(aCb)
%% 
% To apply the parallel axis theorem we also need to define $\mathbf{r}_{O/G_1}$:

r_O_G1 = aCb*[-l_1/2;0;0] + [-h/2;0;0]
I_O_m1_A = simplify(I_G1_m1_A + m_1*((transpose(r_O_G1)*r_O_G1)*eye(3) - r_O_G1*transpose(r_O_G1)))
%% 
% Now we do the exact same thing for $m_2$, except we are starting from 
% frame $\mathcal C$. We define the angle $\beta = \theta_1 + \theta_2$ to be 
% the angle between the two links:

b = theta_1 + theta_2
bCc = [cos(b),sin(b),0;-sin(b),cos(b),0;0,0,1]
aCc = simplify(aCb*bCc)
I_G2_m2_C = m_2*l_2^2/12*(eye(3) - diag([1,0,0]))
I_G2_m2_A = aCc*I_G2_m2_C*transpose(aCc)
r_O_G2 = aCc*[-l_2/2;0;0] + aCb*[-l_1;0;0] + [-h/2;0;0]
I_O_m2_A = simplify(I_G2_m2_A + m_2*((transpose(r_O_G2)*r_O_G2)*eye(3) - r_O_G2*transpose(r_O_G2)))
%% 
% The total moment of inertia will just be the sum of the inertias of the 
% three components

I_O_A = simplify(I_O_cab_A + I_O_m1_A + I_O_m2_A)
%% 
% Finally, if we wished to find the principal axis frame and fully diagonal 
% matrix of inertia, we just need to do an eignedecomposition of the MOI matrix 
% we just derived.  The eigenvalues will be the elements of the diagonal of the 
% principal axis moments, and the eigenvectors will form a DCM that rotates from 
% frame $\mathcal A$ into the principal axis frame.

[v,d] = eig(I_O_A)