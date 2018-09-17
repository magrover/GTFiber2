function [hf, Fim] = plotS2D_fixed(ims,figSave)

% Hard coded figure settings that look nice
if ispc
    font=16;
    flfont=14;
    flpos=[0.7, 0.85];
    position = [227  413  599  569];
else
    font=20;
    flfont=16;
    flpos=[0.8, 0.93];
    position = [390   143   700   650];
end
marker = 7;
markerline = 1;
line = 1.25;
lenscale = 1000;
edgedark = 0;
edgewidth = 0.75;

% Initialize figure
hf=figure;

ax = gca;
hold(ax,'on');

frames = ims.op2d_fixed.xdata ./ 1000;

p1 = plot(ax,frames,ims.op2d_fixed.S_im,'ok');
p2 = plot(frames,zeros(size(frames)),'--k');

% Make things look nice
xlabel('Frame Size (�m)');
ylabel('{\itS}_{2D}')
ax.FontSize = font;
ax.XLim = [0 ceil(frames(end))];
ax.Box = 'on';
ax.LineWidth = 0.75;
ax.PlotBoxAspectRatio = [1 1 1];
ax.YLim = [-0.5 0.5];
ax.TickLength = [0.015, 0.015];
p1.LineWidth = markerline;
p1.MarkerSize = marker;
p2.LineWidth = line;
% p(2).LineWidth = line; p(2).Color = [1, 0, 0];

htex = text('Units', 'normalized', 'Position', flpos, ...
    'BackgroundColor', [1 1 1], ...
    'String', ['{\itS}_{2D} = ', num2str(ims.op2d_fixed.S2D,2)],...
    'FontSize', flfont,...
    'EdgeColor', edgedark*[1 1 1],...
    'LineWidth', edgewidth);

hf.Position=position;

F = getframe(hf);
Fim = F.cdata;

if figSave
    fig_file = [ims.figSavePath, '_OP2D_fixed', '.tif'];
    ensure_dir(fig_file);
    hgexport(hf, fig_file,  ...
        hgexport('factorystyle'), 'Format', 'tiff');
    close(hf)
end

end
