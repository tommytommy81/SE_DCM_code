figure('Units','normalized','Position',[0 0.2 .2*Figwidth .5],'visible','on')

    
    Nparams = length(PEB.Pind)
    Params_id = PEB.Pind-5; % T(1) is the the 6th

    Labels = {'T_s_s', 'T_s_p', 'T_i_i', 'T_d_p',...
        'G_s_p', 'G_s_p_-_s_s', 'G_i_i_-_s_s', 'G_i_i', 'G_s_s_-_i_i', ...
        'G_d_p_-_i_i', 'G_s_s_-_d_p', 'G_i_i_-_d_p', 'G_d_p', 'G_s_s', }


    Tcon  = 1:4;
    Gmod  = [1 4 9 10]+4;
    Gexc  = [5 6 7 ]+4;
    Gihn  = [2 3 8]+4;

    Ep_idx = [Tcon Gmod Gexc  Gihn ];
    try
    checkciao =  setxor(Ep_idx,PEB.Pind-5)';
    
    Tcon(find(ismember(Tcon,checkciao)))  = [];
    Gmod(find(ismember(Gmod,checkciao)))  = [];
    Gexc(find(ismember(Gexc,checkciao)))  = [];
    Gihn(find(ismember(Gihn,checkciao)))  = [];

    
    catch
    checkciao = []
    end
    Ep_idx = [Tcon Gmod Gexc  Gihn ];

    idx1 = 1:length(Tcon);
    idx2 = length(Tcon)+1:length([Tcon Gmod]);
    idx3 = length([Tcon Gmod])+1:length([Tcon Gmod Gexc]);
    idx4 = length([Tcon Gmod Gexc])+1:length(Ep_idx);


    Ep_all = PEB.Ep(1:Nparams,:);
    Ep_red = reshape(PMA.Ep,Nparams,[])
    Ep_red = Ep_red(1:Nparams,:);
    Cp_rec = reshape(diag(PMA.Cp),Nparams,[])
    Cp_rec = Cp_rec(1:Nparams,:);
    
    
    for i = 2:cols

%         subplot(2,cols,i),
        subplot(2,cols-1,i-1) 
            bar(idx1,Ep_all(idx1,i),'facecolor','b');
            hold on, bar(idx2,Ep_all( idx2,i),'facecolor','g');
            hold on, bar(idx3,Ep_all( idx3,i),'facecolor','c');
            hold on, bar(idx4,Ep_all( idx4,i),'facecolor','m');
            set(gca,'XTick',1:Nparams,'XTickLabel',[Labels(Tcon) Labels(Gmod) Labels(Gexc) Labels(Gihn)],'XTickLabelRotation',90)
            ylim([-1 1]*1.1*max(max(abs(Ep_all))))
            title(strrep(PEB.Xnames(i),'_',' '))
                        set(gca,'box','off')

            if i == 2, ylabel ('Full PEB model'), end
% 
        subplot(2,cols-1,i-1+cols-1) 
            bar(idx1,Ep_red(idx1,i),'facecolor','b');
            hold on, bar(idx2,Ep_red( idx2,i),'facecolor','g');
            hold on, bar(idx3,Ep_red( idx3,i),'facecolor','c');
            hold on, bar(idx4,Ep_red( idx4,i),'facecolor','m');
            set(gca,'XTick',1:Nparams,'XTickLabel',[Labels(Tcon) Labels(Gmod) Labels(Gexc) Labels(Gihn)],'XTickLabelRotation',90)
            ylim([-1 1]*1.1*max(max(abs(Ep_red))))
            title(strrep(PEB.Xnames(i),'_',' '))
            set(gca,'box','off')
            if i == 2, ylabel ('Reduced PEB model'), end


        
    end

    %% with SE

    titles = {'Responsiveness',
        'Benzodiazepine',
        'Responsiveness to Benzodiazepine'}
    figure('Units','normalized','Position',[0 0.2 .7 .4],'visible','on')
    for col = 1:3
    subplot(1,3,col),spm_plot_ci(Ep_red(:,col+1), Cp_rec(:,col+1))
    set(gca,'XTick',1:Nparams,'XTickLabel',[Labels(Tcon) Labels(Gmod) Labels(Gexc) Labels(Gihn)],...
        'XTickLabelRotation',45, 'YTick', [-1.5:.5:1.5])
            ylim([-1 1]*2*max(max(abs(Ep_red))))
%             title(strrep(PEB.Xnames(col+1),'_',' '),'fontsize',18)
            title(titles(col),'fontsize',14)
            set(gca,'box','off')
    end