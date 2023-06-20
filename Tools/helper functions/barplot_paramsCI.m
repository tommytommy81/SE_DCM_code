function barplot_paramsCI(base)

% plot the 14 T and G params in ordered colorcoded barplot

% just labels
Tlabels = {'T_s_s', 'T_s_p', 'T_i_i', 'T_d_p'}
Glabels = {'G_s_p', 'G_s_p_-_s_s', 'G_i_i_-_s_s', 'G_i_i', 'G_s_s_-_i_i', ...
           'G_d_p_-_i_i', 'G_s_s_-_d_p', 'G_i_i_-_d_p', 'G_d_p', 'G_s_s', }

 
% extract E,C
Ep_pre  =   [full(base.Ep.T)  full(base.Ep.G)]'  ; 
 Cp_pre   =  diag(full(base.Cp)); % skip first 5 and take 14 values 
Cp_pre   =  Cp_pre([1:14]+5);
 

% index of G types
Gmod  = [1 4 9 10];
Gexc  = [5 6 7 ];
Gihn  = [2 3 8];

% reorder for plotting
coef(:,1)  = Ep_pre([1:4 [Gmod Gexc  Gihn ]+4] )
 CI(:,1)    = Cp_pre([1:4 [Gmod Gexc  Gihn ]+4] );

   spm_plot_ci(coef(:,1), CI(:,1) )
 
    set(gca,'XTick',1:14,'XTickLabel',[Tlabels Glabels(Gmod) Glabels(Gexc) Glabels(Gihn)],'XTickLabelRotation',45, 'FontSize',20)
    set(gca,'box','off')

 