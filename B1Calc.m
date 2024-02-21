%% Calculates B1+ and B1- from H-Field distributions
% Raw_Data -> complex H-Field (either 1D, 2D or 3D array) (Raw Data)
% B0_Direction -> Orientation of the static B0-Field
% x is the data in x direction
% y is the data in y direction
% z is the data in z direction
% Data_Dimension is 2D or 3D (2 or 3 respectivly)

function [Data] =  B1Calc (Raw_Data,B0_Direction,x,y,z,Data_Dimension)

dummy=fprintf('Calculate data...');

Data.mu0=1.25663706212e-6;

switch Data_Dimension
    case 2
        for i=1:length(Raw_Data)
            Data.Hx{i}=complex(Raw_Data{1,i}(:,4)+1i.*Raw_Data{1,i}(:,5));
            Data.Hy{i}=complex(Raw_Data{1,i}(:,6)+1i.*Raw_Data{1,i}(:,7));
            Data.Hz{i}=complex(Raw_Data{1,i}(:,8)+1i.*Raw_Data{1,i}(:,9));
            Data.x{i}=x{1,i};
            Data.y{i}=y{1,i};
            Data.Bx{i}=Data.mu0.*Data.Hx{i};
            Data.By{i}=Data.mu0.*Data.Hy{i};
            Data.Bz{i}=Data.mu0.*Data.Hz{i};

            if B0_Direction == "-" % for negative z direction of B0
                Data.B1p{i} = ( Data.Bx{i} + 1i.*Data.By{i} )./2;
                Data.B1m{i} = conj( Data.Bx{i} - 1i.*Data.By{i} )./2;
            else %for positive z direction of B0
                Data.B1p{i} = conj( Data.Bx{i} - 1i.*Data.By{i} )./2;
                Data.B1m{i} = ( Data.Bx{i} + 1i.*Data.By{i} )./2;
            end

            Data.matrixSize1{i}=squeeze(length(Data.x)); % länge der x richtung im bild
            Data.matrixSize2{i}=squeeze(length(Data.y)); % länge der y richtung im bild
            %%%%%%%%%%%%%%%%%%%%%%%%
            Data.B1p_Field=zeros(length(Data.x{i}),length(Data.y{i})); %hier ist evtl noch ein fehler mit der Zelle Data.x und Data.y
            Data.B1m_Field=zeros(length(Data.x{i}),length(Data.y{i}));
            %%%%%%%%%%%%%%%%%%%%%%%%
            t=1;
            for k=1:length(Data.x{1,1})
                for j=1:length(Data.y{1,1})
                    Data.B1p_Field{i}(k,j)=sqrt(real(Data.B1p{i}(t,1)).^2+imag(Data.B1p{i}(t,1)).^2).*1e6;
                    Data.B1m_Field{i}(k,j)=sqrt(real(Data.B1m{i}(t,1)).^2+imag(Data.B1m{i}(t,1)).^2).*1e6;
                    t=t+1;
                end
            end
        end

    case 3 % 3D

        for i=1:length(Raw_Data)
            Data.Hx{i}=complex(Raw_Data{1,i}.x.re+1i.*Raw_Data{1,i}.x.im);
            Data.Hy{i}=complex(Raw_Data{1,i}.y.re+1i.*Raw_Data{1,i}.y.im);
            Data.Hz{i}=complex(Raw_Data{1,i}.z.re+1i.*Raw_Data{1,i}.z.im);

            Data.Bx{i}=Data.mu0.*Data.Hx{i};
            Data.By{i}=Data.mu0.*Data.Hy{i};
            Data.Bz{i}=Data.mu0.*Data.Hz{i};

            if B0_Direction =="-" % for negative z direction of B0
                Data.B1p{i} = ( Data.Bx{i} + 1i.*Data.By{i} )./2;
                Data.B1m{i} = conj( Data.Bx{i} - 1i.*Data.By{i} )./2;
            else %for positive z direction of B0
                Data.B1p{i} = conj( Data.Bx{i} - 1i.*Data.By{i} )./2;
                Data.B1m{i} = ( Data.Bx{i} + 1i.*Data.By{i} )./2;
            end
            [Data.xLength{i}, Data.yLength{i}, Data.zLength{i}] = size(Data.B1p{i});
            Data.x{i}=x{1,i};
            Data.y{i}=y{1,i};
            Data.z{i}=z{1,i};
            Data.B1p_Real{i}=real(Data.B1p{i});
            Data.B1p_Imag{i}=imag(Data.B1p{i});
            Data.B1m_Real{i}=real(Data.B1m{i});
            Data.B1m_Imag{i}=imag(Data.B1m{i});
            Data.B1p_Field{i}=abs(Data.B1p{i}).*1e6;
            Data.B1m_Field{i}=abs(Data.B1p{i}).*1e6;

            Data.B1p_Field_RMS{i}=Data.B1p_Field{i}./sqrt(2);
            Data.B1m_Field_RMS{i}=Data.B1m_Field{i}./sqrt(2);

            for u=1:Data.zLength{i}
                Data.B1p_complex2D{i}(u,:)=reshape(Data.B1p{1,i}(:,:,u),1,[]); % row vector of the Mask matrix column by column
                Data.B1p_Amplitude2D{i}(u,:)=abs(Data.B1p_complex2D{i}(u,:)); % row vector of the Mask matrix column by column
                Data.B1p_Phase2D{i}(u,:)=angle(Data.B1p_complex2D{i}(u,:)); % row vector of the Mask matrix column by column
            end
            Data.B1p_complex1D{i}=[];
            for u=1:Data.zLength{i}
                Data.B1p_complex1D{i}=cat(2,Data.B1p_complex1D{i},Data.B1p_complex2D{i}(u,:)); % image by image added together
                Data.B1p_Amplitude1D{i}=abs(Data.B1p_complex1D{i}); % image by image added together
                Data.B1p_Phase1D{i}=angle(Data.B1p_complex1D{i}); % image by image added together
            end
        end

end
fprintf(repmat('\b',1,dummy))
disp('B1+ and B1- calculated in uT.');

