library(reshape2)
library(curl)




## Download and unzip the dataset:
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, "getdata.zip")

if (!file.exists("UCI_HAR_Dataset")) { 
  unzip("getdata.zip") 
}

# Get activity and feature information

actLabels = read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] = as.character(actLabels[,2])
features = read.table("UCI HAR Dataset/features.txt")
features[,2] = as.character(features[,2])

# Extract only the mean & Std Dev features 

featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load the Training Data Set

train =  read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainAct = read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects = read.table("UCI HAR Dataset/train/subject_train.txt")
trainData = cbind(trainSubjects, trainAct, train)

# Load the Test Data Set

test = read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testAct = read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects = read.table("UCI HAR Dataset/test/subject_test.txt")
testData = cbind(testSubjects, testAct, test)

# Merge the Training and Test Data sets
completeData = rbind(trainData,testData)

## test head(completeData,2)
## Add Labels

colnames(completeData) = c("subject", "activity", featuresWanted.names)

# test head(completeData,2)
## Turn activities and subjects into Factors
completeData$activity = factor(completeData$activity, levels = actLabels[,1], labels = actLabels[,2])
completeData$subject = as.factor(completeData$subject)

completeData.melted = melt(completeData, id = c("subject", "activity"))
completeData.mean = dcast(completeData.melted, subject + activity ~ variable, mean)

# write to tidy.txt

write.table(completeData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
