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
availableDB$DatabaseID
#>  [1] "FSIRE"         "FAS"           "IFS"           "MCDREO"       
#>  [5] "FSIBS"         "FSI"           "DOT"           "FSIREM"       
#>  [9] "CDIS"          "GFS01M"        "GFS01"         "BOP"          
#> [13] "BOPAGG"        "CPIS"          "APDREO"        "FM"           
#> [17] "AFRREO"        "MCDREO201410"  "FM201410"      "AFRREO201410" 
#> [21] "MCDREO201501"  "APDREO201410"  "COMMP"         "COMMPP"       
#> [25] "WoRLD"         "GFSR"          "GFSSSUC"       "GFSCOFOG"     
#> [29] "GFSFALCS"      "GFSIBS"        "GFSMAB"        "GFSE"         
#> [33] "PGI"           "WHDREO201504"  "WCED"          "WHDREO"       
#> [37] "FM201504"      "APDREO201504"  "MCDREO201505"  "AFRREO201504" 
#> [41] "CDISARCHIVE"   "ICSD"          "HPDD"          "COFR"         
#> [45] "CPI"           "IRFCL"         "COFER"         "FM201510"     
#> [49] "RAFIT2AGG"     "MCDREO201510"  "WHDREO201510"  "APDREO201510" 
#> [53] "AFRREO201510"  "GFSYR2014"     "GFSYSSUC2014"  "GFSYCOFOG2014"
#> [57] "GFSYIBS2014"   "GFSYMAB2014"   "GFSYFALCS2014" "GFSYE2014"    
#> [61] "GFSIBS2015"    "GFSR2015"      "GFSFALCS2015"  "GFSSSUC2015"  
#> [65] "GFSMAB2015"    "GFSCOFOG2015"  "GFSE2015"      "BOPSDMXUSD"
availableDB$DatabaseText
#>  [1] "Financial Soundness Indicators (FSI), Reporting Entities"                                                                          
#>  [2] "Financial Access Survey (FAS)"                                                                                                     
#>  [3] "International Financial Statistics (IFS)"                                                                                          
#>  [4] "Middle East and Central Asia Regional Economic Outlook (MCDREO)"                                                                   
#>  [5] "Financial Soundness Indicators (FSI), Balance Sheets"                                                                              
#>  [6] "Financial Soundness Indicators (FSI)"                                                                                              
#>  [7] "Direction of Trade Statistics (DOTS)"                                                                                              
#>  [8] "Financial Soundness Indicators (FSI), Reporting Entities - Multidimensional"                                                       
#>  [9] "Coordinated Direct Investment Survey (CDIS)"                                                                                       
#> [10] "Government Finance Statistics (GFS 2001) - Multidimensional"                                                                       
#> [11] "Government Finance Statistics (GFS 2001)"                                                                                          
#> [12] "Balance of Payments (BOP)"                                                                                                         
#> [13] "Balance of Payments (BOP), World and Regional Aggregates"                                                                          
#> [14] "Coordinated Portfolio Investment Survey (CPIS)"                                                                                    
#> [15] "Asia and Pacific Regional Economic Outlook (APDREO)"                                                                               
#> [16] "Fiscal Monitor (FM)"                                                                                                               
#> [17] "Sub-Saharan Africa Regional Economic Outlook (AFRREO)"                                                                             
#> [18] "MCD Regional Economic Outlook October 2014"                                                                                        
#> [19] "Fiscal Monitor (FM) October 2014"                                                                                                  
#> [20] "Sub-Saharan Africa Regional Economic Outlook (AFRREO) October 2014"                                                                
#> [21] "MCD Regional Economic Outlook January 2015"                                                                                        
#> [22] "Asia and Pacific Regional Economic Outlook (APDREO) October 2014"                                                                  
#> [23] "Primary Commodity Prices"                                                                                                          
#> [24] "Primary Commodity Prices Projections"                                                                                              
#> [25] "World Revenue Longitudinal Data (WoRLD)"                                                                                           
#> [26] "Government Finance Statistics (GFS), Revenue"                                                                                      
#> [27] "Government Finance Statistics (GFS), Statement of Sources and Uses of Cash"                                                        
#> [28] "Government Finance Statistics (GFS), Expenditure by Function of Government (COFOG)"                                                
#> [29] "Government Finance Statistics (GFS), Financial Assets and Liabilities by Counterpart Sector"                                       
#> [30] "Government Finance Statistics (GFS), Integrated Balance Sheet (Stock Positions and Flows in Assets and Liabilities)"               
#> [31] "Government Finance Statistics (GFS), Main Aggregates and Balances"                                                                 
#> [32] "Government Finance Statistics (GFS), Expense"                                                                                      
#> [33] "Principal Global Indicators (PGI)"                                                                                                 
#> [34] "Western Hemisphere Regional Economic Outlook (WHDREO) April 2015"                                                                  
#> [35] "World Commodity Exporters (WCED)"                                                                                                  
#> [36] "Western Hemisphere Regional Economic Outlook (WHDREO)"                                                                             
#> [37] "Fiscal Monitor (FM) April 2015"                                                                                                    
#> [38] "Asia and Pacific Regional Economic Outlook (APDREO) April 2015"                                                                    
#> [39] "MCD Regional Economic Outlook May 2015"                                                                                            
#> [40] "Sub-Saharan Africa Regional Economic Outlook (AFRREO) April 2015"                                                                  
#> [41] "Coordinated Direct Investment Survey (CDIS) - Archive"                                                                             
#> [42] "Investment and Capital Stock (ICSD)"                                                                                               
#> [43] "Historical Public Debt (HPDD)"                                                                                                     
#> [44] "Coverage of Fiscal Reporting (COFR)"                                                                                               
#> [45] "Consumer Price Index (CPI)"                                                                                                        
#> [46] "International Reserves and Foreign Currency Liquidity (IRFCL)"                                                                     
#> [47] "Currency Composition of Official Foreign Exchange Reserves (COFER)"                                                                
#> [48] "Fiscal Monitor (FM) October 2015"                                                                                                  
#> [49] "RA-FIT Round 2 Aggregates"                                                                                                         
#> [50] "MCD Regional Economic Outlook (MCDREO) October 2015"                                                                               
#> [51] "Western Hemisphere Regional Economic Outlook (WHDREO) October 2015"                                                                
#> [52] "Asia and Pacific Regional Economic Outlook (APDREO) October 2015"                                                                  
#> [53] "Sub-Saharan Africa Regional Economic Outlook (AFRREO) October 2015"                                                                
#> [54] "Government Finance Statistics Yearbook (GFSY 2014), Revenue"                                                                       
#> [55] "Government Finance Statistics Yearbook (GFSY 2014), Statement of Sources and Uses of Cash"                                         
#> [56] "Government Finance Statistics Yearbook (GFSY 2014), Expenditure by Function of Government (COFOG)"                                 
#> [57] "Government Finance Statistics Yearbook (GFSY 2014), Integrated Balance Sheet (Stock Positions and Flows in Assets and Liabilities)"
#> [58] "Government Finance Statistics Yearbook (GFSY 2014), Main Aggregates and Balances"                                                  
#> [59] "Government Finance Statistics Yearbook (GFSY 2014), Financial Assets and Liabilities by Counterpart Sector"                        
#> [60] "Government Finance Statistics Yearbook (GFSY 2014), Expense"                                                                       
#> [61] "Government Finance Statistics Yearbook (GFSY 2015), Integrated Balance Sheet (Stock Positions and Flows in Assets and Liabilities)"
#> [62] "Government Finance Statistics Yearbook (GFSY 2015), Revenue"                                                                       
#> [63] "Government Finance Statistics Yearbook (GFSY 2015), Financial Assets and Liabilities by Counterpart Sector"                        
#> [64] "Government Finance Statistics Yearbook (GFSY 2015), Statement of Sources and Uses of Cash"                                         
#> [65] "Government Finance Statistics Yearbook (GFSY 2015), Main Aggregates and Balances"                                                  
#> [66] "Government Finance Statistics Yearbook (GFSY 2015), Expenditure by Function of Government (COFOG)"                                 
#> [67] "Government Finance Statistics Yearbook (GFSY 2015), Expense"                                                                       
#> [68] "Balance of Payments (BOP), Global SDMX (US Dollars)"
```

### Findout how many dimension available in a given dataset. Here, we use IFS(International Financial Statistics) for example,

``` r
# Get dimension code of IFS dataset
IFS.available.codes <- DataStructureMethod("IFS")
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

### Search possible code to use in each dimension. Here, we want to search code related to GDP in CL\_INDICATOR\_IFS dimension,

``` r
# Search code contains GDP
CodeSearch(IFS.available.codes, "CL_INDICATOR_IFS", "GDP")
#>                                     CodeValue
#> 1464                        GGXWDG_G01_GDP_PT
#> 1468                           GGX_G01_GDP_PT
#> 1486                           GGR_G01_GDP_PT
#> 1567                               NGDP_F_XDC
#> 1568                                NGDP_D_IX
#> 1569                        NGDP_D_PC_CP_A_PT
#> 1570                             NGDP_D_SA_IX
#> 1571                              NGDP_AR_XDC
#> 1572                                 NGDP_EUR
#> 1573                                 NGDP_XDC
#> 1574                           NGDP_SA_AR_XDC
#> 1575                              NGDP_SA_EUR
#> 1576                              NGDP_SA_XDC
#> 1577                                 NGDP_USD
#> 1578                            NGDP_R_AR_XDC
#> 1579                               NGDP_R_EUR
#> 1580                             NGDP_R_F_XDC
#> 1581                                NGDP_R_IX
#> 1582                               NGDP_R_XDC
#> 1583                                NGDP_R_PT
#> 1584                      NGDP_R_CH_SA_AR_XDC
#> 1585                         NGDP_R_SA_AR_XDC
#> 1586                            NGDP_R_SA_EUR
#> 1587                             NGDP_R_SA_IX
#> 1588                            NGDP_R_SA_XDC
#> 1597                           NGDPNPI_AR_XDC
#> 1598                              NGDPNPI_EUR
#> 1599                              NGDPNPI_XDC
#> 1600                        NGDPNPI_SA_AR_XDC
#> 1601                           NGDPNPI_SA_EUR
#> 1602                           NGDPNPI_SA_XDC
#> 1603                              NGDPNPI_USD
#> 2606                               NSDGDP_EUR
#> 2607                               NSDGDP_XDC
#> 2608                         NSDGDP_SA_AR_XDC
#> 2609                               NSDGDP_USD
#> 2671 All_Indicators_Excluding_NGDP_Indicators
#>                                                                                                                                           CodeText
#> 1464                                                                 General Government, Gross debt position, 2001 Manual, Percent of GDP, Percent
#> 1468                                                              General Government, Memo Item: Expenditure, 2001 Manual, Percent of GDP, Percent
#> 1486                                                                             General Government, Revenue, 2001 Manual, Percent of GDP, Percent
#> 1567                                                                                     Gross Domestic Product, at Factor Cost, National Currency
#> 1568                                                                                                       Gross Domestic Product, Deflator, Index
#> 1569                                              Gross Domestic Product, Deflator, Percentage change, corresponding period previous year, Percent
#> 1570                                                                                  Gross Domestic Product, Deflator, Seasonally adjusted, Index
#> 1571                                                                           Gross Domestic Product, Nominal, Annualized Rate, National Currency
#> 1572                                                                                                         Gross Domestic Product, Nominal, Euro
#> 1573                                                                                            Gross Domestic Product, Nominal, National Currency
#> 1574                                                      Gross Domestic Product, Nominal, Seasonally adjusted, annualized Rate, National Currency
#> 1575                                                                                   Gross Domestic Product, Nominal, Seasonally Adjusted, Euros
#> 1576                                                                       Gross Domestic Product, Nominal, Seasonally Adjusted, National Currency
#> 1577                                                                                                   Gross Domestic Product, Nominal, US Dollars
#> 1578                                                                              Gross Domestic Product, Real, Annualized Rate, National Currency
#> 1579                                                                                                           Gross Domestic Product, Real, Euros
#> 1580                                                                                  Gross Domestic Product, Real, Factor Cost, National Currency
#> 1581                                                                                                           Gross Domestic Product, Real, Index
#> 1582                                                                                               Gross Domestic Product, Real, National Currency
#> 1583                                                                                                         Gross Domestic Product, Real, Percent
#> 1584                                      Gross Domestic Product, Real, Reference chained, seasonally adjusted, Annualized Rate, National Currency
#> 1585                                                         Gross Domestic Product, Real, Seasonally adjusted, Annualized Rate, National Currency
#> 1586                                                                                      Gross Domestic Product, Real, Seasonally Adjusted, Euros
#> 1587                                                                                      Gross Domestic Product, Real, Seasonally adjusted, Index
#> 1588                                                                          Gross Domestic Product, Real, Seasonally Adjusted, National Currency
#> 1597                      Income Receipts from Rest of the World less Income Payments to the Rest of the World, Annualized Rate, National Currency
#> 1598                                                   Income Receipts from Rest of the World less Income Payments to the Rest of the World, Euros
#> 1599                                       Income Receipts from Rest of the World less Income Payments to the Rest of the World, National Currency
#> 1600 Income Receipts from Rest of the World less Income Payments to the Rest of the World, Seasonally adjusted, annualized Rate, National Currency
#> 1601                               Income Receipts from Rest of the World less Income Payments to the Rest of the World, Seasonally adjusted, Euro
#> 1602                  Income Receipts from Rest of the World less Income Payments to the Rest of the World, Seasonally Adjusted, National Currency
#> 1603                                              Income Receipts from Rest of the World less Income Payments to the Rest of the World, US Dollars
#> 2606                                                                                                Statistical Discrepancy in GDP, Nominal, Euros
#> 2607                                                                                    Statistical Discrepancy in GDP, Nominal, National Currency
#> 2608                                              Statistical Discrepancy in GDP, Nominal, Seasonally adjusted, Annualized Rate, National Currency
#> 2609                                                                                           Statistical Discrepancy in GDP, Nominal, US Dollars
#> 2671                                                                                                      All Indicators Excluding NGDP Indicators
```

### Make API call to get data,

``` r
databaseID <- "IFS"
startdate = "2001-01-01"
enddate = "2016-12-31"
checkquery = FALSE

## Germany, Norminal GDP in Euros, Norminal GDP in National Currency
queryfilter <- list(CL_FREA = "", CL_AREA_IFS = "GR", CL_INDICATOR_IFS = c("NGDP_EUR", 
    "NGDP_XDC"))
GR.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, 
    checkquery)
GR.NGDP.query[, 1:5]
#>   @FREQ @REF_AREA @INDICATOR @UNIT_MULT @TIME_FORMAT
#> 2     Q        GR   NGDP_EUR          9          P3M
#> 4     A        GR   NGDP_EUR          9          P1Y
GR.NGDP.query$Obs[[1]]
#>    @TIME_PERIOD       @OBS_VALUE @OBS_STATUS
#> 1       2001-Q1          35.2366           K
#> 2       2001-Q2          36.7264        <NA>
#> 3       2001-Q3          39.8428        <NA>
#> 4       2001-Q4          40.3881        <NA>
#> 5       2002-Q1          37.4971        <NA>
#> 6       2002-Q2          39.8739        <NA>
#> 7       2002-Q3          42.3377        <NA>
#> 8       2002-Q4           43.752        <NA>
#> 9       2003-Q1          40.8806        <NA>
#> 10      2003-Q2          43.4188        <NA>
#> 11      2003-Q3          46.6817        <NA>
#> 12      2003-Q4          47.9238        <NA>
#> 13      2004-Q1          44.8781        <NA>
#> 14      2004-Q2  47.604999892938        <NA>
#> 15      2004-Q3          50.8154        <NA>
#> 16      2004-Q4          50.4173        <NA>
#> 17      2005-Q1           45.727        <NA>
#> 18      2005-Q2 49.1768012641032        <NA>
#> 19      2005-Q3          51.7502        <NA>
#> 20      2005-Q4          52.5883        <NA>
#> 21      2006-Q1          50.0931        <NA>
#> 22      2006-Q2          53.9923        <NA>
#> 23      2006-Q3          55.9232        <NA>
#> 24      2006-Q4          57.8529        <NA>
#> 25      2007-Q1          52.8308        <NA>
#> 26      2007-Q2           58.359        <NA>
#> 27      2007-Q3           59.929        <NA>
#> 28      2007-Q4          61.5758        <NA>
#> 29      2008-Q1          55.8782        <NA>
#> 30      2008-Q2           60.746        <NA>
#> 31      2008-Q3          63.0783        <NA>
#> 32      2008-Q4          62.2879        <NA>
#> 33      2009-Q1          53.3813        <NA>
#> 34      2009-Q2          60.2148        <NA>
#> 35      2009-Q3          61.2555        <NA>
#> 36      2009-Q4          62.6826        <NA>
#> 37      2010-Q1          54.2695        <NA>
#> 38      2010-Q2           57.379        <NA>
#> 39      2010-Q3          57.6284        <NA>
#> 40      2010-Q4          56.7546        <NA>
#> 41      2011-Q1          48.8302        <NA>
#> 42      2011-Q2          53.0734        <NA>
#> 43      2011-Q3          53.7756        <NA>
#> 44      2011-Q4          51.3496        <NA>
#> 45      2012-Q1          45.0995        <NA>
#> 46      2012-Q2          48.4733        <NA>
#> 47      2012-Q3          49.7557        <NA>
#> 48      2012-Q4          47.8755        <NA>
#> 49      2013-Q1          42.1708        <NA>
#> 50      2013-Q2          45.8799        <NA>
#> 51      2013-Q3          47.5605        <NA>
#> 52      2013-Q4          44.7779        <NA>
#> 53      2014-Q1          40.4676        <NA>
#> 54      2014-Q2          44.3952        <NA>
#> 55      2014-Q3          48.0023        <NA>
#> 56      2014-Q4          44.6942        <NA>
#> 57      2015-Q1          40.4384        <NA>
#> 58      2015-Q2          44.6036        <NA>
#> 59      2015-Q3          46.7534        <NA>
#> 60      2015-Q4          44.2277        <NA>
#> 61      2016-Q1          39.9625        <NA>
#> 62      2016-Q2          45.1606        <NA>
GR.NGDP.query$Obs[[2]]
#>    @TIME_PERIOD       @OBS_VALUE @OBS_STATUS
#> 1          2001         151.9872           K
#> 2          2002         162.2742        <NA>
#> 3          2003         178.5709        <NA>
#> 4          2004 193.715823551657        <NA>
#> 5          2005 199.242311837475        <NA>
#> 6          2006 217.861568188497        <NA>
#> 7          2007 232.694592661749        <NA>
#> 8          2008 241.990389906673        <NA>
#> 9          2009 237.534181456484        <NA>
#> 10         2010 226.031447205434        <NA>
#> 11         2011 207.028875339588        <NA>
#> 12         2012 191.203907934554        <NA>
#> 13         2013 180.389043118584        <NA>
#> 14         2014  177.55942109271        <NA>
#> 15         2015 176.022666208548        <NA>

## Quarterly, US, NGDP_SA_AR_XDC
queryfilter <- list(CL_FREA = "Q", CL_AREA_IFS = "US", CL_INDICATOR_IFS = "NGDP_SA_AR_XDC")
Q.US.NGDP.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate, 
    checkquery)
Q.US.NGDP.query[, 1:5]
#>   @FREQ @REF_AREA     @INDICATOR @UNIT_MULT @TIME_FORMAT
#> 1     Q        US NGDP_SA_AR_XDC          9          P3M
Q.US.NGDP.query$Obs[[1]]
#>    @TIME_PERIOD @OBS_VALUE
#> 1       2001-Q1    10508.1
#> 2       2001-Q2    10638.4
#> 3       2001-Q3    10639.5
#> 4       2001-Q4    10701.3
#> 5       2002-Q1    10834.4
#> 6       2002-Q2    10934.8
#> 7       2002-Q3    11037.1
#> 8       2002-Q4    11103.8
#> 9       2003-Q1    11230.1
#> 10      2003-Q2    11370.7
#> 11      2003-Q3    11625.1
#> 12      2003-Q4    11816.8
#> 13      2004-Q1    11988.4
#> 14      2004-Q2    12181.4
#> 15      2004-Q3    12367.7
#> 16      2004-Q4    12562.2
#> 17      2005-Q1    12813.7
#> 18      2005-Q2    12974.1
#> 19      2005-Q3    13205.4
#> 20      2005-Q4    13381.6
#> 21      2006-Q1    13648.9
#> 22      2006-Q2    13799.8
#> 23      2006-Q3    13908.5
#> 24      2006-Q4    14066.4
#> 25      2007-Q1    14233.2
#> 26      2007-Q2    14422.3
#> 27      2007-Q3    14569.7
#> 28      2007-Q4    14685.3
#> 29      2008-Q1    14668.4
#> 30      2008-Q2      14813
#> 31      2008-Q3      14843
#> 32      2008-Q4    14549.9
#> 33      2009-Q1    14383.9
#> 34      2009-Q2    14340.4
#> 35      2009-Q3    14384.1
#> 36      2009-Q4    14566.5
#> 37      2010-Q1    14681.1
#> 38      2010-Q2    14888.6
#> 39      2010-Q3    15057.7
#> 40      2010-Q4    15230.2
#> 41      2011-Q1    15238.4
#> 42      2011-Q2    15460.9
#> 43      2011-Q3    15587.1
#> 44      2011-Q4    15785.3
#> 45      2012-Q1    15973.9
#> 46      2012-Q2    16121.9
#> 47      2012-Q3    16227.9
#> 48      2012-Q4    16297.3
#> 49      2013-Q1    16475.4
#> 50      2013-Q2    16541.4
#> 51      2013-Q3    16749.3
#> 52      2013-Q4    16999.9
#> 53      2014-Q1    17025.2
#> 54      2014-Q2    17285.6
#> 55      2014-Q3    17569.4
#> 56      2014-Q4    17692.2
#> 57      2015-Q1    17783.6
#> 58      2015-Q2    17998.3
#> 59      2015-Q3    18141.9
#> 60      2015-Q4    18222.8
#> 61      2016-Q1    18281.6
#> 62      2016-Q2    18437.6

## See exact API call to the data source
CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery, verbose = TRUE)$Obs[[1]]
#> 
#> making API call:
#> http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/IFS/Q.US.NGDP_SA_AR_XDC?startPeriod=2001-01-01&endPeriod=2016-12-31
#>    @TIME_PERIOD @OBS_VALUE
#> 1       2001-Q1    10508.1
#> 2       2001-Q2    10638.4
#> 3       2001-Q3    10639.5
#> 4       2001-Q4    10701.3
#> 5       2002-Q1    10834.4
#> 6       2002-Q2    10934.8
#> 7       2002-Q3    11037.1
#> 8       2002-Q4    11103.8
#> 9       2003-Q1    11230.1
#> 10      2003-Q2    11370.7
#> 11      2003-Q3    11625.1
#> 12      2003-Q4    11816.8
#> 13      2004-Q1    11988.4
#> 14      2004-Q2    12181.4
#> 15      2004-Q3    12367.7
#> 16      2004-Q4    12562.2
#> 17      2005-Q1    12813.7
#> 18      2005-Q2    12974.1
#> 19      2005-Q3    13205.4
#> 20      2005-Q4    13381.6
#> 21      2006-Q1    13648.9
#> 22      2006-Q2    13799.8
#> 23      2006-Q3    13908.5
#> 24      2006-Q4    14066.4
#> 25      2007-Q1    14233.2
#> 26      2007-Q2    14422.3
#> 27      2007-Q3    14569.7
#> 28      2007-Q4    14685.3
#> 29      2008-Q1    14668.4
#> 30      2008-Q2      14813
#> 31      2008-Q3      14843
#> 32      2008-Q4    14549.9
#> 33      2009-Q1    14383.9
#> 34      2009-Q2    14340.4
#> 35      2009-Q3    14384.1
#> 36      2009-Q4    14566.5
#> 37      2010-Q1    14681.1
#> 38      2010-Q2    14888.6
#> 39      2010-Q3    15057.7
#> 40      2010-Q4    15230.2
#> 41      2011-Q1    15238.4
#> 42      2011-Q2    15460.9
#> 43      2011-Q3    15587.1
#> 44      2011-Q4    15785.3
#> 45      2012-Q1    15973.9
#> 46      2012-Q2    16121.9
#> 47      2012-Q3    16227.9
#> 48      2012-Q4    16297.3
#> 49      2013-Q1    16475.4
#> 50      2013-Q2    16541.4
#> 51      2013-Q3    16749.3
#> 52      2013-Q4    16999.9
#> 53      2014-Q1    17025.2
#> 54      2014-Q2    17285.6
#> 55      2014-Q3    17569.4
#> 56      2014-Q4    17692.2
#> 57      2015-Q1    17783.6
#> 58      2015-Q2    17998.3
#> 59      2015-Q3    18141.9
#> 60      2015-Q4    18222.8
#> 61      2016-Q1    18281.6
#> 62      2016-Q2    18437.6

## Return a simple data frame
head(CompactDataMethod(databaseID, queryfilter, startdate, enddate, checkquery, 
    tidy = TRUE))
#>   @TIME_PERIOD @OBS_VALUE @FREQ @REF_AREA     @INDICATOR @UNIT_MULT
#> 1      2001-Q1    10508.1     Q        US NGDP_SA_AR_XDC          9
#> 2      2001-Q2    10638.4     Q        US NGDP_SA_AR_XDC          9
#> 3      2001-Q3    10639.5     Q        US NGDP_SA_AR_XDC          9
#> 4      2001-Q4    10701.3     Q        US NGDP_SA_AR_XDC          9
#> 5      2002-Q1    10834.4     Q        US NGDP_SA_AR_XDC          9
#> 6      2002-Q2    10934.8     Q        US NGDP_SA_AR_XDC          9
#>   @TIME_FORMAT
#> 1          P3M
#> 2          P3M
#> 3          P3M
#> 4          P3M
#> 5          P3M
#> 6          P3M
```
