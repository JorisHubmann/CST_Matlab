%% Extraktion Kopf Geometrie
% Input: SAR Field Data: Must include Size Vectors and Field itself
% output: Contour of the head (with border points) and a mask where everything inside the head
% is 1 and everything outside is 0. This is outputted as a 2D Matrix and a
% 1 D Array (for multiplication with the field vectors from CST)
% varargin -> if no canny edge is going to be used -> 'nc' 

%% Head Contour

function [Head] = HeadExtraction(Data, NDData,startSlice,endSlice,varargin)

if NDData == 2
    Head.circle.r=155; % inner radius of the coil
    Head.circle.value_x=(max(Data.Dim_1{1})+min(Data.Dim_1{1}))/2; % mid of the array as value in x
    Head.circle.value_y=(max(Data.Dim_2{1})+min(Data.Dim_2{1}))/2; % mit of the array as value in y

    Head.circle.pos_x=find(Data.Dim_1{1}==round(Head.circle.value_x)); %mid of the array as indice in x
    if ~(Data.Dim_1{1}==round(Head.circle.value_x)) % if mid is not part of the array-->
        Head.circle.pos_x=round(length(Data.Dim_1{1})/2);
    end

    Head.circle.pos_y=find(Data.Dim_2{1}==round(Head.circle.value_y)); %mid of the array as indice in y
    if ~(Data.Dim_2{1}==round(Head.circle.value_y)) % if mid is not part of the array-->
        Head.circle.pos_y=round(length(Data.Dim_2{1})/2);
    end


    % to exclude contours from the antennas
    dummy=fprintf('Head contour extraction in progress...');
    % extracts a binary file of the head based on the SAR

    for i=1:Data.matrixSize2{1}
        for j=1:Data.matrixSize1{1}
            if (Data.Field{1}(i,j) == 0) % everything outside the head is 0 anyways
                Head.Binary(i,j)=0;
            else
                Head.Binary(i,j)=1;  % everything inside the head is 1
            end
        end
    end

    Head.Edge=edge(Head.Binary,'canny'); % performes edge detection using canny edge
    % exclude everything outside the inner bore diameter from the field to
    % exclude coils

    for i=1:Data.matrixSize2
        for j=1:Data.matrixSize1
            if (Head.Edge(i,j) == 1) && ((i-Head.circle.pos_y)^2+(j-Head.circle.pos_x)^2<=Head.circle.r^2)
                % a^2+b^2=c^2 wenns größer ist, dann außerhalb des radiuses
                % sonst innerhalb
                Head.Contour(i,j)=0; % alles innerhalb und wenn edge = 1 dann 0; invers zu Head.Edge
            else
                Head.Contour(i,j)=1; % alles außerhalb dann 1
            end
        end
    end
    fprintf(repmat('\b',1,dummy))
    disp('Contour extracted.')

    %% Head Border Points
    dummy=fprintf('Edge location point extraction in progress...');
    [Head.row, Head.col]=find(~Head.Contour); % find the points of the head contour edge
    Head.colrow=[Head.col, Head.row];  % x y , array of both values
    Head.colrowsort=sortrows(Head.colrow,2); % sorted acending for rows

    n=1; % for first row
    Head.BorderPoints(1,n) = Head.colrowsort(find(Head.colrowsort(:,2)==Head.colrowsort(1,2),1),1); % min x value for the first row (indices)
    Head.BorderPoints(2,n) = Head.colrowsort(find(Head.colrowsort(:,2)==Head.colrowsort(1,2),1,'last'),1); % max x value for the first row (indices)
    Head.BorderPoints(3,n) = Head.colrowsort(1,2); % y value (indices for y value added)

    for i = 2:length(Head.colrowsort(:,2)) % calculation of the max and min colum per row (row after row)
        if Head.colrowsort(i-1,2)~=Head.colrowsort(i,2)
            n=n+1;
            Head.BorderPoints(1,n) = Head.colrowsort(find(Head.colrowsort(:,2)==Head.colrowsort(i,2),1),1); % min x value for the following rows (indices)
            Head.BorderPoints(2,n) = Head.colrowsort(find(Head.colrowsort(:,2)==Head.colrowsort(i,2),1,'last'),1); % max x value for the following rows (indices)
            Head.BorderPoints(3,n) = Head.colrowsort(i,2); % y value for the following rows (indices)
        end
    end
    fprintf(repmat('\b',1,dummy))
    disp('Edge locations Extracted.')

    %% Mask
    dummy=fprintf('Mask generation in progress...');

    n=1;
    % generates a mask where everything inside the head is 1, everything
    % outside is 0
    for i=1:Data.matrixSize2{1}
        for j=1:Data.matrixSize1{1}
            if i==Head.BorderPoints(3,n) %% if row i contains head
                if j>=Head.BorderPoints(1,n) && j<Head.BorderPoints(2,n) % if head is in col j
                    Head.Mask.Matrix(i,j)=1;
                elseif j==Head.BorderPoints(2,n) % für die letzte Spalte
                    Head.Mask.Matrix(i,j)=1;
                    n=n+1;
                    if n>size(Head.BorderPoints,2) % neccessary so that the array bound is not exceeded (dont know why)
                        n=size(Head.BorderPoints,2); % here maximum element of the Borderpoints
                    end
                else
                    Head.Mask.Matrix(i,j)=0;
                end
            else
                Head.Mask.Matrix(i,j)=0;
            end
        end
    end

    Head.Mask.Vector = reshape(Head.Mask.Matrix.',1,[]).'; % col vector of the Mask matrix row by row
    fprintf(repmat('\b',1,dummy))
    disp('Mask generated.')

    % figure
    % imagesc(Head.Mask.Matrix)
    %hold on
    %plot(Head.circle.x,Head.circle.y)

elseif (NDData==3) % for 3D array

    Head.circle.r=175; % inner radius of the coil
    Head.circle.value_x=(max(Data.x{1})+min(Data.x{1}))/2; % mid of the array as value in x
    Head.circle.value_y=(max(Data.y{1})+min(Data.y{1}))/2; % mit of the array as value in y

    Head.circle.pos_x=find(Data.x{1}==round(Head.circle.value_x)); %mid of the array as indice in x
    if ~(Data.x{1}==round(Head.circle.value_x)) % if mid is not part of the array-->
        Head.circle.pos_x=round(length(Data.x{1})/2);
    end

    Head.circle.pos_y=find(Data.y{1}==round(Head.circle.value_y)); %mid of the array as indice in y
    if ~(Data.y{1}==round(Head.circle.value_y)) % if mid is not part of the array-->
        Head.circle.pos_y=round(length(Data.y{1})/2);
    end
    dummy=fprintf('Head contour extraction in progress...');
    Head.circle.value_z=(max(Data.z{1})+min(Data.z{1}))/2;

    Head.circle.pos_z=find(Data.z{1}==round(Head.circle.value_z));
    if ~(Data.z{1}==round(Head.circle.value_z))
        Head.circle.pos_z=round(length(Data.z{1})/2);
    end

    for u=1:Data.zLength{1}
        for i=1:Data.yLength{1}
            for j=1:Data.xLength{1}
                if (Data.Field{1}(j,i,u) == 0) % everything outside the head is 0 anyways
                    Head.Binary(j,i,u)=0;
                else
                    Head.Binary(j,i,u)=1;  % everything inside the head is 1
                end
            end
        end
        Head.Edge(:,:,u)=edge(Head.Binary(:,:,u),'canny'); % performes edge detection using canny edge
    end

    % exclude everything outside the inner bore diameter from the field to
    % exclude coils

    % --> hier ist noch iwo ein fehler mit dem Kreis für
    % 3D, Kopf ist abgeschnitten
    %     for u=1:Data.zLength{1}
    %         for i=1:Data.yLength{1}
    %             for j=1:Data.xLength{1}
    %                 if (Head.Edge(j,i,u) == 1)

    %&& ((i-Head.circle.pos_x)^2+(j-Head.circle.pos_y)^2<=Head.circle.r^2) && ...
    %((i-Head.circle.pos_x)^2+(u-Head.circle.pos_z)^2<=Head.circle.r^2) && ...
    %((j-Head.circle.pos_y)^2+(u-Head.circle.pos_z)^2<=Head.circle.r^2)
    % a^2+b^2=c^2 wenns größer ist, dann außerhalb des radiuses
    % sonst innerhalb
    %                     Head.Edge(j,i,u)=Head.Edge(j,i,u); % alles innerhalb und wenn edge = 1 dann 0; invers zu Head.Edge
    %                 else
    %                     Head.Edge(j,i,u)=0; % alles außerhalb dann 0
    %                 end
    %             end
    %         end
    %     end
    Head.Contour=~Head.Edge;
    fprintf(repmat('\b',1,dummy))
    disp('Contour extracted.')
    %% Head Border Points

    for u= 1:Data.zLength{1}
        dummy=fprintf('Edge location point extraction in progress for image slice in z: %d ...',u);
        if varargin == "nc"
        %if no canny edge used:
        [Head.row, Head.col, Head.hight]=find(Head.Binary(:,:,u)); % find the points of the head contour edge
        else
        % if canny edge is used:
        [Head.row, Head.col, Head.hight]=find(~Head.Contour(:,:,u));
        end

        if isempty(Head.row) || isempty(Head.col)
            Head.row =(0);
            Head.col =(0);
        end
        Head.colrowhight{u}=[Head.col, Head.row, Head.hight];  % x y z, array of both values
        Head.colrowsort{u}=sortrows(Head.colrowhight{u},2); % sorted acending for rows


        n=1; % for first row
        Head.BorderPoints{u}(1,n) = Head.colrowsort{u}(find(Head.colrowsort{u}(:,2)==Head.colrowsort{u}(1,2),1),1); % min x value for the first row (indices)
        Head.BorderPoints{u}(2,n) = Head.colrowsort{u}(find(Head.colrowsort{u}(:,2)==Head.colrowsort{u}(1,2),1,'last'),1); % max x value for the first row (indices)
        Head.BorderPoints{u}(3,n) = Head.colrowsort{u}(1,2); % y value (indices for y value added)

        for i = 2:length(Head.colrowsort{u}(:,2)) % calculation of the max and min colum per row (row after row)
            if Head.colrowsort{u}(i-1,2)~=Head.colrowsort{u}(i,2)
                n=n+1;
                Head.BorderPoints{u}(1,n) = Head.colrowsort{u}(find(Head.colrowsort{u}(:,2)==Head.colrowsort{u}(i,2),1),1); % min x value for the following rows (indices)
                Head.BorderPoints{u}(2,n) = Head.colrowsort{u}(find(Head.colrowsort{u}(:,2)==Head.colrowsort{u}(i,2),1,'last'),1); % max x value for the following rows (indices)
                Head.BorderPoints{u}(3,n) = Head.colrowsort{u}(i,2); % y value for the following rows (indices)
            end

        end

        fprintf(repmat('\b',1,dummy))
    end
    disp('Edge locations extracted.')

    %% Mask

    % generates a mask where everything inside the head is 1, everything
    % outside is 0
    x=1;
    for u=startSlice:endSlice
        n=1;
        dummy=fprintf('Mask generation in progress for image slice in z: %d ...',u);
        for i=1:Data.xLength{1} %y row
            for j=1:Data.yLength{1} %x column
                if i==Head.BorderPoints{u}(3,n) %% if row i contains head
                    if j>=Head.BorderPoints{u}(1,n) && j<Head.BorderPoints{u}(2,n) % if head is in col j
                        Head.Mask.Matrix(i,j,x)=1;
                    elseif j==Head.BorderPoints{u}(2,n) % für die letzte Spalte
                        Head.Mask.Matrix(i,j,x)=1;
                        n=n+1;
                        if n>size(Head.BorderPoints{u},2) % neccessary so that the array bound is not exceeded
                            n=1;
                        end
                    else
                        Head.Mask.Matrix(i,j,x)=0;
                    end
                else
                    Head.Mask.Matrix(i,j,x)=0;
                end
            end
        end
        x=x+1;
        fprintf(repmat('\b',1,dummy))
    end

    for u=1:size(Head.Mask.Matrix,3)
        Head.Mask.VectorN(u,:) = reshape(Head.Mask.Matrix(:,:,u),1,[]); % row vector of the Mask matrix column by column
    end
    %%
    Head.Mask.Vector=[];
    for u=1:size(Head.Mask.VectorN,1)
        Head.Mask.Vector=cat(2,Head.Mask.Vector,Head.Mask.VectorN(u,:)); % image by image added together
    end
    %%
    disp('Mask generated.')

    % figure
    % imagesc(Head.Mask.Matrix)
    %hold on
    %plot(Head.circle.x,Head.circle.y)


else
    disp('Error: invalid Input of Dimension');
end
end