function [data_bip,data_bip_lab] = createbipolar(data, long1_num, long1, b,a)

clear data_bip*
for ch = 1:length(long1_num)

    data_bip(ch,:) = data.F(long1_num(ch,1),:) - data.F(long1_num(ch,2),:);
    data_bip_lab{ch,1}   = [char(long1.First(ch)) '-' char(long1.Second(ch))] ;

end
    

data_bip = filtfilt(b,a,data_bip')';