%% Reads CST Power Data
% fR frequeny under evaluation
% Name given name (AName) from the Makro
% VoxelData Boolean 0 if no voxel data, 1 if there is voxel data
% varargin = 'LE' + 'ConL' : lumped element loss and conductor loss
% varargin = 'LE' : only lumped element loss
% varargin = 'ConL' : only conductor loss
% varagrin = '' : no lumped element loss and no conducor loss


function [Data] =  PowerRead (fR,Name,VoxelData,varargin)

fR_Str=num2str(fR);
numvarargs = length ( varargin );
switch numvarargs
    case 2
        lumpedE = "true";
        CondL = "true";

    case 1
        if varargin{1} == "LE"
            lumpedE = "true";
            CondL = "false";
        else
            lumpedE = "false";
            CondL = "true";
        end
    case 0
        lumpedE = "false";
        CondL = "false";
end

dummy=fprintf("Read data from %s Power ...", Name');
Power=append(Name,'_Power');
Raw=readcell(Power);
fprintf(repmat('\b',1,dummy))
disp(append(Power+" read in."'));
Data.Raw.Power=Raw;

dummy=fprintf("Read data from %s Dielectric ...", Name');
Dielectric=append(Name,'_Dielectric');
Raw=readcell(Dielectric,'Delimiter', '\n');
fprintf(repmat('\b',1,dummy))
disp(append(Dielectric+" read in."'));
Data.Raw.Dielectric=Raw;

if VoxelData==1
    dummy=fprintf("Read data from %s Voxels...", Name');
    Voxel=append(Name,'_Voxel');
    Raw=readcell(Voxel);
    fprintf(repmat('\b',1,dummy))
    disp(append(Voxel+" read in."'));
    Data.Raw.Voxel=Raw;

    VoxMaterialNum=length(Data.Raw.Voxel(:,1));
    t=1;
    for i=1:3:VoxMaterialNum
        Data.Voxel.Materials{t,1}=Data.Raw.Voxel{i,1};
        Data.Voxel.Materials{t,2}=str2double(Data.Raw.Voxel{i+2,1}(19:end));
        t=t+1;
    end
end
%%

dummy=fprintf("Evaluate data ...");
fR_index=find(string(Data.Raw.Power)==fR_Str);

if lumpedE == "true" && CondL == "true"
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.Conductor=Data.Raw.Power{fR_index(2),2};
    Data.LumpedElemets=Data.Raw.Power{fR_index(3),2};
    Data.Accepted=Data.Raw.Power{fR_index(4),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(5),2};
    Data.Outgoing=Data.Raw.Power{fR_index(6),2};
    Data.Radiated=Data.Raw.Power{fR_index(7),2};
    Data.Stimulated=Data.Raw.Power{fR_index(8),2};
    Data.TM=Data.AcceptedDS-Data.Accepted;
    Data.TMLE=Data.TM+Data.LumpedElemets;
elseif lumpedE == "false" && CondL == "true"
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.Conductor=Data.Raw.Power{fR_index(2),2};
    Data.Accepted=Data.Raw.Power{fR_index(3),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(4),2};
    Data.Outgoing=Data.Raw.Power{fR_index(5),2};
    Data.Radiated=Data.Raw.Power{fR_index(6),2};
    Data.Stimulated=Data.Raw.Power{fR_index(7),2};
    Data.TM=Data.AcceptedDS-Data.Accepted;
elseif lumpedE == "true" && CondL == "false"
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.LumpedElemets=Data.Raw.Power{fR_index(2),2};
    Data.Accepted=Data.Raw.Power{fR_index(3),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(4),2};
    Data.Outgoing=Data.Raw.Power{fR_index(5),2};
    Data.Radiated=Data.Raw.Power{fR_index(6),2};
    Data.Stimulated=Data.Raw.Power{fR_index(7),2};
    Data.TM=Data.AcceptedDS-Data.Accepted;
    Data.TMLE=Data.TM+Data.LumpedElemets;
elseif lumpedE =="false" && CondL == "false"
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.Accepted=Data.Raw.Power{fR_index(2),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(3),2};
    Data.Outgoing=Data.Raw.Power{fR_index(4),2};
    Data.Radiated=Data.Raw.Power{fR_index(5),2};
    Data.Stimulated=Data.Raw.Power{fR_index(6),2};
    Data.TM=Data.AcceptedDS-Data.Accepted;
end

%%
MaterialNum=length(Data.Raw.Dielectric(:,1));
t=1;
for i=1:3:MaterialNum
    Data.Dielectrics.Materials{t,1}=Data.Raw.Dielectric{i,1};
    Data.Dielectrics.Materials{t,2}=str2double(Data.Raw.Dielectric{i+2,1}(19:end));
    t=t+1;
end

%%

fprintf(repmat('\b',1,dummy))
disp("Evaluation done.");
end