
section Ringostat;

[DataSource.Kind="Ringostat", Publish="Ringostat.Publish"]
shared Ringostat.Data = Value.ReplaceType(Ringostat.Func, FuncType);

FuncType = type function (
     
    start as (type text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.FieldDescription = "Enter the first date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"2020-02-28"}
    ]),
     end as (type text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.FieldDescription = "Enter the last date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"yesterday"}
    ])
    )
    as table meta [
        Documentation.Name = "Ringostat.Data Function",
        Documentation.LongDescription = "Created to get data from Ringostat.",
        Documentation.Examples = {
        [
            Description = "Returns a list of records from your Ringostat table",
            Code = "Ringostat.Data(""2020-02-20"",""yesterday"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ],
        [
            Description = "Returns a list of records from your Ringostat table",
            Code = "Ringostat.Data(""500daysAgo"",""today"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ]
        }
    ];



Ringostat.Func =( start as text, end as text)=>
let
 
data = [#"export_type"="json", #"from"=dateFunc(start)& " 00:00:01", #"to"= dateFunc(end)& " 23:59:59", #"fields"="caller,dst,pool_name,disposition,calldate,category_mark,duration,call_type,waittime,billsec,connected_with,call_counter,proper_flag,repeated_flag,utm_source,utm_medium,utm_campaign,utm_content,utm_term,uniqueid,category_number,employee_number,employee_mark,client_id,remote_ip,refferrer,landing,recording,call_card,additional_number,has_recording,scheme_name,duration_ms,employee_fio"],
headers = [#"Auth-key"= Extension.CurrentCredential()[Key], #"Content-Type"="application/json"],
web = Web.Contents("https://api.ringostat.net/calls/list", [Query = data, Headers = headers, ManualStatusHandling = {404, 400}]),
result = Json.Document(web),
#"Преобразовано в таблицу" = Table.FromList(result, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
#"Преобразовано в таблицу";


    


dateFunc= (dat)=>
       if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"yyyy-MM-dd") 
       else if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"yyyy-MM-dd")
       else if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"yyyy-MM-dd") 
       else dat ;



Ringostat = [
    TestConnection = (dataSourcePath) => 
        { "Ringostat.Data", 
        Json.Document(dataSourcePath)[start],
        Json.Document(dataSourcePath)[end]},
    Authentication = [
        
         Key = []
   
    ],
    Label = "Ringostat Connection"
];



Ringostat.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { "Ringostat Connector", "Ringostat Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g/",
    SourceImage = Ringostat.Icons,
    SourceTypeImage = Ringostat.Icons
];



Ringostat.Icons = [
    Icon16 = { Extension.Contents("Ringostat16.png"), Extension.Contents("Ringostat20.png"), Extension.Contents("Ringostat24.png"), Extension.Contents("Ringostat32.png") },
    Icon32 = { Extension.Contents("Ringostat32.png"), Extension.Contents("Ringostat40.png"), Extension.Contents("Ringostat48.png"), Extension.Contents("Ringostat64.png") }
];
