library(sqldf)

if(!file.exists("Data")) {dir.create("Data")}

data_file <- "Data/household_power_consumption.txt"

# Only download if the data file doesn't exist yet
if(!file.exists(data_file)) {
    temp <- "Data/household_power_consumption.zip"
    download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",temp)
    unzip(temp,exdir = "Data")
    unlink(temp)
}

# Only retrieve necessary columns
columns <- "Global_active_power"
dates <- "'1/2/2007','2/2/2007'"

household_power <- read.csv.sql("Data/household_power_consumption.txt", 
                     sql = paste("select [Date], [Time], ",columns," from file where [Date] in (",dates,")"), 
                     header = TRUE, 
                     sep = ";")

# Close the connections to avoid warnings
closeAllConnections()

# Turn the dates into actual date/times
household_power$DateTime <- as.POSIXct( strptime(paste(household_power$Date,household_power$Time),"%d/%m/%Y %H:%M:%S"))

# No need to keep those
household_power$Date <- NULL
household_power$Time <- NULL

# NAs are coded as "?", turned in NA by coercing if present
household_power$Global_active_power <- as.numeric(household_power$Global_active_power)

png("plot1.png",
    width = 480,
    height = 480)

hist(household_power$Global_active_power,
     xlab = "Global Active Power (kilowatts)",
     main = "Global Active Power",
     col = "red")

dev.off()
