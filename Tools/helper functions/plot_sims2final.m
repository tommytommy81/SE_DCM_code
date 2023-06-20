%% 
function plot_sims2final(sim20, sims, options)
    

colormap hot
cols   = 'rmbc'
sqtype = 'YlOrRd';%YlGnBu
gris = (uint8(255*cbrewer('seq', sqtype, size(sim20,2))));

ax1 = 1:size(sim20,1);
ax2 = 1:size(sim20,2);

legendrealdata = options.legendrealdata;

figure, 
    subplot(121)
%     imagesc(ax1, ax2, -sign(sim20(end,end)-sim20(1,1))*sim20)
    imagesc(ax1, ax2,  flipud(sim20))
    ylabel(options.label1)
    xlabel(options.label2)
    set(gca,'XTick',[],'YTick',[])
    colormap hot
    clim([ -8 -2])
    colorbar
     
    subplot(122)
    for i = 1:size(options.ICMPsd,2)
        plot(options.ICMPsd(:,i),'color',cols(i),'LineWidth',2)
        hold on
    end
    

    for e = 1:length(ax1)
        if options.diagonal == 1
            plot(sims{e,e} ,'color',gris(e,:))
        else
            plot(sims{e,length(ax1)-e+1},'color',gris(e,:))
        end
        hold on
    end
    ylabel('log Power [dB]')
    xlabel('Frequency [Hz]')
    legend(legendrealdata)
    axis([0 45 -10 2])
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 .5 .8 .5]);
    saveas(gcf,[options.F.today filesep options.figurename '2.tiff'])

end



