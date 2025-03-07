% Demonstration of use of the curve fitting toolbox fit function
%
% NOTE: As of March 2025, there appears to be a critical issue with the fit
% function when running on Apple Silicon macs.  The observed behavior is
% that the call to the fit function ramps CPU usage to 100% on all cores,
% and then runs for an unreasonable long time.  There is not yet a fix, but
% a partial workaround is to execute (in MATLAB):
%
% >> maxNumCompThreads(1)
%
% This will avoid maxing out CPU and will generate results more quickly
% (although it will still take a while). 

% generate some fake data
x = linspace(0, 10,10000);
y = sin(x*20/2/pi);

% add some random noise
% create a random stream for repeatability
s = RandStream('mt19937ar','Seed',5);
% this will always contain the same 'random' values:
noise = randn(s,size(y)); 
ynoisy = y + noise*0.1;

figure(1)
clf
plot(x,ynoisy,'b')
hold on
plot(x,y,'c','LineWidth',3)
legend({'Noisy Measurement','True Data'})

% create a smoothing spline interpolation of the data (this has the effect
% of smoothing the noisy data set)
% note the required dimensionality of the inputs
f1 = fit(x.', ynoisy.', 'smoothingspline', 'SmoothingParam', 0.999);

% grab 1000 points from the spline
x1 = linspace(min(x),max(x),5000);
y1 = f1(x1);

figure(2)
clf
plot(x,ynoisy,'b')
hold on
plot(x1,y1,'c','LineWidth',3)
legend({'Noisy Data', 'Smoothing Spline'})

figure(3)
clf
plot(x,y,x1,y1,'LineWidth',2)
legend({'True Data', 'Smoothing Spline'})