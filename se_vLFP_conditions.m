function reccond = se_vLFP_conditions(F)  %% condition labels for each vLFP window

clear reccond*

modelinfo = table2array(F.Xfull(2:2:end,:));

resp      = find(modelinfo(:,2));
nresp     = find(modelinfo(:,2)==0);
benz      = find(modelinfo(:,3));
anti      = find(modelinfo(:,4));
barb      = find(modelinfo(:,5));
prop      = find(modelinfo(:,6));

resp_benz  = intersect(resp,benz);
nresp_benz = intersect(nresp,benz);
resp_anti  = intersect(resp,anti);
nresp_anti = intersect(nresp,anti);
resp_barb  = intersect(resp,barb);
nresp_barb = intersect(nresp,barb);
resp_prop  = intersect(resp,prop);
nresp_prop = intersect(nresp,prop);

for s=1:length(modelinfo)

    if sum(ismember(s,resp_benz))
        reccond(s).cond = 'Benz Resp';
    end
    if sum(ismember(s,nresp_benz))
        reccond(s).cond = 'Benz NonResp';
    end
    if ~sum(ismember(s,benz)) & sum(ismember(s,resp))
        reccond(s).cond = '2ndLine Resp';
    end
    if ~sum(ismember(s,benz)) & sum(ismember(s,nresp))
        reccond(s).cond = '2ndLine NonResp';
    end

end

reccond2 = [reccond; reccond];
reccond  = reccond2(:);

save([F.today filesep 'reccond'],'reccond')
