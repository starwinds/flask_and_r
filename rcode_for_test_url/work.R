require(RJSONIO)
temp2 <- '{\"namespace\": \"ucloud/server\", \"dimensions\": {\"count\": 1, \"dimension\": [{\"name\": \"name\", \"value\": \"sis-test-windows(d030b375-7f44-4834-a62d-34fe22409227)\"}]}, \"unit\": \"Bytes\", \"metricname\": \"NetworkOut\"}'
json_file <- fromJSON(temp2)

json_file <- lapply(json_file, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

json_file$dimensions <- NULL

temp_df <- as.data.frame(do.call(cbind,json_file))

# final work for json list  

temp2 <- '[{\"namespace\": \"ucloud/server\", \"dimensions.name\": \"template\",\"dimensions.value\": \"ubuntu\", \"unit\": \"Bytes\", \"metricname\": \"NetworkOut\"},{\"namespace\": \"ucloud/server\", \"dimensions.name\": \"template\",\"dimensions.value\": \"centos\", \"unit\": \"Bytes\", \"metricname\": \"NetworkOut\"},{\"namespace\": \"ucloud/server\", \"dimensions.name\": \"template\",\"dimensions.value\": \"window\", \"unit\": \"Bytes\", \"metricname\": \"NetworkOut\"}]'
json_file <- fromJSON(temp2)

json_file <- lapply(json_file, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

temp_df <- as.data.frame(do.call(rbind,json_file))

timestamp <- "2015-03-01T01:55:00.000"
t <- paste(strsplit(timestamp,'T')[[1]][1],strsplit(timestamp,'T')[[1]][2])
temp_date <- strptime(t,"%Y-%m-%d %H:%M:%S")

temp_df <- data.frame(cbind(c("2015-02-23T00:05:00.000","2015-02-23T00:10:00.000","2015-02-23T00:15:00.000"),c(0.04525,0.0442499998,0.0417500004)))
names(temp_df) <- c('date','cpu')
temp_df$date <- as.character(temp_df$date)
temp_df2 <- cbind(temp_df,strptime(paste(strsplit(temp_df$date,'T')[[1]][1],strsplit(temp_df$date,'T')[[1]][2]),"%Y-%m-%d %H:%M:%S"))
names(temp_df2)[3] <- c("date2")

