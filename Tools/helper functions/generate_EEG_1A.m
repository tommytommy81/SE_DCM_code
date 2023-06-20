function generate_EEG_1A(data, data_bip, data_bip_lab, shift, reftime, xlimits)

 

figure('Units','normalized','Position',[0 0 .8 1],'visible','on')
% shift = 500e-6;
for ch = 1:size(data_bip,1)
    plot(data.Time, data_bip(ch,:)-shift*ch,'k')
    hold on
end

set(gca,'YTick',[-ch:-1 ]*shift, 'YTickLabel',flipud(data_bip_lab))

% axis
quiver( reftime-2, 0,  1, 0,'k','ShowArrowHead','off')
hold on
quiver( reftime-2, 0, 0, shift ,'k','ShowArrowHead','off')
text( reftime-1.8, -shift/6, '1 s')
text( reftime-3.5, shift/2, [num2str(shift*1e6) ' \muV'])

set(gca,'XTick',[],'box','off')
xlim(xlimits)
 
ax1=gca;
ax2 = axes('Position',ax1.Position,...
  'XColor',[1 1 1],...
  'YColor',[1 1 1],... 
  'Color','none',...
  'XTick',[],...
  'YTick',[]);
 