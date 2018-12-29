// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	Create создает необходимые поля в структуре ERPData.
Procedure Create(ERPData) Export

	//	Путь до конфигурационного файла ERPEngine.xml.
	ERPData.Insert("Config", "C:\inetpub\ERPWebInterface\Settings\ERPEngine.xml");
	
	//	Загруженный конфигурационный файл ERPEngine.xml.
	ERPData.Insert("DOMDocument", Undefined);
	
	//	COM-объект подключения к SQL-базе данных ADODB.Connection 
	ERPData.Insert("Connection", New COMObject("ADODB.Connection"));
	
	//	Строка подключения к SQL-базе данных 
	ERPData.Insert("ConnStr", "");
	
	//	Уровень вложенности трнзакции
	ERPData.Insert("TransLevel", 0);
	
	//	Таблица заголовков и дочерние таблицы
	ERPData.Insert("HeaderTable", New ValueTable);
	ERPData.Insert("ChildTables", New Array);
	
	//	Строка данных таблицы заголовков
	ERPData.Insert("header", Undefined);
	
	//	Номер теущий строки таблицы заголовов
	ERPData.Insert("HeaderLine", -1);
	
	//	Краткие имена дочерних таблиц
	ERPData.Insert("ChildNames", New Array);
	
	//	Индекс дочерней таблицы
	ERPData.Insert("ChildIndex", -1);
	
	//	Номера текущих строк дочерних таблиц
	ERPData.Insert("ChildLines", New Array);
	
	//	Полное имя таблицы заголовка и дочерних таблиц
	ERPData.Insert("HeaderTableName", "");
	ERPData.Insert("ChildTableNames", New Array);
	
	//	Индексы колонок заголовка с контрольной информацией (кол-во строк в дочерней таблице)
	ERPData.Insert("TotalIndexes", New Array);
	
EndProcedure

//	Connect подключает модуль к SQL-базе данных.
Function Connect(ERPData) Export
	
	DOMBuilder = New DOMBuilder;
	XMLReader = New XMLReader;
	
	Try
		XMLReader.OpenFile(ERPData.Config);
	 	ERPData.DOMDocument = DOMBuilder.Read(XMLReader);
		XMLReader.Close();
	Except
		Return "Ошибка чтения конфигурационного файла <" + ERPData.Config + ">:" + Chars.CR + Chars.LF + ErrorDescription();
	EndTry;
	
	EngineNode = ERPData.DOMDocument.DocumentElement;
	
	If EngineNode.NodeName <> "ERPEngine" Then
		Return "Недопустимый формат описателя интерфейса ERP-WMS (отсутствует корневой элемент ERPEngine)";
	EndIf;
	
	//	Переберем атрибуты интерфейса ERP-EME.WMS
	For Each EngineAttrib In EngineNode.Attributes Do
		If EngineAttrib.Name = "connection" Then
			ERPData.ConnStr = Mid(EngineAttrib.Value, StrLen("ODBC:") + 1);
		EndIf
	EndDo;
	
	Try
		//	Открываем соединение
		ERPData.Connection.Open(ERPData.ConnStr);
	Except
		Return "Ошибка подключения к базе данных <" + ERPData.ConnStr + ">:" + Chars.CR + Chars.LF + ErrorDescription();
	EndTry;
		
	//	Устанавливаем уровень изоляции adXactReadCommitted
	ERPData.Connection.IsolationLevel = 4096;
	
	Return "";
	
EndFunction

//	Disconnect отключает модуль к SQL-базе данных.
Procedure Disconnect(ERPData) Export
	
	//	Закрываем соединение
	ERPData.Connection.Close();
	
EndProcedure

//  BeginExport начинает экспорт сообщения <Name> c источником <Source> и приемником <Target>.
Procedure BeginExport(ERPData, Val Source, Val Target, Val Name) Export
	
	Markup(ERPData, Source, Target, Name);
	ERPData.TransLevel = 0;

	 // Проиницализируем текущие строки
 	ERPData.HeaderLine = -1;
 	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
 		ERPData.ChildLines.Add();
  		ERPData.ChildLines[ChildIndex] = -1;
	EndDo;

EndProcedure

//  CommitExport фиксирует изменения после экспорта сообщений в SQL-базе данных.
Procedure CommitExport(ERPData) Export
	
	//	Начинаем Sql-транзакцию
	ERPData.TransLevel = ERPData.Connection.BeginTrans();
	
	Если ERPData.HeaderTableName = "erp_wms_goods_header" Тогда
		DeleteOldMessages(ERPData);
		InsertNewMessages(ERPData);
	ИначеЕсли (ERPData.header<>Неопределено) И (ERPData.header.total_lines = 0) Тогда
		DeleteOldMessages(ERPData);
		InsertNewMessages(ERPData);
	Иначе
		Если СообщениеУжеОтправлялось (ERPData) Тогда
			ОбновитьСообщение(ERPData);
		Иначе
			DeleteOldMessages(ERPData);
			InsertNewMessages(ERPData);
		КонецЕсли;
	КонецЕсли;

	//	Завершаем Sql-транзакцию
	ERPData.Connection.CommitTrans();
	ERPData.TransLevel = 0;
	
EndProcedure

//  RollbackExport откатывает изменения после экспорта сообщений в SQL-базе данных.
Procedure RollbackExport(ERPData) Export
	
	//	Откатываем Sql-транзакцию
	If ERPData.TransLevel > 0 Then
		ERPData.Connection.RollbackTrans();
		ERPData.TransLevel = 0;
	EndIf

EndProcedure

//  AppendHeaderLine добавляет строку в таблицу заголовка сообщения.
Procedure AppendHeaderLine(ERPData) Export
	
	ERPData.header = ERPData.HeaderTable.Add();
	ERPData.header.id = "";
	ERPData.header.what_to_do = "MOD";
	ERPData.header.state = "NEW";
	ERPData.header.created_at = CurrentDate();
	ERPData.header.processed_at = '00010101000000';
	ERPData.header.error_code = "";
	
	//	Обнулим контрольную информацию по количеству строк в дочерних таблицах
	For Each TotalIndex In ERPData.TotalIndexes Do
		ERPData.header[TotalIndex] = 0;
	EndDo
	
EndProcedure

//  SelectChild задает в качестве текущей дочерней таблицы сообщения таблицу <ChildName>.
Procedure SelectChild(ERPData, Val ChildName) Export
	
	ChildIndex = ERPData.ChildNames.Find(ChildName);
	
	If ChildIndex = Undefined Then
		Raise "В описателе интерфейса ERP-WMS отсутствует таблица " + ChildName;
	EndIf;
	
	ERPData.ChildIndex = ChildIndex;
	ERPData.ChildLines[ChildIndex] = -1;
	
EndProcedure

//  AppendChildLine добавляет строку в текущую дочернюю таблицу сообщения. 
Procedure AppendChildLine(ERPData) Export

	ChildIndex = ERPData.ChildIndex;
	If ChildIndex < 0 Then
		Raise "Не задана дочерняя таблица";
	EndIf;
	
	ChildRow = ERPData.ChildTables[ChildIndex].Add();
	ERPData.Insert(ERPData.ChildNames[ChildIndex], ChildRow);
	
	ChildRow.id = "";
	ChildRow.header_id = ERPData.header.id;
    ChildRow.error_code = "";
	
	//	Увеличим на 1 контрольную информацию по кол-ву строк в дочерней таблице
	TotalIndex = ERPData.TotalIndexes[ChildIndex];
	ERPData.header[TotalIndex] = ERPData.header[TotalIndex] + 1;
	
EndProcedure

//  BeginImport начинает импорт сообщения <Name> c источником <Source> и приемником <Target>.
Procedure BeginImport(ERPData, Val Source, Val Target, Val Name, Val HeaderId = "") Export
	
	Markup(ERPData, Source, Target, Name);
	ERPData.TransLevel = 0;

	//	Начинаем Sql-транзакцию
	ERPData.TransLevel = ERPData.Connection.BeginTrans();
	
	//	Прочитаем заголовки сообщений
	QueryText = "SELECT * FROM """ + ERPData.HeaderTableName + """ WHERE (""state""='NEW' OR ""state""='WRN')";
	If HeaderId <> "" Then
		HeaderId = StrReplace(HeaderId, "'", "''");
		QueryText = QueryText + " AND ""id""='" + HeaderId + "'";
	EndIf;
	QueryText = QueryText + " ORDER BY ""id"";";
	
	SelectLines(ERPData.Connection, QueryText, ERPData.HeaderTable);
		
	//	Проиницализируем текущие строки
	ERPData.HeaderLine = -1;
	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		ERPData.ChildLines.Add();
		ERPData.ChildLines[ChildIndex] = -1;
	EndDo;
	
EndProcedure

Procedure BeginImportDate(ERPData, Val Source, Val Target, Val Name, Val HeaderId = "") Export
	
	Markup(ERPData, Source, Target, Name);
	//ERPData.TransLevel = 0;

	////	Начинаем Sql-транзакцию
	//ERPData.TransLevel = ERPData.Connection.BeginTrans();
	
	//	Прочитаем заголовки сообщений
	QueryText = "SELECT * FROM """ + ERPData.HeaderTableName + """ WHERE (""state""='NEW' OR ""state""='OK')";
	If HeaderId <> "" Then
		HeaderId = StrReplace(HeaderId, "'", "''");
		QueryText = QueryText + " AND ""id""='" + HeaderId + "'";
	EndIf;
	QueryText = QueryText + " ORDER BY ""created_at"" DESC;";
	
	SelectLines(ERPData.Connection, QueryText, ERPData.HeaderTable);
		
	//	Проиницализируем текущие строки
	ERPData.HeaderLine = -1;
	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		ERPData.ChildLines.Add();
		ERPData.ChildLines[ChildIndex] = -1;
	EndDo;
	
EndProcedure

Procedure GetOrderState(ERPData, Val Source, Val Target, Val Name, Val order_no = "") Export
	
	Markup(ERPData, Source, Target, Name);
		
	QueryText = "SELECT * FROM """ + ERPData.HeaderTableName + """ WHERE (""state""='NEW' OR ""state""='OK')";
	If order_no <> "" Then
		QueryText = QueryText + " AND ""order_no""='" + order_no + "'";
	EndIf;
		
	SelectLines(ERPData.Connection, QueryText, ERPData.HeaderTable);
		
	//	Проиницализируем текущие строки
	ERPData.HeaderLine = -1;
	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		ERPData.ChildLines.Add();
		ERPData.ChildLines[ChildIndex] = -1;
	EndDo;
	
EndProcedure



//  CommitImport фиксирует изменения после импорта сообщений в SQL-базе данных.
Procedure CommitImport(ERPData) Export
	
	//	Обновим последнюю строку
	If ERPData.HeaderLine <> -1 Then
		UpdateMessage(ERPData);
	EndIf;
	
	//	Завершаем Sql-транзакцию
	ERPData.Connection.CommitTrans();
	ERPData.TransLevel = 0;
	
EndProcedure

//  RollbackImport откатывает изменения после импорта сообщений в SQL-базе данных.
Procedure RollbackImport(ERPData) Export
	
	//	Откатываем Sql-транзакцию
	If ERPData.TransLevel > 0 Then
		ERPData.Connection.RollbackTrans();
		ERPData.TransLevel = 0;
	EndIf

EndProcedure

//  NextHeaderLine переставляет указатель на следующую строку в таблице заголовка сообщения.
Function NextHeaderLine(ERPData) Export
	
	If ERPData.HeaderLine + 1 < ERPData.HeaderTable.Count() Then
		
		If ERPData.HeaderLine <> -1 Then
			UpdateMessage(ERPData);
		EndIf;
		
		ERPData.HeaderLine = ERPData.HeaderLine + 1;
		
		ERPData.header = ERPData.HeaderTable[ERPData.HeaderLine];
		
		//	Прочитаем строки сообщений
		For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
			
			SelectLines(
				ERPData.Connection,
				"SELECT * FROM """ + ERPData.ChildTableNames[ChildIndex] + """ WHERE ""header_id"" = '" + ERPData.header.id + "';",
				ERPData.ChildTables[ChildIndex]);
		EndDo;
			
		For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
			
			//	Проверим контрольную информацию
			If ERPData.ChildTables[ChildIndex].Count() <> ERPData.HeaderTable[ERPData.HeaderLine][ERPData.TotalIndexes[ChildIndex]] Then
				ErrorHeader(ERPData, "TOTAL" + (ChildIndex + 1));
			EndIf;

			ERPData.ChildLines[ChildIndex] = -1;
		EndDo;
		
		Return True;
	Else
		Return False;
	EndIf

EndFunction

//  NextChildLine переставляет указатель на следующую строку в текущей дочерней таблице сообщения.
Function NextChildLine(ERPData) Export
	
	ChildIndex = ERPData.ChildIndex; 
	ChildName = ERPData.ChildNames[ChildIndex];
	ChildLine = ERPData.ChildLines[ChildIndex];
	
	If ChildLine + 1 < ERPData.ChildTables[ChildIndex].Count() Then
		ERPData.ChildLines[ChildIndex] = ChildLine + 1;
		ERPData.Insert(ChildName, ERPData.ChildTables[ChildIndex][ERPData.ChildLines[ChildIndex]]);
		
		Return True;
	Else
		Return False;
	EndIf

EndFunction

//  ErrorHeader фиксирует ошибку <ErrorCode> в текущей строке таблицы заголовка сообщения.
Procedure ErrorHeader(ERPData, Val ErrorCode) Export
	
	//If HasErrors(ERPData) Then
	//	Return
	//EndIf;
		
	ERPData.header.state = "ERR";
	ERPData.header.processed_at = CurrentDate();
	ERPData.header.error_code = ErrorCode;
	
EndProcedure

//  ErrorChild фиксирует ошибку <ErrorCode> в текущей строке текущей дочерней таблице заголовка сообщения.
Procedure ErrorChild(ERPData, Val ErrorCode) Export
	
	//If HasErrors(ERPData) Then
	//	Return
	//EndIf;
		
	ChildIndex = ERPData.ChildIndex;
	ErrorHeader(ERPData, "CHILD" + (ChildIndex + 1));
	ERPData.ChildTables[ChildIndex][ERPData.ChildLines[ChildIndex]].error_code = ErrorCode;
		
EndProcedure

//  HasErrors возвращает true, если при импорте сообщения были зафиксированы ошибки, иначе возвращает false.
Function HasErrors(ERPData) Export
	
	Return ERPData.header.state = "ERR";
	
EndFunction

//  WarningHeader фиксирует предупреждение <WarningCode> в текущей строке таблицы заголовка сообщения.
Procedure WarningHeader(ERPData, Val WarningCode) Export
	
	If HasErrors(ERPData) Then
		Return
	EndIf;
		
	ERPData.header.state = "WRN";
	ERPData.header.processed_at = CurrentDate();
	ERPData.header.error_code = WarningCode;
	
EndProcedure

//  WarningChild фиксирует предупреждение <WarningCode> в текущей строке текущей дочерней таблице заголовка сообщения.
Procedure WarningChild(ERPData, Val WarningCode) Export
	
	If HasErrors(ERPData) Then
		Return
	EndIf;
		
	ChildIndex = ERPData.ChildIndex;
	WarningHeader(ERPData, "CHILD" + (ChildIndex + 1));
	ERPData.ChildTables[ChildIndex][ERPData.ChildLines[ChildIndex]].error_code = WarningCode;
		
EndProcedure

//  HasWarnings возвращает true, если при импорте сообщения были зафиксированы предупреждения, иначе возвращает false.
Function HasWarnings(ERPData) Export
	
	Return ERPData.header.state = "WRN";
	
EndFunction

//  Success явно подтверждает удачный импорт сообщений
Procedure Success(ERPData) Export
	
	If HasErrors(ERPData) Then
		Raise "Нельзя подтвердить успешный импорт сообщения в котором уже есть ошибки";
	EndIf;
	
	ERPData.header.state = "OK";
	ERPData.header.processed_at = CurrentDate();
	
EndProcedure

//  UndoImport откатывает импорт сообщений <Name> c источником <Source> и приемником <Target> в идентификаторами HeaderIds.
Function UndoImport(ERPData, Val Source, Val Target, Val Name, HeaderIds) Export
	
	Markup(ERPData, Source, Target, Name);
	ERPData.Connection.BeginTrans();
	Try
		For Each HeaderId In HeaderIds Do
			UndoImportCore(ERPData, HeaderId);
		EndDo;
		ERPData.Connection.CommitTrans();
	Except
		ERPData.Connection.RollbackTrans();
		Return ErrorDescription();
	EndTry;
	
	Return "";

EndFunction

//  UndoImportCore откатывает импорт сообщения <HeaderId>.
Procedure UndoImportCore(ERPData, Val HeaderId)
	
	HeaderId = StrReplace(HeaderId, "'", "''");
    UndoCommand = ReplaceMacro(ERPData, "UPDATE [$HEADER$] SET [$STATE$]='NEW', [$PROCESSED_AT$]=NULL, [$ERROR_CODE$]=NULL WHERE [$ID$]='" + HeaderId + "';");
    ERPData.Connection.Execute(UndoCommand);

	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		ERPData.ChildIndex = ChildIndex;
		UndoCommand = ReplaceMacro(ERPData, "UPDATE [$CHILD$] SET [$ERROR_CODE$]=NULL WHERE [$HEADER_ID$]='" + HeaderId + "';");
		ERPData.Connection.Execute(UndoCommand);
    EndDo

EndProcedure

//	GetStatistics заполняет таблицу <Table> статистикой сообщений.
Procedure GetStatistics(ERPData, Table) Export

	Table.Columns.Clear();
	AddField(Table, "varchar(4)", "source");
	AddField(Table, "varchar(4)", "target");
	AddField(Table, "varchar(32)", "name");
	AddField(Table, "varchar(4)", "state");
	AddField(Table, "integer", "count");
	
	EngineNode = ERPData.DOMDocument.DocumentElement;
	
	//	Переберем сообщения интерфейса ERP-EME.WMS
	For Each MessageNode In EngineNode.ChildNodes Do
		
		If MessageNode.NodeName <> "ERPMessage" Then
			Continue
		EndIf;
		
		MessageName = "";
		MessageSource = "";
		MessageTarget = "";
		
		//	Переберем атрибуты сообщения интерфейса ERP-EME.WMS
		For Each MessageAttrib In MessageNode.Attributes Do
			
			If MessageAttrib.Name = "name" Then
				MessageName = MessageAttrib.Value;
			ElsIf MessageAttrib.Name = "source" Then
				MessageSource = MessageAttrib.Value;
			ElsIf MessageAttrib.Name = "target" Then
				MessageTarget = MessageAttrib.Value;
			EndIf
			
		EndDo;
		
		GetMessageCount(ERPData, MessageSource, MessageTarget, MessageName, "NEW", Table);
		GetMessageCount(ERPData, MessageSource, MessageTarget, MessageName, "WRN", Table);
		GetMessageCount(ERPData, MessageSource, MessageTarget, MessageName, "ERR", Table);
		GetMessageCount(ERPData, MessageSource, MessageTarget, MessageName, "OK", Table);
		
	EndDo;
	
EndProcedure

//	GetMessageCount возвращает количество сообщений.
Procedure GetMessageCount(ERPData, Val Source, Val Target, Val Name, Val State, Table)
	
	CountTable = New ValueTable;
	AddField(CountTable, "integer", "count");
	
	SqlTableName = Source + "_" + Target + "_" + Name + "_header";
	SelectLines(
		ERPData.Connection,
		"SELECT COUNT(id) AS count FROM """ + SqlTableName + """ WHERE ""state""='" + State + "';",
		CountTable);
		
	CountRow = CountTable[0];
	Count = CountRow.count;
	If Count <> 0 Then
		Row = Table.Add();
		Row.source = Source;
		Row.target = Target;
		Row.name = Name;
		Row.state = State;
		Row.count = Count;
	EndIf
	
EndProcedure

//	GetHeaders заполняет таблицу <Table> заголовками сообщения <Name> c источником <Source> и приемником <Target> на статусе <State>.
Procedure GetHeaders(ERPData, Val Source, Val Target, Val Name, Val State, Table) Export

	MessageNode = GetMessageNode(ERPData, Source, Target, Name);
	TableNode = GetTableNode(MessageNode, "header");
	MarkupTable(TableNode, Table);
	
	//	Имя SQL-таблицы заголовков сообщений
	SqlTableName = TableNode.Attributes.GetNamedItem("name").Value;
	
	//	Сформируем условие отбора по статусу сообщения
	StateCondition = "";
	States = StrReplace(State, ",", Chars.LF);
	For Index = 1 To StrLineCount(States) Do
		If StateCondition <> "" Then
			StateCondition = StateCondition + " OR ";
		EndIf;
		
        StateCondition = StateCondition + """state""='" + StrGetLine(States, Index) + "'";
	EndDo;
		
	//	Прочитаем заголовки сообщений
	SelectLines(
		ERPData.Connection,
		"SELECT * FROM """ + SqlTableName + """ WHERE " + StateCondition + " ORDER BY ""id"";",
		Table);
	
EndProcedure

//	GetChilds заполняет массив <ChildsArray> заголовками сообщения <Name> c источником <Source> и приемником <Target>.
Procedure GetChilds(ERPData, Val Source, Val Target, Val Name, ChildsArray) Export

	MessageNode = GetMessageNode(ERPData, Source, Target, Name);
	
	//	Переберем таблицы сообщения интерфейса ERP-EME.WMS
	For Each TableNode In MessageNode.ChildNodes Do
		
		If TableNode.NodeName <> "ERPTable" Then
			Continue
		EndIf;

		TableType = "";
		TableChild = "";
		
		//	Переберем атрибуты таблицы сообщения интерфейса ERP-EME.WMS
		For Each TableAttrib In TableNode.Attributes Do
			If TableAttrib.Name = "type" Then
				TableType = TableAttrib.Value;
			ElsIf TableAttrib.Name = "child" Then
				TableChild = TableAttrib.Value;
			EndIf
		EndDo;
		
		If (TableType = "child") Then
			ChildsArray.Add(TableChild);
		EndIf
		
	EndDo;
	
EndProcedure

//	GetChildLines заполняет таблицу <Table> строками <Child> сообщения <Name> с идентификатором <HeaderId> c источником <Source> и приемником <Target> на статусе <State>.
Procedure GetChildLines(ERPData, Val Source, Val Target, Val Name, Val Child, Val HeaderId, Table) Export

	MessageNode = GetMessageNode(ERPData, Source, Target, Name);
	TableNode = GetTableNode(MessageNode, Child);
	MarkupTable(TableNode, Table);
	
	//	Имя SQL-таблицы заголовков сообщений
	SqlTableName = TableNode.Attributes.GetNamedItem("name").Value;
	
	//	Прочитаем строки сообщения
	SelectLines(
		ERPData.Connection,
		"SELECT * FROM """ + SqlTableName + """ WHERE ""header_id""='" + StrReplace(HeaderId, "'", "''") + "';",
		Table);
	
EndProcedure

//  Markup размечает набор данных под сообщение <Name> c источником <Source> и приемником <Target>.
Procedure Markup(ERPData, Val Source, Val Target, Val Name);
	
	//	Очистим структуру ERPData от предыдущей разметки
	ERPData.HeaderTable.Columns.Clear();
	ERPData.ChildTables.Clear();
	ERPData.header = Undefined;
	ERPData.HeaderLine = -1;
	For Each ChildName In ERPData.ChildNames Do
		ERPData.Delete(ChildName);
	EndDo;
	ERPData.ChildNames.Clear();
	ERPData.ChildIndex = -1;
	ERPData.ChildLines.Clear();
	ERPData.HeaderTableName = "";
	ERPData.ChildTableNames.Clear();
	ERPData.TotalIndexes.Clear();

	MessageNode = GetMessageNode(ERPData, Source, Target, Name);
	
	ChildCount = 0;
			
	//	Переберем таблицы сообщения интерфейса ERP-EME.WMS
	For Each TableNode In MessageNode.ChildNodes Do
		
		If TableNode.NodeName <> "ERPTable" Then
			Continue
		EndIf;

		TableName = "";
		TableType = "";
		TableChild = "";
		
		//	Переберем атрибуты таблицы сообщения интерфейса ERP-EME.WMS
		For Each TableAttrib In TableNode.Attributes Do
			If TableAttrib.Name = "name" Then
				TableName = TableAttrib.Value;
			ElsIf TableAttrib.Name = "type" Then
				TableType = TableAttrib.Value;
			ElsIf TableAttrib.Name = "child" Then
				TableChild = TableAttrib.Value;
			EndIf
		EndDo;
		
		If TableType = "header" Then
			ERPData.HeaderTableName = TableName;
			Table = ERPData.HeaderTable;
		ElsIf TableType = "child" Then
			ERPData.ChildTables.Add(New ValueTable);
			ERPData.ChildNames.Add(TableChild);
			ERPData.ChildTableNames.Add(TableName);
			ERPData.Insert(TableChild, Undefined);
			Table = ERPData.ChildTables[ChildCount];
			ChildCount = ChildCount + 1;
		Else
			Continue
		EndIf;
		
		MarkupTable(TableNode, Table);
		
	EndDo;
	
	//	Найдем в таблице заголовков колонки с итоговыми количествами строк в дочерних таблицах
	For Each ChildName In ERPData.ChildNames Do
		TotalColumnName = "total_" + ChildName;
		
		TotlaIndex = Undefined;
		For ColumnIndex = 0 To ERPData.HeaderTable.Columns.Count() - 1 Do
			If ERPData.HeaderTable.Columns[ColumnIndex].Name = TotalColumnName Then
				TotlaIndex = ColumnIndex;
				Break
			EndIf
		EndDo;
		
		If TotlaIndex = Undefined Then
			Raise "В таблице заголовков отсутствует колонка " + TotalColumnName + " с контрольной информацией и кол-ве строк в дочерней таблиц";
		EndIf;
		
		ERPData.TotalIndexes.Add(TotlaIndex);
	EndDo;
	
EndProcedure

//  GetMessageNode возвращает XML-описатель сообщения <Name> c источником <Source> и приемником <Target>.
Function GetMessageNode(ERPData, Val Source, Val Target, Val Name)
	
	EngineNode = ERPData.DOMDocument.DocumentElement;
	
	//	Переберем сообщения интерфейса ERP-EME.WMS
	For Each MessageNode In EngineNode.ChildNodes Do
		
		If MessageNode.NodeName <> "ERPMessage" Then
			Continue
		EndIf;
		
		MessageName = "";
		MessageSource = "";
		MessageTarget = "";
		
		//	Переберем атрибуты сообщения интерфейса ERP-EME.WMS
		For Each MessageAttrib In MessageNode.Attributes Do
			
			If MessageAttrib.Name = "name" Then
				MessageName = MessageAttrib.Value;
			ElsIf MessageAttrib.Name = "source" Then
				MessageSource = MessageAttrib.Value;
			ElsIf MessageAttrib.Name = "target" Then
				MessageTarget = MessageAttrib.Value;
			EndIf
			
		EndDo;
		
		If MessageName = Name And MessageSource = Source And MessageTarget = Target Then
			Return MessageNode;
		EndIf
	EndDo;
	
	Raise "В описателе интерфейса ERP-WMS отсутствует сообщение " + Name + " (откуда-" + Source + ", куда-" + Target + ")";
	Return Undefined;
	
EndFunction

//  GetMessageNode возвращает XML-описатель таблицы <TableName> в XML-описателе сообщения <MessageNode>.
Function GetTableNode(MessageNode, Val TableName)
	
	//	Переберем таблицы сообщения интерфейса ERP-EME.WMS
	For Each TableNode In MessageNode.ChildNodes Do
		
		If TableNode.NodeName <> "ERPTable" Then
			Continue
		EndIf;

		TableType = "";
		TableChild = "";
		
		//	Переберем атрибуты таблицы сообщения интерфейса ERP-EME.WMS
		For Each TableAttrib In TableNode.Attributes Do
			If TableAttrib.Name = "type" Then
				TableType = TableAttrib.Value;
			ElsIf TableAttrib.Name = "child" Then
				TableChild = TableAttrib.Value;
			EndIf
		EndDo;
		
		If (TableType = "header" И TableName = "header") Или (TableType = "child" И TableName = TableChild) Then
			Return TableNode;
		EndIf
		
	EndDo;
	
	Raise "В описателе интерфейса ERP-WMS отсутствует таблица " + TableName;
	Return Undefined;
	
EndFunction

//  MarkupTable по XML-описателю таблицы <TableNode> размечает таблцу <Table>.
Procedure MarkupTable(TableNode, Table)
	
	//	Переберем поля таблицы сообщения интерфейса ERP-EME.WMS
	For Each FieldNode In TableNode.ChildNodes Do
		
		If FieldNode.NodeName <> "ERPField" Then
			Continue;
		EndIf;

		FieldName = "";
		FieldType = "";
		
		//	Переберем атрибуты поля таблицы сообщения интерфейса ERP-EME.WMS
		For Each FieldAttrib In FieldNode.Attributes Do
			If FieldAttrib.Name = "name" Then
				 FieldName = FieldAttrib.Value;
			ElsIf FieldAttrib.Name = "type" Then
				 FieldType = FieldAttrib.Value;
			EndIf
		EndDo;
		
		AddField(Table, FieldType, FieldName);
		
	EndDo
	
EndProcedure
	
//	DeleteOldMessages удаляет старые сообщения.
Procedure DeleteOldMessages(ERPData)
	
	For Each TableRow In ERPData.HeaderTable Do
		
		//	Удаляем старый заголовок сообщения
		ERPData.Connection.Execute("DELETE FROM """ + ERPData.HeaderTableName + """ WHERE ""id""='" + TableRow.id + "';");
		
		//	Удаляем старые строки сообщения
		For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
			ERPData.Connection.Execute("DELETE FROM """ + ERPData.ChildTableNames[ChildIndex] + """ WHERE ""header_id""='" + TableRow.id + "';");
		EndDo
		
	EndDo;
		
EndProcedure

//	InsertNewMessages добавляет новые сообщения.
Procedure InsertNewMessages(ERPData)
	
	//	Добавляем новые заголовки сообщений
	InsertLines(ERPData.Connection, ERPData.HeaderTableName, ERPData.HeaderTable);
	
	//	Добавляем новые строки сообщений
	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		InsertLines(ERPData.Connection, ERPData.ChildTableNames[ChildIndex], ERPData.ChildTables[ChildIndex]);
	EndDo

EndProcedure

//  UpdateMessage обновляет проимпортированные сообщения.
Procedure UpdateMessage(ERPData)
	
	//	Таблица с ответом в заголовке сообщения
	AnswerHeader = New ValueTable;
	AddField(AnswerHeader, "varchar(36)", "id");
	AddField(AnswerHeader, "varchar(4)", "state");
	AddField(AnswerHeader, "datetime", "processed_at");
	AddField(AnswerHeader, "varchar(8)", "error_code");
	
	//	Таблица с ответом в строках сообщения
	AnswerChild = New ValueTable;
	AddField(AnswerChild, "varchar(36)", "header_id");
	AddField(AnswerChild, "varchar(36)", "id");
	AddField(AnswerChild, "varchar(8)", "error_code");
	
	AnswerHeaderRow = AnswerHeader.Add();
	AnswerHeaderRow.id = ERPData.header.id;
	AnswerHeaderRow.state = ERPData.header.state;
	AnswerHeaderRow.processed_at = ERPData.header.processed_at;
	AnswerHeaderRow.error_code = ERPData.header.error_code;
	
	UpdateLines(ERPData.Connection, ERPData.HeaderTableName, AnswerHeader);

	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		AnswerChild.Clear();
		For ChildLine = 0 To ERPData.ChildTables[ChildIndex].Count() - 1 Do
			ChildRow = ERPData.ChildTables[ChildIndex][ChildLine];
			If ChildRow.error_code <> "" Then
				AnswerChildRow = AnswerChild.Add();
				AnswerChildRow.header_id = ChildRow.header_id;
				AnswerChildRow.id = ChildRow.id;
				AnswerChildRow.error_code = ChildRow.error_code;
			EndIf
		EndDo;
		UpdateLines(ERPData.Connection, ERPData.ChildTableNames[ChildIndex], AnswerChild);
	EndDo		
	
EndProcedure

Процедура ОбновитьСообщение (ERPData)
	
	//	Таблица с ответом в заголовке сообщения
	AnswerHeader = New ValueTable;
	AddField(AnswerHeader, "varchar(36)", "id");
	AddField(AnswerHeader, "varchar(4)", "state");
	AddField(AnswerHeader, "datetime", "processed_at");
	AddField(AnswerHeader, "varchar(8)", "error_code");
	AddField(AnswerHeader, "varchar(8)", "total_lines");
	AddField(AnswerHeader, "varchar(10)", "order_no_internet");
	AddField(AnswerHeader, "varchar(7)", "wrh_no_internet");
	AddField(AnswerHeader, "datetime", "despatch_date");
	AddField(AnswerHeader, "varchar(128)", "comment");
	
	//	Таблица с ответом в строках сообщения
	AnswerChild = New ValueTable;
	AddField(AnswerChild, "varchar(36)", "header_id");
	AddField(AnswerChild, "varchar(36)", "id");
	AddField(AnswerChild, "varchar(36)", "order_line_no");
	AddField(AnswerChild, "varchar(8)", "error_code");
	AddField(AnswerChild, "varchar(8)", "quantity");
	AddField(AnswerChild, "varchar(36)", "goods_id");
	AddField(AnswerChild, "varchar(11)", "goods_code");
	AddField(AnswerChild, "varchar(8)", "mu_code");
	
	//Таблица для инсёрта))
	InsertTab = New ValueTable;
	AddField(InsertTab, "varchar(36)", "header_id");
	AddField(InsertTab, "varchar(36)", "id");
	AddField(InsertTab, "varchar(36)", "order_line_no");
	AddField(InsertTab, "varchar(8)", "error_code");
	AddField(InsertTab, "varchar(8)", "quantity");
	AddField(InsertTab, "varchar(36)", "goods_id");
	AddField(InsertTab, "varchar(11)", "goods_code");
	AddField(InsertTab, "varchar(8)", "mu_code");
	AddField(InsertTab, "varchar(8)", "stock_status");
	
	AnswerHeaderRow = AnswerHeader.Add();
	AnswerHeaderRow.id = ERPData.header.id;
	AnswerHeaderRow.state = ERPData.header.state;
	AnswerHeaderRow.processed_at = ERPData.header.processed_at;
	AnswerHeaderRow.error_code = ERPData.header.error_code;
	AnswerHeaderRow.total_lines = ERPData.header.total_lines;
	AnswerHeaderRow.order_no_internet = ERPData.header.order_no_internet;
	AnswerHeaderRow.wrh_no_internet = ERPData.header.wrh_no_internet;
	AnswerHeaderRow.despatch_date = ERPData.header.despatch_date;
	AnswerHeaderRow.comment = ERPData.header.comment;
	
	UpdateLines(ERPData.Connection, ERPData.HeaderTableName, AnswerHeader);
		
	For ChildIndex = 0 To ERPData.ChildTables.Count() - 1 Do
		AnswerChild.Clear();
		InsertTab.Clear();
		For ChildLine = 0 To ERPData.ChildTables[ChildIndex].Count() - 1 Do
			ChildRow = ERPData.ChildTables[ChildIndex][ChildLine];
			Если СообщениеУжеОтправлялось(ERPData,ChildRow) Тогда
				AnswerChildRow = AnswerChild.Add();
				AnswerChildRow.header_id = ChildRow.header_id;
				AnswerChildRow.id = ChildRow.id;
				AnswerChildRow.order_line_no = ChildRow.order_line_no;
				AnswerChildRow.error_code = ChildRow.error_code;
				AnswerChildRow.quantity		= ChildRow.quantity;
				AnswerChildRow.goods_id		= ChildRow.goods_id;
				AnswerChildRow.goods_code	= ChildRow.goods_code;
				AnswerChildRow.mu_code = ChildRow.mu_code;
			Иначе
				InsertTabRow = InsertTab.Add();
				InsertTabRow.header_id = ChildRow.header_id;
				InsertTabRow.id = ChildRow.id;
				InsertTabRow.order_line_no = ChildRow.order_line_no;
				InsertTabRow.error_code = ChildRow.error_code;
				InsertTabRow.quantity		= ChildRow.quantity;
				InsertTabRow.goods_id		= ChildRow.goods_id;
				InsertTabRow.goods_code	= ChildRow.goods_code;
				InsertTabRow.mu_code = ChildRow.mu_code;
				InsertTabRow.stock_status = ChildRow.stock_status;
			КонецЕсли;
		EndDo;
		UpdateLines(ERPData.Connection, ERPData.ChildTableNames[ChildIndex], AnswerChild);
		Если InsertTab.Количество()>0 Тогда
			InsertLines(ERPData.Connection, ERPData.ChildTableNames[ChildIndex], InsertTab);
		КонецЕсли;
		
	EndDo		
	
КонецПроцедуры


//	AddField добавляет поле FieldName с типом FieldType в таблицу Table.
Procedure AddField(Table, Val FieldType, Val FieldName)
	
	FieldType = Lower(FieldType);
	
	If FieldType = "integer" Or FieldType = "int" Then
		
		IntegerQualifier = New NumberQualifiers(10, 0, AllowedSign.Any);
		TypeDescription = New TypeDescription("Number", , IntegerQualifier);
		Table.Columns.Add(FieldName, TypeDescription);
		
	ElsIf FieldType = "date" Then
		
		DateQualifier = New DateQualifiers(DateFractions.Date);
		TypeDescription = New TypeDescription("Date", , DateQualifier);
		Table.Columns.Add(FieldName, TypeDescription);
		
	ElsIf FieldType = "time" Then
		
		TimeQualifier = New DateQualifiers(DateFractions.Time);
		TypeDescription = New TypeDescription("Date", , TimeQualifier);
		Table.Columns.Add(FieldName, TypeDescription);
		
	ElsIf FieldType = "datetime" Then
		
		DateTimeQualifier = New DateQualifiers(DateFractions.DateTime);
		TypeDescription = New TypeDescription("Date", , DateTimeQualifier);
		Table.Columns.Add(FieldName, TypeDescription);
		
	ElsIf FieldType = "float" Then
		
		FloatQualifier = New NumberQualifiers(15, 6, AllowedSign.Any);
		TypeDescription = New TypeDescription("Number", , FloatQualifier);
		Table.Columns.Add(FieldName, TypeDescription);
		
	Else
		
		Length = StrLen(FieldType);
		If Left(FieldType, 8) = "varchar(" And Length > 9 And Right(FieldType, 1) = ")" Then
			Size = Mid(FieldType, 9);
			Size = Number(Лев(Size, StrLen(Size) - 1));
			StringQualifiers = New StringQualifiers(Size, AllowedLength.Variable);
			TypeDescription = New TypeDescription("String", , StringQualifiers);
			Table.Columns.Add(FieldName, TypeDescription);
		Else
			Raise "Неподдерживаемый тип " + FieldType + " у поля " + FieldName;
		EndIf
		
	EndIf
		
EndProcedure

//	AsSqlValue возвращает значение в форме, пригодной для использования в SQL-выражениях.
Function AsSqlValue(Val Value, Val Type)
	
	If Value = Undefined Then
		SqlValue = "NULL";
	Else
		If Type.ContainsType(Type("String")) Then
			
			SqlValue = "'" + StrReplace(Value, "'", "''") + "'";
			
		ElsIf Type.ContainsType(Type("Number")) Then
			
			If Type.NumberQualifiers.FractionDigits = 0 Then
				SqlValue = Format(Value, "NZ=0;NG=0");
			Else
				SqlValue = Format(Value, "NZ=0;NG=0;NDS=.");
			EndIf
				
		ElsIf Type.ContainsType(Type("Date")) Then
			
			If Type.DateQualifiers.DateFractions = DateFractions.Time Then
				SqlValue = Format(Value, "DF=""HH:mm:ss.000""");
				SqlValue = "{ t '" + SqlValue + "' }";
			Else
				If Value < '19000101' Then
					SqlValue = "NULL";
				Else
					If Type.DateQualifiers.DateFractions = DateFractions.DateTime Then
						SqlValue = Format(Value, "DF=""yyyy-MM-dd HH:mm:ss.000""");
						SqlValue = "{ ts '" + SqlValue + "' }";
					ElsIf Type.DateQualifiers.DateFractions = DateFractions.Date Then
						SqlValue = Format(Value, "DF=""yyyy-MM-dd""");
						SqlValue = "{ d '" + SqlValue + "' }";
					Else
						Raise "Неподдерживаемый тип даты" + Type.DateQualifiers.DateFractions;
					EndIf
				EndIf
			EndIf;
			
		Else
			
			Raise "Неподдерживаемый тип " + Type;
			
		EndIf;
	EndIf;
	
	Return SqlValue;

EndFunction

//	CastCase приводит имя <Name> к верхнему регистру в зависимости от настроек. Возвращает приведенное имя.
Function CastCase(ERPData, Val Name)
	Return Name;
EndFunction

//	ReplaceMacro производит контекстную замену макросов в строке SQL-запроса. Возвращает преобразованную строку SQL-запроса.
Function ReplaceMacro(ERPData, Val SqlQuery)
	
	Count = ERPData.ChildTableNames.Count();
	Index = ERPData.ChildIndex;
	If Index >= 0 And Index < Count Then
		SqlQuery = StrReplace(SqlQuery, "$CHILD$", ERPData.ChildTableNames[ERPData.ChildIndex]);
	EndIf;
	SqlQuery = StrReplace(SqlQuery, "$HEADER$", ERPData.HeaderTableName);
	SqlQuery = StrReplace(SqlQuery, "[", """");
	SqlQuery = StrReplace(SqlQuery, "]", """");
	SqlQuery = StrReplace(SqlQuery, "$STATE$", CastCase(ERPData, "state"));
	SqlQuery = StrReplace(SqlQuery, "$ID$", CastCase(ERPData, "id"));
	SqlQuery = StrReplace(SqlQuery, "$HEADER_ID$", CastCase(ERPData, "header_id"));
	SqlQuery = StrReplace(SqlQuery, "$CREATED_AT$", CastCase(ERPData, "created_at"));
	SqlQuery = StrReplace(SqlQuery, "$PROCESSED_AT$", CastCase(ERPData, "processed_at"));
	SqlQuery = StrReplace(SqlQuery, "$ERROR_CODE$", CastCase(ERPData, "error_code"));
	
	Return SqlQuery;
EndFunction

//	InsertLines добавляет строки из 1C-таблицы Table в Sql-таблицу TableName.
Procedure InsertLines(Connection, Val TableName, Table)
	
	Columns = "(";
	For ColumnIndex = 0 To Table.Columns.Count() - 1 Do
		If ColumnIndex <> 0 Then
			Columns = Columns + ", ";
		EndIf;
		Columns = Columns + """" + Table.Columns[ColumnIndex].Name + """";
	EndDo;
	Columns = Columns + ")";
	
	For Each TableRow In Table Do
		Values = "(";
		For ColumnIndex = 0 To Table.Columns.Count() - 1  Do
			
			If ColumnIndex <> 0 Then
				Values = Values + ", ";
			EndIf;
			
			Value = TableRow[ColumnIndex];
			Type = Table.Columns[ColumnIndex].ValueType;
			
			Values = Values + AsSqlValue(Value, Type);
			
		EndDo;
		Values = Values + ")";
		Connection.Execute("INSERT INTO """ + TableName + """ " + Columns + " VALUES " + Values + ";");
	EndDo;

EndProcedure

//	SelectLines выбирает строки запроса QueryText и помещает их в 1C-таблицу значений Table.
Procedure SelectLines(Connection, Val QueryText, Table)
	
	//	Очистим 1С-таблицу значений
	Table.Clear();
	
	//	Создадим рекордсет с параметрами adOpenForwardOnly и adLockReadOnly
	Recordset = New COMObject("ADODB.Recordset");
	Recordset.Open(QueryText, Connection, 0, 1, -1);
	
	//	Найдем соответствие полей рекордсета и колонок 1С-таблицы значений
	SQLTo1C = New Array;
	FieldsCount = Recordset.Fields.Count;
	For FieldIndex = 0 To FieldsCount - 1 Do
		SQLTo1C.Add();
		SQLTo1C[FieldIndex] = -1;
		
		FieldColumn = Table.Columns.Find(Recordset.Fields(FieldIndex).Name);
		If FieldColumn <> Undefined Then
			SQLTo1C[FieldIndex] = Table.Columns.IndexOf(FieldColumn);
		Else
			SQLTo1C[FieldIndex] = -1;
		EndIf

	EndDo;
	
	//	Скопируем данные из рекордсета в 1С-таблицу значений
	If Not Recordset.EOF Then
		Recordset.MoveFirst();
		While Not Recordset.EOF Do
			Row = Table.Add();
			For FieldIndex = 0 To FieldsCount - 1 Do
				If SQLTo1C[FieldIndex] <> -1 Then
					Row[SQLTo1C[FieldIndex]] = Recordset.Fields(FieldIndex).Value;
				EndIf
			EndDo;
			Recordset.MoveNext();
		EndDo;
	EndIf;
	
	//	Закроем рекордсет
	Recordset.Close();
	
EndProcedure

//	UpdateLines обновляет строки в Sql-таблице TableName по данным в 1С-таблице значений.
Procedure UpdateLines(Connection, Val TableName, Table)
	
	For Each TableRow In Table Do
		
		SetExpression = "";
		WhereExpression = "";
		
		For ColumnIndex = 0 To Table.Columns.Count() - 1  Do
			
			Name = Table.Columns[ColumnIndex].Name;
			Type = Table.Columns[ColumnIndex].ValueType;
			Value = TableRow[ColumnIndex];
			
			If Name = "id" Or Name = "header_id" Then
				If WhereExpression <> "" Then
					WhereExpression = WhereExpression + " AND ";
				EndIf;
				WhereExpression = WhereExpression + """" + Name + """=" + AsSqlValue(Value, Type);
			Else
				If SetExpression <> "" Then
					SetExpression = SetExpression + ", ";
				EndIf;
				SetExpression = SetExpression + """" + Name + """=" + AsSqlValue(Value, Type);
			EndIf
				
		EndDo;
		
		Connection.Execute("UPDATE """ + TableName + """ SET " + SetExpression + " WHERE " + WhereExpression + ";");
		
	EndDo;
	
EndProcedure

//	Convert преобразует текст OldCodeLines, использующий движок ERPEngine.dll,
//	в текст NewCodeLines, использующий общий модуль EmeWmsERPEgine;
Procedure Convert(OldCodeLines, NewCodeLines) Export
	
	//	Имя объекта движка
	ERPEngine = "ERPEngine";
	
	//	Свойства
	Properties = New Array;
	Properties.Add("Config");
	Properties.Add("EnableLog");
	Properties.Add("LogFile");
	
	//	Методы движка ERPEngine.dll
	Methods = New Array;
	Methods.Add("Connect");
	Methods.Add("Disconnect");
	Methods.Add("BeginExport");
	Methods.Add("CommitExport");
	Methods.Add("RollbackExport");
	Methods.Add("AppendHeaderLine");
	Methods.Add("PutHeaderData");
	Methods.Add("PutHeaderDataAsText");
	Methods.Add("SelectChild");
	Methods.Add("AppendChildLine");
	Methods.Add("PutChildData");
	Methods.Add("PutChildDataAsText");
	Methods.Add("BeginImport");
	Methods.Add("CommitImport");
	Methods.Add("RollbackImport");
	Methods.Add("NextHeaderLine");
	Methods.Add("GetHeaderData");
	Methods.Add("GetHeaderDataAsText");
	Methods.Add("NextChildLine");
	Methods.Add("GetChildData");
	Methods.Add("GetChildDataAsText");
	Methods.Add("ErrorHeader");
	Methods.Add("ErrorChild");
	Methods.Add("HasErrors");
	Methods.Add("WarningHeader");
	Methods.Add("WarningChild");
	Methods.Add("HasWarnings");
	Methods.Add("Success");
	Methods.Add("Log");

	Child = "";
	
	For Index = 0 To OldCodeLines.Count() - 1 Do
		OldLine = OldCodeLines.Get(Index);
		NewLine = "";
		
		//	COM-объект
		If Find(OldLine, "EME.ERPEngine") > 0 Then
			NewCodeLines.Add(Символ(9) + "ERPData = Новый Структура;");
			NewCodeLines.Add(Символ(9) + "EmeWmsERPEngine.Create(ERPData);");
			Continue;
		EndIf;
		
		//	Свойства
		Property = CheckKeyWord(OldLine, Properties);
		If Property <> "" Then
			If Find(OldLine, ERPEngine + "." + Property) Then
				NewLine = StrReplace(OldLine, ERPEngine + "." + Property, "ERPData." + Property);
			Endif
		EndIf;
		
		//	Методы
		If NewLine = "" Then
			
			Method = CheckKeyWord(OldLine, Methods);
			If Method <> "" Then
				CallMethod = ERPEngine + "." + Method + "(";
				Pos = Find(OldLine, CallMethod);
				If Find(OldLine, CallMethod) > 0 Then
					NewLine = NewLine + Left(OldLine, Pos);
					If Find(Method, "Data") > 0 Then
						
						If Find(OldLine, CallMethod) > 0 Then
							//	Таблица данных
							Table = Lower(Child);
							If Find(Method, "Header") > 0 Then
								Table = "header";
							EndIf;
								
							//	Поле данных
							Field = ExtractString(OldLine);
							If Find(OldLine, """" + Field + """,") > 0 Then
								OldLine = StrReplace(OldLine, """" + Field + """,", "");
							Else
								OldLine = StrReplace(OldLine, """" + Field + """", "");
							EndIf;
							
							//	Оператор присваивания
							Assignment = "";
							If Find(Method, "Put") > 0 Then
								Assignment = " =";
							EndIf;
							
							NewLine = StrReplace(OldLine, CallMethod, "ERPData." + Table + "." + Lower(Field) + Assignment);
							
							//	Удалим закрывающую скобку
							NewLine = StrReplace(NewLine, ");", ";");
						EndIf
						
					Else
						If Find(OldLine, CallMethod + ")") > 0 Then
							NewLine = StrReplace(OldLine, CallMethod, "EmeWmsERPEngine." + Method + "(ERPData");
						Else
							NewLine = StrReplace(OldLine, CallMethod, "EmeWmsERPEngine." + Method + "(ERPData, ");
						EndIf;
						If Method = "SelectChild" Then
							Child = ExtractString(OldLine);
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf;

		If NewLine = "" Then
			NewLine = OldLine;
		EndIf;
		
		NewLine = StrReplace(NewLine, "(" + ERPEngine, "(ERPData");
		
		NewCodeLines.Add(NewLine);
	EndDo
EndProcedure

//	Convert преобразует текст OldCodeLines, использующий движок ERPEngine.dll,
//	в текст NewCodeLines, использующий общий модуль EmeWmsERPEgine;
Procedure ConvertNew(OldCodeLines, NewCodeLines) Export
	
	//	Имя объекта движка
	ERPEngine = "ERPEngine";
	
	//	Свойства
	Properties = New Array;
	Properties.Add("Config");
	Properties.Add("EnableLog");
	Properties.Add("LogFile");
	
	//	Методы движка ERPEngine.dll
	Methods = New Array;
	Methods.Add("Connect");
	Methods.Add("Disconnect");
	Methods.Add("BeginExport");
	Methods.Add("CommitExport");
	Methods.Add("RollbackExport");
	Methods.Add("AppendHeaderLine");
	Methods.Add("PutHeaderData");
	Methods.Add("PutHeaderDataAsText");
	Methods.Add("SelectChild");
	Methods.Add("AppendChildLine");
	Methods.Add("PutChildData");
	Methods.Add("PutChildDataAsText");
	Methods.Add("BeginImport");
	Methods.Add("CommitImport");
	Methods.Add("RollbackImport");
	Methods.Add("NextHeaderLine");
	Methods.Add("GetHeaderData");
	Methods.Add("GetHeaderDataAsText");
	Methods.Add("NextChildLine");
	Methods.Add("GetChildData");
	Methods.Add("GetChildDataAsText");
	Methods.Add("ErrorHeader");
	Methods.Add("ErrorChild");
	Methods.Add("HasErrors");
	Methods.Add("WarningHeader");
	Methods.Add("WarningChild");
	Methods.Add("HasWarnings");
	Methods.Add("Success");
	Methods.Add("Log");

	Child = "";
	
	For Index = 0 To OldCodeLines.Count() - 1 Do
		OldLine = OldCodeLines.Get(Index);
		NewLine = "";
		
		//	COM-объект
		If Find(OldLine, "EME.ERPEngine") > 0 Then
			NewCodeLines.Add(Символ(9) + "ERPData = Новый Структура;");
			NewCodeLines.Add(Символ(9) + "EmeWmsERPEngine.Create(ERPData);");
			Continue;
		EndIf;
		
		//	Свойства
		Property = CheckKeyWord(OldLine, Properties);
		If Property <> "" Then
			If Find(OldLine, ERPEngine + "." + Property) Then
				NewLine = StrReplace(OldLine, ERPEngine + "." + Property, "ERPData." + Property);
			Endif
		EndIf;
		
		//	Методы
		If NewLine = "" Then
			While OldLine <> "" Do
				
				For Each Method In Methods Do
					CallMethod = ERPEngine + "." + Method + "(";
					Pos = Find(OldLine, CallMethod);
					If (Pos > 0) Then
						Break
					EndIf
				EndDo;
				
				If Pos > 0 Then
					NewLine = NewLine + Left(OldLine, Pos - 1);
					OldLine = Mid(OldLine, Pos + StrLen(CallMethod));
					If Find(Method, "Data") > 0 Then
						NewLine = NewLine + "ERPData.";
						
						//	Таблица данных
						If Find(Method, "Header") > 0 Then
							NewLine = NewLine + "header";
						Else
							NewLine = NewLine + Child;
						EndIf;
						
						NewLine = NewLine + ".";
						
						//	Поле данных
						FieldName = ExtractString(OldLine);
						NewLine = NewLine + FieldName;
						If Find(OldLine, """" + FieldName + """,") > 0 Then
							OldLine = StrReplace(OldLine, """" + FieldName + """,", "");
						Else
							OldLine = StrReplace(OldLine, """" + FieldName + """", "");
						EndIf;
							
						//	Оператор присваивания
						If Find(Method, "Put") > 0 Then
							NewLine = NewLine + " =";
						EndIf;
						
						//	Найдем и удалим закрывающую скобку
						BraceCount = 1;
						While OldLine <> "" Do
							Symbol = Left(OldLine, 1);
							OldLine = Mid(OldLine, 2);
							If Symbol = "(" Then
								BraceCount = BraceCount + 1;
							ElsIf Symbol = ")" Then
								BraceCount = BraceCount - 1;
							EndIf;
							If BraceCount = 0 Then
								Break
							Else
								NewLine = NewLine + Symbol;
							EndIf
						EndDo
						
					Else
						NewLine = NewLine + "EmeWmsERPEngine." + Method + "(ERPData";
						
						If Left(OldLine, 1) <> ")" Then
							NewLine = NewLine + ", ";
						EndIf;
						
						If Method = "SelectChild" Then
							Child = ExtractString(OldLine);
						EndIf
					EndIf
				Else
					NewLine = NewLine + OldLine;
					OldLine = "";
				EndIf;
			EndDo
		EndIf;

		If NewLine = "" Then
			NewLine = OldLine;
		EndIf;
		
		NewLine = StrReplace(NewLine, "(" + ERPEngine, "(ERPData");
		
		NewCodeLines.Add(NewLine);
	EndDo
EndProcedure

//	CheckKeyWord проверяет наличие в строке Line ключевого слова из массива ключевых слов KeyWords.
//	Если ключевое слово найдено, то возвращает его, иначе возвращает пустую строку "".
Function CheckKeyWord(Val Line, KeyWords)
		
	For Each KeyWord In KeyWords Do
		If Find(Line, KeyWord) > 0 Then
			Return KeyWord;
		EndIf;
	EndDo;		
		
	Return "";
	
EndFunction

//	 ExtractString извлекает из строки <Line> подстроку ограниченную кавычками.
Function ExtractString(Val Line)
	FirstPos = Find(Line, """");
	If FirstPos > 0 Then
		LastPos = Find(Mid(Line, FirstPos + 1), """");
		If LastPos > 0 Then
			Return Mid(Line, FirstPos + 1, LastPos - 1);
		EndIf
	EndIf;
	Return "???";
EndFunction

Процедура ПроверитьУдаленныеСтрокиВДокументе (ERPData, Док,УИДСтроки) Экспорт
	
	Если Док = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если УИДСтроки=Неопределено Тогда
		УИДСтроки=0;
	КонецЕсли;
	
	СтрокиИзЕМЕ = ПолучитьСтрокиИзЕМЕ(ERPData);
	Если СтрокиИзЕМЕ.Количество()>0 Тогда
		Для Каждого стр из СтрокиИзЕМЕ Цикл
			ТекНом = Справочники.Номенклатура.НайтиПоКоду(СокрЛП(стр.goods_code));
			Если ТекНом.Пустая() Тогда
				Продолжить;
			КонецЕсли;
			
			ТекСтр = Док.Товары.Найти(ТекНом,"Номенклатура");
			Если ТекСтр = Неопределено Тогда
				ТекСтр = НайтиПодчинённую(ТекНом,Док);
			КонецЕсли;
		
			Если ТекСтр = Неопределено Тогда
				УИДСтроки = УИДСтроки + 1;
				
				AppendChildLine(ERPData);
				ERPData.lines.header_id = стр.header_id;
				ERPData.lines.id = стр.order_line_no;//УИДСтроки;
				ERPData.lines.error_code = стр.error_code;
				ERPData.lines.quantity		= "0";
				ERPData.lines.goods_id		= стр.goods_id;
				ERPData.lines.goods_code	= стр.goods_code;
				ERPData.lines.mu_code = стр.mu_code;
				ERPData.lines.order_line_no = стр.order_line_no;
				
			ИначеЕсли (ТекСтр <> Неопределено) И (стр.quantity="0") Тогда	
				Если  стр.order_line_no = Строка(ТекСтр.КлючСтроки) Тогда
					Продолжить;
				КонецЕсли;
				AppendChildLine(ERPData);
				ERPData.lines.header_id = стр.header_id;
				ERPData.lines.id = стр.order_line_no;//УИДСтроки;
				ERPData.lines.error_code = стр.error_code;
				ERPData.lines.quantity		= стр.quantity;
				ERPData.lines.goods_id		= стр.goods_id;
				ERPData.lines.goods_code	= стр.goods_code;
				ERPData.lines.mu_code = стр.mu_code;
				ERPData.lines.order_line_no = стр.order_line_no;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;

	
КонецПроцедуры

Функция СообщениеУжеОтправлялось (ERPData,Строка=Неопределено) 
	
	Если ЗначениеЗаполнено(Строка) Тогда
		ИмяТаб = "erp_wms_orders_lines";
		QueryText = "SELECT * FROM """ + ИмяТаб + """ WHERE ""header_id""='" + Строка.header_id + "'"+" AND ""id""='" + Строка.id +"'"+" AND ""goods_id""='" + Строка.goods_id + "'";
	Иначе
		QueryText = "SELECT * FROM """ + ERPData.HeaderTableName + """ WHERE ""id""='" + ERPData.header.id + "'";
	КонецЕсли;
	
	Recordset = New COMObject("ADODB.Recordset");
	Recordset.Open(QueryText, ERPData.Connection, 0, 1, -1);
	
	Если Recordset.EOF Тогда
		Recordset.Close();
		Возврат Ложь;
	Иначе
		Recordset.Close();
		Возврат Истина;
	КонецЕсли;
		
КонецФункции

Функция ПолучитьСтрокиИзЕМЕ(ERPData) Экспорт
	
	Строка = ERPData.ChildTables[0][0];
	
	ИмяТаб = "erp_wms_orders_lines";
	QueryText = "SELECT * FROM """ + ИмяТаб + """ WHERE ""header_id""='" + Строка.header_id + "'";
	
	ТабРезалт = New ValueTable;
	AddField(ТабРезалт, "varchar(36)", "header_id");
	AddField(ТабРезалт, "varchar(36)", "id");
	AddField(ТабРезалт, "varchar(8)", "error_code");
	AddField(ТабРезалт, "varchar(8)", "quantity");
	AddField(ТабРезалт, "varchar(36)", "goods_id");
	AddField(ТабРезалт, "varchar(11)", "goods_code");
	AddField(ТабРезалт, "varchar(8)", "mu_code");
	AddField(ТабРезалт, "varchar(8)", "order_line_no");

		
	SelectLines(ERPData.Connection, QueryText, ТабРезалт);
		
	Возврат ТабРезалт;
	
	
КонецФункции

Функция НайтиПодчинённую(ТекНом, Док)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Ст.Номенклатура
	               |ИЗ
	               |	Документ.ЗаказПокупателя.Товары КАК Ст
	               |ГДЕ
	               |	Ст.Ссылка = &ТекДок
	               |	И Ст.Номенклатура.емеСсылкаНаОсновнуюНоменклатуру = &ТекНом";
	Запрос.УстановитьПараметр("ТекДок",Док);
	Запрос.УстановитьПараметр("ТекНом",ТекНом);
	
	Рез = Запрос.Выполнить().Выгрузить();
	Если Рез.Количество()<>1 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Док.Товары.Найти(Рез[0].Номенклатура,"Номенклатура");
	
	
	
КонецФункции