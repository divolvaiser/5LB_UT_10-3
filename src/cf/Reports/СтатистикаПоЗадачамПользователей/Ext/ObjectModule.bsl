﻿#Если Клиент Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ НАЧАЛЬНОЙ НАСТРОЙКИ ОТЧЕТА

// Процедура установки начальных настроек отчета с использованием текста запроса
//
Процедура УстановитьНачальныеНастройки(ДополнительныеПараметры = Неопределено) Экспорт
	
	// Настройка общих параметров универсального отчета
	
	// Содержит название отчета, которое будет выводиться в шапке.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.мНазваниеОтчета = "Название отчета";
	УниверсальныйОтчет.мНазваниеОтчета = СокрЛП(ЭтотОбъект.Метаданные().Синоним);
	
	// Содержит признак необходимости отображения надписи и поля выбора раздела учета в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	
	// Содержит имя регистра, по метаданным которого будет выполняться заполнение настроек отчета.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.ИмяРегистра = "ТоварыНаСкладах";
	
	// Содержит признак необходимости вывода отрицательных значений показателей красным цветом.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	
	// Содержит признак необходимости вывода в отчет общих итогов.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.ВыводитьОбщиеИтоги = Ложь;
	
	// Содержит признак необходимости вывода детальных записей в отчет.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ВыводитьДетальныеЗаписи = Истина;
	
	// Содержит признак необходимости отображения флага использования свойств и категорий в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Ложь;
	УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Истина;
	
	// Содержит признак использования свойств и категорий при заполнении настроек отчета.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ИспользоватьСвойстваИКатегории = Истина;
	
	// Содержит признак использования простой формы настроек отчета без группировок колонок.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.мРежимФормыНастройкиБезГруппировокКолонок = Истина;
	
	// Дополнительные параметры, переданные из отчета, вызвавшего расшифровку.
	// Информация, передаваемая в переменной ДополнительныеПараметры, может быть использована
	// для реализации специфичных для данного отчета параметрических настроек.
	
	// Описание исходного текста запроса.
	
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Задачи.Ссылка КАК Задача,
	|	Задачи.Выполнена КАК Выполнена,
	|	ЕСТЬNULL(Задачи.ДатаИсполнения, &ПустаяДата) КАК ДатаВыполнения,
	|	ЕСТЬNULL(Задачи.СрокИсполнения, &ПустаяДата) КАК СрокИсполнения,
	|	Задачи.Наименование,
	|	Задачи.ТочкаМаршрута КАК ТочкаМаршрута,
	|	ВЫБОР
	|		КОГДА Задачи.Выполнена
	|			ТОГДА 1
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоВыполненных,
	|	ВЫБОР
	|		КОГДА (НЕ Задачи.Выполнена)
	|			ТОГДА 1
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоНеВыполненных,
	|	ВЫБОР
	|		КОГДА Задачи.Выполнена
	|			ТОГДА ВЫБОР
	|					КОГДА Задачи.СрокИсполнения < Задачи.ДатаИсполнения
	|							И (НЕ Задачи.СрокИсполнения = &ПустаяДата)
	|						ТОГДА 1
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоПросроченныхВыполненных,
	|	ВЫБОР
	|		КОГДА Задачи.Выполнена
	|			ТОГДА ВЫБОР
	|					КОГДА Задачи.СрокИсполнения >= Задачи.ДатаИсполнения
	|							ИЛИ Задачи.СрокИсполнения = &ПустаяДата
	|						ТОГДА 1
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоНеПросроченныхВыполненных,
	|	ВЫБОР
	|		КОГДА (НЕ Задачи.Выполнена)
	|			ТОГДА ВЫБОР
	|					КОГДА Задачи.СрокИсполнения >= &ТекущаяДата
	|							ИЛИ Задачи.СрокИсполнения = &ПустаяДата
	|						ТОГДА 1
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоНеПросроченныхНеВыполненных,
	|	ВЫБОР
	|		КОГДА (НЕ Задачи.Выполнена)
	|			ТОГДА ВЫБОР
	|					КОГДА Задачи.СрокИсполнения < &ТекущаяДата
	|							И (НЕ Задачи.СрокИсполнения = &ПустаяДата)
	|						ТОГДА 1
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КоличествоПросроченныхНеВыполненных,
	|	ВЫБОР
	|		КОГДА Задачи.Выполнена
	|			ТОГДА ВЫБОР
	|					КОГДА Задачи.СрокИсполнения < Задачи.ДатаИсполнения
	|							И (НЕ Задачи.СрокИсполнения = &ПустаяДата)
	|						ТОГДА РАЗНОСТЬДАТ(Задачи.СрокИсполнения, Задачи.ДатаИсполнения, ДЕНЬ)
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ ВЫБОР
	|				КОГДА Задачи.СрокИсполнения < &ТекущаяДата
	|						И (НЕ Задачи.СрокИсполнения = &ПустаяДата)
	|					ТОГДА РАЗНОСТЬДАТ(Задачи.СрокИсполнения, &ТекущаяДата, ДЕНЬ)
	|				ИНАЧЕ 0
	|			КОНЕЦ
	|	КОНЕЦ КАК ПросроченоДней,
	|	1 КАК КоличествоЗадач,
	|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Задачи.Ссылка) КАК ЗадачаПредставление,
	|	Задачи.Исполнитель КАК Исполнитель
	|{ВЫБРАТЬ
	|	Выполнена,
	|	ДатаВыполнения,
	|	СрокИсполнения,
	|	Наименование,
	|	КоличествоЗадач,
	|	Задача.* КАК Задача,
	|	КоличествоВыполненных,
	|	КоличествоНеВыполненных,
	|	КоличествоПросроченныхВыполненных,
	|	КоличествоНеПросроченныхВыполненных,
	|	КоличествоНеПросроченныхНеВыполненных,
	|	КоличествоПросроченныхНеВыполненных,
	|	КоличествоЗадач,
	|	Исполнитель.*,
	|	ПросроченоДней}
	|ИЗ
	|	Задача.ЗадачиПользователя КАК Задачи
	|ГДЕ
	|	Задачи.Дата МЕЖДУ &ДатаНачала И &ДатаКонца
	|{ГДЕ
	|	Задачи.Ссылка.*,
	|	Задачи.Выполнена,
	|	Задачи.БизнесПроцесс.*,
	|	Задачи.Исполнитель.*}
	|
	|УПОРЯДОЧИТЬ ПО
	|	Задача
	|{УПОРЯДОЧИТЬ ПО
	|	Задачи.Ссылка.*,
	|	Задачи.Дата,
	|	КоличествоВыполненных,
	|	КоличествоНеВыполненных,
	|	КоличествоПросроченныхВыполненных,
	|	КоличествоНеПросроченныхВыполненных,
	|	КоличествоНеПросроченныхНеВыполненных,
	|	КоличествоПросроченныхНеВыполненных,
	|	КоличествоЗадач,
	|	ПросроченоДней,
	|	Исполнитель.*,
	|	ТочкаМаршрута.*,
	|	СрокИсполнения,
	|	ДатаВыполнения}
	|ИТОГИ
	|	СУММА(КоличествоВыполненных),
	|	СУММА(КоличествоНеВыполненных),
	|	СУММА(КоличествоПросроченныхВыполненных),
	|	СУММА(КоличествоНеПросроченныхВыполненных),
	|	СУММА(КоличествоНеПросроченныхНеВыполненных),
	|	СУММА(КоличествоПросроченныхНеВыполненных),
	|	СУММА(КоличествоЗадач)
	|ПО
	|	ОБЩИЕ
	|{ИТОГИ ПО
	|	ТочкаМаршрута.*,
	|	Задачи.БизнесПроцесс.*,
	|	Исполнитель.*}
	|АВТОУПОРЯДОЧИВАНИЕ";
	
		
	// Инициализация текста запроса построителя отчета
	УниверсальныйОтчет.ПостроительОтчета.Текст = ТекстЗапроса;
	
	// Представления полей отчета.
	// Необходимо вызывать для каждого поля запроса.
	// УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить(<ИмяПоля>, <ПредставлениеПоля>);
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Состояние",      "Состояние");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("БизнесПроцесс",  "Бизнес-процесс");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ТочкаМаршрута",  "Точка маршрута");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ПросроченоДней", "Просрочено (дней)");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("СрокИсполнения", "Срок исполнения");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ДатаВыполнения", "Дата исполнения");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Задача",         "Задача пользователя");
    	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоЗадач"      , "Всего задач");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоВыполненных", "Всего выполнено");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоПросроченныхВыполненных", "Выполнено просрочено");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоНеПросроченныхВыполненных", "Выполнено не просрочено");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоНеВыполненных",               "Всего не выполнено");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоПросроченныхНеВыполненных",   "Не выполнено просрочено");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоНеПросроченныхНеВыполненных", "Не выполнено не просрочено");
    	
	// Добавление показателей
	// Необходимо вызывать для каждого добавляемого показателя.
	// УниверсальныйОтчет.ДобавитьПоказатель(<ИмяПоказателя>, <ПредставлениеПоказателя>, <ВключенПоУмолчанию>, <Формат>, <ИмяГруппы>, <ПредставлениеГруппы>);
	//УниверсальныйОтчет.ДобавитьПоказатель("ЗначениеТочкиЗаказа", "Ед. хранения", Истина, "ЧЦ=15; ЧДЦ=3", "ЗначениеТочкиЗаказа", "Значение" + Символы.ПС + "точки заказа");
	// Добавление предопределенных группировок строк отчета.
	// Необходимо вызывать для каждой добавляемой группировки строки.
	// УниверсальныйОтчет.ДобавитьИзмерениеСтроки(<ПутьКДанным>);
	
	// Добавление предопределенных группировок колонок отчета.
	// Необходимо вызывать для каждой добавляемой группировки колонки.
	// УниверсальныйОтчет.ДобавитьИзмерениеКолонки(<ПутьКДанным>);
	
	// Добавление предопределенных отборов отчета.
	// Необходимо вызывать для каждого добавляемого отбора.
	// УниверсальныйОтчет.ДобавитьОтбор(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьОтбор("Исполнитель");
	УниверсальныйОтчет.ДобавитьОтбор("БизнесПроцесс");
	
	//УниверсальныйОтчет.ДобавитьПоказатель("ЗначениеТочкиЗаказа", "Ед. хранения", Истина, "ЧЦ=15; ЧДЦ=3", "ЗначениеТочкиЗаказа", "Значение" + Символы.ПС + "точки заказа");
	//ДобавитьПоказатель(ИмяПоля, ПредставлениеПоля = Неопределено, ВключенПоУмолчанию = Неопределено, ФорматнаяСтрока = Неопределено, ИмяГруппы = Неопределено, ПредставлениеГруппы = Неопределено, Ширина = 0) Экспорт
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЗадач",                       "Всего задач",   Истина, " ",,);
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоВыполненных",                 "Всего",         Истина, " ", "Выполнено", "Выполнено");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоПросроченныхВыполненных",     "Просрочено",    Истина, " ", "Выполнено", "Выполнено");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоНеПросроченныхВыполненных",   "Не просрочено", Ложь, " ",   "Выполнено"  , "Выполнено");
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоНеВыполненных",               "Всего",         Истина, " ", "НеВыполнено", "Не выполнено");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоПросроченныхНеВыполненных",   "Просрочено",    Истина, " ", "НеВыполнено", "Не выполнено");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоНеПросроченныхНеВыполненных", "Не просрочено", Ложь,   " ", "НеВыполнено", "Не выполнено");
	
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("ТочкаМаршрута");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Исполнитель");
	
	//УниверсальныйОтчет.ДобавитьДополнительноеПоле("", <Размещение>, <Положение>);

	// Добавление предопределенных полей порядка отчета.
	// Необходимо вызывать для каждого добавляемого поля порядка.
	// УниверсальныйОтчет.ДобавитьПорядок(<ПутьКДанным>);
	
	// Установка связи подчиненных и родительских полей
	// УниверсальныйОтчет.УстановитьСвязьПолей(<ПутьКДанным>, <ПутьКДаннымРодитель>);
	
	// Установка связи полей и измерений
	// УниверсальныйОтчет.УстановитьСвязьПоляИИзмерения(<ИмяПоля>, <ИмяИзмерения>);

	// Установка представлений полей
	УниверсальныйОтчет.УстановитьПредставленияПолей(УниверсальныйОтчет.мСтруктураПредставлениеПолей, УниверсальныйОтчет.ПостроительОтчета);
	
	// Установка типов значений свойств в отборах отчета
	УниверсальныйОтчет.УстановитьТипыЗначенийСвойствДляОтбора();
	
	// Заполнение начальных настроек универсального отчета
	УниверсальныйОтчет.УстановитьНачальныеНастройки(Ложь);
	УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Ложь;

	УниверсальныйОтчет.ВыводитьДетальныеЗаписи = Ложь;
	УниверсальныйОтчет.ДобавитьДополнительноеПоле("Задача", ТипРазмещенияРеквизитовИзмерений.Отдельно);
	УниверсальныйОтчет.ДобавитьДополнительноеПоле("ПросроченоДней", ТипРазмещенияРеквизитовИзмерений.Отдельно);

КонецПроцедуры // УстановитьНачальныеНастройки()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМИРОВАНИЯ ОТЧЕТА 
	
// Процедура формирования отчета
//
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт
	
	// Перед формирование отчета можно установить необходимые параметры универсального отчета.
	УниверсальныйОтчет.ПостроительОтчета.Параметры.Вставить("ТекущаяДата", ТекущаяДата());
	УниверсальныйОтчет.ПостроительОтчета.Параметры.Вставить("ПустаяДата", Дата( 1 , 1 , 1));
	УниверсальныйОтчет.ПостроительОтчета.Параметры.Вставить("ПустойПользователь", Справочники.Пользователи.ПустаяСсылка());
	
	УниверсальныйОтчет.СформироватьОтчет(ТабличныйДокумент);

КонецПроцедуры // СформироватьОтчет()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Процедура обработки расшифровки
//
Процедура ОбработкаРасшифровки(Расшифровка, Объект) Экспорт
	
	// Дополнительные параметры в расшифровывающий отчет можно передать
	// посредством инициализации переменной "ДополнительныеПараметры".
	
	ДополнительныеПараметры = Неопределено;
	УниверсальныйОтчет.ОбработкаРасшифровкиУниверсальногоОтчета(Расшифровка, Объект, ДополнительныеПараметры);
	
КонецПроцедуры // ОбработкаРасшифровки()

// Формирует структуру для сохранения настроек отчета
//
Процедура СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками) Экспорт
	
	УниверсальныйОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками);
	
КонецПроцедуры // СформироватьСтруктуруДляСохраненияНастроек()

// Заполняет настройки отчета из структуры сохраненных настроек
//
Функция ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт
	
	Возврат УниверсальныйОтчет.ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ЭтотОбъект);
	
КонецФункции // ВосстановитьНастройкиИзСтруктуры()

// Содержит значение используемого режима ввода периода.
// Тип: Число.
// Возможные значения: 0 - произвольный период, 1 - на дату, 2 - неделя, 3 - декада, 4 - месяц, 5 - квартал, 6 - полугодие, 7 - год
// Значение по умолчанию: 0
// Пример:
// УниверсальныйОтчет.мРежимВводаПериода = 1;
УниверсальныйОтчет.мРежимВводаПериода = 0;

#КонецЕсли
