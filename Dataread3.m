%% DATAREAD3(Name,Dimension,Field,Variable,Value,Orientation,Stepsize)
% Read CST data from text (hdf5 for 3d) file with the structure:
% Name_Dimension_Field_Variable_Value_Orientation
% eg: Loop_1D_SAR_CD_1_y.txt
% Ident: Name (Identifier)
% Dimension: 1D, 2D, 3D
% Field: H, E, B1p, B1m, SAR
% Variable: Changing variable eg. CD
% Value: Value of the changing variable eg. CD=[1 2 3] --> Value=[1 2 3], 0 if
% no data given
% Orientation: x,y,z,xy,xz,yz, default = xz (2D)
% Stepsize: size of the plotted steps, default = 1 (not necesssary for 3D)
% SO FAR: 1D and 2D Data as Ascii, 3D as HDF5 file!! (both datatypes to be
% implemeneted (for 1D and 2D, for 3D Ascii is not practical)
%%

function [Data] = Dataread3 (Name,Dimension,Field,varargin)

numvarargs = length ( varargin ) ; % number of additional inputs
switch numvarargs
    case 4 % 4 inputs (all variables filled)
        Variable = varargin{1};
        Value = varargin{2};
        Orientation = varargin{3};
        Stepsize = varargin{4};
    case 3 % only 3 inputs (3 is only possible if a variable is assigned)
        Variable = varargin{1};
        Value = varargin{2};
        if  ~isnumeric( varargin{3} ) % when the 3rd input is not numeric -> then it is the orientation
            Orientation = varargin{3};
            Stepsize = 1;
        else % when its numeric it is the stepsize
            Orientation = 'n';
            Stepsize = varargin{3};
        end
    case 2 % either orientation and stepsize or variable and value
        if varargin{1} == "x" || varargin{1} == "y" || varargin{1} == "z" || varargin{1} == "xy" || varargin{1} == "xz" || varargin{1} == "yz" % if orientation and stepsize
            Variable = 'n';
            Value = 0;
            Orientation = varargin{1};
            Stepsize = varargin{2};
        else %if variable and value
            Variable = varargin{1};
            Value = varargin{2};
            Orientation = 'n';
            Stepsize = 1;
        end
    case 1 % either stepsize or orientation
        Variable = 'n';
        Value = 0;
        if  ~isnumeric( varargin{1} ) % when not numeric then orientation
            Orientation = varargin{1};
            Stepsize = 1;
        else % when numeric then stepsize
            Orientation = 'n';
            Stepsize = varargin{1};
        end
    case 0 % no addition parameters -> all set to default
        Variable = 'n';
        Value = 0;
        Orientation = 'n';
        Stepsize = 1;
end

% until here only for different inputs

switch Field % Field under observation
    case 'H'
        F="H_";
    case 'E'
        F="E_";
    case 'B1p'
        F="B1p_";
    case 'B1m'
        F="B1m_";
    case 'SAR'
        F="SAR_";
    case 'PLD'
        F="PLD_";
end

if Variable ~='n'
    C=append(Variable,'_');
    C_disp=append(Variable,'=');
else
    C='';
    C_disp="no additional variable";
end

if Variable~='n'  %data range of the changed variable if non 0
    if (Orientation~='n')  % orientation of the data, if n then no specific orientation
        Values="" + (Value);
        switch Orientation
            case 'x'
                O="_x";
            case 'y'
                O="_y";
            case 'z'
                O="_z";
            case 'xy'
                O="_xy";
            case 'xz'
                O="_xz";
            case 'yz'
                O="_yz";
        end
    else
        Values="" + (Value);
        O='';
    end
else % if there is no var to change or given
    if (Orientation~='n') % if an orientation is given
        Values='';
        O=Orientation;
    else
        Values="";
        O="";
        switch Field % Field under observation
            case 'H'
                F="H";
            case 'E'
                F="E";
            case 'B1p'
                F="B1p";
            case 'B1m'
                F="B1m";
            case 'SAR'
                F="SAR";
            case 'PLD'
                F="PLD";
            case 'EED'
                F="EED";
        end
    end
end

if Dimension == 3
    End=".h5";
else
    End=".txt";
end

switch Dimension % Dimension of the Data 3D not jet implemented
    case 1
        D="_1D_";
        Datapath=append(Name,D,F,C,Values,O,End);
        for i=1:length(Datapath)
            dummy=fprintf("Read data from %s ...", Datapath(i));
            Raw=importdata(Datapath(i));
            fprintf(repmat('\b',1,dummy))
            dummy=fprintf("Data evaluation...");
            if (Field == "B1p") || (Field == "B1m")
                Data.Raw{i}(:,1)=Raw.data(:,1); % x axis
                Data.Raw{i}(:,2)=Raw.data(:,2).*1e6; %micro tesla
            else
                Data.Raw{i}=Raw.data(:,:);
            end

            Data.info{i}=Raw.textdata;
            Data.variables{i}=append(C_disp,Values(i));
            fprintf(repmat('\b',1,dummy))
            disp(append(Name,'_',F,C,Values(i),O)+" read in ... (" + i + '/' + length(Datapath)+ ')');
        end
    case 2
        D='_2D_';
        Datapath=append(Name,D,F,C,Values,O,End);
        for i=1:length(Datapath)
            dummy=fprintf("Read data from %s ...", Datapath(i)');
            Raw=importdata(Datapath(i));
            fprintf(repmat('\b',1,dummy))
            dummy=fprintf("Data evaluation...");
            Data.Raw{i}=Raw.data(:,:);
            if (Field == "SAR")
                Data.Total{i}=[Data.Raw{i}(:,1),Data.Raw{i}(:,2),Data.Raw{i}(:,3),Data.Raw{i}(:,4)];
            elseif Field == "PLD"
                Data.Total{i}=[Data.Raw{i}(:,1),Data.Raw{i}(:,2),Data.Raw{i}(:,3),Data.Raw{i}(:,4)];
            else
                Data.Absolut{i}=[Data.Raw{i}(:,1),Data.Raw{i}(:,2),Data.Raw{i}(:,3),sqrt(Data.Raw{i}(:,4).^2 ...
                    +Data.Raw{i}(:,5).^2),sqrt(Data.Raw{i}(:,6).^2+Data.Raw{i}(:,7).^2),sqrt(Data.Raw{i}(:,8).^2 ...
                    +Data.Raw{i}(:,9).^2)];

                Data.Total{i}=[Data.Absolut{i}(:,1:3),sqrt(Data.Absolut{i}(:,4).^2+Data.Absolut{i}(:,5).^2 ...
                    +Data.Absolut{i}(:,6).^2)];
                Data.Compl.Absolut{i}=[Data.Raw{i}(:,1:3),sqrt(Data.Raw{i}(:,4).^2+Data.Raw{i}(:,6).^2+Data.Raw{i}(:,8).^2), ...
                    sqrt(Data.Raw{i}(:,5).^2 + Data.Raw{i}(:,7).^2+Data.Raw{i}(:,9).^2)];


                Data.Compl.Total{i}=complex(Data.Compl.Absolut{i}(:,4) + 1i.*Data.Compl.Absolut{i}(:,5));


                if Field == "B1p" || Field == "B1m"
                    Data.Total{i}(:,4)=Data.Total{i}(:,4).*1e6; %% in microtesla
                end
            end

            switch Orientation
                case 'xy'
                    Data.Dim_1{i}=min(Data.Total{i}(:,1)):Stepsize:max(Data.Total{i}(:,1)); % x im Bild -> y bei der matrix
                    Data.Dim_2{i}=min(Data.Total{i}(:,2)):Stepsize:max(Data.Total{i}(:,2)); % y im Bild -> x bei der matrix
                case 'xz'
                    Data.Dim_1{i}=min(Data.Total{i}(:,3)):Stepsize:max(Data.Total{i}(:,3)); % x im Bild -> x bei der matrix
                    Data.Dim_2{i}=min(Data.Total{i}(:,1)):Stepsize:max(Data.Total{i}(:,1)); % z im Bild -> y bei der matrix -> x in der realität
                case 'yz'
                    Data.Dim_1{i}=min(Data.Total{i}(:,2)):Stepsize:max(Data.Total{i}(:,2));
                    Data.Dim_2{i}=min(Data.Total{i}(:,3)):Stepsize:max(Data.Total{i}(:,3));
                otherwise % falls keine Richtung angegeben dann xz als default
                    if (max(Data.Total{i}(:,3))==min(Data.Total{i}(:,3))) % if max(z)=min(z) then it must be the xy plane
                        Data.Dim_1{i}=min(Data.Total{i}(:,1)):Stepsize:max(Data.Total{i}(:,1)); % x im Bild -> y bei der matrix
                        Data.Dim_2{i}=min(Data.Total{i}(:,2)):Stepsize:max(Data.Total{i}(:,2)); % y im Bild -> x bei der matrix

                    elseif (max(Data.Total{i}(:,2))==min(Data.Total{i}(:,2))) % if max(y)=min(y) then it must be the xz plane

                        Data.Dim_1{i}=min(Data.Total{i}(:,3)):Stepsize:max(Data.Total{i}(:,3)); % x im Bild -> x bei der matrix
                        Data.Dim_2{i}=min(Data.Total{i}(:,1)):Stepsize:max(Data.Total{i}(:,1)); % z im Bild -> y bei der matrix -> x in der realität

                    elseif (max(Data.Total{i}(:,1))==min(Data.Total{i}(:,1))) % if max(x)=min(x) then it must be the zy plane

                        Data.Dim_1{i}=min(Data.Total{i}(:,2)):Stepsize:max(Data.Total{i}(:,2));
                        Data.Dim_2{i}=min(Data.Total{i}(:,3)):Stepsize:max(Data.Total{i}(:,3));
                    else
                        Data.Dim_1{i}=min(Data.Total{i}(:,3)):Stepsize:max(Data.Total{i}(:,3)); % x im Bild -> x bei der matrix
                        Data.Dim_2{i}=min(Data.Total{i}(:,1)):Stepsize:max(Data.Total{i}(:,1)); % z im Bild -> y bei der matrix -> x in der realität
                    end
            end

            Data.matrixSize1{i}=squeeze(length(Data.Dim_1{i})); % länge der x richtung im bild
            Data.matrixSize2{i}=squeeze(length(Data.Dim_2{i})); % länge der y richtung im bild
            Data.Field{i}=zeros(Data.matrixSize2{i},Data.matrixSize1{i});
            t=1;

            for k=1:Data.matrixSize2{i}
                for j=1:Data.matrixSize1{i}
                    Data.Field{i}(k,j)=Data.Total{i}(t,4);
                    if Field ~= "SAR"
                        Data.Compl.Field{i}(k,j)=Data.Compl.Total{i}(t,1);
                    end
                    t=t+1;
                end
            end
            if Field ~= "SAR"
                Data.Compl.Mag{i}=abs(Data.Compl.Field{i});
                Data.Compl.Pha{i}=angle(Data.Compl.Field{i});
            end
            Data.info{i}=Raw.textdata;
            Data.variables{i}=append(C_disp,Values(i));
            fprintf(repmat('\b',1,dummy))
            disp(append(Name,'_',F,C,Values(i),O)+" read in ... (" + i + '/' + length(Datapath) + ')');
        end

    case 3
        D='_3D_';
        Datapath=append(Name,D,F,C,Values,O,End);
        for i=1:length(Datapath)
            dummy=fprintf("Read data from %s ...", Datapath(i));
            switch Field
                case 'H'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/H-Field');
                case 'E'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/E-Field');
                case 'SAR'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/SAR');
                case 'B1p'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/B-Field');
                case 'PLD'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/Power Loss Density');
                case 'EED'
                    Data.Raw{i}=h5read(char(Datapath(i)),'/Electric Energy Density');
                otherwise
                    Data.Raw{i}=h5read(char(Datapath(i)),'/B-Field');
            end
            fprintf(repmat('\b',1,dummy))
            dummy=fprintf("Data evaluation...");
            if Field == "SAR"
                Data.Total{i}=Data.Raw{i};
            elseif Field == "PLD"
                Data.Total{i}=Data.Raw{i};
            elseif Field == "EED"
                Data.Total{i}=Data.Raw{i};
            else
                Data.Real.x{i}=double(Data.Raw{i}.x.re);
                Data.Img.x{i}=double(Data.Raw{i}.x.im);
                Data.Real.y{i}=double(Data.Raw{i}.y.re);
                Data.Img.y{i}=double(Data.Raw{i}.y.im);
                Data.Real.z{i}=double(Data.Raw{i}.z.re);
                Data.Img.z{i}=double(Data.Raw{i}.z.im);

                % Complex

                Data.Compl.Real{i}=sqrt((Data.Raw{i}.x.re).^2+(Data.Raw{i}.y.re).^2+(Data.Raw{i}.z.re).^2); %passt (H,CH1)
                Data.Compl.Img{i}=sqrt((Data.Raw{i}.x.im).^2+(Data.Raw{i}.y.im).^2+(Data.Raw{i}.z.im).^2);  %passt (H,CH2)

                Data.Compl.Total{i}=complex(Data.Compl.Real{i}+1i.*Data.Compl.Img{i});

                Data.Compl.Field{i}=Data.Compl.Total{i};

                Data.Compl.Mag{i}=abs(Data.Compl.Field{i});
                Data.Compl.Pha{i}=angle(Data.Compl.Field{i});

                Data.Absolut.x{i}=sqrt((Data.Raw{i}.x.re).^2+(Data.Raw{i}.x.im).^2);
                Data.Absolut.y{i}=sqrt((Data.Raw{i}.y.re).^2+(Data.Raw{i}.y.im).^2);
                Data.Absolut.z{i}=sqrt((Data.Raw{i}.z.re).^2+(Data.Raw{i}.z.im).^2);

                Data.Total{i}=sqrt(Data.Absolut.x{i}.^2+Data.Absolut.y{i}.^2+Data.Absolut.z{i}.^2); %passt(H,CH1,CH2)
            end

            Data.x{i}=h5read(char(Datapath(i)),'/Mesh line x'); % x
            Data.y{i}=h5read(char(Datapath(i)),'/Mesh line y'); % y
            Data.z{i}=h5read(char(Datapath(i)),'/Mesh line z'); % z

            Data.xLength{i}=squeeze(length(Data.x{i})); % länge der x richtung im bild
            Data.yLength{i}=squeeze(length(Data.y{i})); % länge der y richtung im bild
            Data.zLength{i}=squeeze(length(Data.z{i})); % länge der z richtung im bild

            if Field == "B1p" || Field == "B1m"
                Data.Total{i}=Data.Total{i}.*1e6;
            end

            Data.Field{i}=zeros(Data.xLength{i},Data.yLength{i},Data.zLength{i});
            Data.Field{i}=Data.Total{i};

            Data.Info{i}=h5info(char(Datapath(i)));
            Data.variables{i}=append(C_disp,Values(i));

            fprintf(repmat('\b',1,dummy))
            disp(append(Name,'_',F,C,Values(i),O)+" read in ... (" + i + '/' + length(Datapath) + ')');
        end
end


end

