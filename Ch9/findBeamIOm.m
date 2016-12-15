function res = findBeamIOm(x)

[~,y] = particleOnBeamAnimation(x);

res = abs(y(1,1) - y(end,1));

end
