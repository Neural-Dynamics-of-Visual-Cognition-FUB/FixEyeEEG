# FixEyeEEG 

This code was used to produce the results for the paper **The influence of the bullseye versus standard fixation cross on eye movements and classifying natural images from EEG** by Häberle et al. (2023). The code was written in MATLAB 2021 and R version 1.3.109331

To clone the repository use the following link: 

**add in link for cloning the repository** 


## Preprocessing

### EEG

*/EEG/preprocess_EEG.m* preprocesses EEG data according to the steps outlined in the paper. 

### Eye tracking

*/eyetracking/eyetracking_preprocessing.Rmd preprocesses eye tracking data according to the outlined steps in the paper for the saccade and microsaccade detection algorithm 

*/eyetracking/eyetracking_preprocessing.m* brings preprocessed eye tracking data in the correct format for MVPA and filters at 200 Hz.

## Saccade and microsaccade detection and modelling 

*/eyetracking/cross_models.Rmd* calculates GLMMs for number of saccades and microsaccades as well as their amplitudes. 


## Multivariate Pattern Analysis (MVPA)

### Time-resolved object decoding 
*/decoding/category_decoding_SVM.m* - time-resolved animate versus inanimate category decoding with two flags:
1. subj (subject identifier as integer) 
3. method (either 'eeg' or 'eye' for eye tracking)
### Time-resolved category decoding
*/decoding/object_decoding_SVM_all_same_trials.m* - time-resolved object exemplar decoding with three flags:
subj and method (either EEG or eye for eye tracking)
1. subj (subject identifier as integer) 
2. fixation condition ('standard' or 'bulls')
3. method (either 'eeg' or 'eye' for eye tracking)
### Time-generalized object decoding 
*/decoding/time_time_object_decoding.m* - time-generalized object exemplar decoding with three flags:
subj and method (either EEG or eye for eye tracking)
1. subj (subject identifier as integer) 
2. fixation condition ('standard' or 'bulls')
3. method (either 'eeg' or 'eye' for eye tracking)

### Time-generalized category decoding
*/decoding/time_time_category_decoding.m* - time-generalized animate versus inanimate object decoding with three flags:
subj and method (either EEG or eye for eye tracking)
1. subj (subject identifier as integer) 
2. fixation condition ('standard' or 'bulls')
3. method (either 'eeg' or 'eye' for eye tracking)

## Representational Similarity Analysis (RSA)

## Statistics 

## Plotting
