library("lme4")
library("dplyr")

load(file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/df_all_subj_all_sacs_behav.Rda")

# rename1 column for better understanding of the models 
names(df_all_subj_all_sacs_behav)[names(df_all_subj_all_sacs_behav) == "cond"] <- "cross"

df_all_subj_all_sacs_behav$saccType <- ifelse(df_all_subj_all_sacs_behav$amplitude < 1, 'microsaccade', 'saccade')

df_all_subj_all_sacs_behav$cross = as.character(df_all_subj_all_sacs_behav$cross)
df_all_subj_all_sacs_behav$cross[df_all_subj_all_sacs_behav$cross == '1'] = 'bullseye' 
df_all_subj_all_sacs_behav$cross[df_all_subj_all_sacs_behav$cross == '2'] = 'standard' 
df_all_subj_all_sacs_behav$cross = as.factor(df_all_subj_all_sacs_behav$cross)

df_all_subj_all_sacs_behav$category = as.character(df_all_subj_all_sacs_behav$category)
df_all_subj_all_sacs_behav$category[df_all_subj_all_sacs_behav$category == '0'] = 'inanimate' 
df_all_subj_all_sacs_behav$category[df_all_subj_all_sacs_behav$category == '1'] = 'animate' 
df_all_subj_all_sacs_behav$category = as.factor(df_all_subj_all_sacs_behav$category)


# all saccades < 1 are classfied as microsaccades 
df_all_subj_microsaccades = df_all_subj_all_sacs_behav %>% filter(amplitude <1)
df_all_subj_saccades = df_all_subj_all_sacs_behav %>% filter(amplitude >= 1)

#create data frame for number of microsaccades 
df_n_all_saccades = as.data.frame(table(df_all_subj_all_sacs_behav$subj,df_all_subj_all_sacs_behav$trial, df_all_subj_all_sacs_behav$cross, df_all_subj_all_sacs_behav$saccType, df_all_subj_all_sacs_behav$category))
colnames(df_n_all_saccades) = c('subj','trial','cross','saccType','category','n_occurence')

df_n_microsaccades = df_n_all_saccades %>% filter(saccType == 'microsaccade')
df_n_saccades = df_n_all_saccades %>% filter(saccType ==  'saccade')


## all saccades 
contrasts(df_all_subj_all_sacs_behav$cross) = c(-0.5,0.5)
contrasts(df_all_subj_all_sacs_behav$category) = c(-0.5,0.5)

base_amplitude_all = lmer(amplitude ~ 1 + (1+cross+category|subj), df_all_subj_all_sacs_behav, REML = FALSE)
amplitude_all_cross = lmer(amplitude ~ 1 + cross + (1+cross|subj), df_all_subj_all_sacs_behav, REML = FALSE)
amplitude_all_category = lmer(amplitude ~ 1 + category + (1+cross|subj), df_all_subj_all_sacs_behav, REML = FALSE)
amplitude_all_cross_category = lmer(amplitude ~ 1 + cross+category + (1+cross|subj), df_all_subj_all_sacs_behav, REML = FALSE)
amplitude_all_cross_category_interaction = lmer(amplitude ~ 1 + cross*category + (1+cross|subj), df_all_subj_all_sacs_behav, REML = FALSE)

save(base_amplitude_all, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/base_amplitude_all")
save(amplitude_all_cross, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_all_cross")
save(amplitude_all_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_all_category")
save(amplitude_all_cross_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_all_cross_category")
save(amplitude_all_cross_category_interaction, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_all_cross_category_interaction")


## microsaccades 
contrasts(df_all_subj_microsaccades$cross) = c(-0.5,0.5)
contrasts(df_all_subj_microsaccades$category) = c(-0.5,0.5)

base_amplitude_ms = lmer(amplitude ~ 1 + (1+cross|subj), df_all_subj_microsaccades, REML = FALSE)
amplitude_ms_cross = lmer(amplitude ~ 1 + cross + (1+cross|subj), df_all_subj_microsaccades, REML = FALSE)
amplitude_ms_category = lmer(amplitude ~ 1 + category + (1+cross|subj), df_all_subj_microsaccades, REML = FALSE)
amplitude_ms_cross_category = lmer(amplitude ~ 1 + cross+category + (1+cross|subj), df_all_subj_microsaccades, REML = FALSE)
amplitude_ms_cross_category_interaction = lmer(amplitude ~ 1 + cross*category + (1+cross|subj), df_all_subj_microsaccades, REML = FALSE)

save(base_amplitude_ms, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/base_amplitude_ms")
save(amplitude_ms_cross, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_ms_cross")
save(amplitude_ms_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_ms_category")
save(amplitude_ms_cross_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_ms_cross_category")
save(amplitude_ms_cross_category_interaction, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_ms_cross_category_interaction")

## saccades 

contrasts(df_all_subj_saccades$cross) = c(-0.5,0.5)
contrasts(df_all_subj_saccades$category) = c(-0.5,0.5)

base_amplitude_sac = lmer(amplitude ~ 1 + (1+cross|subj), df_all_subj_saccades, REML = FALSE)
amplitude_sac_cross = lmer(amplitude ~ 1 + cross + (1+cross|subj), df_all_subj_saccades, REML = FALSE)
amplitude_sac_category = lmer(amplitude ~ 1 + category + (1+cross|subj), df_all_subj_saccades, REML = FALSE)
amplitude_sac_cross_category = lmer(amplitude ~ 1 + cross+category + (1+cross|subj), df_all_subj_saccades, REML = FALSE)
amplitude_sac_cross_category_interaction = lmer(amplitude ~ 1 + cross*category + (1+cross|subj), df_all_subj_saccades, REML = FALSE)

save(base_amplitude_sac, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/base_amplitude_sac")
save(amplitude_sac_cross, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_sac_cross")
save(amplitude_sac_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_sac_category")
save(amplitude_sac_cross_category, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_sac_cross_category")
save(amplitude_sac_cross_category_interaction, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/amplitude_sac_cross_category_interaction")

