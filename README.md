<!-- README.md is generated from README.Rmd. Please edit that file -->

# IMFData

[![Build
Status](http://travis-ci.org/mingjerli/IMFData.png?branch=master)](https://travis-ci.org/mingjerli/IMFData)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/IMFData)](https://cran.r-project.org/package=IMFData)

IMFData is an R package to access [IMF (Internation Monetary Fund)
data](http://data.imf.org) . It has three main goals:

-   Find out available datasets in the API.
-   Find out the dataset datastructure and code to use to make a query.
-   Query through the API.

## Installation

Right now, you can install

-   from CRAN with

``` r
install.packages('IMFData')
```

-   the latest development version from github with

``` r
devtools::install_github('mingjerli/IMFData')
```

## Loading the package

``` r
library(IMFData)
```

## How to use IMFData

If you don’t know anything about [IMF data](http://data.imf.org) API,
the following four steps is a good way to start.

### Find out available dataset in [IMF data](http://data.imf.org).

``` r
availableDB <- DataflowMethod()
#> {"Structure":{"@xmlns:xsd":"http://www.w3.org/2001/XMLSchema","@xmlns:xsi":"http://www.w3.org/2001/X
sample_lines <- sample.int(nrow(availableDB), 10)
availableDB[sample_lines, ]
#>           DatabaseID
#> 91          FAS_2017
#> 150      IFS_2020M03
#> 76      GFSCOFOG2015
#> 14      WHDREO201504
#> 114     AFRREO201504
#> 88      AFRREO201904
#> 32        DOT_2017Q2
#> 210      IFS_2021M02
#> 197 IFS_DISCONTINUED
#> 129      GFSSSUC2015
#>                                                                                          DatabaseText
#> 91                                                                Financial Access Survey (FAS), 2017
#> 150                                                International Financial Statistics (IFS), 2020 M03
#> 76  Government Finance Statistics Yearbook (GFSY 2015), Expenditure by Function of Government (COFOG)
#> 14                                   Western Hemisphere Regional Economic Outlook (WHDREO) April 2015
#> 114                                  Sub-Saharan Africa Regional Economic Outlook (AFRREO) April 2015
#> 88                                   Sub-Saharan Africa Regional Economic Outlook (AFRREO) April 2019
#> 32                                                      Direction of Trade Statistics (DOTS), 2017 Q2
#> 210                                                International Financial Statistics (IFS), 2021 M02
#> 197                                     International Financial Statistics (IFS), Discontinued Series
#> 129         Government Finance Statistics Yearbook (GFSY 2015), Statement of Sources and Uses of Cash
```

### Findout how many dimensions are available in a given dataset. Here, we use IFS(International Financial Statistics) for example,

``` r
# Get dimension code of IFS dataset
IFS.available.codes <- DataStructureMethod('IFS')
#> {"Structure":{"@xmlns:xsd":"http://www.w3.org/2001/XMLSchema","@xmlns:xsi":"http://www.w3.org/2001/X
# Available dimension code
names(IFS.available.codes)
#> [1] "CL_FREQ"          "CL_AREA_IFS"      "CL_INDICATOR_IFS"
# Possible code in the first dimension
IFS.available.codes[[1]] 
#>   CodeValue  CodeText
#> 1         A    Annual
#> 2         B Bi-annual
#> 3         Q Quarterly
#> 4         M   Monthly
#> 5         D     Daily
#> 6         W    Weekly
```

### Search possible code to use in each dimension. Here, we want to search code related to GDP in CL_INDICATOR_IFS dimension,

``` r
# Search code contains GDP
all_gdp_codes <- CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP')
sample_lines <- sample.int(nrow(all_gdp_codes), 10)
all_gdp_codes[sample_lines, ]
#>               CodeValue
#> 714   NGDP_R_PC_CP_A_PT
#> 710       NGDP_PC_PP_PT
#> 1631     NNITSPX_SA_XDC
#> 713          NGDP_R_XDC
#> 719    NGDP_R_CH_SA_XDC
#> 1599         NSDGDP_XDC
#> 1603   NSDGDP_R_PYP_XDC
#> 702   NGDP_D_PC_CP_A_PT
#> 705  NGDP_D_PC_PP_SA_PT
#> 1632          NGDPT_XDC
#>                                                                                                                                                   CodeText
#> 714                           National Accounts, Expenditure, Gross Domestic Product, Real, Percentage change, corresponding period previous year, Percent
#> 710                                           National Accounts, Expenditure, Gross Domestic Product, Nominal, Percentage change, previous period, Percent
#> 1631 National Accounts, GDP-GNP Relation, National Income, Taxes on Production and Imports less Subsidies, Nominal, Seasonally adjusted, Domestic Currency
#> 713                                                                        National Accounts, Expenditure, Gross Domestic Product, Real, Domestic Currency
#> 719                                National Accounts, Expenditure, Gross Domestic Product, Real, Reference Chained, Seasonally adjusted, Domestic Currency
#> 1599                                                                         National Accounts, Statistical Discrepancy in GDP, Nominal, Domestic Currency
#> 1603                                                                                Statistical Discrepancy, Real, Previous year prices, Domestic Currency
#> 702                       National Accounts, Expenditure, Gross Domestic Product, Deflator, Percentage change, corresponding period previous year, Percent
#> 705                     National Accounts, Expenditure, Gross Domestic Product, Deflator, Percentage change, previous period, Seasonally adjusted, Percent
#> 1632                                                                                                  National Accounts, NGDPT, Nominal, Domestic Currency
```

### Make API call to get data

``` r
databaseID <- 'IFS'
startdate <- '2001-01-01'
enddate <- '2016-12-31'
checkquery <- FALSE

## Germany, Norminal GDP in Euros, Norminal GDP in National Currency
queryfilter <- list(CL_FREA = "", CL_AREA_IFS = "DE", CL_INDICATOR_IFS = c("NGDP_EUR","NGDP_XDC"))
DE.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#> {"CompactData":{"@xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","@xmlns:xsd":"http://www.w3
DE.NGDP.query[,1:5]
#>   @FREQ @REF_AREA @INDICATOR @UNIT_MULT @TIME_FORMAT
#> 1     A        DE   NGDP_XDC          6          P1Y
#> 2     Q        DE   NGDP_XDC          6          P3M
tail(DE.NGDP.query$Obs[[1]])
#>    @TIME_PERIOD @OBS_VALUE
#> 11         2011    2693560
#> 12         2012    2745310
#> 13         2013    2811350
#> 14         2014    2927430
#> 15         2015    3026180
#> 16         2016    3134740
tail(DE.NGDP.query$Obs[[2]])
#>    @TIME_PERIOD @OBS_VALUE
#> 59      2015-Q3     765670
#> 60      2015-Q4     781320
#> 61      2016-Q1     762950
#> 62      2016-Q2     779080
#> 63      2016-Q3     788980
#> 64      2016-Q4     803730

## Quarterly, US, NGDP_SA_XDC
queryfilter <- list(CL_FREA = "Q", CL_AREA_IFS = "US", CL_INDICATOR_IFS = "NGDP_SA_XDC")
Q.US.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery)
#> {"CompactData":{"@xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","@xmlns:xsd":"http://www.w3
Q.US.NGDP.query[,1:5]
#>   @FREQ @REF_AREA  @INDICATOR @UNIT_MULT @TIME_FORMAT
#> 1     Q        US NGDP_SA_XDC          6          P3M
tail(Q.US.NGDP.query$Obs[[1]])
#>    @TIME_PERIOD @OBS_VALUE
#> 59      2015-Q3   18347425
#> 60      2015-Q4   18378803
#> 61      2016-Q1   18470156
#> 62      2016-Q2   18656207
#> 63      2016-Q3   18821359
#> 64      2016-Q4   19032580

## See exact API call to the data source
tail(CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery, verbose = TRUE)$Obs[[1]])
#> 
#> making API call:
#> http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/IFS/Q.US.NGDP_SA_XDC?startPeriod=2001-01-01&endPeriod=2016-12-31
#> {"CompactData":{"@xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","@xmlns:xsd":"http://www.w3
#>    @TIME_PERIOD @OBS_VALUE
#> 59      2015-Q3   18347425
#> 60      2015-Q4   18378803
#> 61      2016-Q1   18470156
#> 62      2016-Q2   18656207
#> 63      2016-Q3   18821359
#> 64      2016-Q4   19032580

## Return a simple data frame
head(CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery, tidy = TRUE))
#> {"CompactData":{"@xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","@xmlns:xsd":"http://www.w3
#>   @TIME_PERIOD @OBS_VALUE @FREQ @REF_AREA  @INDICATOR @UNIT_MULT @TIME_FORMAT
#> 1      2001-Q1   10472879     Q        US NGDP_SA_XDC          6          P3M
#> 2      2001-Q2   10597822     Q        US NGDP_SA_XDC          6          P3M
#> 3      2001-Q3   10596294     Q        US NGDP_SA_XDC          6          P3M
#> 4      2001-Q4   10660294     Q        US NGDP_SA_XDC          6          P3M
#> 5      2002-Q1   10788952     Q        US NGDP_SA_XDC          6          P3M
#> 6      2002-Q2   10893207     Q        US NGDP_SA_XDC          6          P3M
```
