require(RJSONIO)
options(shiny.trace = TRUE) # debug logging 

get_df_from_url_param <- function(input_str){
  cat("input_str = ",input_str,file=stderr())
  input_str <- gsub("'","\"",input_str)
  input_str <- gsub(": u",": ",input_str)
  json_file <- fromJSON(input_str)
  json_file <- lapply(json_file, function(x) {
    x[sapply(x, is.null)] <- NA
    unlist(x)
  })
  result_df <- as.data.frame(do.call(rbind,json_file))
  result_df
}

get_df_from_metric_url_param <- function(input_str){
  cat("input_str = ",input_str,file=stderr())
  input_str <- gsub("'","\"",input_str)
  input_str <- gsub(": u",": ",input_str)
  json_file <- fromJSON(input_str)
  json_file <- lapply(json_file$metricstatistics, function(x) {
    x[sapply(x, is.null)] <- NA
    unlist(x)
  })
  result_df <- as.data.frame(do.call(rbind,json_file))
  result_df
}