
#' @title Get List of Available Datasets from API
#'
#' @description \code{DataflowMethod} returns a data frame with availble
#' datasets
#'
#' @return \code{DataflowMethod} returns a data frame object to describe
#' available datasets from IMF data API. This data frame includes the following
#' two columns:
#'
#' DatabaseID - Database ID uses for making API call \cr
#' DatabaseText - Database description
#'
#' @example demo/demoDataflowMethod.R
#' @import httr
#' @import jsonlite
#' @export

DataflowMethod <- function(){
  r <- httr::GET('http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow/')
  r.parsed <- jsonlite::fromJSON(httr::content(r, "text"))
  available.datasets <- r.parsed$Structure$KeyFamilies$KeyFamily
  available.datasets.id <- available.datasets$`@id`
  available.datasets.text <- available.datasets$Name$`#text`
  available.db <- data.frame(
    DatabaseID = available.datasets.id,
    DatabaseText = available.datasets.text,
    stringsAsFactors = FALSE
  )
  return(available.db)
}

#' @title Get List of Dimension of a Given Dataset
#'
#' @description \code{DataStructureMethod} get the data structure of dataset with available code and description for each dimension.
#'
#' @param databaseID string. Database ID of the dataset. Obtained from \code{DataflowMethod}.
#' @param checkquery logical. If true, it will check the database ID is available or not.
#'
#' @return \code{DataStructureMethod} returns a list of data frame to describe available dimensions in the dataset.
#' The name of the list is the dimension name.
#' Each element of the list is a data frame with two columns;
#'
#' CodeValue - dimension code used for \code{CompactDataMethod}. \cr
#' CodeText - dimension description.
#'
#' @example  demo/demoDataStructureMethod.R
#' @import httr
#' @import jsonlite
#' @import plyr
#' @export

DataStructureMethod <- function(databaseID, checkquery = FALSE){
  # return a list with all dimension and legitimate values of each diemnsion
  if(checkquery){
    available.datasets <- DataflowMethod()$DatabaseID
    if (!is.element(databaseID, available.datasets)){
      return(NULL)
    }
  }

  r <- httr::GET(paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',databaseID))
  if(httr::http_status(r)$reason != "OK"){
    return(list())
  }

  r.parsed <- jsonlite::fromJSON(httr::content(r, "text"))
  dim.code <- r.parsed$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@codelist`
  dim.code.list<- r.parsed$Structure$CodeLists$CodeList$Code
  names(dim.code.list) <- r.parsed$Structure$CodeLists$CodeList$`@id`
  dim.code.list <- dim.code.list[dim.code]
  dim.code.list <- plyr::llply(dim.code.list,
                               function(x){
                                 data.frame(CodeValue = x$`@value`,
                                            CodeText = x$Description$`#text`,
                                            stringsAsFactors = FALSE)})
  return(dim.code.list)
}

#' @title Search Available Code in a Dimension of a Given Dataset
#'
#' @description \code{CodeSearch} search matching codes in a given dimension of a dataset
#'
#' @param available.codes string. Database ID of the dataset.
#' @param code string. Dimension code get from \code{DataStructureMethod}.
#' @param searchtext string. String to search in the dimension code.
#' @param search.value logical. If true, it will search \code{searchtext} in \code{CodeValue}.
#' @param search.text logical. If true, it will search \code{searchtext} in \code{CodeText}.
#'
#' @return A list for each dimension.
#' The name of the list is the dimension name.
#' Each element of the list is a data frame with two columns; dimension code and dimension text(description).
#'
#' @example demo/demoCodeSearch.R
#' @import httr
#' @import jsonlite
#' @export

CodeSearch <- function(available.codes, code, searchtext, search.value = TRUE, search.text = TRUE){
  if( ! is.element(code, names(available.codes))){
    stop(paste0("Code, ", code, ", does not exist."))
  }

  match.index <- c()
  if(search.value){
    code.value.match <- grep(searchtext, available.codes[[code]]$CodeValue)
    match.index <- unique(c(match.index, code.value.match))
  }
  if(search.text){
    code.text.match <- grep(searchtext, available.codes[[code]]$CodeText)
    match.index <- unique(c(match.index, code.text.match))
  }

  if(length(match.index) == 0){
    warning('no match!')
    return(NULL)
  }
  return(available.codes[[code]][match.index,])
}


#' @title Make Query to Get Data from the API
#'
#' @description \code{CompactDataMethod} will make an API call with filter
#' (if not NULL) to get data of each available code in the data set. It might
#' only return incomplete data because of API limit. In this case, try to add
#' more constraints in the filter.
#'
#' @param databaseID A character string. Database ID for the dataset. Can be
#' obtained from \code{DataflowMethod}
#' @param queryfilter list. A list that contains filter to use in the API call.
#' If not NULL, it must be a list with the lengtho of dimension of dataset. If
#' NULL, no filter has been set.
#' @param startdate string. Start date in format of "YYYY-mm-dd".
#' @param enddate string. End date in format of "YYYY-mm-dd".
#' @param checkquery logical. If true, it will check the database ID is
#' available or not.
#'
#' @return A data frame. The last column, \code{Obs}, is a time series data
#' described by other columns.
#' @example demo/demoCompactDataMethod.R
#' @import httr
#' @import plyr
#' @import jsonlite
#' @export

CompactDataMethod <- function(databaseID, queryfilter=NULL,
                              startdate='2001-01-01', enddate='2001-12-31',
                              checkquery = FALSE){
  if(checkquery){
    available.datasets <- DataflowMethod()$DatabaseID
    if (!is.element(databaseID, available.datasets)){
      stop('databaseID is not exist in API')
      return(NULL)
    }
    acceptedquery <- DataStructureMethod(databaseID)
    if (length(queryfilter) !=0 ||
        length(queryfilter) != length(acceptedquery)){
      stop('queryfilter is wrong format')
      return(NULL)
    }
  }

  queryfilterstr <- ''
  if (length(queryfilter) > 0){
    queryfilterstr <- paste0(
      unlist(plyr::llply(queryfilter,
                         function(x)(paste0(x, collapse="+")))), collapse=".")
  }
  r <- httr::GET(paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/',
                  databaseID,'/',queryfilterstr,
                  '?startPeriod=',startdate,'&endPeriod=',enddate))

  if(httr::http_status(r)$reason != "OK"){
    stop(paste(unlist(httr::http_status(r))))
    return(list())
  }
  r.parsed <- jsonlite::fromJSON(httr::content(r, "text"))

  if(is.null(r.parsed$CompactData$DataSet$Series)){
    warning("No data available")
    return(NULL)
  }

  if(class(r.parsed$CompactData$DataSet$Series) == "data.frame"){
    r.parsed$CompactData$DataSet$Series <- r.parsed$CompactData$DataSet$Series[!plyr::laply(r.parsed$CompactData$DataSet$Series$Obs, is.null),]
    if(nrow(r.parsed$CompactData$DataSet$Series) ==0){
      warning("No data available")
      return(NULL)
    }
  }

  if(class(r.parsed$CompactData$DataSet$Series) == "list"){
    if(is.null(r.parsed$CompactData$DataSet$Series$Obs)){
      warning("No data available")
      return(NULL)
    }
    ret.df <- as.data.frame(r.parsed$CompactData$DataSet$Series[1:(length(r.parsed$CompactData$DataSet$Series)-1)])
    ret.df$Obs <- list(r.parsed$CompactData$DataSet$Series$Obs)
    names(ret.df) <- names(r.parsed$CompactData$DataSet$Series)
    r.parsed$CompactData$DataSet$Series <- ret.df
  }

  return(r.parsed$CompactData$DataSet$Series)
}
