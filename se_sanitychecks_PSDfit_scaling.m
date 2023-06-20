%% SANITY CHECK PSD fit

figure
for p = 1:52

    subplot(7,8,p)
    plot(log(abs( FCM{p}.xY.y{1}))) % data PSD
    hold on
    plot( log(abs( FCM{p}.Hc{1})))  % dcm PSD
    hold on
    axis([0 50 -10 0 ])
end
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% saveas(gcf,[F.today filesep FCMfilename ' SANITY PSD check.png'])


%% SANITY CHECK  scaling within patient

clear FE
for fcm = 1:length(FCM)
    FE(fcm,1) = FCM{fcm}.F;
end

clear L datascale
for fcm = 1:length(FCM)
    datascale(fcm,1) = FCM{fcm}.xY.datascale;
    L(fcm,1)         = FCM{fcm}.Ep.L;
end

figure,
subplot(311), bar(datascale),title('DCM.xY.datascale')
subplot(312), bar(L),title('DCM.Ep.L')
subplot(3,1,3),bar(FE), ylim([-2000 2000]),title('FE sigle DCM')
