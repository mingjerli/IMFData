IFS.available.codes <- DataStructureMethod('IFS') # Get dimension code of IFS dataset
names(IFS.available.codes) # Available dimension code
IFS.available.codes[[1]] # Possible code in the first dimension
CodeSearch(IFS.available.codes, 'CLL', 'GDP') # Error (CLL is not a dimension code of IFS dataset)
CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDP') # Search code contains GDP
CodeSearch(IFS.available.codes, 'CL_INDICATOR_IFS', 'GDPABCDE') # NULL (cannot find GDPABCDE in CL_INDICATOR_IFS dimension)
