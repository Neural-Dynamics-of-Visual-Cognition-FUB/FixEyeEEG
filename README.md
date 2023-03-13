# FixEyeEEG 

This code was used to produce the results for the paper **The influence of the bullseye versus standard fixation cross on eye movements and classifying natural images from EEG** by Häberle et al. (2023). The code was written in MATLAB 2021 and R version 1.3.109331

## Preprocessing
Preprocessing relies on function from the *[Fieldtrip Toolbox](https://www.fieldtriptoolbox.org/download/)*
### Eye tracking

*/eyetracking/fix_trials_eyetracking.R* deals with an issue with the trial definition during the recording. 

*/eyetracking/eyetracking_preprocessing_correct_trialinfo_mac.R* preprocesses eye tracking data according to the outlined steps in the paper for the saccade and microsaccade detection algorithm   

*/eyetracking/remove_cleaned_EEG_trials_from_eyetracking.R* reject trials that were rejected during EEG preproceccesing   

*/eyetracking/remove_all_trials_from_eyetracking_not_in_EEG.R/* double check whether there are any additional trials left that differ and remove if that is the case   

*/eyetracking/eyetracking_preprocessing.m* brings preprocessed eye tracking data in the correct format for MVPA and filters at 200 Hz.

### EEG

**IMPORTANT eye tracking preprocessing needs to run before EEG preprocessing**. 

*/EEG/preprocess_EEG.m* preprocesses EEG data according to the steps outlined in the paper. 




## Saccade and microsaccade detection and modelling 

Saccade and microsaccade detection has been performed with the *[Microsaccade Toolbox for R](http://read.psych.uni-potsdam.de/index.php?option=com_content&view=article&id=140:engbert-et-al-2015-microsaccade-toolbox-for-r&catid=26:publications&Itemid=34)*.

*/eyetracking/cross_models.Rmd* calculates GLMMs for number of saccades and microsaccades as well as their amplitudes. 


## Multivariate Pattern Analysis (MVPA)
Scripts for MVPA relie on the *[libsvm toolbox](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)*. 

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
*/decoding/pearson_object_decoding.m* - calculates RDMs on a subject level using 1-Pearson's r 

*/stats/statistics_rsa.m* calculates ground truth RSA between EEG and eye tracking data and calculates statistics

## Statistics 
Scripts to calculate statistics including:
1. cluster based permutation test for time-resolved and time generalized MVPA 
2. bootstrapped peak latencies 
3. representational similarity analysis and the corresponding noise ceilings

## Plotting
Code to reproduce plots from the paper 
