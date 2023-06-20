function makefigure_PEBparams(PEB, PMA)

figure,
    cols = length(PEB.Xnames)
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

    for i = 1:cols

        subplot(2,cols,i),
            bar(idx1,Ep_all(idx1,i),'facecolor','b');
            hold on, bar(idx2,Ep_all( idx2,i),'facecolor','g');
            hold on, bar(idx3,Ep_all( idx3,i),'facecolor','c');
            hold on, bar(idx4,Ep_all( idx4,i),'facecolor','m');
            set(gca,'XTick',1:Nparams,'XTickLabel',[Labels(Tcon) Labels(Gmod) Labels(Gexc) Labels(Gihn)],'XTickLabelRotation',90)
            ylim([-1 1]*max(max(abs(Ep_all))))
            title(strrep(PEB.Xnames(i),'_','__'))

        subplot(2,cols,i+cols),
            bar(idx1,Ep_red(idx1,i),'facecolor','b');
            hold on, bar(idx2,Ep_red( idx2,i),'facecolor','g');
            hold on, bar(idx3,Ep_red( idx3,i),'facecolor','c');
            hold on, bar(idx4,Ep_red( idx4,i),'facecolor','m');
            set(gca,'XTick',1:Nparams,'XTickLabel',[Labels(Tcon) Labels(Gmod) Labels(Gexc) Labels(Gihn)],'XTickLabelRotation',90)
            ylim([-1 1]*max(max(abs(Ep_red))))


        
    end