% Gives Amplitude and Phase for the CST Touchdown Data
% File = File with sparameter data
% fR = Frequency of interest in MHz
% parameter 'S','Y','Z'
% varargin can be used to read in several s-parameter files at once  e.g.
% [1 2 3]

function [Spara] = CST_S_Matrix(File,fR,parameter,varargin)

if isempty(varargin)
    numvarargs = 1;
else
    numvarargs = length ( varargin{1}) ; % number of additional inputs
    Values="_" + (varargin{1});
    File=append(File{1}(1:end-4), Values, File{1}(end-3:end));
end

for i=1:numvarargs
    dummy=fprintf("Read data from %s ...", File(i));
    switch parameter
        case 'S'
            Data=sparameters(File(i));
            Spara.Datatype='S';
            Spara.Raw.Impedance{i}=Data.Impedance;
            fR_Ind{i}=find(Data.Frequencies==fR*1e6);
            Spara.Abs{i}=mag2db(abs(Data.Parameters(:,:,fR_Ind{i})));
            Spara.Lin{i}=abs(Data.Parameters(:,:,fR_Ind{i}));
        case 'Y' || 'y'
            Data=yparameters(File);
            Spara.Datatype='Y';
            fR_Ind{i}=find(Data.Frequencies==fR*1e6);
            Spara.Abs{i}=(abs(Data.Parameters(:,:,fR_Ind{i})));
            Spara.Lin{i}=abs(Data.Parameters(:,:,fR_Ind{i}));
        case 'Z' || 'z'
            Data=zparameters(File);
            Spara.Datatype='Z';
            fR_Ind{i}=find(Data.Frequencies==fR*1e6);
            Spara.Abs{i}=(abs(Data.Parameters(:,:,fR_Ind{i})));
            Spara.Lin{i}=abs(Data.Parameters(:,:,fR_Ind{i}));
    end

    Spara.Ang{i}=angle(Data.Parameters(:,:,fR_Ind{i})).*180./pi();
    Spara.fR{i}=fR;
    Spara.Raw.Complex{i}=squeeze(Data.Parameters);
    Spara.Raw.Absolut{i}=squeeze(mag2db(abs(Spara.Raw.Complex{i})));
    Spara.Raw.Frequencies{i}=Data.Frequencies;
    Spara.Raw.NumPorts{i}=Data.NumPorts;
    fprintf(repmat('\b',1,dummy))
    disp(append(File(i)+" read in ... (" + i + '/' + length(File) + ')'));
end
end