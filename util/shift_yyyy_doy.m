function [yyyy_doynew] = shift_yyyy_doy(yyyy_doy,shift_day)
    y = sscanf(yyyy_doy,'%d_%d');
    dnew = y(2) + shift_day;
    ynew = y(1);
    doy = get_doy(ynew);
    while (dnew<1) || (dnew>doy)
        if dnew < 1
            ynew = ynew-1;
            doy =get_doy(ynew);
            dnew = doy+dnew;
        else
            dnew = dnew-doy;
            ynew = ynew+1;
            doy =get_doy(ynew);
        end
    end
    yyyy_doynew = sprintf('%4d_%03d',ynew,dnew);
end