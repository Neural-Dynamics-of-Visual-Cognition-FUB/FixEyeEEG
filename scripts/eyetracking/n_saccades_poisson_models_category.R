
library("lme4")
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

# set contrast coding to effect coding as we are interested in the main effects 
contrasts(df_n_all_saccades$cross) = c(-0.5,0.5)
contrasts(df_n_all_saccades$category) = c(-0.5,0.5)

# #these would be the full models which do not converge 
base_n_saccades_full = glmer(n_occurence ~ 1 + (1+cross+category|subj), df_n_saccades,family = "poisson")
cross_n_saccades_full = glmer(n_occurence ~ 1 + cross + (1+cross+category|subj), df_n_saccades, family = "poisson")
category_n_all_saccades_full = glmer(n_occurence ~ 1 + category + (1+cross+category|subj), df_n_saccades, family = "poisson")

cross_category_n_saccadess_full = glmer(n_occurence ~ 1 + cross + category + (1+cross+category|subj), df_n_saccades, family = "poisson")
cross_category_interaction_n_saccadess_full = glmer(n_occurence ~ 1 + cross * category + (1+cross*category|subj), df_n_saccades, family = "poisson")

save.lmer.effects(base_n_saccades_full, 
     file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/base_n_saccades_full")
save.lmer.effects(cross_n_saccades_full, 
     file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_n_saccades_full")
save.lmer.effects(category_n_all_saccades_full, 
     file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/category_n_all_saccades_full")
save.lmer.effects(cross_category_n_saccadess_full, 
     file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_n_saccadess_full")
save.lmer.effects(cross_category_interaction_n_saccadess_full, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_interaction_n_saccadess_full")
# microsaccades 
# set contrast coding to effect coding as we are interested in the main effects 
contrasts(df_n_microsaccades$cross) = c(-0.5,0.5)
contrasts(df_n_microsaccades$category) = c(-0.5,0.5)

#these would be the full models which do not converge 
base_n_microsaccades = glmer(n_occurence ~ 1 + (1+cross+category|subj), df_n_microsaccades,family = "poisson")
cross_n_microsaccades = glmer(n_occurence ~ 1 + cross + (1+cross+category|subj), df_n_microsaccades, family = "poisson")
category_n_microsaccades = glmer(n_occurence ~ 1 + category + (1+cross+category|subj), df_n_microsaccades, family = "poisson")

cross_category_n_microsaccades = glmer(n_occurence ~ 1 + cross + category + (1+cross+category|subj), df_n_microsaccades, family = "poisson")
cross_category_interaction_n_microsaccades = glmer(n_occurence ~ 1 + cross * category + (1+cross*category|subj), df_n_microsaccades, family = "poisson")

save.lmer.effects(base_n_microsaccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/base_n_microsaccades")
save.lmer.effects(cross_n_microsaccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_n_microsaccades")
save.lmer.effects(category_n_microsaccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/category_n_microsaccades")
save.lmer.effects(cross_category_n_microsaccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_n_microsaccades")
save.lmer.effects(cross_category_interaction_n_microsaccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_interaction_n_microsaccades")


# set contrast coding to effect coding as we are interested in the main effects 
contrasts(df_n_saccades$cross) = c(-0.5,0.5)
contrasts(df_n_saccades$category) = c(-0.5,0.5)

#these would be the full models which do not converge 
base_n_saccades = glmer(n_occurence ~ 1 + (1+cross+category|subj), df_n_saccades,family = "poisson")
cross_n_saccades = glmer(n_occurence ~ 1 + cross + (1+cross+category|subj), df_n_saccades, family = "poisson")
category_n_saccades = glmer(n_occurence ~ 1 + category + (1+cross+category|subj), df_n_saccades, family = "poisson")
cross_category_n_saccades = glmer(n_occurence ~ 1 + cross + category + (1+cross+category|subj), df_n_saccades, family = "poisson")
cross_category_interaction_n_saccades = glmer(n_occurence ~ 1 + cross * category + (1+cross*category|subj), df_n_saccades, family = "poisson")

save.lmer.effects(base_n_saccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/base_n_saccades")
save.lmer.effects(cross_n_saccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_n_saccades")
save.lmer.effects(category_n_saccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/category_n_saccades")
save.lmer.effects(cross_category_n_saccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_n_saccades")
save.lmer.effects(cross_category_interaction_n_saccades, 
                  file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/models/category/cross_category_interaction_n_saccades")
