%% (c) Palash Jain, 
% This file parses the first .c81 file in the directory
% .c81 files contain airfoil tables for use in 2-D lifting-line analysis
% For Matlab R2018b and higher (replace rmmissing for backward compatibility) 
file = ls('*.c81');
file = file(1,:);

%% Format specifications
DataStartLine = 2;
VariableNames  = {'Col1','Col2','Col3','Col4','Col5','Col6','Col7',...
    'Col8','Col9','Col10'};
VariableWidths = [7,7,7,7,7,7,7,7,7,7] ;
opts = fixedWidthImportOptions('VariableNames',VariableNames,...
    'DataLines',DataStartLine,'VariableWidths',VariableWidths);
opts.ExtraColumnsRule ='addvars';

%% Read File
T = table2array(readtable(file,opts));
T = str2double(T(1:end-1,:));

%% Parse
for data = 1:3 %1 for Cl, 2 for Cd, 3 for Cm
    if isnan(T(2,1)) %data spans two lines
        lines_Cx = 2;
        [x,y]=find(isnan(T(3:2:end,1)));
        end_of_Cx = 2*x-1;
        Cx = [T(3:2:end_of_Cx,2:10),T(4:2:end_of_Cx+1,2:10)];
        if data == 1 %reads Cl data
            Mach_Cl = [T(1,:),T(2,:)];
            Mach_Cl = rmmissing(Mach_Cl);
            angle_Cl = T(3:2:end_of_Cx,1);
            Cl = rmmissing(Cx,2);
        elseif data == 2 %reads Cd data
            Mach_Cd = [T(1,:),T(2,:)];
            Mach_Cd = rmmissing(Mach_Cd);
            angle_Cd= T(3:2:end_of_Cx,1);
            Cd = rmmissing(Cx,2);
        elseif data == 3 %reads Cm data
            Mach_Cm = [T(1,:),T(2,:)];
            Mach_Cm = rmmissing(Mach_Cm);
            angle_Cm= T(3:2:end_of_Cx,1);
            Cm = rmmissing(Cx,2);
        end
        T(1:end_of_Cx+1,:) = [];
    else %data spans only one line
        lines_Cx = 1;
        [x,y]=find(isnan(T(3:2:end,1)));
        if ~isempty(x)
            end_of_Cx = x-1;
        else
            end_of_Cx = length(T)-1;
        end
        Cx = T(2:end_of_Cx,2:10);
        if data == 1 %reads Cl data
            Mach_Cl = T(1,:);
            Mach_Cl = rmmissing(Mach_Cl);
            angle_Cl = T(2:end_of_Cx,1);
            Cl = rmmissing(Cx,2);
        elseif data == 2 %reads Cd data
            Mach_Cd = T(1,:);
            Mach_Cd = rmmissing(Mach_Cd);
            angle_Cd= T(2:end_of_Cx,1);
            Cd = rmmissing(Cx,2);
        elseif data == 3 %reads Cm data
            Mach_Cm = T(1,:);
            Mach_Cm = rmmissing(Mach_Cm);
            angle_Cm= T(2:end_of_Cx,1);
            Cm = rmmissing(Cx,2);
        end
        T(1:end_of_Cx+1,:) = []; %delete parsed data for recursive analysis
    end
    
end
[MACH_Cl,ANGLE_Cl] = meshgrid(Mach_Cl,angle_Cl);
[MACH_Cd,ANGLE_Cd] = meshgrid(Mach_Cd,angle_Cd);
[MACH_Cm,ANGLE_Cm] = meshgrid(Mach_Cm,angle_Cm);
clearvars -except ANGLE_Cl ANGLE_Cd ANGLE_Cm...
    MACH_Cl MACH_Cd MACH_Cm Cl Cd Cm

save('table.mat')
