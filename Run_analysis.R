# First obtain the data
## Download the zip file
fileName <- "UCIdata.zip"
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

## Check if the file already exists, then put it in working directory
if(!file.exists(fileName)){
        download.file(url,fileName, mode = "wb") 
}
# ... where wb = binary mode;

## Check if the directory already exists, then unzip the downloaded file, 
if(!file.exists(dir)){
        unzip("UCIdata.zip", files = NULL, exdir=".")
}
# where: 
# - files = vector of recorded filepaths to be extracted
# - exdir = directory to which files are extracted, created if necessary

# Provide references to the files
path_ref <- file.path("." , "UCI HAR Dataset")
files <- list.files(path_ref, recursive=TRUE)

## Then read in the data:

# "X_train.txt" and "X_test.txt" provide the features values:
testfeatures <- read.table(file.path(path_ref, "test" , "X_test.txt" ),header = FALSE)
trainfeatures <- read.table(file.path(path_ref, "train", "X_train.txt"),header = FALSE)

# "Y_train.txt" and "Y_test.txt" provide the activity values:
testactivity  <- read.table(file.path(path_ref, "test" , "Y_test.txt" ),header = FALSE)
trainactivity <- read.table(file.path(path_ref, "train", "Y_train.txt"),header = FALSE)

# "subject_train.txt" and subject_test.txt" provide the subject values:
trainsubject <- read.table(file.path(path_ref, "train", "subject_train.txt"),header = FALSE)
testsubject <- read.table(file.path(path_ref, "test" , "subject_test.txt"), header = FALSE)

# "activity_labels.txt" provides the activity labels
activitylabels <- read.table(file.path(path_ref, "activity_labels.txt"), header = FALSE)


## "You should create one R script called run_analysis.R that does the following."
# "1. Merge the training and the test sets to create one data set."

# step 1: connect the features, activity and subject tables
subject <- rbind(trainsubject, testsubject)
activity <- rbind(trainactivity, testactivity)
features <- rbind(trainfeatures, testfeatures)

# step 2: insert names
names(subject)<-c("subject")
names(activity)<- c("activity")
# ... since "features.txt" provides the features names:
namesfeatures <- read.table(file.path(path_ref, "features.txt"), head=FALSE)
names(features)<- namesfeatures$V2

# step 3: combine all data
subjectactivity <- cbind(subject, activity)
finaldata <- cbind(features, subjectactivity)


# "2. Extract only the measurements on the mean and standard deviation for each measurement."

# step 1: take the names where mean or std is mentioned in features
meanstdfeatures <- namesfeatures$V2[grep("mean\\(\\)|std\\(\\)", namesfeatures$V2)]
# .. where grep finds the elements matching the provided search phrase

# step 2: use these names to subset from the finaldata
subnamesfeatures <- c(as.character(meanstdfeatures), "subject", "activity" )
meanstddata <- subset(finaldata, select = subnamesfeatures)


# "3. Uses descriptive activity names to name the activities in the data set"

meanstddata <- merge(x= meanstddata, y = activitylabels, by.x = "activity", by.y = "V1", all.x = TRUE)
colnames(meanstddata)[69] <- c("activitylabel")

# examples of descriptive statistics:
str(meanstddata$activitylabel)
summary(meanstddata$activitylabel)
head(meanstddata$activitylabel, 10)


# "4. Appropriately labels the data set with descriptive activity names"

# Before, the activity and subject variables were named. 
# Left to be labelled are the features:
names(meanstddata)<- gsub("Acc", "Accelerometer", names(meanstddata))
names(meanstddata)<- gsub("BodyBody", "Body", names(meanstddata))
names(meanstddata)<- gsub("^f", "frequency", names(meanstddata))
names(meanstddata)<- gsub("Gyro", "Gyroscope", names(meanstddata))
names(meanstddata)<- gsub("Mag", "Magnitude", names(meanstddata))
names(meanstddata)<- gsub("^t", "time", names(meanstddata))

# "5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject."

tidydata <- ddply(meanstddata, c("subject","activity"), numcolwise(mean))
write.table(tidydata, file="tidydata.txt", sep = ",")