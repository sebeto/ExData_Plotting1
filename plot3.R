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
columns <- "Sub_metering_1,Sub_metering_2,Sub_metering_3"
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
household_power$Sub_metering_1 <- as.numeric(household_power$Sub_metering_1)
household_power$Sub_metering_2 <- as.numeric(household_power$Sub_metering_2)
household_power$Sub_metering_3 <- as.numeric(household_power$Sub_metering_3)

png("plot3.png",
    width = 480,
    height = 480)

plot(household_power$DateTime,
     household_power$Sub_metering_1,
     type = "l",
     xlab = "",
     ylab = "Energy sub metering")

lines(household_power$DateTime,
      household_power$Sub_metering_2,
      col = "red")

lines(household_power$DateTime,
      household_power$Sub_metering_3,
      col = "blue")

legend("topright",
       legend = c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
       lty=c(1,1,1),
       col = c("black","red","blue"))

dev.off()

