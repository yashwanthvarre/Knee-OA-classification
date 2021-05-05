
%yashwanth_varre; U01758611; Final-project_code

location = 'C:\Users\akars\Documents\Spring_2021_course_documents\Computer_vision\matlab_programs\preds';
filePattern = fullfile(location, '*.png'); %Taking all the png images
dataset = dir(filePattern); %  folder in which your images exists
temp = 0;
min_dist = []; %vector for minimum distance
min_dist_vector=[];
for i =1: 193
   
    for k = temp+1 : temp +160
        
        %Writing file names individually
        baseFileName = dataset(k).name;
        disp(baseFileName);
        %Keeping the location of folder and file names under one variable
        fullFileName = fullfile(location, baseFileName);
        
        %Reading the images
        mydata = imread(fullFileName);
        edges = edge(mydata,'Canny'); %Extracting the edges of the images using canny edge detection
        edges = bwareafilt(edges, 2, 'Largest'); %Selecting the largest blobs in the image (femur and tibia bones)

        %Providing imported data as input to algorithm
        image_bw=edges; 
        
         %Converting input to logical format
        image_bw = logical(image_bw); 
        
        %Using areafilt we first we find the latgest object in the image
        object1=bwareafilt(image_bw,1);
        warning('off');
        %Extracting rows and columns of object1
        [rows_obj1,cols_obj1]=find(object1);
        
         %Object2
        object2=image_bw-object1; 
        object2=bwareaopen(object2, 220,8);
        
        %Extracting rows and columns of object2
        [rows_obj2,cols_obj2]=find(object2);
        
        % Rows an columns of object1
        matrix_A1=[cols_obj1 rows_obj1];
        
        % Rows an columns of object2
        matrix_A2=[cols_obj2 rows_obj2];
        
        
        if size(cols_obj2) == [0 1]
            dmin = 0;
%            disp("dmin is zero"); 
          else
        %Finding the pair wise distance between object 1 and objec
        dist = pdist2(matrix_A1,matrix_A2);
        
        %Finding the minimum distance
        [dmin,idx] = min(dist(:));
        [row, col] = ind2sub(size(dist), idx);
       
        end
       
        % storing the value of dmin in a vector
        min_dist = [min_dist;dmin]; 
    end
min_dist=mean(min_dist(min_dist>0)); %Finding the average of non zero distances in the vector
    
min_dist_vector=[min_dist_vector;min_dist]; %storing the minimum distances into a vector
    
temp = temp +160;
min_dist = [];

end

opts = detectImportOptions('Supporting file.csv'); %Importing the bone dataset
opts.SelectedVariableNames = {'id','V03KLGrade'}; % Choosing only specific columns
Table1 = readtable('Supporting file',opts); %converting them into a table
T3= table(min_dist_vector); %COnverting the vector into a table

AB = [T3 Table1]; % COmbining the two tables 
writetable(AB,('tibia_4.csv'));

