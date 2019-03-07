
## @example demo/demoDataflowMethod.R

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
#' @examples
#' \donttest{
#' availableDB <- DataflowMethod()
#' availableDB
#' availableDB$DatabaseID[1]
#' }
#' @import httr
#' @import jsonlite
#' @export

DataflowMethod <- function(){
  r <- httr::GET('http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow', httr::add_headers('user-agent' = ''))
  r.parsed <- jsonlite::fromJSON(httr::content(r, "text"))
  available.datasets <- r.parsed$Structure$Dataflows$Dataflow
  available.datasets.id <- available.datasets$KeyFamilyRef$KeyFamilyID
  available.datasets.text <- available.datasets$Name$`#text`
  available.db <- data.frame(
    DatabaseID = available.datasets.id,
    DatabaseText = available.datasets.text,
    stringsAsFactors = FALSE
  )
  return(available.db)
}

## @example  demo/demoDataStructureMethod.R

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
#' @examples
#' \donttest{
#' available.codes <- DataStructureMethod('IFS')
#' names(available.codes)
#' available.codes[[1]]#'
#' }
#'
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

  r <- httr::GET(paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',databaseID), httr::add_headers('user-agent' = ''))
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

## @example demo/demoCodeSearch.R

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
#' @examples
#' \donttest{
#' IFS.available.codes <- DataStructureMethod('IFS') # Get dimension code of IFS dataset
#' names(IFS.available.codes) # Available dimension code
#' IFS.available.codes[[1]] # Possible code in the first dimension
#' CodeSearch(IFS.available.codes, 'CLL', 'GDP') # Error (CLL is not a dimension code of IFS dataset)
#' CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP') # Search code contains GDP
#' CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDPABCDE') # NULL
#' }
#'
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

## @example demo/demoCompactDataMethod.R

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
#' @param verbose logical. If true, it will print the exact API call.
#' @param tidy logical. If true, it will return a simple data fram.
#'
#' @return A data frame. The last column, \code{Obs}, is a time series data
#' described by other columns.
#'
#' @examples
#' \donttest{
#' databaseID <- 'IFS'
#' startdate='2001-01-01'
#' enddate='2016-12-31'
#' checkquery = FALSE
#'
#' IFS.available.codes <- DataStructureMethod('IFS')
#'
#' ## Germany, Norminal GDP in Euros, Norminal GDP in National Currency
#' queryfilter <- list(CL_FREA="", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
#' GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' GR.NGDP.query[,1:5]
#' GR.NGDP.query$Obs[[1]]
#' GR.NGDP.query$Obs[[2]]
#'
#' ## Example for verbose
#' GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, verbose=TRUE)
#'
#' ## Example for tidy
#' GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, tidy=TRUE)
#' head(GR.NGDP.query)
#'
#' ## Quarterly, Germany, Norminal GDP in Euros, Norminal GDP in National Currency
#' queryfilter <- list(CL_FREA="Q", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
#' Q.GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' Q.GR.NGDP.query[,1:5]
#' Q.GR.NGDP.query$Obs[[1]]
#'
#' ## Quarterly, USA
#' queryfilter <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS = "")
#' Q.US.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' Q.US.query[,1:5]
#' CodeSearch(IFS.available.codes, "CL_INDICATOR_IFS", "FITB_3M_PA") # Reverse look up meaning of code
#'
#' ## Quarterly, USA, GDP related
#' IFS.available.codes <- DataStructureMethod('IFS')
#' ALLGDPCodeValue <- CodeSearch(IFS.available.codes, "CL_INDICATOR_IFS","GDP")$CodeValue
#' queryfilter <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS =ALLGDPCodeValue[1:10])
#' Q.US.GDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' Q.US.GDP.query[,1:5]
#' Q.US.GDP.query$Obs[[1]]
#' Q.US.GDP.query$Obs[[2]]
#'
#' ## Quarterly, US, NGDP_SA_AR_XDC
#' queryfilter <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS ="NGDP_SA_AR_XDC")
#' Q.US.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' Q.US.NGDP.query[,1:5]
#' Q.US.NGDP.query$Obs[[1]]
#'
#' ## Monthly, US, NGDP_SA_AR_XDC
#' queryfilter <- list(CL_FREA="M", CL_AREA_IFS="", CL_INDICATOR_IFS ="NGDP_SA_AR_XDC")
#' M.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#' M.NGDP.query$Obs # NULL
#'
#' ## Example for DOT dataset
#' DOT.available.codes <- DataStructureMethod('DOT')
#' names(DOT.available.codes)
#' queryfilter <- list(CL_FREQ = "", CL_AREA_DOT="US",
#'                     CL_INDICATOR_DOT = "", CL_COUNTERPART_AREA_DOT="")
#' US.query <- CompactDataMethod('DOT', queryfilter, startdate, enddate, FALSE)
#' US.query[1:5,1:(length(US.query)-1)]
#' US.query$Obs[[1]] # Monthly. US. TMG_CIF_USD CH
#' }
#'
#' @import httr
#' @import plyr
#' @import jsonlite
#' @export

CompactDataMethod <- function(databaseID, queryfilter=NULL,
                              startdate='2001-01-01', enddate='2001-12-31',
                              checkquery = FALSE, verbose=FALSE, tidy=FALSE){
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

  APIstr <- paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/',
                    databaseID,'/',queryfilterstr,
                    '?startPeriod=',startdate,'&endPeriod=',enddate)
  r <- httr::GET(APIstr, httr::add_headers('user-agent' = ''))

  if(verbose){
    cat('\nmaking API call:\n')
    cat(APIstr)
    cat('\n')
  }

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

  if(tidy){
    ret.df <- r.parsed$CompactData$DataSet$Series
    for(i in 1:length(ret.df$Obs)){
      ret.df$Obs[[i]] <- merge(ret.df$Obs[[i]], ret.df[i,1:(ncol(ret.df)-1)])
    }
    ret.df <- plyr::ldply(ret.df$Obs)
    return(ret.df)
  }

  return(r.parsed$CompactData$DataSet$Series)
}
