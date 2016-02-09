function dampedSHO_freq_response(z)
% dampedSHO_freq_response draws an annotated plot of the frequency response
% curve for a damped simple harmonic oscillator. The free paramteter z
% represents the damping coefficient, set to a value of 0.2 by default

% Copyright (c) 2016 Dmitry Savransky (ds264@cornell.edu)

if ~exist('z','var') || isempty(z), z = 0.2; end

wr = sqrt(1 - 2*z^2);
Amax = 1/sqrt(1 - wr.^4);

eta = linspace(0,2,1000);
A = ((1 - eta.^2).^2 + (2*eta*z).^2).^(-0.5);

[~,ind1] = min(abs(A(1:500) - Amax/sqrt(2)));
[~,ind2] = min(abs(A(501:end) - Amax/sqrt(2)));
ind2 = ind2+500;

figure(1)
clf
plot(eta,A,'LineWidth',2)
hold on
plot([0,2],[Amax,Amax],'k--')
plot([0,2],[Amax,Amax]/sqrt(2),'k--')
plot([wr,wr],[0,Amax*1.1],'k--')
plot([eta(ind1),eta(ind1)],[0,Amax/sqrt(2)],'k--')
plot([eta(ind2),eta(ind2)],[0,Amax/sqrt(2)],'k--')
hold off

set(gca,'FontSize',18,'XTick',[eta(ind1),wr,eta(ind2)],...
    'XTickLabel',{'$\omega_1$','$\omega_r$','$\omega_2$'},...
    'YTick',[Amax/sqrt(2),Amax],'YTickLabel',...
    {'$A_{max}/\sqrt{2}$','$A_{max}$'},'TickLabelInterpreter','Latex')
ylim([0,Amax*1.1])
xlabel('Frequency')
ylabel('Amplitude')

end 