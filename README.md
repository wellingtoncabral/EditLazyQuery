#EditLazyQuery
EditLazyQuery is a component that performs queries on the database using pagination. The default page size is 100, but can be changed in your settings. 

![EditLazyQuery](https://s25.postimg.org/mj26gfx5r/Edit_Lazy_Query.png)

The query will only be triggered when the user stops typing (500 milliseconds). This allows the component to be very performative.

##How to use
1. Add an EditLazyQuery in your Form
2. Set a TDataSet component into EditLazyQuery
3. Set a Page size into EditLazyQuery
4. Implements 3 methods: **OnGetRecordCount(); OnSearch(); and OnSearchByKeyValue();**

###procedure OnGetRecordCount(var RecordCount: Integer);
You need to tell the component how many records the query will have. This information is important because the component needs to build the paging.

```delphi
procedure TForm.EditLazyQuery1GetRecordCount(var RecordCount: Integer);
begin
  RecordCount := GetQueryRecordCount;
end;
```

###procedure EditLazyQuerySearch(Text: string; AStartRowNum, AEndRowNum: Integer);
In this method you need to prepare the Query with the parameters:
Text: Text entered by the user in the component;
AStartRowNum: Initial record number;
AEndRowNum: Number of the final record;

```delphi
procedure TForm.EditLazyQuerySearch(Text: string; AStartRowNum,
  AEndRowNum: Integer);

const
  C_SQL = 'SELECT * FROM customers WHERE name LIKE ''%s''';

  C_SQL_SELECT_ROWNUM_ORACLE =
    'SELECT * FROM ( ' +
    '  SELECT a.*, ROWNUM rnum FROM ( ' +
    '    %s ' +
    '  ) a WHERE ROWNUM <= %d ' +
    ') WHERE rnum >= %d';

  C_SQL_SELECT_ROWNUM_MYSQL = '%s LIMIT %d, %d';

var
  Sql: string;
begin
  DataSet.Close;

  Sql := Format(C_SQL, [Text]);

  // Oracle
  DataSet.CommandText := Format(C_SQL_SELECT_ROWNUM_ORACLE, [Sql, AEndRowNum, AStartRowNum]);

  // MySQL
  DataSet.CommandText := Format(C_SQL_SELECT_ROWNUM_MYSQL, [Sql, AStartRowNum-1, EditLazyQuery.PageSize]);

  DataSet.Open;
end;
```

###procedure EditLazyQuerySearchByKeyValue(AKeyValue: OleVariant);
This method will be fired when EditLazyQuery.SetKeyValue (Value) is invoked.
You need to open DataSet by searching for ID.

```delphi
procedure TForm.EditLazyQuerySearchByKeyValue(AKeyValue: OleVariant);

const
  C_SQL = 'SELECT * FROM customers WHERE id = %d';

begin
  DataSet.Close;
  DataSet.CommandText := Format(C_SQL, [AKeyValue]);
  DataSet.Open;
end;
```
