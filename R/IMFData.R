## roxygen2::roxygenise()

library(plyr)
library(dplyr)
library(httr)
library(jsonlite)

#' @title Get list of available datasets from API
#'
#' @description \code{DataflowMethod} returns a data frame with availble
#' datasets
#'
#' @return \code{DataflowMethod} returns a data frame object to describe
#' available datasets from the API. The data frame includes the following
#' components
#' DatabaseID Database ID uses for making API call
#' DatabaseText Database description.
#'
#' @examples
#' availableDB <- DataflowMethod()
#' availableDB
#' availableDB$DatabaseID[1]
#'

DataflowMethod <- function(){
  r <- GET('http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow/')
  r.parsed <- fromJSON(content(r, "text"))
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

#' @title Get list of dimension
#'
#' @description \code{DataStructureMethod} get the data structure of dataset
#'
#' @param databaseID string. Database ID of the dataset. Obtained from \code{DataflowMethod}
#' @param checkquery logical. If true, it will check the database ID is available or not.
#'
#' @return \code{DataStructureMethod} returns a list of data frame to describe available dimensions in the dataset.
#' The name of the list is the dimension name.
#' Each element of the list is a data frame with two columns; CodeValue for dimension code and CodeText for dimension description.
#' @examples
#' available.codes <- DataStructureMethod('IFS')
#' names(available.codes)
#' available.codes[[1]]
DataStructureMethod <- function(databaseID, checkquery = FALSE){
  # return a list with all dimension and legitimate values of each diemnsion
  if(checkquery){
    available.datasets <- DataflowMethod()$DatabaseID
    if (!is.element(databaseID, available.datasets)){
      return(NULL)
    }
  }

  r <- GET(paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',databaseID))
  if(http_status(r)$reason != "OK"){
    return(list())
  }

  r.parsed <- fromJSON(content(r, "text"))
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

#' @title Code Search
#'
#' @description \code{CodeSearch} search
#'
#' @param available.codes string. Database ID of the dataset.
#' @param code string. If true, it will check the database ID is available or not.
#' @param searchtext string. Database ID of the dataset.
#' @param search.value logical. If true, it will search only the .
#' @param search.text logical. If true, it will search .
#'
#' @return A list for each dimension.
#' The name of the list is the dimension name.
#' Each element of the list is a data frame with two columns; dimension code and dimension text(description).
#' @examples
#' IFS.available.codes <- DataStructureMethod('IFS')
#' names(IFS.available.codes)
#' IFS.available.codes[[1]]
#' CodeSearch(IFS.available.codes, 'CLL', 'GDP')
#' CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP')
#' nrow(CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP'))
#' nrow(CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'employ'))
#' nrow(CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'employaaaaaaaaa'))
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


#' @title Make query to the database
#'
#' @description \code{CompactDataMethod}
#'
#' @param databaseID A character string. Database ID for the dataset. Can be obtained from \code{DataflowMethod}
#' @param querry list. A list that contains. If NULL, it will get the result of the first 3000 codes in the database.
#' @param startdate string. Start date in format of "YYYY-mm-dd".
#' @param enddate string. End date in format of "YYYY-mm-dd".
#' @param checkquery logical. If true, it will check the database ID is available or not.
#'
#' @return A list for .
#' The name of the list is the dimension name.
#' Each element of the list is a data frame with two columns; dimension code and dimension text(description).
#' @examples
#' IFS.available.codes <- DataStructureMethod('IFS')
#' databaseID <- 'IFS'
#' startdate='2001-01-01'
#' enddate='2016-12-31'
#' checkquery = FALSE
#' query <- list(CL_FREA="", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
#' NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
#' NGDPquery[,1:5]
#' NGDPquery$Obs[[1]]
#'
#' query <- list(CL_FREA="Q", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
#' NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
#' NGDPquery[,1:5]
#' NGDPquery$Obs[[1]]
#'
#' query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS = "")
#' NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
#' NGDPquery[,1:5]
#' NGDPquery$Obs[[1]]
#' NGDPquery$`@INDICATOR`[grep("GDP", NGDPquery$`@INDICATOR`)]
#'
#' # If the return data has only multiple data set, return a data frame
#' query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS =ALLGDPCodeValue[5:21]) # Looks like I can have 17 code at once maximum
#' NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
#' NGDPquery[,1:5]
#' NGDPquery$Obs[[5]]
#'
#' ## Example US GDP
#' # If the return data has only one data set, return a list
#' query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS ="NGDP_SA_AR_XDC")
#' NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
#' NGDPquery$Obs
#'
#' DOT.available.codes <- DataStructureMethod('DOT')
#' names(DOT.available.codes)
#' DOT.available.codes[[2]]
#' CodeSearch(DOT.available.codes, "CL_AREA_DOT", "Taiwan")
#' query <- list(CL_FREQ = "", CL_AREA_DOT="F6", CL_INDICATOR_DOT = "", CL_COUNTERPART_AREA_DOT="")
#' DOTTXGquery <- CompactDataMethod('DOT', query, startdate, enddate, FALSE)
#' class(DOTTXGquery[1,])
#' DOTTXGquery$Obs[1]

CompactDataMethod <- function(databaseID, query=NULL, startdate='2001-01-01', enddate='2001-12-31', checkquery = FALSE){
  if(checkquery){
    available.datasets <- DataflowMethod()$DatabaseID
    if (!is.element(databaseID, available.datasets)){
      stop('databaseID is not exist in API')
      return(NULL)
    }
    acceptedquery <- DataStructureMethod(databaseID)
    if (length(query) !=0 || length(query) != length(acceptedquery)){
      stop('query is wrong format')
      return(NULL)
    }
  }

  querystr <- ''
  if (length(query) > 0){
    querystr <- paste0(unlist(plyr::llply(query, function(x)(paste0(x, collapse="+")))), collapse=".")
  }
  r <- GET(paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/',databaseID,'/',querystr,'?startPeriod=',startdate,'&endPeriod=',enddate))

  if(http_status(r)$reason != "OK"){
    stop(paste(unlist(http_status(r))))
    return(list())
  }
  r.parsed <- fromJSON(content(r, "text"))

  if(is.null(r.parsed$CompactData$DataSet$Series)){
    warning("No data available")
    return(NULL)
  }
  return(r.parsed$CompactData$DataSet$Series)
}

## Test
# IFS.available.codes <- DataStructureMethod('IFS')
# databaseID <- 'IFS'
# startdate='2001-01-01'
# enddate='2016-12-31'
# checkquery = FALSE
# query <- list(CL_FREA="", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
# NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
# NGDPquery[,1:5]
# NGDPquery$Obs[[1]]
# query <- list(CL_FREA="Q", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
# NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
# NGDPquery[,1:5]
# NGDPquery$Obs[[1]]
# ALLGDPCode <- CodeSearch(IFS.available.codes, "CL_INDICATOR_IFS", "GDP")
# ALLGDPCodeValue <- ALLGDPCode$CodeValue
# query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS = "")
# NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
# NGDPquery[,1:5]
# NGDPquery$Obs[[1]]
# NGDPquery$`@INDICATOR`[grep("GDP", NGDPquery$`@INDICATOR`)]
# # If the return data has only multiple data set, return a data frame
# query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS =ALLGDPCodeValue[5:21]) # Looks like I can have 17 code at once maximum
# NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
# NGDPquery[,1:5]
# NGDPquery$Obs[[5]]
#
# ## Example US GDP
# # If the return data has only one data set, return a list
# query <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS ="NGDP_SA_AR_XDC")
# # querystr <- paste0(unlist(plyr::llply(query, function(x)(paste0(x, collapse="+")))), collapse=".")
# NGDPquery <- CompactDataMethod(databaseID, query, startdate, enddate, checkquery)
# class(NGDPquery)
# NGDPquery$Obs
#
# DOT.available.codes <- DataStructureMethod('DOT')
# names(DOT.available.codes)
# DOT.available.codes[[2]]
# CodeSearch(DOT.available.codes, "CL_AREA_DOT", "Taiwan")
# query <- list(CL_FREQ = "", CL_AREA_DOT="F6", CL_INDICATOR_DOT = "", CL_COUNTERPART_AREA_DOT="")
# startdate='2001-01-01'
# enddate='2016-12-31'
# DOTTXGquery <- CompactDataMethod('DOT', query, startdate, enddate, FALSE)
# class(DOTTXGquery[1,])
# DOTTXGquery$Obs[1]
