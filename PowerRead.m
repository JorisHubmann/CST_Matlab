%% Reads CST Power Data
% fR frequeny under evaluation
% Name given name (AName) from the Makro
% VoxelData Boolean 0 if no voxel data, 1 if there is voxel data
% varargin random value if there are lumped elements

function [Data] =  PowerRead (fR,Name,VoxelData,varargin)

fR_Str=num2str(fR);
if isempty(varargin)
    lumpedE = "false";
else
    lumpedE = "true";
end
dummy=fprintf("Read data from %s Power ...", Name');
Power=append(Name,'_Power');
Raw=readcell(Power);
fprintf(repmat('\b',1,dummy))
disp(append(Power+" read in."'));
Data.Raw.Power=Raw;

dummy=fprintf("Read data from %s Dielectric ...", Name');
Dielectric=append(Name,'_Dielectric');
Raw=readcell(Dielectric);
fprintf(repmat('\b',1,dummy))
disp(append(Dielectric+" read in."'));
Data.Raw.Dielectric=Raw;

if VoxelData==1
    dummy=fprintf("Read data from %s Dielectric...", Name');
    Voxel=append(Name,'_Voxel');
    Raw=readcell(Voxel);
    fprintf(repmat('\b',1,dummy))
    disp(append(Voxel+" read in."'));
    Data.Raw.Voxel=Raw;
end
%%

dummy=fprintf("Evaluate data ...");
fR_index=find(string(Data.Raw.Power)==fR_Str);
if lumpedE =="false"
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.Accepted=Data.Raw.Power{fR_index(2),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(3),2};
    Data.Outgoing=Data.Raw.Power{fR_index(4),2};
    Data.Radiated=Data.Raw.Power{fR_index(5),2};
    Data.Stimulated=Data.Raw.Power{fR_index(6),2};
else
    Data.Dielectrics.Total=Data.Raw.Power{fR_index(1),2};
    Data.LumpedElemets=Data.Raw.Power{fR_index(2),2};
    Data.Accepted=Data.Raw.Power{fR_index(3),2};
    Data.AcceptedDS=Data.Raw.Power{fR_index(4),2};
    Data.Outgoing=Data.Raw.Power{fR_index(5),2};
    Data.Radiated=Data.Raw.Power{fR_index(6),2};
    Data.Stimulated=Data.Raw.Power{fR_index(7),2};
end

%%
MaterialNum=squeeze(size(Data.Raw.Dielectric(:,1)));

for i=1:3:MaterialNum/3
    Data.Dielectrics.Materials{i,1}=Data.Raw.Dielectric{i,1};
    Data.Dielectrics.Materials{i,2}=str2double(Data.Raw.Dielectric{i+2,1}(19:end));
end

%%
VoxMaterialNum=squeeze(size(Data.Raw.Voxel(:,1)));
t=1;
for i=1:3:VoxMaterialNum+1/3
    Data.Voxel.Materials{t,1}=Data.Raw.Voxel{i,1};
    Data.Voxel.Materials{t,2}=str2double(Data.Raw.Voxel{i+2,1}(19:end));
    t=t+1;
end
fprintf(repmat('\b',1,dummy))
disp("Evaluation done.");
end