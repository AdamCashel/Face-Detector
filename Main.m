face_vertical = 100;
face_horizontal = 100;


% choosing a set of random weak classifiers
number = 1000;
weak_classifiers = cell(1, number);
for i = 1:number
    weak_classifiers{i} = generate_classifier(face_vertical, face_horizontal);
end

% save classifiers1000 weak_classifiers

%%

%  precompute responses of all training examples on all weak classifiers

%clear all;
%load examples1000;
%load classifiers1000;

%load training faces and nonfaces


example_number = size(faces, 3) + size(nonfaces, 3);
labels = zeros(example_number, 1);
labels (1:size(faces, 3)) = 1;
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
        responses(feature, example) = eval_weak_classifier(classifier, integral);
    end
    disp(example)
end

% save training1000 responses labels classifier_number example_number

%Calling adaboost to find error rates of 25 strong classifiers
boosted_classifier = AdaBoost(responses, labels, 25);


