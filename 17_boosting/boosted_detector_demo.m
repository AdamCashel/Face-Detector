function [result, boxes] =  ...
    boosted_detector_demo(image, scales,  classifiers, ...
                          weak_classifiers, face_size, result_number)

% function [result, boxes] =  ...
%     boosted_detector_demo(image, scales,  classifiers, ...
%                           weak_classifiers, face_size, result_number)

boxes = boosted_detector(image, scales, classifiers, ...
                         weak_classifiers, face_size, result_number);
result = image;

for number = 1:result_number
    result = draw_rectangle1(result, boxes(number, 1), boxes(number, 2), ...
                             boxes(number, 3), boxes(number, 4));
end
