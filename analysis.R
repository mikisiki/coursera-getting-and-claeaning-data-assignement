library(dplyr)
library(data.table)

#create a directory 
if (!dir.exists("data")){
  dir.create("data")
}

setwd("data")
#download data
URL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, destfile = "data.zip", method = "libcurl")
unzip("data.zip")

#change working directory to a folder with data
setwd(list.files()[2])

#read colnames from a file
features = read.table("features.txt")[,2]
#extracts only the indices of the measurements on the mean and standard 
#deviation for each measurement.
indices <- grep("mean|std", features) 
#extracts the appropriate colnames
names <- as.character(features[indices])

#read activity label
activity_labels = read.table('activity_labels.txt')
colnames(activity_labels) <- c("label", "activity")

#read train data
train_data = fread('train/X_train.txt', select = indices, data.table = FALSE)
train_labels = read.table('train/y_train.txt')
train_subjects = read.table('train/subject_train.txt')
#merge train data into one data set
train_data <- cbind(train_data, train_subjects, train_labels)

#read test data
test_data = fread('test/X_test.txt', select = indices, data.table = FALSE)
test_labels = read.table('test/y_test.txt')
test_subjects = read.table('test/subject_test.txt')
#merge test data
test_data <- cbind(test_data, test_subjects, test_labels)

#merge test and train data into one data set
data_set = rbind(test_data,train_data)

#labels the data set with descriptive variable names
colnames(data_set) = c(names, "subject", "label")

#descriptive activity names to name the activities in the data set
merged_data = merge(data_set, activity_labels, by = "label", all = TRUE )
merged_data = select(merged_data,-1)

#independent tidy data set with the average of each variable for each activity and each subject.
tidy_average_data_set <- merged_data %>% group_by(subject, activity) %>% summarise_all(funs(mean)) 

colnames(tidy_average_data_set)[3:81] <-paste0("average_", colnames(tidy_average_data_set)[3:81])
#save tidy data set
write.table(tidy_average_data_set, file = "tidy_average_data_set.txt", row.names = FALSE)

tab = read.table("tidy_average_data_set.txt", header = TRUE)
