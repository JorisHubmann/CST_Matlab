% Gives Amplitude and Phase for the CST Touchdown Data

function [Zpara] = CST_Z_Matrix(File,fR)

Data=zparameters(File);
fR_Ind=find(Data.Frequencies==fR);
Zpara.Abs=abs(Data.Parameters(:,:,fR_Ind));
Zpara.Ang=angle(Data.Parameters(:,:,fR_Ind)).*180./pi();
Zpara.fR=fR;
Zpara.Raw.Complex=squeeze(Data.Parameters);
Zpara.Raw.Absolut=squeeze(abs(Zpara.Raw.Complex));
Zpara.Raw.Frequencies=Data.Frequencies;
Zpara.Raw.NumPorts=Data.NumPorts;

end