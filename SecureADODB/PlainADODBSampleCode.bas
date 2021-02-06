Attribute VB_Name = "PlainADODBSampleCode"
'@Folder("-- DraftsTemplatesSnippets --")
'@IgnoreModule
Option Explicit


Public Sub TestADODBSourceSQL()
    Dim sDriver As String
    Dim sOptions As String
    Dim sDatabase As String

    Dim adoConnStr As String
    Dim qtConnStr As String
    Dim sSQL As String
    Dim sQTName As String
    
    sDatabase = ThisWorkbook.Path + "\" + "SecureADODB.db"
    sDriver = "{SQLite3 ODBC Driver}"
    sOptions = "SyncPragma=NORMAL;LongNames=True;NoCreat=True;FKSupport=True;OEMCP=True;"
    adoConnStr = "Driver=" + sDriver + ";" + _
                 "Database=" + sDatabase + ";" + _
                 sOptions

    qtConnStr = "OLEDB;" + adoConnStr
    
    sSQL = "SELECT * FROM categories WHERE category_id <= 3 AND section = 'machinery'"
    
    Dim AdoRecordset As ADODB.Recordset
    Set AdoRecordset = New ADODB.Recordset
    AdoRecordset.CursorLocation = adUseClient
    AdoRecordset.Open source:=sSQL, ActiveConnection:=adoConnStr, CursorType:=adOpenKeyset, LockType:=adLockReadOnly, Options:=(adCmdText Or adAsyncFetch)
    Set AdoRecordset.ActiveConnection = Nothing
End Sub


Public Sub TestADODBSourceCMD()
    Dim sDriver As String
    Dim sOptions As String
    Dim sDatabase As String

    Dim adoConnStr As String
    Dim qtConnStr As String
    Dim sSQL As String
    Dim sQTName As String
    
    sDatabase = ThisWorkbook.Path + "\" + "SecureADODB.db"
    sDriver = "{SQLite3 ODBC Driver}"
    sOptions = "SyncPragma=NORMAL;LongNames=True;NoCreat=True;FKSupport=True;OEMCP=True;"
    adoConnStr = "Driver=" + sDriver + ";" + _
                 "Database=" + sDatabase + ";" + _
                 sOptions

    qtConnStr = "OLEDB;" + adoConnStr
    
    sSQL = "SELECT * FROM categories WHERE category_id <= 3 AND section = 'machinery'"
    
    Dim AdoRecordset As ADODB.Recordset
    Set AdoRecordset = New ADODB.Recordset
    Dim AdoCommand As ADODB.Command
    Set AdoCommand = New ADODB.Command
    
    With AdoCommand
        .CommandType = adCmdText
        .CommandText = sSQL
        .ActiveConnection = adoConnStr
        .ActiveConnection.CursorLocation = adUseClient
    End With
    
    With AdoRecordset
        Set .source = AdoCommand
        .CursorLocation = adUseClient
        .CursorType = adOpenKeyset
        .LockType = adLockReadOnly
        .Open Options:=adAsyncFetch
        Set .ActiveConnection = Nothing
    End With
    AdoCommand.ActiveConnection.Close
End Sub


' Could not make it to work with named parameters
Public Sub TestADODBSourceCMDwithParametersPositional()
    Dim sDriver As String
    Dim sOptions As String
    Dim sDatabase As String

    Dim adoConnStr As String
    Dim qtConnStr As String
    Dim sSQL As String
    Dim sQTName As String
    
    sDatabase = ThisWorkbook.Path + "\" + "SecureADODB.db"
    sDriver = "{SQLite3 ODBC Driver}"
    sOptions = "SyncPragma=NORMAL;LongNames=True;NoCreat=True;FKSupport=True;OEMCP=True;"
    adoConnStr = "Driver=" + sDriver + ";" + _
                 "Database=" + sDatabase + ";" + _
                 sOptions

    qtConnStr = "OLEDB;" + adoConnStr
    
    sSQL = "SELECT * FROM categories WHERE category_id <= ? AND section = ?"
    
    Dim AdoRecordset As ADODB.Recordset
    Set AdoRecordset = New ADODB.Recordset
    Dim AdoCommand As ADODB.Command
    Set AdoCommand = New ADODB.Command
    
    Dim mappings As ITypeMap
    Set mappings = AdoTypeMappings.Default
    Dim provider As IParameterProvider
    Set provider = AdoParameterProvider.Create(mappings)
    
    Dim adoParameter As ADODB.Parameter
    Set adoParameter = provider.FromValue(3)
    'adoParameter.name = "@category_id"
    AdoCommand.Parameters.Append adoParameter
    Set adoParameter = provider.FromValue("machinery")
    'adoParameter.name = "@section"
    AdoCommand.Parameters.Append adoParameter
    
    With AdoCommand
        .CommandType = adCmdText
        .CommandText = sSQL
        .Prepared = True
        '.NamedParameters = True
        .ActiveConnection = adoConnStr
        .ActiveConnection.CursorLocation = adUseClient
    End With
        
    With AdoRecordset
        Set .source = AdoCommand
        .CursorLocation = adUseClient
        .CursorType = adOpenKeyset
        .LockType = adLockReadOnly
        .Open Options:=adAsyncFetch
        Set .ActiveConnection = Nothing
    End With
    AdoCommand.ActiveConnection.Close
    Debug.Print "RecordCount: " & CStr(AdoRecordset.RecordCount)
End Sub


Public Sub TestADODBSourceSQLite()
    Dim fso As New Scripting.FileSystemObject
    Dim sDriver As String
    Dim sDatabase As String
    Dim sDatabaseExt As String
    Dim sTable As String
    Dim adoConnStr As String
    Dim sSQL As String
    
    sDriver = "{SQLite3 ODBC Driver}"
    sDatabaseExt = ".db"
    sTable = "categories"
    sDatabase = ThisWorkbook.Path & Application.PathSeparator & fso.GetBaseName(ThisWorkbook.Name) & sDatabaseExt
    adoConnStr = "Driver=" & sDriver & ";" & _
                 "Database=" & sDatabase & ";"
    
    sSQL = "SELECT * FROM """ & sTable & """"
        
    Dim AdoRecordset As ADODB.Recordset
    Set AdoRecordset = New ADODB.Recordset
    AdoRecordset.CursorLocation = adUseClient
    AdoRecordset.Open _
            source:=sSQL, _
            ActiveConnection:=adoConnStr, _
            CursorType:=adOpenKeyset, _
            LockType:=adLockReadOnly, _
            Options:=(adCmdText Or adAsyncFetch)
    Set AdoRecordset.ActiveConnection = Nothing
End Sub


Public Sub TestADODBSourceCSV()
    Dim fso As New Scripting.FileSystemObject
    Dim sDriver As String
    Dim sDatabase As String
    Dim sDatabaseExt As String
    Dim sTable As String
    Dim adoConnStr As String
    Dim sSQL As String
    
    sDriver = "{Microsoft Text Driver (*.txt; *.csv)}"
    sDatabaseExt = ".csv"
    sDatabase = ThisWorkbook.Path
    sTable = fso.GetBaseName(ThisWorkbook.Name) & sDatabaseExt
    adoConnStr = "Driver=" & sDriver & ";" & _
                 "Database=" & sDatabase & ";"
    
    sSQL = "SELECT * FROM """ & sTable & """"
    
    Dim AdoRecordset As ADODB.Recordset
    Set AdoRecordset = New ADODB.Recordset
    AdoRecordset.CursorLocation = adUseClient
    AdoRecordset.Open _
            source:=sSQL, _
            ActiveConnection:=adoConnStr, _
            CursorType:=adOpenKeyset, _
            LockType:=adLockReadOnly, _
            Options:=(adCmdText Or adAsyncFetch)
    Set AdoRecordset.ActiveConnection = Nothing
End Sub


