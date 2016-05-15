################ LIBRARIES ##################
library(data.table)

################ LOAD DATA ##################
data_path <- "UCI HAR Dataset/train/"
data_test_path <- "UCI HAR Dataset/test/"

## Train data sets
X_train_data_raw <- read.table(paste0(data_path,"X_train.txt"))
Y_train_data_raw <- read.table(paste0(data_path,"y_train.txt"))
subject_train_data_raw <- read.table(paste0(data_path,"subject_train.txt"))

## Test data sets
X_test_data_raw <- read.table(paste0(data_test_path,"X_test.txt"))
Y_test_data_raw <- read.table(paste0(data_test_path,"y_test.txt"))
subject_test_data_raw <- read.table(paste0(data_test_path,"subject_test.txt"))

# Features
feature_names <- read.table("UCI HAR Dataset/features.txt")[,2]

## Activity names
activity_names <- read.table("UCI HAR Dataset/activity_labels.txt")


########################################################################
### 1. Merges the training and the test sets to create one data set. ###
########################################################################
X_data_raw <- rbind(X_train_data_raw,X_test_data_raw)
y_data_raw <- rbind(Y_train_data_raw,Y_test_data_raw)
subject_data <- rbind(subject_train_data_raw,subject_test_data_raw)

## Rename columns in X_data
names(X_data_raw) <- feature_names

##################################################################################################
### 2. Extracts only the measurements on the mean and standard deviation for each measurement. ###
##################################################################################################
mean_vector <- which(grepl("mean\\(\\)",feature_names) == T )
std_vector <- which(grepl("std\\(\\)",feature_names) == T )

filter_vector <- c(mean_vector,std_vector)

X_data <- X_data_raw[,filter_vector]

#################################################################################
### 3. Uses descriptive activity names to name the activities in the data set ###
#################################################################################
y_data <- merge(y_data_raw,activity_names)

##############################################################################
### 4. Appropriately labels the data set with descriptive variable names. ####
##############################################################################
## y_data
names(y_data) <- c("activity_id","activity_name")
## subject_data
names(subject_data) <- "subject"
## X_data
X_data_col_names <- colnames(X_data)
X_data_col_names <- gsub(  "-", "_",X_data_col_names)
X_data_col_names <- gsub(  "[()]", "",X_data_col_names)
X_data_col_names <- gsub(  "mean", "MEAN",X_data_col_names)
X_data_col_names <- gsub(  "std", "STD",X_data_col_names)

names(X_data) <- X_data_col_names

########################################################################################################################################################
### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject ###
########################################################################################################################################################
tidy_data <- cbind(X_data,y_data,subject_data)

groupBy <- list(tidy_data$activity_name,tidy_data$subject)
data_grouped <- aggregate(tidy_data, by =  groupBy, mean)

names(data_grouped)[c(1,2)] <- c("Activity","Subject")
means_tidy_data <- data_grouped[,1:66]


## Write the output file in the current working directory
write.table(means_tidy_data ,file = "means_data_output.txt",row.names = FALSE)
