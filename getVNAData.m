% getNVAData
% fR - frequency of interest in MHz
% File - File name of the Sparameter eg. msxx.dat(xx is a
% placeholder)
% additional parameter for varables (eg. 45/65)
% DISCLAIMER: only for s11 tested and programmed

function [Data] = getVNAData(fR, FileName, varargin)

if isempty(varargin)
    numvarargs = 1;
else
    numvarargs = length (varargin{1}) ; % number of additional inputs
    Values=""+(varargin{1});
    FileName=append(FileName{1}(1:end-4), Values, FileName{1}(end-3:end));
end

for i=1:numvarargs
    dummy=fprintf("Read data from %s ...", FileName(i));
    Data.Raw{i}=importdata(FileName(i));
    Data.fR=fR;
    Data.Variables{i}=Values{i};
    fR_Ind=find(Data.Raw{1,i}.data(:,1)==fR*1e6);
    Data.Abs{i}=Data.Raw{1,i}.data(fR_Ind,2);
    Data.Frequencies{i}=Data.Raw{1,1}.data(:,1);
    fprintf(repmat('\b',1,dummy))
    disp(append(FileName(i)+" read in ... (" + i + '/' + length(FileName) + ')'));

end