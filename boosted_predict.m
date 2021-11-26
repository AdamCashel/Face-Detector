function result = boosted_predict(image, boosted_model, weak_classifiers, classifier_number)
% function result = boosted_predict(image, boosted_model, weak_classifiers, classifier_number)
% Classify an instance (image) given the boosted model and the weak classifiers.
%
% Parameters:
% image - the instance for which we want to predict its label. Note: the
%           image size has to be the same as the ones used for training.
% boosted_model - The trained model generated by AdaBoost. Contains the
%                   indexes, alpha values, and threshold of each
%                   weak classifier selected by AdaBoost.
% weak_classifiers - The list of all random weak_classifiers generated.
% classifier_number - How many weak classifiers to use for prediction.
%
% Return:
% result - The prediction value. Positive values indicate a positive
%           class prediction, whereas negative values indicate a negative
%           class prediction.


if nargin < 4   % classifier_number not provided
    % Used all weak classifiers selected by AdaBoost
    classifier_number = size(boosted_model, 1);
end

% Number of classifiers to use cannot be bigger than how many were selected
% by AdaBoost
classifier_number = min(size(boosted_model, 1), classifier_number);

image = double_gray(image);

%integral_img = integral_image(image); % Uses the given integral_image function
integral_img = integralImage(image); % Uses the integralImage function that comes with Matlab
                                     % which is faster than the given integral_image function
integral_img = integral_img(2:end,2:end); % The Matlab integralImage function adds an extra
                                          % row and column, which we need to get rid of.

result = 0;

for i=1:classifier_number
	classifier_index = boosted_model(i, 1);
    classifier_alpha = boosted_model(i, 2);
    classifier_threshold = boosted_model(i, 3);
	
    weak_cl = weak_classifiers{classifier_index};
    weak_eval = eval_weak_classifier(weak_cl, integral_img);
    
    if weak_eval > classifier_threshold
        weak_decision = 1;
    else
        weak_decision = -1;
    end
    
    result = result + weak_decision * classifier_alpha;
end

return;