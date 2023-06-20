function generate_EEG_1B(data, data_bip, data_bip_lab, info)

shift      = info.shift;                 
reftime    = info.reftime;                 
xlimits    = info.xlimits;                 
ylimits    = info.ylimits;                 
druginfo   = info.druginfo;                 
patientID  = info.patientID;                 

figure('Units','normalized','Position',[0 0 .8 .2],'visible','on')
% shift = 500e-6;
 
plot(data.Time, data_bip ,'k')
 

set(gca,'YTick',0, 'YTickLabel',flipud(data_bip_lab))

hold on
% axis
quiver( reftime-60, -2.5*shift, 60, 0,'k','ShowArrowHead','off')
hold on
quiver( reftime-60, -2.5*shift, 0, shift ,'k','ShowArrowHead','off')
text( reftime-80, -2.5*shift*1.1, '1 minute')
text( reftime-150, -2.5*shift*.8, [num2str(shift*1e6) ' \muV'])

text( data.Time(1)+30,  2.9*shift, ['patient ' patientID], 'fontsize',18)
 
hold on
line([1 1]*(data.Time(1)+1000),ylimits,'color','r','linestyle','--')
hold on
text(data.Time(1)+1020, 2.5*shift, druginfo,'fontsize',18, 'color','r')

set(gca,'XTick',[],'box','off')
xlim(xlimits)
ylim(ylimits)

ax1=gca;
ax2 = axes('Position',ax1.Position,...
  'XColor',[1 1 1],...
  'YColor',[1 1 1],... 
  'Color','none',...
  'XTick',[],...
  'YTick',[]);
 
 