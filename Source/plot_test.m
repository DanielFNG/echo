rise = results.XTrace{:, 1};
peak = results.XTrace{:, 2};
fall = results.XTrace{:, 3};

figure
cmap = colormap;
% change c into an index into the colormap
% min(c) -> 1, max(c) -> number of colors
c = round(1+(size(cmap,1)-1)*(means - min(means))/(max(means)-min(means)));
% make a blank plot
plot3(rise,peak,fall,'linestyle','none')
% add line segments
for k = 1:(length(rise)-1)
    line(rise(k:k+1),peak(k:k+1),fall(k:k+1),'color',cmap(c(k),:))
end
colorbar