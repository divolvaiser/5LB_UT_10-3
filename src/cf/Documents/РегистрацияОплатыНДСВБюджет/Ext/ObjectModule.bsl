﻿Перем мУдалятьДвижения;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьТаблицуПечатныхФорм()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ АВТОЗАПОЛНЕНИЯ СТРОК ДОКУМЕНТА

// Заполняет табличную часть НДС по договорам налогового агента
//
Процедура ЗаполнитьТабличнуюЧастьПоДоговорамНалоговогоАгента() Экспорт

	Результат = ПолучитьОстаткиНДСРасчетыСБюджетом();
	
	ОплатаПоДоговорамНалоговогоАгента.Загрузить(Результат);
	
КонецПроцедуры

// Заполняет табличную часть НДС по собственному потреблению
//
Процедура ЗаполнитьТабличнуюЧастьДляСобственногоПотребления() Экспорт
 
	Результат = ПолучитьОстаткиНДСРасчетыСБюджетом(Истина);
	
	ОплатаДляСобственногоПотребления.Загрузить(Результат);
	
КонецПроцедуры

// Функция возвращает выборку из регистра НДСРасчетыСПоставщиками по расчетам с бюджетом
//
// Параметры
//  ПоДоговорамНалоговогоАгента - если Истина, то выбираются расчеты по агентским договорам
//
Функция ПолучитьОстаткиНДСРасчетыСБюджетом(ОтбиратьПоПустомуДоговору = Ложь)

	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ОтбиратьПоПустомуДоговору", ОтбиратьПоПустомуДоговору);
	Запрос.УстановитьПараметр("ПустойДоговор", Справочники.ДоговорыКонтрагентов.ПустаяСсылка());
	Запрос.УстановитьПараметр("Дата", Новый граница(КонецДня(Дата),ВидГраницы.Включая));
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	НДСРасчетыСПоставщикамиОстатки.Поставщик,
	               |	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
	               |	НДСРасчетыСПоставщикамиОстатки.Документ как СчетФактура,
	               |	СУММА(НДСРасчетыСПоставщикамиОстатки.СуммаОстаток) КАК Сумма
	               |ИЗ
	               |	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(
	               |		&Дата,
	               |		Организация = &Организация
	               |			И РасчетыСБюджетом = ИСТИНА
	               |			И ВЫБОР
	               |				КОГДА ДоговорКонтрагента = &ПустойДоговор
	               |					ТОГДА &ОтбиратьПоПустомуДоговору
	               |				ИНАЧЕ ВЫБОР
	               |						КОГДА &ОтбиратьПоПустомуДоговору
	               |							ТОГДА ЛОЖЬ
	               |						ИНАЧЕ ИСТИНА
	               |					КОНЕЦ
	               |			КОНЕЦ) КАК НДСРасчетыСПоставщикамиОстатки
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
	               |	НДСРасчетыСПоставщикамиОстатки.Поставщик,
	               |	НДСРасчетыСПоставщикамиОстатки.Документ";
				   
	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// По результату запроса по шапке документа и табличным частям формирует движения по регистрам.
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоДоговорамНалоговогоАгента, ТаблицаДляСобственногоПотребления, Отказ, Заголовок)
	
	ДвиженияПоРегиструНДСРасчетыСПоставщиками(СтруктураШапкиДокумента, ТаблицаПоДоговорамНалоговогоАгента, Отказ, Заголовок);
	
	ДвиженияПоРегиструНДСРасчетыСПоставщиками(СтруктураШапкиДокумента, ТаблицаДляСобственногоПотребления, Отказ, Заголовок);
	
КонецПроцедуры

// Движения по регистру НДСРасчетыСПоставщиками
//
Процедура ДвиженияПоРегиструНДСРасчетыСПоставщиками(СтруктураШапкиДокумента, ТаблицаПоДоговорам, Отказ, Заголовок)
	
	Если Отказ ИЛИ (ТаблицаПоДоговорам.Количество() = 0) Тогда
		Возврат;		
	КонецЕсли;
	
	НаборЗаписей_НДСРасчетыСПоставщиками = Движения.НДСРасчетыСПоставщиками;
	
	ТаблицаДвижений_НДСРасчетыСПоставщиками = НаборЗаписей_НДСРасчетыСПоставщиками.Выгрузить();
	ТаблицаДвижений_НДСРасчетыСПоставщиками.Очистить();
	
	// Расход по сущестующим записям в регистре
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоДоговорам, ТаблицаДвижений_НДСРасчетыСПоставщиками);
	
	НаборЗаписей_НДСРасчетыСПоставщиками.мПериод = Дата;
	НаборЗаписей_НДСРасчетыСПоставщиками.мТаблицаДвижений = ТаблицаДвижений_НДСРасчетыСПоставщиками;
	НаборЗаписей_НДСРасчетыСПоставщиками.ВыполнитьРасход();
	
	// Приход распределенной суммы
	НаборЗаписей_НДСУчетРаспределенныхОплатПоставщикам = Движения.НДСУчетРаспределенныхОплатПоставщикам;
	
	ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам = НаборЗаписей_НДСУчетРаспределенныхОплатПоставщикам.Выгрузить();
	ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам.Очистить();
	
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоДоговорам, ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам);
	
	НаборЗаписей_НДСУчетРаспределенныхОплатПоставщикам.мПериод = Дата;
	НаборЗаписей_НДСУчетРаспределенныхОплатПоставщикам.мТаблицаДвижений = ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам;
	НаборЗаписей_НДСУчетРаспределенныхОплатПоставщикам.ВыполнитьПриход();
	
КонецПроцедуры

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - структура, содержащая рексвизиты шапки документа и результаты запроса по шапке,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
Функция ПодготовитьТаблицуПоДоговорамНалоговогоАгента(РезультатЗапросаПоДоговорамНалоговогоАгента, СтруктураШапкиДокумента)

	ТаблицаПоДоговорамНалоговогоАгента = РезультатЗапросаПоДоговорамНалоговогоАгента.Выгрузить();
	
	ТаблицаПоДоговорамНалоговогоАгента.Колонки.Добавить("РасчетыСБюджетом", Новый ОписаниеТипов("Булево"));
	ТаблицаПоДоговорамНалоговогоАгента.ЗаполнитьЗначения(Истина, "РасчетыСбюджетом");
	
	Возврат ТаблицаПоДоговорамНалоговогоАгента;

КонецФункции // ПодготовитьТаблицуПоДоговорамНалоговогоАгента()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
Функция ПодготовитьТаблицуДляСобственногоПотребления(РезультатЗапросаДляСобственногоПотребления, СтруктураШапкиДокумента)

	ТаблицаДляСобственногоПотребления = РезультатЗапросаДляСобственногоПотребления.Выгрузить();
	
	ТаблицаДляСобственногоПотребления.Колонки.Добавить("РасчетыСБюджетом", Новый ОписаниеТипов("Булево"));
	ТаблицаДляСобственногоПотребления.ЗаполнитьЗначения(Истина, "РасчетыСбюджетом");
	
	Возврат ТаблицаДляСобственногоПотребления;

КонецФункции // ПодготовитьТаблицуПоДоговорамНалоговогоАгента()

// Проверяет правильность заполнения строк табличной части.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиПоДоговорамНалоговогоАгента(СтруктураШапкиДокумента, ТаблицаПоДоговорамНалоговогоАгента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Поставщик, ДоговорКонтрагента, СчетФактура");
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОплатаПоДоговорамНалоговогоАгента", СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверка полей без прекращения проведения
	СтрокаСообщения = "Не заполнен документ оплаты.";

	Для каждого СтрокаТаблицы из ТаблицаПоДоговорамНалоговогоАгента Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументОплаты) Тогда
			СтрокаНачалаСообщенияОбОшибке = "В строке номер """+ СокрЛП(СтрокаТаблицы.НомерСтроки) + """ табличной части ""По договорам налогового агента"" : ";
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке+СтрокаСообщения,,Заголовок,СтатусСообщения.Внимание);
		КонецЕсли;
	КонецЦикла; 
	
КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// Проверяет правильность заполнения строк табличной части.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиДляСобственногоПотребления(СтруктураШапкиДокумента, ТаблицаДляСобственногоПотребления, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("СчетФактура");
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОплатаДляСобственногоПотребления", СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверка полей без прекращения проведения
	СтрокаСообщения = "Не заполнен документ оплаты.";

	Для каждого СтрокаТаблицы из ТаблицаДляСобственногоПотребления Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументОплаты) Тогда
			СтрокаНачалаСообщенияОбОшибке = "В строке номер """+ СокрЛП(СтрокаТаблицы.НомерСтроки) + """ табличной части ""Для собственного потребления"" : ";
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке+СтрокаСообщения,,Заголовок,СтатусСообщения.Внимание);
		КонецЕсли;
	КонецЦикла; 
	
	
КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(Отказ, Заголовок);
	
	// Подготовим данные необходимые для проведения и проверки заполнения табличных частей.
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация",			"Ссылка.Организация");
	СтруктураПолей.Вставить("Поставщик",			"Поставщик");
	СтруктураПолей.Вставить("ДоговорКонтрагента",	"ДоговорКонтрагента");
	СтруктураПолей.Вставить("СчетФактура",			"СчетФактура");
	СтруктураПолей.Вставить("Документ",				"СчетФактура");
	СтруктураПолей.Вставить("ДокументОплаты",		"ДокументОплаты");
	СтруктураПолей.Вставить("Сумма",				"Сумма");
	СтруктураПолей.Вставить("РаспределеннаяСумма",	"Сумма");
	
	РезультатЗапросаПоДоговорамНалоговогоАгента = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОплатаПоДоговорамНалоговогоАгента", СтруктураПолей);
	
	СтруктураПолей.Удалить("Поставщик");
	СтруктураПолей.Удалить("ДоговорКонтрагента");
	
	РезультатЗапросаДляСобственногоПотребления = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОплатаДляСобственногоПотребления", СтруктураПолей);

	ТаблицаПоДоговорамНалоговогоАгента = ПодготовитьТаблицуПоДоговорамНалоговогоАгента(РезультатЗапросаПоДоговорамНалоговогоАгента, СтруктураШапкиДокумента);
	ТаблицаДляСобственногоПотребления = ПодготовитьТаблицуДляСобственногоПотребления(РезультатЗапросаДляСобственногоПотребления, СтруктураШапкиДокумента);
	
	ПроверитьЗаполнениеТабличнойЧастиПоДоговорамНалоговогоАгента(СтруктураШапкиДокумента,ТаблицаПоДоговорамНалоговогоАгента, Отказ, Заголовок);
	ПроверитьЗаполнениеТабличнойЧастиДляСобственногоПотребления(СтруктураШапкиДокумента,ТаблицаДляСобственногоПотребления, Отказ, Заголовок);
	
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоДоговорамНалоговогоАгента, ТаблицаДляСобственногоПотребления, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	мУдалятьДвижения = НЕ ЭтоНовый();

КонецПроцедуры // ПередЗаписью

Процедура ОбработкаУдаленияПроведения(Отказ)

	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);

КонецПроцедуры // ОбработкаУдаленияПроведения

