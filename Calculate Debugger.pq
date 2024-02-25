let func =   
 (filterExpression as text,
 myColumnName as text,
 optional MaxFilters as number
) =>

let
/* Debug parameters
    myColumnName = "Datum",
    filterExpression = "DATESYTD(DimDate[Datum])",
    MaxFilters = 10,
   */// End of debug parameters

    maxFilters = Text.From(if MaxFilters = null then 10 else MaxFilters),
    ListOfDelimiters = {">=", "<=", "<>", "=", ">", "<"},
    
    // Splits filterExpression by the first delimiter it finds
    SplittedBoolean = List.Accumulate(  
                        ListOfDelimiters, 
                        {},
                        (state, current) =>  if List.Count(state) = 2 
                                                then state 
                                                else Text.Split(filterExpression, current)),
    HasSyntaxSugar = not Text.Contains(
                            List.First(SplittedBoolean), 
                            ")"),
    FullFilterExpression = if HasSyntaxSugar 
                            then "Filter(All(" & SplittedBoolean{0} & "), " & filterExpression & ")" 
                            else filterExpression,
    MeasureString = "
DAX Debugger = 
VAR FilterTable = " 
    & FullFilterExpression & "
VAR TableLength = 
    COUNTROWS(FilterTable)
VAR ColumnMax = 
    MAXX(FilterTable, [" & myColumnName & "])
VAR ColumnMin = 
    MINX(FilterTable, [" & myColumnName & "])
VAR TOPX = IF(TableLength < " & maxFilters & ", TableLength, " & maxFilters &")
VAR ValuesInColumn = 
    CONCATENATEX(TOPN(TOPX, FilterTable), [" & myColumnName & "], "", "") 
RETURN
    --""TableLength: "" & TableLength  & "", Min: "" & ColumnMin & "", Max: "" & ColumnMax
     ""TableLength: "" & TableLength  & "", Min: "" & ColumnMin & "", Max: "" & ColumnMax & UNICHAR(13) & UNICHAR(10) & ""Top "" & TOPX & "" Values: "" & ValuesInColumn
                "
in
    MeasureString ,
documentation = [
Documentation.Name =  " DAX.CalculateDebugger.pq ",
Documentation.Description = " Produces DAX code to debug a filter argument of CALCULATE. ",
Documentation.LongDescription = " Produces DAX code to debug a filter argument of CALCULATE. <code>filterExpression</code> holds the code of the CALCULATE filter expression, <code>myColumnName</code> the name of the column whose values to show and optional <code>MaxFilters</code> can modify the default value of the first 10 sample values to show. ",
Documentation.Category = " DAX ",
Documentation.Source = " www.TheBIccountant.com .  https://wp.me/p6lgsG-1nD . ",
Documentation.Version = " 1.0 ",
Documentation.Author = " Imke Feldmann: www.TheBIccountant.com. https://wp.me/p6lgsG-1nD . ",
Documentation.Examples = {[Description =  "  ",
Code = "  ",
Result = "  "]}]
  
 in  
  Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))  