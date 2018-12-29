﻿#Если Клиент Тогда

////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

// Количество строк заголовка поля табличного документа
Перем мКоличествоВыведенныхСтрокЗаголовка Экспорт;

// Настройка периода
Перем НП Экспорт;

// Структура - соответствие имен полей и их представления для построителя отчетов
Перем мСтруктураСоответствияИмен Экспорт;

// Список значений, имена отборов построителя отчета, которые существуют постоянно
Перем мСписокОтбора Экспорт;

// Макет отчета
Перем мМакет;

// Структура, ключи которой - имена отборов Построителя, значения - параметры Построителя
Перем мСтруктураДляОтбораПоКатегориям Экспорт;

// Список "взведенных" показателей отчета
Перем мПоказатели;

// Данные для построения диаграммы
Перем мДеревоДиаграммы Экспорт;

// Настройки отчета
Перем мТекущаяНастройка Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Процедура передает построителю отчета запрос
//
// Параметры
//  НЕТ
//
// Возвращаемое значение
//  НЕТ
//
Процедура ЗаполнитьНачальныеНастройки() Экспорт

	// формула запроса:
	// Продажи<ИсточникИнформацииПриОбращении#(Событие<ИсточникИнформацииПриОбращении)<ПродажиСебестоимость
	// где '<' - левое соединение, '#' - полное соединение
	
	ТекстЗапроса = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ //РАЗЛИЧНЫЕ
	|	ПродажиКомпанииОбороты.Контрагент                     КАК Контрагент,
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииПриОбращении,
	|	"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиКомпанииОбороты.Номенклатура КАК Номенклатура, ПродажиКомпанииОбороты.Подразделение КАК Подразделение,","")+"
	|	ПродажиКомпанииОбороты.КоличествоСобытий              КАК КоличествоСобытий,
	|	ПродажиКомпанииОбороты.Прибыль                        КАК Прибыль,
	|	ПродажиКомпанииОбороты.Выручка                        КАК Выручка,
	|	ПродажиКомпанииОбороты.ВыручкаБезНДС                  КАК ВыручкаБезНДС,
	|	ПродажиКомпанииОбороты.КоличествоПроданныхТоваров     КАК КоличествоПроданныхТоваров,
	|	ПродажиКомпанииОбороты.КоличествоРасходныхДокументов  КАК КоличествоРасходныхДокументов
	|{ВЫБРАТЬ
	|	"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиКомпанииОбороты.Номенклатура.* КАК Номенклатура, ПродажиКомпанииОбороты.Подразделение.* КАК Подразделение,","")+"
	|	ПродажиКомпанииОбороты.Контрагент.* КАК Контрагент,
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииПриОбращении
	|	//СВОЙСТВА
	|}
	|
	|ИЗ
	|	(
	|	ВЫБРАТЬ
	|		"+?(ВыбранаГруппировкаПоНоменклатуре, "МАКСИМУМ(Номенклатура) КАК Номенклатура, МАКСИМУМ(Подразделение) КАК Подразделение,","")+"
	|		Контрагент,
	|		ИсточникИнформацииПриОбращении,
	|		МАКСИМУМ(КоличествоСобытий)             КАК КоличествоСобытий,
	|		МАКСИМУМ(Прибыль)                       КАК Прибыль,
	|		МАКСИМУМ(Выручка)                       КАК Выручка,
	|		МАКСИМУМ(ВыручкаБезНДС)                 КАК ВыручкаБезНДС,
	|		МАКСИМУМ(КоличествоПроданныхТоваров)    КАК КоличествоПроданныхТоваров,
	|		МАКСИМУМ(КоличествоРасходныхДокументов) КАК КоличествоРасходныхДокументов
	|	ИЗ
	|		(
	|		ВЫБРАТЬ
	|			"+?(ВыбранаГруппировкаПоНоменклатуре, "ПродажиОбороты.Номенклатура КАК Номенклатура, ПродажиОбороты.Подразделение КАК Подразделение,","")+"
	|			ПродажиОбороты.Контрагент                                        КАК Контрагент,
	|			ИсточникИнформацииПриОбращении.ИсточникИнформации                КАК ИсточникИнформацииПриОбращении,
	|			NULL                                                             КАК КоличествоСобытий,
	|			СУММА(ВЫБОР
	|					КОГДА &НДСВСтоимости
	|					ТОГДА ВЫБОР
	|							КОГДА ЦеныНоменклатуры.ЦенаЕдиницы ЕСТЬ NULL ИЛИ ЦеныНоменклатуры.ЦенаЕдиницы=0
	|							ТОГДА 0
	|							ИНАЧЕ (ПродажиОбороты.СтоимостьОборот - ЦеныНоменклатуры.ЦенаЕдиницы * ПродажиОбороты.КоличествоОборот)
	|							КОНЕЦ
	|					ИНАЧЕ ВЫБОР
	|							КОГДА ЦеныНоменклатуры.ЦенаЕдиницы ЕСТЬ NULL ИЛИ ЦеныНоменклатуры.ЦенаЕдиницы=0
	|							ТОГДА 0
	|							ИНАЧЕ (ПродажиОбороты.СтоимостьОборот - ПродажиОбороты.НДСОборот - ЦеныНоменклатуры.ЦенаЕдиницы * ПродажиОбороты.КоличествоОборот)
	|							КОНЕЦ
	|					КОНЕЦ)                                                   КАК Прибыль,
	|			СУММА(ПродажиОбороты.СтоимостьОборот)                            КАК Выручка,
	|			СУММА(ПродажиОбороты.СтоимостьОборот - ПродажиОбороты.НДСОборот) КАК ВыручкаБезНДС,
	|			СУММА(ПродажиОбороты.КоличествоОборот)                           КАК КоличествоПроданныхТоваров,
	|			КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ПродажиОбороты.ДокументПродажи)             КАК КоличествоРасходныхДокументов
	|		ИЗ
	|			РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, (ДоговорКонтрагента <> &ПустойДоговор)) КАК ПродажиОбороты
	|
	|		ЛЕВОЕ СОЕДИНЕНИЕ
	|			(
	|			ВЫБРАТЬ
	|				ИсточникИнформацииПриОбращении.Контрагент               КАК Контрагент,
	|				ИсточникИнформацииПриОбращении.Период                   КАК Период,
	|				ИсточникИнформацииПриОбращении.ИсточникИнформации       КАК ИсточникИнформации,
	|				МИНИМУМ(ИсточникИнформацииПриОбращении.ПериодОкончания) КАК ПериодОкончания
	|			ИЗ
	|				(
	|				ВЫБРАТЬ
	|					Источник.Контрагент         КАК Контрагент,
	|					Источник.ИсточникИнформации КАК ИсточникИнформации,
	|					Источник.Период             КАК Период,
	|					Источник2.Период            КАК ПериодОкончания
	|				ИЗ
	|				РегистрСведений.ИсточникИнформацииПриОбращении КАК Источник
	|				ЛЕВОЕ СОЕДИНЕНИЕ
	|					РегистрСведений.ИсточникИнформацииПриОбращении КАК Источник2
	|				ПО
	|					Источник.Период < Источник2.Период
	|					И Источник.Контрагент = Источник2.Контрагент
	|				)
	|				КАК ИсточникИнформацииПриОбращении
	|			СГРУППИРОВАТЬ ПО
	|				ИсточникИнформацииПриОбращении.Контрагент,
	|				ИсточникИнформацииПриОбращении.Период,
	|				ИсточникИнформацииПриОбращении.ИсточникИнформации
	|			)
	|			КАК ИсточникИнформацииПриОбращении
	|		ПО
	|			ИсточникИнформацииПриОбращении.Контрагент = ПродажиОбороты.Контрагент
	|			И ((ПродажиОбороты.Регистратор.Дата >= ИсточникИнформацииПриОбращении.Период
	|			И ПродажиОбороты.Регистратор.Дата < ИсточникИнформацииПриОбращении.ПериодОкончания)
	|			ИЛИ (ПродажиОбороты.Регистратор.Дата >= ИсточникИнформацииПриОбращении.Период
	|			И ИсточникИнформацииПриОбращении.ПериодОкончания ЕСТЬ NULL))
	|
	|		ЛЕВОЕ СОЕДИНЕНИЕ
	|			(
	|			ВЫБРАТЬ
	|				СебестоимостьКомпанииОбороты.Номенклатура               КАК Номенклатура,
	|				СебестоимостьКомпанииОбороты.ЗаказПокупателя            КАК ЗаказПокупателя,
	|				СебестоимостьКомпанииОбороты.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|				СебестоимостьКомпанииОбороты.Регистратор                КАК Регистратор,
	|				ВЫБОР
	|					КОГДА СебестоимостьКомпанииОбороты.КоличествоОборот = 0
	|					ТОГДА 0
	|					ИНАЧЕ (СебестоимостьКомпанииОбороты.СтоимостьОборот / СебестоимостьКомпанииОбороты.КоличествоОборот)
	|					КОНЕЦ                                               КАК ЦенаЕдиницы
	|			ИЗ
	|				РегистрНакопления.ПродажиСебестоимость.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор) КАК СебестоимостьКомпанииОбороты
	|			)
	|			КАК ЦеныНоменклатуры
	|		ПО
	|			ЦеныНоменклатуры.Номенклатура = ПродажиОбороты.Номенклатура
	|			И ЦеныНоменклатуры.ХарактеристикаНоменклатуры = ПродажиОбороты.ХарактеристикаНоменклатуры
	|			И ЦеныНоменклатуры.Регистратор = ПродажиОбороты.Регистратор
	|
	|		СГРУППИРОВАТЬ ПО
	|			"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиОбороты.Номенклатура, ПродажиОбороты.Подразделение,","")+"
	|			ПродажиОбороты.Контрагент,
	|			ИсточникИнформацииПриОбращении.ИсточникИнформации
	|
	|		ОБЪЕДИНИТЬ ВСЕ
	//		Количество событий в разрезе Контрагентов и Источников информации
	|		
	|		ВЫБРАТЬ
	|			"+?(ВыбранаГруппировкаПоНоменклатуре, "NULL, NULL,","")+"
	|			Контрагент,
	|			ИсточникИнформации,
	|			СУММА(КоличествоСобытий) КАК КоличествоСобытий,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL
	|		ИЗ
	|			(
	|			ВЫБРАТЬ
	|				События.Контрагент                КАК Контрагент,
	|				ВЫБОР
	|					КОГДА ИсточникИнформации2.ИсточникИнформации <> &ПустойИсточник
	|					ТОГДА ИсточникИнформации2.ИсточникИнформации
	|					ИНАЧЕ События.СсылкаСобытие.ИсточникИнформацииПриОбращении
	|					КОНЕЦ                         КАК ИсточникИнформации,
	|				КОЛИЧЕСТВО(События.СсылкаСобытие) КАК КоличествоСобытий
	|			ИЗ
	|				(
	|				ВЫБРАТЬ
	|					Событие.Ссылка                           КАК СсылкаСобытие,
	|					Событие.Контрагент                       КАК Контрагент,
	|					МАКСИМУМ(ИсточникИнформацииВнутр.Период) КАК МаксимумПериод
	|				ИЗ
	|					Документ.Событие КАК Событие
	|				ЛЕВОЕ СОЕДИНЕНИЕ
	|					РегистрСведений.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииВнутр
	|				ПО
	|					ИсточникИнформацииВнутр.Период <= Событие.Дата И ИсточникИнформацииВнутр.Контрагент = Событие.Контрагент 
	|				ГДЕ
	//					Обрабатываем только проведенные события с контрагентами
	|					Событие.Проведен = Истина
	|					И Событие.ВидОбъекта = &ВидОбъектаСобытияКонтрагент
	|					И Событие.ТипСобытия = &ТипСобытия
	//					В отчете отображаем только покупателей или новых, не зарегистрированных контрагентов
	|					И (Событие.Контрагент.Покупатель = Истина ИЛИ НЕ Событие.Контрагент ССЫЛКА Справочник.Контрагенты)
	|					И ((&ДатаОкончания = &ПустаяДата И &ДатаНачала = &ПустаяДата)
	|					ИЛИ ((&ДатаОкончания = &ПустаяДата И &ДатаНачала <> &ПустаяДата) И Событие.Дата >= &ДатаНачала)
	|					ИЛИ ((&ДатаОкончания <> &ПустаяДата И &ДатаНачала = &ПустаяДата) И Событие.Дата <= &ДатаОкончания)
	|					ИЛИ ((&ДатаОкончания <> &ПустаяДата И &ДатаНачала <> &ПустаяДата) И (Событие.Дата <= &ДатаОкончания И Событие.Дата >= &ДатаНачала)))
	|				СГРУППИРОВАТЬ ПО
	|					Событие.Ссылка,
	|					Событие.Контрагент
	|				)
	|				КАК События
	|				
	|			ЛЕВОЕ СОЕДИНЕНИЕ
	|				РегистрСведений.ИсточникИнформацииПриОбращении КАК ИсточникИнформации2
	|			ПО
	|				События.МаксимумПериод = ИсточникИнформации2.Период И События.Контрагент = ИсточникИнформации2.Контрагент
	|			СГРУППИРОВАТЬ ПО
	|				События.Контрагент,
	|				ИсточникИнформации2.ИсточникИнформации,
	|				События.СсылкаСобытие.ИсточникИнформацииПриОбращении
	|			)
	|			КАК ПромежуточныйСчетчик
	|		СГРУППИРОВАТЬ ПО
	|			Контрагент,
	|			ИсточникИнформации
	|		)
	|		КАК СобытияИсточники
	|	СГРУППИРОВАТЬ ПО
	|		Контрагент,
	|		ИсточникИнформацииПриОбращении
	|
	|	)
	|	КАК ПродажиКомпанииОбороты
	|
	|//СОЕДИНЕНИЯ
	|
	|ГДЕ
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении <> &ПустойИсточник
	|	ИЛИ ПродажиКомпанииОбороты.КоличествоРасходныхДокументов = 0
	|{ГДЕ
	|	"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиКомпанииОбороты.Номенклатура.* КАК Номенклатура, ПродажиКомпанииОбороты.Подразделение.* КАК Подразделение,","")+"
	|	ПродажиКомпанииОбороты.Контрагент.* КАК Контрагент,
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииПриОбращении
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|
	|УПОРЯДОЧИТЬ ПО
	|	Выручка УБЫВ
	|
	|{УПОРЯДОЧИТЬ ПО	
	|	"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиКомпанииОбороты.Номенклатура.*	КАК Номенклатура, ПродажиКомпанииОбороты.Подразделение.* КАК Подразделение,","")+"
	|	ПродажиКомпанииОбороты.Контрагент.* КАК Контрагент,
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииПриОбращении
	|	//СВОЙСТВА
	|}
	|
	|ИТОГИ
	|	СУММА(КоличествоСобытий)
	|ПО
	|	ОБЩИЕ ИсточникИнформацииПриОбращении
	|
	|{
	|ИТОГИ ПО
	|	"+?(ВыбранаГруппировкаПоНоменклатуре,"ПродажиКомпанииОбороты.Номенклатура.*	КАК Номенклатура, ПродажиКомпанииОбороты.Подразделение.* КАК Подразделение,","")+"	
	|	ПродажиКомпанииОбороты.Контрагент.* КАК Контрагент,
	|	ПродажиКомпанииОбороты.ИсточникИнформацииПриОбращении КАК ИсточникИнформацииПриОбращении
	|	//СВОЙСТВА
	|}
	|";
	
	мСтруктураСоответствияИмен.Очистить();
	мСтруктураСоответствияИмен = Новый Структура("Контрагент, КонтактноеЛицо, ИсточникИнформацииПриОбращении, ДокументПродажи", "Контрагент", "Контактное лицо события", "Источник информации при обращении покупателя", "Документ продажи");
	
	мСоответствиеНазначений = Новый Соответствие;

	Если ИспользоватьСвойстваИКатегории Тогда
		
		ТаблицаПолей = Новый ТаблицаЗначений;
		ТаблицаПолей.Колонки.Добавить("ПутьКДанным");  // описание поля запроса поля, для которого добавляются свойства и категории. Используется в условии соединения с регистром сведений, хранящим значения свойств или категорий
		ТаблицаПолей.Колонки.Добавить("Представление");// представление поля, для которого добавляются свойства и категории. 
		ТаблицаПолей.Колонки.Добавить("Назначение");   // назначение свойств/категорий объектов для данного поля
		ТаблицаПолей.Колонки.Добавить("ТипЗначения");  // тип значения поля, для которого добавляются свойства и категории. Используется, если не установлено назначение
		ТаблицаПолей.Колонки.Добавить("НетКатегорий"); // признак НЕиспользования категорий для объекта

		НоваяСтрока = ТаблицаПолей.Добавить();
		НоваяСтрока.ПутьКДанным = "ПродажиКомпанииОбороты.Контрагент";
		НоваяСтрока.Представление = "Контрагент";
		НоваяСтрока.Назначение = ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_Контрагенты;
		
		ТекстПоляКатегорий = "";
		ТекстПоляСвойств = "";

		// Добавим строки запроса, необходимые для использования свойств и категорий
		УправлениеОтчетами.ДобавитьВТекстСвойстваИКатегории(ТаблицаПолей, ТекстЗапроса, мСтруктураСоответствияИмен, мСоответствиеНазначений, ПостроительОтчета.Параметры, , ТекстПоляКатегорий, ТекстПоляСвойств, , , , , , мСтруктураДляОтбораПоКатегориям);

	КонецЕсли;
	
	ПостроительОтчета.Текст = ТекстЗапроса;
	
	Если ИспользоватьСвойстваИКатегории Тогда
		УправлениеОтчетами.УстановитьТипыЗначенийСвойствИКатегорийДляОтбора(ПостроительОтчета, ТекстПоляКатегорий, ТекстПоляСвойств, мСоответствиеНазначений, мСтруктураСоответствияИмен);
	КонецЕсли;
	
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(мСтруктураСоответствияИмен, ПостроительОтчета);
	
	Для каждого ЭлементСписка Из мСписокОтбора Цикл
		Если ПостроительОтчета.Отбор.Найти(ЭлементСписка.Значение) = Неопределено Тогда
			ПостроительОтчета.Отбор.Добавить(ЭлементСписка.Значение);
		КонецЕсли; 
	КонецЦикла;
	
	ПостроительОтчета.ИзмеренияСтроки.Добавить("ИсточникИнформацииПриОбращении");
	ПостроительОтчета.ИзмеренияСтроки.Добавить("Контрагент");
	
КонецПроцедуры

// Функция формирует строку представления периода отчета
//
// Параметры
//  НЕТ
//
// Возвращаемое значение:
//   Строка
//
Функция СформироватьСтрокуПериода() Экспорт

	ОписаниеПериода = "";
	
	// Вывод заголовка, описателя периода и фильтров и заголовка
	Если ДатаНачала = '00010101000000' И ДатаОкончания = '00010101000000' Тогда

		ОписаниеПериода     = "Период не установлен";

	Иначе

		Если ДатаНачала = '00010101000000' ИЛИ ДатаОкончания = '00010101000000' Тогда

			ОписаниеПериода = "Период: " + Формат(ДатаНачала, "ДФ = ""дд.ММ.гггг""; ДП = ""...""") 
							+ " - "      + Формат(ДатаОкончания, "ДФ = ""дд.ММ.гггг""; ДП = ""...""");

		Иначе

			Если ДатаНачала <= ДатаОкончания Тогда
				ОписаниеПериода = "Период: " + ПредставлениеПериода(НачалоДня(ДатаНачала), КонецДня(ДатаОкончания), "ФП = Истина");
			Иначе
				ОписаниеПериода = "Неправильно задан период!"
			КонецЕсли;

		КонецЕсли;

	КонецЕсли;

	Возврат ОписаниеПериода;
	
КонецФункции // ()

// Процедура меняет видимость заголовка поля табличного документа
// 
// Параметры
//  Таб - табличный документ
//
// Возвращаемые значения
//  НЕТ
Процедура ИзменитьВидимостьЗаголовка(Таб) Экспорт

	ОбластьВидимости = Таб.Область(1,,мКоличествоВыведенныхСтрокЗаголовка,);
	ОбластьВидимости.Видимость = ПоказыватьЗаголовок;

КонецПроцедуры

// Процедура восстановления сохраненных настроек отчета
//
Процедура ВосстановитьНастройки(ЭлементыФормы) Экспорт
	
	Перем СохраненнаяНастройка;
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Пользователь", глЗначениеПеременной("глТекущийПользователь"));
	СтруктураНастройки.Вставить("ИмяОбъекта", Строка(ЭтотОбъект));
	СтруктураНастройки.Вставить("НаименованиеНастройки", ?(мТекущаяНастройка = Неопределено, Неопределено, мТекущаяНастройка.НаименованиеНастройки));
	
	Результат = УниверсальныеМеханизмы.ВосстановлениеНастроек(СтруктураНастройки);
	
	Если Результат <> Неопределено Тогда
		
		мТекущаяНастройка = Результат;
		ВосстановитьНастройкиИзСтруктуры(Результат.СохраненнаяНастройка);
		
	Иначе
		
		мТекущаяНастройка = СтруктураНастройки;
		
	КонецЕсли;

КонецПроцедуры // ВосстановитьНастройки()

// Процедура сохранения настроек отчета
//
Процедура СохранитьНастройки(ЭлементыФормы) Экспорт
	
	Перем СохраненнаяНастройка;
	
	СформироватьСтруктуруДляСохраненияНастроек(СохраненнаяНастройка);
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Пользователь", глЗначениеПеременной("глТекущийПользователь"));
	СтруктураНастройки.Вставить("ИмяОбъекта", Строка(ЭтотОбъект));
	СтруктураНастройки.Вставить("НаименованиеНастройки", ?(мТекущаяНастройка = Неопределено, Неопределено, мТекущаяНастройка.НаименованиеНастройки));
	СтруктураНастройки.Вставить("СохраненнаяНастройка", СохраненнаяНастройка);
	СтруктураНастройки.Вставить("ИспользоватьПриОткрытии", Ложь);
	СтруктураНастройки.Вставить("СохранятьАвтоматически", Ложь);
	
	Результат = УниверсальныеМеханизмы.СохранениеНастроек(СтруктураНастройки);
	
	Если Результат <> Неопределено Тогда
		мТекущаяНастройка = Результат;
	Иначе
		мТекущаяНастройка = СтруктураНастройки;
	КонецЕсли;
	
КонецПроцедуры // СохранитьНастройки()

// Процедура восстановления значений реквизитов отчета
//
Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт
	
	Перем ТаблицаПоказателейОтчета;
	
	Если ТипЗнч(СтруктураСНастройками) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("ПоказателиОтчета", ТаблицаПоказателейОтчета);
	
	Если ТипЗнч(ТаблицаПоказателейОтчета) = Тип("ТаблицаЗначений") Тогда
		ПоказателиОтчета.Загрузить(ТаблицаПоказателейОтчета);
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("ДатаНачала"                      , ДатаНачала);
	СтруктураСНастройками.Свойство("ДатаОкончания"                   , ДатаОкончания);
	СтруктураСНастройками.Свойство("ПоказыватьЗаголовок"             , ПоказыватьЗаголовок);
	СтруктураСНастройками.Свойство("РаскрашиватьГруппировки"         , РаскрашиватьГруппировки);
	СтруктураСНастройками.Свойство("НастройкиДиаграммы"              , НастройкиДиаграммы);
	СтруктураСНастройками.Свойство("ИспользоватьСвойстваИКатегории"  , ИспользоватьСвойстваИКатегории);
	СтруктураСНастройками.Свойство("ВыбранаГруппировкаПоНоменклатуре", ВыбранаГруппировкаПоНоменклатуре);
	
	ПостроительОтчета.УстановитьНастройки(СтруктураСНастройками.НастройкиПостроителя);
	
КонецПроцедуры // ВосстановитьНастройкиИзСтруктуры()

// Процедура сохранения значений реквизитов отчета
//
Процедура СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками) Экспорт
	
	Если ТипЗнч(СтруктураСНастройками) <> Тип("Структура") Тогда
		СтруктураСНастройками = Новый Структура;
	КонецЕсли;
	
	СтруктураСНастройками.Вставить("НастройкиПостроителя"            , ПостроительОтчета.ПолучитьНастройки());
	СтруктураСНастройками.Вставить("ДатаНачала"                      , ДатаНачала);
	СтруктураСНастройками.Вставить("ДатаОкончания"                   , ДатаОкончания);
	СтруктураСНастройками.Вставить("ПоказыватьЗаголовок"             , ПоказыватьЗаголовок);
	СтруктураСНастройками.Вставить("РаскрашиватьГруппировки"         , РаскрашиватьГруппировки);
	СтруктураСНастройками.Вставить("НастройкиДиаграммы"              , НастройкиДиаграммы);
	СтруктураСНастройками.Вставить("ИспользоватьСвойстваИКатегории"  , ИспользоватьСвойстваИКатегории);
	СтруктураСНастройками.Вставить("ВыбранаГруппировкаПоНоменклатуре", ВыбранаГруппировкаПоНоменклатуре);
	СтруктураСНастройками.Вставить("ПоказателиОтчета"                , ПоказателиОтчета.Выгрузить());
	
КонецПроцедуры // СформироватьСтруктуруДляСохраненияНастроек()

////////////////////////////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ПЕЧАТНОЙ ФОРМЫ ОТЧЕТА

// Процедура заполняет ПолеТабличногоДокумента
//
// Параметры - Таб - ПолеТабличногоДокумента
Процедура СформироватьОтчет(Таб) Экспорт
	
	// Показатели
	мПоказатели.Очистить();
	Для каждого Строки Из ПоказателиОтчета Цикл
		Если Строки.ИспользованиеПоказателя Тогда
			мПоказатели.Добавить(Строки.ИмяПоказателя, Строки.ПредставлениеПоказателя);
		КонецЕсли; 
	КонецЦикла;
	
	ПостроительОтчета.Параметры.Вставить("ПустаяДата"                 , '00010101000000');
	ПостроительОтчета.Параметры.Вставить("ДатаНачала"                 , НачалоДня(ДатаНачала));
	ПостроительОтчета.Параметры.Вставить("ДатаОкончания"              , ?(ДатаОкончания = '00010101000000', ДатаОкончания, КонецДня(ДатаОкончания)));
	ПостроительОтчета.Параметры.Вставить("ПустойКонтрагент"           , Справочники.Контрагенты.ПустаяСсылка());
	ПостроительОтчета.Параметры.Вставить("ПустойИсточник"             , Справочники.ИсточникиИнформацииПриОбращенииПокупателей.ПустаяСсылка());
	ПостроительОтчета.Параметры.Вставить("ПустойДоговор"              , Справочники.ДоговорыКонтрагентов.ПустаяСсылка());
	ПостроительОтчета.Параметры.Вставить("ВидОбъектаСобытияКонтрагент", Перечисления.ВидыОбъектовСобытия.Контрагент);
	ПостроительОтчета.Параметры.Вставить("ТипСобытия"				  , Перечисления.ВходящееИсходящееСобытие.Входящее);

	Отказ = Ложь;
	УчетнаяПолитика = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(Не ЗначениеЗаполнено(ДатаОкончания), ТекущаяДата(), ДатаОкончания), Отказ);
	Если Отказ Тогда
		НеВключатьНДСВСтоимостьПартий = Ложь;
	Иначе
		НеВключатьНДСВСтоимостьПартий = УчетнаяПолитика.НеВключатьНДСВСтоимостьПартий;
	КонецЕсли;
	ПостроительОтчета.Параметры.Вставить("НДСВСтоимости", НЕ НеВключатьНДСВСтоимостьПартий);
	
	Если НЕ УправлениеОтчетами.ЗадатьПараметрыОтбораПоКатегориям(ПостроительОтчета, мСтруктураДляОтбораПоКатегориям) Тогда
		Предупреждение("По одной категории нельзя устанавливать несколько отборов");
		Возврат;
	КонецЕсли;
	
	мКоличествоВыведенныхСтрокЗаголовка = 0;
	
	ПостроительОтчета.Выполнить();

	Таб.Очистить();

	Секция = мМакет.ПолучитьОбласть("ШапкаВерх|ОсновнаяКолонка");
	Таб.Вывести(Секция);
	Таб.Область(1, 2, 3, (?(мПоказатели.Количество()>2, 2, мПоказатели.Количество())*2 + 2)).ПоВыделеннымКолонкам = Истина;

	Секция = мМакет.ПолучитьОбласть("ШапкаИнтервал|ОсновнаяКолонка");
	Секция.Параметры.СтрокаИнтервал = СформироватьСтрокуПериода();
	Таб.Вывести(Секция);
	Таб.Область(4, 2, 4, (мПоказатели.Количество()*2 + 2)).ПоВыделеннымКолонкам = Истина;
	мКоличествоВыведенныхСтрокЗаголовка = 4;
	
	СтрокаГруппировок = УправлениеОтчетами.СформироватьСтрокуИзмерений(ПостроительОтчета.ИзмеренияСтроки);
	Если НЕ ПустаяСтрока(СтрокаГруппировок) Тогда
		СтрокаГруппировок = "Группировки строк: " + СтрокаГруппировок;
		Секция = мМакет.ПолучитьОбласть("ШапкаГруппировки|ОсновнаяКолонка");
		Секция.Параметры.СтрокаГруппировок = СтрокаГруппировок;
		Таб.Вывести(Секция);
		Таб.Область((мКоличествоВыведенныхСтрокЗаголовка + 1), 2, (мКоличествоВыведенныхСтрокЗаголовка + 1), (мПоказатели.Количество()*2 + 2)).ПоВыделеннымКолонкам = Истина;
		мКоличествоВыведенныхСтрокЗаголовка = мКоличествоВыведенныхСтрокЗаголовка + 1;
	КонецЕсли; 

	СтрокаОтборов = УправлениеОтчетами.СформироватьСтрокуОтборов(ПостроительОтчета.Отбор);
	Если НЕ ПустаяСтрока(СтрокаОтборов) Тогда
		СтрокаОтборов = "Отбор: " + СтрокаОтборов;
		Секция = мМакет.ПолучитьОбласть("ШапкаОтбор|ОсновнаяКолонка");
		Секция.Параметры.СтрокаОтборов = СтрокаОтборов;
		Таб.Вывести(Секция);
		Таб.Область((мКоличествоВыведенныхСтрокЗаголовка + 1), 2, (мКоличествоВыведенныхСтрокЗаголовка + 1), (мПоказатели.Количество()*2 + 2)).ПоВыделеннымКолонкам = Истина;
		мКоличествоВыведенныхСтрокЗаголовка = мКоличествоВыведенныхСтрокЗаголовка + 1;
	КонецЕсли; 
	
	СтрокаПорядка = УправлениеОтчетами.СформироватьСтрокуПорядка(ПостроительОтчета.Порядок);
	Если НЕ ПустаяСтрока(СтрокаПорядка) Тогда
		СтрокаПорядка = "Сортировка: " + СтрокаПорядка;
		Секция = мМакет.ПолучитьОбласть("ШапкаПорядок|ОсновнаяКолонка");
		Секция.Параметры.СтрокаПорядка = СтрокаПорядка;
		Таб.Вывести(Секция);
		Таб.Область((мКоличествоВыведенныхСтрокЗаголовка + 1), 2, (мКоличествоВыведенныхСтрокЗаголовка + 1), (мПоказатели.Количество()*2 + 2)).ПоВыделеннымКолонкам = Истина;
		мКоличествоВыведенныхСтрокЗаголовка = мКоличествоВыведенныхСтрокЗаголовка + 1;
	КонецЕсли;
	
	Секция = мМакет.ПолучитьОбласть("ШапкаТаблицы|ОсновнаяКолонка");
	Таб.Вывести(Секция);
	
	ДеревоДиаграммы = Новый ДеревоЗначений;
	ДеревоДиаграммы.Колонки.Добавить("Группировка");
	ДеревоДиаграммы.Колонки.Добавить("ИмяГруппировки");
	
	СтруктураПоказателей = Новый Структура;
	
	Для каждого Строки Из мПоказатели Цикл
		
		ДеревоДиаграммы.Колонки.Добавить(Строки.Значение);
		
		Секция = мМакет.ПолучитьОбласть("ШапкаТаблицы|КолонкаПоказателя");
		Секция.Параметры.НаименованиеПоказателя = Строки.Представление;
		Таб.Присоединить(Секция);
		
		СуммаПоказателя = 0;

		ВыборкаДокументов = ПостроительОтчета.Результат.Выбрать();
		Если Строки.Значение = "КоличествоСобытий" Тогда
			Если ВыборкаДокументов.Следующий() Тогда
				СуммаПоказателя = СуммаПоказателя + ?(ВыборкаДокументов[Строки.Значение] = NULL, 0, ВыборкаДокументов[Строки.Значение]);
			КонецЕсли;
		Иначе
			Пока ВыборкаДокументов.Следующий() Цикл
				Если ВыборкаДокументов.ТипЗаписи() = ТипЗаписиЗапроса.ДетальнаяЗапись Тогда
					СуммаПоказателя = СуммаПоказателя + ?(ВыборкаДокументов[Строки.Значение] = NULL, 0, ВыборкаДокументов[Строки.Значение]);
				КонецЕсли; 
			КонецЦикла; 
		КонецЕсли; 
		
		СтруктураПоказателей.Вставить(Строки.Значение, СуммаПоказателя);

	КонецЦикла; 
	
	Таб.НачатьАвтогруппировкуСтрок();
	
	РезультатЗапроса = ПостроительОтчета.Результат;
	
	ВывестиСтроки(Таб, мМакет, РезультатЗапроса, 0, СтруктураПоказателей, ДеревоДиаграммы.Строки);

	мДеревоДиаграммы = ДеревоДиаграммы;

	Таб.ЗакончитьАвтогруппировкуСтрок();
	
	ИзменитьВидимостьЗаголовка(Таб);
	
	Таб.Показать();
	
КонецПроцедуры

// Процедура выводит строки в ПолеТабличногоДокумента
// 
// Параметры
//  Таб - ПолеТабличногоДокумента
//  Макет - макет отчета
//  ТекущаяВыборка - выборка запроса, из которой выводить строки
//  МассивГруппировок - массив с именами группировок
//  ИндексТекущейГруппировки - число, индекс выводимой группировки
// 
// Возвращаемое значение
//  НЕТ
Процедура ВывестиСтроки(Таб, Макет, ТекущаяВыборка, ИндексТекущейГруппировки, ПоказателиПрошлойГруппировки, СтрокиДереваДиаграммы)

	Если ИндексТекущейГруппировки > ПостроительОтчета.ИзмеренияСтроки.Количество()-1 Тогда
		Возврат;
	КонецЕсли;
	
	НаименованиеГруппировки = ПостроительОтчета.ИзмеренияСтроки[ИндексТекущейГруппировки].Имя;

	// Если добавить в группировки строк одинаковые значения, то в именах групировок
	// добавляется цифра 1,2,3..., а поля таблицы запроса естественно не добавляются с такими именами
	// поэтому из имени группировки удилим последние цифры в имени
	
	а = СтрДлина(НаименованиеГруппировки);
	Пока а > 0 Цикл
		Если КодСимвола(Сред(НаименованиеГруппировки, а, 1)) >= 49 И КодСимвола(Сред(НаименованиеГруппировки, а, 1)) <= 57 Тогда
			а = а - 1;
			Продолжить;
		КонецЕсли;
		Прервать;
	КонецЦикла;
	
	НаименованиеГруппировки = Лев(НаименованиеГруппировки, а);
	
	СтруктураПоказателей = Новый Структура;
	
	Выборка = ТекущаяВыборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, НаименованиеГруппировки);
	
	Пока Выборка.Следующий() Цикл

		Если Выборка.ТипЗаписи() = ТипЗаписиЗапроса.ОбщийИтог Тогда
			Продолжить;
		КонецЕсли; 

		ТекущийЦвет = Новый Цвет;
		Если РаскрашиватьГруппировки Тогда
			Если ИндексТекущейГруппировки <> ПостроительОтчета.ИзмеренияСтроки.Количество()-1 Тогда
				ИндексЦвета = ИндексТекущейГруппировки;
				Если ИндексЦвета >= 10 Тогда
					ИндексЦвета = (ИндексТекущейГруппировки/10 - Цел(ИндексТекущейГруппировки/10))*10;
				КонецЕсли; 
				ТекущийЦвет = Макет.Области["Цвет"+СокрЛП(ИндексЦвета)].ЦветФона;
			Иначе
				ТекущийЦвет = Новый Цвет;
			КонецЕсли; 
		КонецЕсли;
			
		СтрокаВывода = СокрЛП(Выборка[НаименованиеГруппировки]);
		Если ПустаяСтрока(СтрокаВывода) Тогда
			СтрокаВывода = "<...>";
		КонецЕсли;

		Секция = Макет.ПолучитьОбласть("СтрокаГруппировки|ОсновнаяКолонка");
		Секция.Параметры.ЗначениеГруппировки = СтрокаВывода;
		Секция.Области.ЗначениеГруппировки.Отступ = ИндексТекущейГруппировки;
		Секция.Области.ЗначениеГруппировки.Расшифровка = Выборка[НаименованиеГруппировки];
		Если НаименованиеГруппировки = "Контрагент" И ТипЗнч(Выборка[НаименованиеГруппировки]) = Тип("Строка") Тогда
			Секция.Области.ЗначениеГруппировки.ЦветТекста = ЦветаСтиля.ТекстИнформационнойНадписи;
		КонецЕсли; 
		Если РаскрашиватьГруппировки Тогда
			Секция.Области.ЗначениеГруппировки.ЦветФона = ТекущийЦвет;
		КонецЕсли;
		Таб.Вывести(Секция, ИндексТекущейГруппировки);
		
		СтрокаДереваДиаграммы = СтрокиДереваДиаграммы.Добавить();
		СтрокаДереваДиаграммы.Группировка    = Выборка[НаименованиеГруппировки];
		СтрокаДереваДиаграммы.ИмяГруппировки = НаименованиеГруппировки;

		Для каждого Строки Из мПоказатели Цикл

			СуммаПоказателя = 0;
			
			Если Строки.Значение = "КоличествоСобытий"  Тогда
				СуммаПоказателя = СуммаПоказателя + ?(Выборка[Строки.Значение] = NULL, 0, Выборка[Строки.Значение]);
			Иначе
				ВыборкаДокументов = Выборка.Выбрать();
				Пока ВыборкаДокументов.Следующий() Цикл
					Если ВыборкаДокументов.ТипЗаписи() = ТипЗаписиЗапроса.ДетальнаяЗапись Тогда
						СуммаПоказателя = СуммаПоказателя + ?(ВыборкаДокументов[Строки.Значение] = NULL, 0, ВыборкаДокументов[Строки.Значение]);
					КонецЕсли; 
				КонецЦикла; 
			КонецЕсли;
			
			СтруктураПоказателей.Вставить(Строки.Значение, СуммаПоказателя);
			
			ДействительнаяСуммаПоказателяПрошлойГруппировки = 0;
			ПоказателиПрошлойГруппировки.Свойство(Строки.Значение, ДействительнаяСуммаПоказателяПрошлойГруппировки);
			
			ПроцентПоказателя = "" + (?(ДействительнаяСуммаПоказателяПрошлойГруппировки = 0, 0, (Окр((СуммаПоказателя/ДействительнаяСуммаПоказателяПрошлойГруппировки*100),2))));
			
			Секция = Макет.ПолучитьОбласть("СтрокаГруппировки|КолонкаПоказателя");
			Секция.Параметры.СуммаПоказателя = Формат(СуммаПоказателя, "ЧЦ=20; ЧДЦ=2; ЧРД=,");
			Секция.Параметры.ПроцентПоказателя = Формат(ПроцентПоказателя, "ЧЦ=5; ЧДЦ=2; ЧРД=,") + " %";
			Если РаскрашиватьГруппировки Тогда
				Секция.Области.ЗначенияПоказателя.ЦветФона = ТекущийЦвет;
			КонецЕсли;
			Если НаименованиеГруппировки = "Контрагент" Тогда
				СтруктураРасшифровки = Новый Структура("Контрагент", Выборка[НаименованиеГруппировки]);
				Секция.Области.ЗначенияПоказателя.Расшифровка = СтруктураРасшифровки;
			КонецЕсли; 
			Таб.Присоединить(Секция, ИндексТекущейГруппировки);
			
			СтрокаДереваДиаграммы[Строки.Значение] = СуммаПоказателя;
			
		КонецЦикла;
		
		ВывестиСтроки(Таб, Макет, Выборка, ИндексТекущейГруппировки+1, СтруктураПоказателей, СтрокаДереваДиаграммы.Строки);
		
	КонецЦикла; 
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

мВалютаУпрУчета = глЗначениеПеременной("ВалютаУправленческогоУчета");

СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "Выручка";
СтрокаПоказателя.ПредставлениеПоказателя  = "Сумма выручки в " + СокрЛП(мВалютаУпрУчета.Наименование);
СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "ВыручкаБезНДС";
СтрокаПоказателя.ПредставлениеПоказателя  = "Сумма выручки без НДС в " + СокрЛП(мВалютаУпрУчета.Наименование);
СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "Прибыль";
СтрокаПоказателя.ПредставлениеПоказателя = "Сумма прибыли в " + СокрЛП(мВалютаУпрУчета.Наименование);
СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "КоличествоРасходныхДокументов";
СтрокаПоказателя.ПредставлениеПоказателя = "Количество продаж";
СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "КоличествоПроданныхТоваров";
СтрокаПоказателя.ПредставлениеПоказателя = "Количество проданных товаров";
СтрокаПоказателя = ПоказателиОтчета.Добавить();
СтрокаПоказателя.ИмяПоказателя = "КоличествоСобытий";
СтрокаПоказателя.ПредставлениеПоказателя = "Количество событий";

мМакет = ПолучитьМакет("Макет");

мКоличествоВыведенныхСтрокЗаголовка = 0;

// Установим имена быстрых отборов
мСписокОтбора = Новый СписокЗначений;
мСписокОтбора.Добавить("Контрагент");
мСписокОтбора.Добавить("ИсточникИнформацииПриОбращении");

НП = Новый НастройкаПериода;

мСтруктураСоответствияИмен = Новый Структура;

мПоказатели = Новый СписокЗначений;

ВыбранаГруппировкаПоНоменклатуре = Ложь;
#КонецЕсли
