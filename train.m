
directory;
userpath(code_directory);
%Gettting training_faces into matrix
Location = 'training_faces\*bmp';
Location = append(data_directory,Location);
current_face_size = 100;
current_nonface_size = 100;
ds = imageDatastore(Location);
length = 3547; %Number of pictures in training_faces
faces = zeros(35,35,100); %Matrix to hold current training face pics
total_facepics = zeros(35,35,length); % Matrix to hold all training face pics 
total_nonfacepics = zeros(35,35,length); % Matrix to hold all training nonface pics 
counter = 1;

while hasdata(ds)
    tempImage = read(ds);
    tempImage = mat2gray(tempImage);
    tempImage = tempImage(1:35,1:35);
    total_facepics(:,:,counter) = tempImage;
    %faces(:,:,counter) = tempImage;
    
    counter = counter + 1;
end

%Gettting training_nonfaces into matrix
Location2 = 'training_nonfaces\*jpg';
Location2 = append(data_directory,Location2);
ds2 = imageDatastore(Location2);
length = 3547; %Number of pictures in training_faces
nonfaces = zeros(35,35,100);
counter = 1;

while hasdata(ds2)
    tempImage = read(ds2);
    tempImage = mat2gray(tempImage);
    tempImage = tempImage(1:35,1:35);
    total_nonfacepics(:,:,counter) = tempImage;
    %nonfaces(:,:,counter) = tempImage;
    
    counter = counter + 1;
end

%Get only the first 100 training pics of face and nonface
faces(:,:,1:100) = total_facepics(:,:,1:100);
nonfaces(:,:,1:100) = total_nonfacepics(:,:,1:100);


% choosing a set of random weak classifiers
number = 10000;
face_vertical = 35;
face_horizontal = 35;
weak_classifiers = cell(1, number);
for i = 1:number
    weak_classifiers{i} = generate_classifier(face_vertical, face_horizontal);
end

% save classifiers1000 weak_classifiers

%Get face_integrals
face_integrals = zeros(35,35,current_face_size);

for i = 1:current_face_size
    face_integrals(:,:,i) = integral_image(faces(:,:,i));
    
end

%Get nonface_integrals
nonface_integrals = zeros(35,35,current_nonface_size);

for i = 1:current_nonface_size
    nonface_integrals(:,:,i) = integral_image(nonfaces(:,:,i));
     
end




face_vertical = 35;
face_horizontal = 35;




%%

%  precompute responses of all training examples on all weak classifiers

%clear all;
%load examples1000;
%load classifiers1000;

%load training faces and nonfaces

example_number = size(faces, 3) + size(nonfaces, 3);
labels = zeros(example_number, 1);
labels(1:size(faces, 3)) = 1;
labels((size(faces, 3)+1):example_number) = -1;
examples = zeros(face_vertical, face_horizontal, example_number);
examples (:, :, 1:size(faces, 3)) = face_integrals;
examples(:, :, (size(faces, 3)+1):example_number) = nonface_integrals;

classifier_number = numel(weak_classifiers);

responses =  zeros(classifier_number, example_number);

for example = 1:example_number
    integral = examples(:, :, example);
    for feature = 1:classifier_number
        classifier = weak_classifiers {feature};
        %eval_weak_classifier(classifier, integral);
        responses(feature, example) = eval_weak_classifier(classifier, integral);
    end
end

% save training1000 responses labels classifier_number example_number

%Calling adaboost to find error rate of strong classifier with 35 rounds of
%training
boosted_classifier = AdaBoost(responses, labels, 35)
Total = 0;
Correct_Ada = 0;
Wrong_Ada = 0;
for j = 1:3547
    prediction = boosted_predict(total_nonfacepics(:,:,j), boosted_classifier, weak_classifiers, 35);
    Total = Total + 1;
    
    if prediction > 3
        Wrong_Ada = Wrong_Ada + 1;
    else
        Correct_Ada = Correct_Ada + 1;
    end
    
    prediction = boosted_predict(total_facepics(:,:,j), boosted_classifier, weak_classifiers, 35);
    Total = Total + 1;
    
    if prediction < 3
        Wrong_Ada = Wrong_Ada + 1;
    else
        Correct_Ada = Correct_Ada + 1;
    end
    
end

Correct_Ada_Percentage = (Correct_Ada / Total) * 100







%Bootstraping Section

%Detecting nonfaces
numberpics = 0;
wrong = 0;

for j = (100)+1:3547
    prediction = boosted_predict(total_nonfacepics(:,:,j), boosted_classifier, weak_classifiers, 35);
    numberpics = numberpics + 1;
    %if prediction is less than 0 add to training data
    prediction
    if prediction > 3
        current_nonface_size = current_nonface_size + 1;
        temp_matrix = zeros(35,35,current_nonface_size);
        temp_matrix = nonfaces(:,:,1:current_nonface_size-1);
        temp_matrix(:,:,current_nonface_size) = total_nonfacepics(:,:,j);
        nonfaces = zeros(35,35,current_nonface_size);
        nonfaces(:,:,1:current_nonface_size) = temp_matrix(:,:,1:current_nonface_size);
        
        %Get and Add integral nonface picture
        tempmatrix = zeros(35,35,current_nonface_size);
        tempmatrix(:,:,1:current_nonface_size-1) = nonface_integrals(:,:,1:current_nonface_size-1);
        tempmatrix(:,:,current_nonface_size) = integral_image(total_nonfacepics(:,:,j));
        nonface_integrals = zeros(35,35,current_nonface_size);
        nonface_integrals(:,:,1:current_nonface_size) = tempmatrix(:,:,1:current_nonface_size);
        
        wrong = wrong + 1;
    end
end


wrong;
correct = numberpics - wrong;
Correct_Percentage_Bootstrapping_Faces = (correct / numberpics) * 100
%Dectecting faces
%Add threshold other than 0

numberpics = 0;
wrong = 0;

for k = (100)+1:3547
     prediction = boosted_predict(total_facepics(:,:,k), boosted_classifier, weak_classifiers, 35);
     numberpics = numberpics + 1;
    %if prediction is less than 0 add to training data
    if prediction < 3
        current_face_size = current_face_size + 1;
        temp_matrix = zeros(35,35,current_face_size);
        temp_matrix = faces(:,:,1:current_face_size-1);
        temp_matrix(:,:,current_face_size) = total_facepics(:,:,k);
        faces = zeros(35,35,current_face_size);
        faces(:,:,1:current_face_size) = temp_matrix(:,:,1:current_face_size);
        
        %Get and Add integral face picture
        tempmatrix = zeros(35,35,current_face_size);
        tempmatrix(:,:,1:current_face_size-1) = face_integrals(:,:,1:current_face_size-1);
        tempmatrix(:,:,current_face_size) = integral_image(total_facepics(:,:,k));
        face_integrals = zeros(35,35,current_face_size);
        face_integrals(:,:,1:current_face_size) = tempmatrix(:,:,1:current_face_size);
        
        wrong = wrong + 1;
    end
end



wrong
correct = numberpics - wrong
Correct_Percentage_Bootstrapping_NonFaces = (correct / numberpics) * 100


%Classifier Cascades
%Result is either a face or not a face for a window of an image
%If result = 1 -> predicted face pic, If result = 0 -> predicted nonface
%pic
Total_Pics = 0;
Wrong_Total = 0;
for f = 1:current_face_size
    %tetsing faces
    here = 'here';
    Total_Pics = Total_Pics + 1;
    result = cascade_classify(faces(:,:,f), boosted_classifier,weak_classifiers);
    if result == 0
        Wrong_Total = Wrong_Total + 1;
    end
end
Wrong_Total
Correct_Total = Total_Pics - Wrong_Total;
Correct_Percentage = Correct_Total / Total_Pics
Total_Pics = 0;
Wrong_Total = 0;

for f = 1:current_nonface_size
     %testing nonfaces
      Total_Pics = Total_Pics + 1;
    result = cascade_classify(nonfaces(:,:,f), boosted_classifier, weak_classifiers);
    if result == 1
        Wrong_Total = Wrong_Total + 1;
    end 
end
Wrong_Total
Correct_Total = Total_Pics - Wrong_Total;
Correct_Percentage = Correct_Total / Total_Pics

save boosted_classifier
save weak_classifiers







