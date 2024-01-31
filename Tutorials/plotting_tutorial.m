% MATLAB provides extensive functionality for creating plots of all kinds

%% 2D line plots

% line and scatter plots in 2D can be generated via the plot function

% the figure command creates a figure. if omitted, the last used figure
% will be re-used. If not figure exists, a new one will be created
% automatically on the first plot command
figure(1) 
clf % this clears any existing content in the figure

% generate some data
x = linspace(0,2*pi,100);
y = cos(x);

% plot the results
plot(x,y)

% issuing a new plot command will overwrite the figure contents:
plot(x, y.^2)

% you can put multiple curves into a single plot command:
plot(x,y, x, y.^2)

% alternatively, you can use the hold command:
plot(x,y)
hold on % save previous plot content
plot(x, y.^2)
hold off % clear previous plot content upon next plot command

% Note that MATLAB's hold behavior is opposite of Python's matplotlib
% hold is off by default

% curves can be customized with colors, linestyles and symbols
help plot

plot(x, y, 'r')
hold on
plot(x, y.^2, 'b.')
plot(x,y.^3, 'kp-')

% there are a bunch of other options as well
p1 = plot(x,abs(y), 'Linewidth', 3);
hold off

% we can explore all of these options by inspecting the generated plot
% object
p1

% once we're happy with the contents of our plot, it's time to label
% everything
xlabel('This sets the x-axis label')
ylabel('This sets the y-axis label')
title('This sets the title')

% that text looks a little small. Fortunately, we can change the font size
% for everything all at once. 
set(gca,'FontSize',18) % gca returns the current axis object

% multiple curves require a legend
legend({'y', 'y^2','y^3','| y |'})
% the {...} syntax creates a cell array - this is MATLAB's way of storing
% different objects (or strings of different lengths) in a single array

% not loving that legend location. let's put it somewhere else
legend({'y', 'y^2','y^3','| y |'}, 'Location', 'southwest')

%% Subplots

% While you can always create multiple figures to get multiple axes to plot
% in, sometimes you may wish to create multiple axes in a single figure.
% this is enabled by the subplot command.
% subplot is called as subplot(m,n,p) - this creates an mxn grid of axes,
% and selects the pth one

figure(2)
subplot(2,2,1)
plot(x, y, 'r')

subplot(2,2,2)
plot(x, y.^2, 'b.')

subplot(2,2,3)
plot(x,y.^3, 'kp-')

subplot(2,2,4)
plot(x,abs(y), 'Linewidth', 3)

% note that the label commands apply to the last used subplot
xlabel('This sets the x-axis label')
ylabel('This sets the y-axis label')
title('This sets the title')

% we can always go back, though:
subplot(2,2,1)
title('This is a different title')