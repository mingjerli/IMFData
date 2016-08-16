<!-- README.md is generated from README.Rmd. Please edit that file -->
IMFData
=======

[![Build Status](http://travis-ci.org/mingjerli/IMFData.png?branch=master)](https://travis-ci.org/mingjerli/IMFData) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/IMFData)](http://cran.r-project.org/package=IMFData)

IMFData is an R package to access [IMF (Internation Monetary of Fund) data](http://data.imf.org) . It has three main goals:

-   Findout available datasets in the API.
-   Findout the dataset datastructure and code to use to make a query.
-   Query through the API.

Installation
------------

Right now, you can install

-   from CRAN with

    ``` r
    install.packages('IMFData')
    ```

-   the latest development version from github with

    ``` r
    devtools::install_github('mingjerli/IMFData')
    ```

Loading the package
-------------------

``` r
library(IMFData)
```

How to use IMFData
------------------

If you don't know anything about [IMF data](http://data.imf.org) API, the following four steps is a good way to start.

### Findout available dataset in [IMF data](http://data.imf.org).

``` r
availableDB <- DataflowMethod()
availableDB
availableDB$DatabaseID[1]
```

### Findout how many dimension available in a given dataset. Here, we use IFS(International Financial Statistics) for example,

``` r
# Get dimension code of IFS dataset
IFS.available.codes <- DataStructureMethod('IFS')
# Available dimension code
names(IFS.available.codes)
# Possible code in the first dimension
IFS.available.codes[[1]] 
```

### Search possible code to use in each dimension. Here, we want to search code related to GDP in CL\_INDICATOR\_IFS dimension,

``` r
# Search code contains GDP
CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP') 
```

### Make API call to get data,

``` r
databaseID <- 'IFS'
startdate='2001-01-01'
enddate='2016-12-31'
checkquery = FALSE

## Germany, Norminal GDP in Euros, Norminal GDP in National Currency
queryfilter <- list(CL_FREA="", CL_AREA_IFS="GR", CL_INDICATOR_IFS =c("NGDP_EUR","NGDP_XDC"))
GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
GR.NGDP.query[,1:5]
GR.NGDP.query$Obs[[1]]
GR.NGDP.query$Obs[[2]]

## Quarterly, US, NGDP_SA_AR_XDC
queryfilter <- list(CL_FREA="Q", CL_AREA_IFS="US", CL_INDICATOR_IFS ="NGDP_SA_AR_XDC")
Q.US.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
Q.US.NGDP.query[,1:5]
Q.US.NGDP.query$Obs[[1]]
```
