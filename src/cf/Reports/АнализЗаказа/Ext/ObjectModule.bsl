﻿// Формирует текст запроса по номенклатуре анализируемого заказа, 
// устанавливает параметры и выполняет запрос
//
// Параметры: 
//  Заказ - объект заказа,
//  ДатаАнализа - дата анализа.
//
// Возвращаемое значение:
//  результат запроса.
//                    
Функция ПолучитьРезультатЗапросаПоНоменклатуре(Заказ, ДатаАнализа) Экспорт 	
	
	ТипЗаказа = ПолучитьТипЗаказа(Заказ);
	
	// Формируем текст запроса по номенклатуре анализируемого заказа.

	Запрос = Новый Запрос;
	Если ТипЗаказа = "Покупателя" Тогда
		Запрос.Текст=
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура КАК Номенклатура,
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдиницаХраненияОстатков,
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура.ВестиУчетПоХарактеристикам КАК НоменклатураВестиУчетПоХарактеристикам,
		|	ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоПриход КАК Запланировано,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоРасход КАК ОтгруженоОтменено,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоКонечныйОстаток КАК ОсталосьОтгрузить,
		|	РезервыКомпании.КоличествоОстаток КАК Резерв,
		|	РазмещениеЗаказовПокупателей.КоличествоОстаток КАК Заказано,
		|	ЕстьNULL(ОстаткиТоваровКомпании.КоличествоОстаток,0)+ЕстьNULL(ОстаткиТоваровКомпанииВРознице.КоличествоОстаток,0) -
		|	ЕстьNULL(РезервыТоваровКомпании.КоличествоОстаток,0) -
		|	ЕстьNULL(ТоварыКПередачеКомпании.КоличествоОстаток,0) КАК СвободныйОстаток
		|ИЗ
		|	РегистрНакопления.ЗаказыПокупателей.ОстаткиИОбороты(, &ДатаАнализа, , , ЗаказПокупателя = &Заказ) КАК ЗаказыПокупателейОстаткиИОбороты
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаАнализа, ДокументРезерва = &Заказ) КАК РезервыКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РезервыКомпании.ХарактеристикаНоменклатуры
		|			И ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РезервыКомпании.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.РазмещениеЗаказовПокупателей.Остатки(&ДатаАнализа, ЗаказПокупателя = &Заказ) КАК РазмещениеЗаказовПокупателей
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РазмещениеЗаказовПокупателей.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РазмещениеЗаказовПокупателей.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(&ДатаАнализа, ) КАК ОстаткиТоваровКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ОстаткиТоваровКомпании.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ОстаткиТоваровКомпании.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРознице.Остатки(&ДатаАнализа, ) КАК ОстаткиТоваровКомпанииВРознице
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ОстаткиТоваровКомпанииВРознице.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ОстаткиТоваровКомпанииВРознице.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаАнализа, ) КАК РезервыТоваровКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РезервыТоваровКомпании.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РезервыТоваровКомпании.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыКПередачеСоСкладов.Остатки(&ДатаАнализа, ) КАК ТоварыКПередачеКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ТоварыКПередачеКомпании.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ТоварыКПередачеКомпании.ХарактеристикаНоменклатуры
		|			И ЗаказыПокупателейОстаткиИОбороты.СтатусПартии = ТоварыКПередачеКомпании.СтатусПартии
		|ИТОГИ
		|	СУММА(Запланировано),
		|	СУММА(ОтгруженоОтменено),
		|	СУММА(ОсталосьОтгрузить),
		|	СУММА(Резерв),
		|	СУММА(Заказано),
		|	СУММА(СвободныйОстаток)
		|ПО
		|	Номенклатура,
		|	ХарактеристикаНоменклатуры";
	ИначеЕсли ТипЗаказа = "Внутренний" Тогда
		Запрос.Текст="ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура                            КАК Номенклатура,
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура.ЕдиницаХраненияОстатков    КАК ЕдиницаХраненияОстатков,
		|	ЗаказыПокупателейОстаткиИОбороты.Номенклатура.ВестиУчетПоХарактеристикам КАК НоменклатураВестиУчетПоХарактеристикам,
		|	ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоПриход           КАК Запланировано,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоРасход           КАК ОтгруженоОтменено,
		|	ЗаказыПокупателейОстаткиИОбороты.КоличествоКонечныйОстаток  КАК ОсталосьОтгрузить,
		|	РезервыКомпании.КоличествоОстаток                           КАК Резерв,
		|	ЕстьNULL(РазмещениеЗаказовПокупателей.КоличествоОстаток,0)  КАК Заказано,
		|	ЕстьNULL(ОстаткиТоваровКомпании.КоличествоОстаток,0) + ЕстьNULL(ОстаткиТоваровКомпанииВРознице.КоличествоОстаток,0) -
		|	ЕстьNULL(РезервыТоваровКомпании.КоличествоОстаток,0) -
		|	ЕстьNULL(ТоварыКПередачеКомпании.КоличествоОстаток,0) КАК СвободныйОстаток
		|ИЗ
		|	РегистрНакопления.ВнутренниеЗаказы.ОстаткиИОбороты(,&ДатаАнализа,,,ВнутреннийЗаказ=&Заказ) КАК ЗаказыПокупателейОстаткиИОбороты
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаАнализа, ДокументРезерва=&Заказ) КАК РезервыКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РезервыКомпании.ХарактеристикаНоменклатуры 
		|			И ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РезервыКомпании.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.РазмещениеЗаказовПокупателей.Остатки(&ДатаАнализа, ЗаказПокупателя = &Заказ) КАК РазмещениеЗаказовПокупателей
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РазмещениеЗаказовПокупателей.Номенклатура 
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РазмещениеЗаказовПокупателей.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(&ДатаАнализа) КАК ОстаткиТоваровКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ОстаткиТоваровКомпании.Номенклатура 
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ОстаткиТоваровКомпании.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРознице.Остатки(&ДатаАнализа) КАК ОстаткиТоваровКомпанииВРознице
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ОстаткиТоваровКомпанииВРознице.Номенклатура 
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ОстаткиТоваровКомпанииВРознице.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаАнализа) КАК РезервыТоваровКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = РезервыТоваровКомпании.Номенклатура 
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = РезервыТоваровКомпании.ХарактеристикаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыКПередачеСоСкладов.Остатки(&ДатаАнализа, ) КАК ТоварыКПередачеКомпании
		|		ПО ЗаказыПокупателейОстаткиИОбороты.Номенклатура = ТоварыКПередачеКомпании.Номенклатура
		|			И ЗаказыПокупателейОстаткиИОбороты.ХарактеристикаНоменклатуры = ТоварыКПередачеКомпании.ХарактеристикаНоменклатуры
		|			И ЗаказыПокупателейОстаткиИОбороты.СтатусПартии = ТоварыКПередачеКомпании.СтатусПартии
		|	
		|ИТОГИ 
		|	СУММА(Запланировано), 
		|	СУММА(ОтгруженоОтменено), 
		|	СУММА(ОсталосьОтгрузить),
		|	СУММА(Резерв), 
		|	СУММА(Заказано), 
		|	СУММА(СвободныйОстаток) 
		|ПО
		|	Номенклатура,
		|	ХарактеристикаНоменклатуры";
	Иначе
		Запрос.Текст = "
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РегЗаказы.Номенклатура                            КАК Номенклатура,
		|	РегЗаказы.Номенклатура.ЕдиницаХраненияОстатков    КАК ЕдиницаХраненияОстатков,
		|	РегЗаказы.Номенклатура.ВестиУчетПоХарактеристикам КАК НоменклатураВестиУчетПоХарактеристикам,
		|	РегЗаказы.ХарактеристикаНоменклатуры              КАК ХарактеристикаНоменклатуры,
		|	РегЗаказы.КоличествоПриход          КАК Запланировано,
		|	РегЗаказы.КоличествоРасход          КАК ОтгруженоОтменено,
		|	РегЗаказы.КоличествоКонечныйОстаток КАК ОсталосьОтгрузить,
		|	ЕстьNULL(РегРазмещение.КоличествоОстаток,0) КАК Резерв
		|ИЗ
		|	РегистрНакопления.ЗаказыПоставщикам.ОстаткиИОбороты(&НачалоЗаказа, &ДатаАнализа, , , ЗаказПоставщику = &Заказ) КАК РегЗаказы
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.РазмещениеЗаказовПокупателей.Остатки(&ДатаАнализа, ЗаказПоставщику = &Заказ) КАК РегРазмещение
		|		ПО РегЗаказы.Номенклатура = РегРазмещение.Номенклатура
		|		 И РегЗаказы.ХарактеристикаНоменклатуры = РегРазмещение.ХарактеристикаНоменклатуры
		|
		|ИТОГИ СУММА(Запланировано), СУММА(ОтгруженоОтменено), СУММА(ОсталосьОтгрузить), СУММА(Резерв) ПО
		|	Номенклатура,
		|	ХарактеристикаНоменклатуры";
		
	КонецЕсли;
	
	// Устанавливаем параметры запроса
	
	Запрос.УстановитьПараметр("ДатаАнализа",  ?(ДатаАнализа='00010101000000','00010101000000',ДатаАнализа));
	Запрос.УстановитьПараметр("НачалоЗаказа", Заказ.Дата);
	Запрос.УстановитьПараметр("Заказ",        Заказ);
	Если ТипЗаказа = "Внутренний" Тогда
		Запрос.УстановитьПараметр("СкладЗаказа",  Заказ.Заказчик);
	ИначеЕсли ТипЗаказа = "Покупателя" Тогда
		Запрос.УстановитьПараметр("СкладЗаказа",  Заказ.СкладГруппа);
	Иначе
		Запрос.УстановитьПараметр("СкладЗаказа",  Заказ.Склад);
	КонецЕсли;
	Запрос.УстановитьПараметр("ПустойЗаказ",  Неопределено);

    // Выполнение сформированного запроса и возврат результата	
	
	Возврат Запрос.Выполнить();                               
	
КонецФункции

// Формирует текст запроса по состоянию взаиморасчетов по договору,
// устанавливает параметры и выполняет запрос
// Параметры: 
//  Заказ - объект заказа,
//  ДатаАнализа - дата анализа.
//
// Возвращаемое значение:
//  результат запроса.
Функция ПолучитьРезультатЗапросаПоВзаиморасчетам(Заказ, ДатаАнализа) Экспорт
	
	ТипЗаказа = ПолучитьТипЗаказа(Заказ);
	
	//Формируем текст запроса по состоянию взаиморасчетов по договору.
	
	Запрос = Новый Запрос;
	Если ТипЗаказа = "Покупателя" Тогда 
		Запрос.Текст=
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РасчетыСКонтрагентами.СуммаВзаиморасчетовПриход КАК Запланировано,
		|	РасчетыСКонтрагентами.СуммаВзаиморасчетовРасход КАК Оплачено,
		|	РасчетыСКонтрагентами.Сделка КАК Заказ,
		|	РасчетыСКонтрагентами.ДоговорКонтрагента КАК ЗаказДоговорКонтрагента
		|ИЗ
		|	РегистрНакопления.РасчетыСКонтрагентами.Обороты(, &ДатаАнализа, , ДоговорКонтрагента = &ДоговорКонтрагента) КАК РасчетыСКонтрагентами
		|
		|ИТОГИ 
		|	СУММА(Оплачено), 
		|	СУММА(Запланировано)
		|ПО ОБЩИЕ,
		|	Заказ";
	Иначе
		Запрос.Текст=
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РасчетыСКонтрагентами.СуммаВзаиморасчетовПриход КАК Оплачено,
		|	РасчетыСКонтрагентами.СуммаВзаиморасчетовРасход КАК Запланировано,
		|	РасчетыСКонтрагентами.Сделка КАК Заказ,
		|	РасчетыСКонтрагентами.ДоговорКонтрагента КАК ЗаказДоговорКонтрагента
		|ИЗ
		|	РегистрНакопления.РасчетыСКонтрагентами.Обороты(, &ДатаАнализа, , ДоговорКонтрагента = &ДоговорКонтрагента) КАК РасчетыСКонтрагентами
		|
		|ИТОГИ 
		|	СУММА(Оплачено), 
		|	СУММА(Запланировано)
		|ПО ОБЩИЕ,
		|	Заказ";
	КонецЕсли;
	
	// Устанавливаем параметры запроса
	
	Запрос.УстановитьПараметр("ДатаАнализа",?(ДатаАнализа='00010101000000','00010101000000',ДатаАнализа));
	Запрос.УстановитьПараметр("ДоговорКонтрагента",Заказ.ДоговорКонтрагента);
	 
	 // Выполнение сформированного запроса и возврат результата
	 
	 Возврат Запрос.Выполнить();
	 
КонецФункции

// Возвращает тип заказа
//
// Параметры: 
//  Заказ - объект заказа,
//
// Возвращаемое значение:
//  строка.
Функция ПолучитьТипЗаказа(Заказ)
	ТипЗначЗаказ = ТипЗнч(Заказ);
	Возврат ?(ТипЗначЗаказ = Тип("ДокументСсылка.ЗаказПоставщику"),
				"Поставщику",
				?(ТипЗначЗаказ = Тип("ДокументСсылка.ВнутреннийЗаказ"), "Внутренний", "Покупателя"));
КонецФункции


#Если Клиент Тогда

// Вывод строки отчета (с проверкой необходимости этого вывода)
//
// Параметры:
//	Выборка       - выборка из результата отчета, которая обходится в процедуре
//	СтруктураПараметров - структура параметров, необходимых для вывода строки
//	Номер         - число, номер обходимой группировки
//
Процедура ВывестиСтроку(Выборка, СтруктураПараметров, Номер)

	Перем ЭтоМатериалы;

	ОбластьОбщийОтступ = СтруктураПараметров.ОбщийОтступ;
	ОбластьЗначениеГруппировки   = СтруктураПараметров.ЗначениеГруппировки;
	ОбластьЗначенияПоказателя    = СтруктураПараметров.ЗначенияПоказателя;
	ЗначениеГруппировки = "";
	ЗначениеРасшифровки = Неопределено;
	ИмяГруппировки  = Выборка.Группировка();
	ТипЗаписиВыборки = Выборка.ТипЗаписи();
	СтруктураДанныхТекущегоЗаказа= Новый Структура;
	ТипЗаказа = СтруктураПараметров.ТипЗаказа;

	ТабДок = СтруктураПараметров.ТабДок;

	Если НЕ СтруктураПараметров.Свойство("СтруктураДанныхТекущегоЗаказа",СтруктураДанныхТекущегоЗаказа) Тогда 
		// Выборка из запроса по номенклатуре. 
		
		ЗначениеГруппировки = "";

		ЗначениеТекущейГруппировки = "" + Выборка[ИмяГруппировки];
		Если ПустаяСтрока(ЗначениеТекущейГруппировки) Тогда
			Если ИмяГруппировки = "ХарактеристикаНоменклатуры" Тогда
				Если  Выборка["НоменклатураВестиУчетПоХарактеристикам"] = Истина Тогда
					ЗначениеТекущейГруппировки = "Характеристика не задана";
				Иначе

					// Если учета характеристик нет, то не выводим группировку вообще
					Возврат;
				КонецЕсли;
			Иначе
				ЗначениеТекущейГруппировки = "<...>";
			КонецЕсли;
		КонецЕсли;

		ЗначениеГруппировки = ЗначениеГруппировки + ЗначениеТекущейГруппировки;
		Если ИмяГруппировки = "Номенклатура" Тогда
			ЗначениеГруппировки = ЗначениеГруппировки +", " + Выборка["ЕдиницаХраненияОстатков"];
		КонецЕсли;
		ЗначениеРасшифровки = Выборка[ИмяГруппировки];

	Иначе
        // Выборка из запроса по взаиморасчетам.
		Если (СтруктураПараметров.НомерОбхода=1) И (ТипЗаписиВыборки = ТипЗаписиЗапроса.ОбщийИтог) Тогда 
			ЗначениеГруппировки="Всего"; // Первый обход запроса по взаиморасчетам: записываются значения итогов.
		ИначеЕсли (СтруктураПараметров.НомерОбхода=1) И (СокрЛП("" + Выборка[ИмяГруппировки])=СокрЛП(""+Заказ)) Тогда
			ЗначениеГруппировки="Текущий заказ"; 	// Первый обход запроса по взаиморасчетам: выводятся
													// данные по текущему заказу.
		ИначеЕсли (СтруктураПараметров.НомерОбхода=2) И (ТипЗаписиВыборки = ТипЗаписиЗапроса.ОбщийИтог) Тогда 
			ЗначениеГруппировки="Другие заказы по договору"; 	// Второй обход запроса по взаиморасчетам:
																// выводится итоговая строка по другим заказам.
		ИначеЕсли (СтруктураПараметров.НомерОбхода=2) И (СокрЛП("" + Выборка[ИмяГруппировки])<>СокрЛП(""+Заказ)) Тогда 
            // Второй обход запроса по взаиморасчетам: выводятся данные по другим заказам.
			ЗначениеГруппировки= "" + Выборка[ИмяГруппировки];
			ЗначениеРасшифровки = Выборка[ИмяГруппировки];
		Иначе 
            // Второй обход запроса по взаиморасчетам: пропускаем текущий заказ.
			Возврат 
		КонецЕсли;

	КонецЕсли;
	
	Если ЗначениеГруппировки<>"Всего" Тогда  // При первом обходе запроса по взаиморасчетам итоговая строка не выводится.

		Если (ТипЗаписиВыборки = ТипЗаписиЗапроса.ИтогПоГруппировке) И (ЗначениеГруппировки<>"Текущий заказ") Тогда
			СдвигУровня = СтруктураПараметров.СтруктураСдвигУровняГруппировок[ИмяГруппировки];
		ИначеЕсли (ТипЗаписиВыборки=ТипЗаписиЗапроса.ОбщийИтог) ИЛИ (ЗначениеГруппировки="Текущий заказ") Тогда
			СдвигУровня=0;
		КонецЕсли;
		
		ТабДок.Вывести(ОбластьОбщийОтступ, СдвигУровня);

		ОбластьЗначениеГруппировки.Параметры.ЗначениеГруппировки = СокрЛП(ЗначениеГруппировки);
        ОбластьЗначениеГруппировки.Параметры.Расшифровка = ЗначениеРасшифровки;

		ОбластьЗначениеГруппировки.Область().Отступ = СдвигУровня;
		
		ТабДок.Присоединить(ОбластьЗначениеГруппировки);

	КонецЕсли;

	Если НЕ СтруктураПараметров.Свойство("СтруктураДанныхТекущегоЗаказа",СтруктураДанныхТекущегоЗаказа) Тогда 
		// Выборка из запроса по номенклатуре. 

		Если НЕ СтруктураПараметров.Свойство("ЭтоМатериалы",ЭтоМатериалы) Тогда 
			// Если не материалы
			
			Если ИмяГруппировки<>"ТоварТара" Тогда

				ФорматПоказателя = "ЧЦ = 15 ; ЧДЦ = 3 ; ЧН = ""0,000""";

				Если СтруктураПараметров.ТипЗаказа = "Покупателя" ИЛИ СтруктураПараметров.ТипЗаказа = "Внутренний" Тогда
					Заказать = ?( Выборка["ОсталосьОтгрузить"] = NULL, 0, Выборка["ОсталосьОтгрузить"])
								  - ?( Выборка["Резерв"]            = NULL, 0, Выборка["Резерв"])
								  - ?( Выборка["Заказано"]          = NULL, 0, Выборка["Заказано"]);
					ЗначениеСвободныйОстаток	= Формат(?(Выборка["СвободныйОстаток"]=NULL,0,
																Выборка["СвободныйОстаток"]), ФорматПоказателя);
					ЗначениеЗаказано			= Формат(?(Выборка["Заказано"]=NULL,0,
																Выборка["Заказано"]), ФорматПоказателя);

					СсылкаНоменклатура = Выборка[ИмяГруппировки];
					Если ТипЗнч(СсылкаНоменклатура) = Тип("СправочникСсылка.Номенклатура") Тогда
						Если СсылкаНоменклатура.Услуга Тогда
							Заказать = 0;
						КонецЕсли;
					КонецЕсли;

				Иначе
					Заказать = "";
					СвободныйОстаток = Выборка["ОсталосьОтгрузить"] - Выборка["Резерв"];
					
					СсылкаНоменклатура = Выборка[ИмяГруппировки];
					Если ТипЗнч(СсылкаНоменклатура) = Тип("СправочникСсылка.Номенклатура") Тогда
						Если СсылкаНоменклатура.Услуга Тогда
							СвободныйОстаток = 0;
						КонецЕсли;
					КонецЕсли;

					ЗначениеСвободныйОстаток = Формат(СвободныйОстаток, ФорматПоказателя);
				КонецЕсли;

				ЗначениеЗапланировано 		= Формат(?(Выборка["Запланировано"]=NULL,0,
															Выборка["Запланировано"]), ФорматПоказателя);
				ЗначениеОтгруженоОтменено  	= Формат(?(Выборка["ОтгруженоОтменено"]=NULL,0,
															Выборка["ОтгруженоОтменено"]), ФорматПоказателя);
				ЗначениеОсталосьОтгрузить  	= Формат(?(Выборка["ОсталосьОтгрузить"]=NULL,0,
															Выборка["ОсталосьОтгрузить"]), ФорматПоказателя);
				ЗначениеРезерв 				= Формат(?(Выборка["Резерв"]=NULL,0,
															Выборка["Резерв"]), ФорматПоказателя);
				ЗначениеЗаказать			= Формат(Заказать, ФорматПоказателя);

			Иначе
				
				ЗначениеЗапланировано 		= "";
				ЗначениеОтгруженоОтменено  	= "";
				ЗначениеОсталосьОтгрузить  	= "";
				ЗначениеРезерв 				= "";
				ЗначениеЗаказано			= "";
				ЗначениеСвободныйОстаток	= "";
				ЗначениеЗаказать			= "";

			КонецЕсли;

			ОбластьЗначенияПоказателя.Параметры.Запланировано     = СокрЛП(ЗначениеЗапланировано);
			ОбластьЗначенияПоказателя.Параметры.ОтгруженоОтменено = СокрЛП(ЗначениеОтгруженоОтменено);
			ОбластьЗначенияПоказателя.Параметры.ОсталосьОтгрузить = СокрЛП(ЗначениеОсталосьОтгрузить);
			Если СтруктураПараметров.ТипЗаказа = "Покупателя" 
				ИЛИ СтруктураПараметров.ТипЗаказа = "Внутренний" Тогда
				ОбластьЗначенияПоказателя.Параметры.Резерв 	 = СокрЛП(ЗначениеРезерв);
				ОбластьЗначенияПоказателя.Параметры.Заказать = СокрЛП(ЗначениеЗаказать);
				ОбластьЗначенияПоказателя.Параметры.Заказано         = СокрЛП(ЗначениеЗаказано);
				ОбластьЗначенияПоказателя.Параметры.СвободныйОстаток = СокрЛП(ЗначениеСвободныйОстаток);
			Иначе
				ОбластьЗначенияПоказателя.Параметры.Заказано         = СокрЛП(ЗначениеРезерв);
				ОбластьЗначенияПоказателя.Параметры.СвободныйОстаток = СокрЛП(ЗначениеСвободныйОстаток);
			КонецЕсли;

			ТабДок.Присоединить(ОбластьЗначенияПоказателя);

		Иначе	// Если материалы
			
			ФорматПоказателя = "ЧЦ = 15 ; ЧДЦ = 3 ; ЧН = ""0,000""";
			
			Если ТипЗаказа = "Поставщику" Тогда 
				
				ЗначениеЗапланировано 		= Формат(?(Выборка["Запланировано"]=NULL,0,
															Выборка["Запланировано"]), ФорматПоказателя);
				ЗначениеОтгруженоОтменено  	= Формат(?(Выборка["ОтгруженоОтменено"]=NULL,0,
															Выборка["ОтгруженоОтменено"]), ФорматПоказателя);
				ЗначениеОсталосьОтгрузить  	= Формат(?(Выборка["ОсталосьОтгрузить"]=NULL,0,
															Выборка["ОсталосьОтгрузить"]), ФорматПоказателя);

				ОбластьЗначенияПоказателя.Параметры.Запланировано     = СокрЛП(ЗначениеЗапланировано);
				ОбластьЗначенияПоказателя.Параметры.ОтгруженоОтменено = СокрЛП(ЗначениеОтгруженоОтменено);
				ОбластьЗначенияПоказателя.Параметры.ОсталосьОтгрузить = СокрЛП(ЗначениеОсталосьОтгрузить);
				
				ТабДок.Присоединить(ОбластьЗначенияПоказателя);
			
			ИначеЕсли ТипЗаказа = "Покупателя" Тогда 
				
				ЗначениеЗапланировано 		= Формат(?(Выборка["Запланировано"]=NULL,0,
															Выборка["Запланировано"]), ФорматПоказателя);
				ЗначениеПолученоОтменено  	= Формат(?(Выборка["ПолученоОтменено"]=NULL,0,
															Выборка["ПолученоОтменено"]), ФорматПоказателя);
				ЗначениеОсталосьПолучить  	= Формат(?(Выборка["ОсталосьПолучить"]=NULL,0,
															Выборка["ОсталосьПолучить"]), ФорматПоказателя);

				ОбластьЗначенияПоказателя.Параметры.Запланировано     = СокрЛП(ЗначениеЗапланировано);
				ОбластьЗначенияПоказателя.Параметры.ПолученоОтменено = СокрЛП(ЗначениеПолученоОтменено);
				ОбластьЗначенияПоказателя.Параметры.ОсталосьПолучить = СокрЛП(ЗначениеОсталосьПолучить);

				ТабДок.Присоединить(ОбластьЗначенияПоказателя);
			
			КонецЕсли;
				
		КонецЕсли;

	Иначе

        ПроцентПредоплаты=Заказ.ДоговорКонтрагента.ПроцентПредоплаты/100;

		ФорматПоказателя = "ЧЦ = 15 ; ЧДЦ = 2 ; ЧН = ""0,00""";

		Запланировано=Выборка["Запланировано"];
		ЗапланированоПредоплата=Выборка["Запланировано"]*ПроцентПредоплаты;
		Оплачено=?(ПустаяСтрока(Выборка["Оплачено"]),0,Выборка["Оплачено"]);
		ОплатитьВсего=Выборка["Запланировано"]-Оплачено;
		ОплатитьВсегоПредоплата=?(ЗапланированоПредоплата>Оплачено,ЗапланированоПредоплата-Оплачено,0);

		Если (ЗначениеГруппировки="Всего") или (ЗначениеГруппировки="Текущий заказ") Тогда 
			СтруктураДанных=Новый Структура;
			СтруктураДанных.Вставить("Запланировано",Запланировано);
			СтруктураДанных.Вставить("ЗапланированоПредоплата",ЗапланированоПредоплата);
			СтруктураДанных.Вставить("Оплачено",Оплачено);
			СтруктураДанных.Вставить("ОплатитьВсего",ОплатитьВсего);
			СтруктураДанных.Вставить("ОплатитьВсегоПредоплата",ОплатитьВсегоПредоплата);
		ИначеЕсли ЗначениеГруппировки="Другие заказы по договору" Тогда
			Запланировано=Запланировано-СтруктураДанныхТекущегоЗаказа.ДанныеЗаказа.Запланировано;
			ЗапланированоПредоплата=ЗапланированоПредоплата-СтруктураДанныхТекущегоЗаказа.ДанныеЗаказа.ЗапланированоПредоплата;
			Оплачено=Оплачено-СтруктураДанныхТекущегоЗаказа.ДанныеЗаказа.Оплачено;
			ОплатитьВсего=Запланировано-Оплачено;
			ОплатитьВсегоПредоплата=?(ЗапланированоПредоплата>Оплачено,ЗапланированоПредоплата-Оплачено,0);
		КонецЕсли;

		Если ЗначениеГруппировки="Всего" Тогда
			//Сохраняются итоговые данные запроса по взаиморасчетам, которые выводятся в последнюю очередь.
			СтруктураДанныхТекущегоЗаказа.Вставить("Всего",СтруктураДанных);
			СтруктураПараметров.Вставить("СтруктураДанныхТекущегоЗаказа",СтруктураДанныхТекущегоЗаказа);
			Возврат;
		Иначе
			//Сохраняются данные запроса по взаиморасчетам, касающиеся текущего заказа.
			СтруктураДанныхТекущегоЗаказа.Вставить("ДанныеЗаказа",СтруктураДанных);
			СтруктураПараметров.Вставить("СтруктураДанныхТекущегоЗаказа",СтруктураДанныхТекущегоЗаказа);
		КонецЕсли;

		ЗначениеЗапланировано 				= Формат(Запланировано, ФорматПоказателя);
		ЗначениеЗапланированоПредоплата  	= Формат(ЗапланированоПредоплата, ФорматПоказателя);
		ЗначениеОплачено  					= Формат(Оплачено, ФорматПоказателя);
		ЗначениеОплатитьВсего				= Формат(ОплатитьВсего, ФорматПоказателя);
		ЗначениеОплатитьВсегоПредоплата		= Формат(ОплатитьВсегоПредоплата, ФорматПоказателя);

		ОбластьЗначенияПоказателя.Параметры.Запланировано 				= СокрЛП(ЗначениеЗапланировано);
		ОбластьЗначенияПоказателя.Параметры.ЗапланированоПредоплата  	= СокрЛП(ЗначениеЗапланированоПредоплата);
		ОбластьЗначенияПоказателя.Параметры.Оплачено   					= СокрЛП(ЗначениеОплачено);
		ОбластьЗначенияПоказателя.Параметры.ОплатитьВсего 				= СокрЛП(ЗначениеОплатитьВсего);
		ОбластьЗначенияПоказателя.Параметры.ОплатитьВсегоПредоплата 	= СокрЛП(ЗначениеОплатитьВсегоПредоплата);

		ТабДок.Присоединить(ОбластьЗначенияПоказателя);

		Если (ЗначениеГруппировки="Текущий заказ") 
			ИЛИ (ЗначениеГруппировки="Другие заказы по договору") 
			ИЛИ (ЗначениеГруппировки="Всего")  Тогда
			ТабДок.Область(	ТабДок.ВысотаТаблицы, 2, 
							ТабДок.ВысотаТаблицы, ТабДок.ШиринаТаблицы).Шрифт=СтруктураПараметров.ШрифтГрупп;
		КонецЕсли;

	КонецЕсли;
		
КонецПроцедуры // ВывестиСтроку()

// Обход выборки из результата запроса по группировкам для вывода строк отчета
//
// Параметры:
//
//	Выборка       - выборка из результата отчета, которая обходится в процедуре,
//	СтруктураПараметров - структура параметров, передеваемых в процедуру вывода
//	                строки отчета,
//	Номер         - число, номер обходимой группировки
//
Процедура ВывестиВыборку(Выборка, СтруктураПараметров, Номер)

	ОбработкаПрерыванияПользователя();
	ВсегоГруппировок = СтруктураПараметров.ВсегоГруппировок;
	ЕстьНоменклатура = СтруктураПараметров.ЕстьНоменклатура;
   
	// Берутся группировки все подряд, 
	Пока Выборка.Следующий() Цикл

		ВывестиСтроку(Выборка, СтруктураПараметров, Номер);

		// Детальные записи не нужны: для последней группировки после итогов оп группировке идут 
		// детальные записи
		Если Номер = ВсегоГруппировок
			И Выборка.ТипЗаписи() =  ТипЗаписиЗапроса.ИтогПоГруппировке Тогда 
			Продолжить;
		КонецЕсли;
		
		ВывестиВыборку(Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам), СтруктураПараметров, Номер + 1);
		
	КонецЦикла;

КонецПроцедуры // ВывестиВыборку()

//Формирует текст запроса, исполняет запрос и выводит результат в табличный документ.
//
Процедура СформироватьОтчет(ДокументРезультат) Экспорт

    // Проверка на пустые значения
	Если ПустаяСтрока(Заказ) Тогда
		Предупреждение("Не выбран заказ!");
		Возврат;
	КонецЕсли;

	ТипЗаказа = ПолучитьТипЗаказа(Заказ);	

	// Получаем результат запроса по номенклатуре
	Результат = ПолучитьРезультатЗапросаПоНоменклатуре(Заказ, ДатаАнализа);
		
    Макет = ПолучитьМакет( ?(ТипЗаказа = "Поставщику", "МакетЗаказПоставщику", ?(ТипЗаказа = "Внутренний", "МакетВнутреннийЗаказ", "Макет")));
	ДокументРезультат.Очистить();
	СтруктураПараметров = Новый Структура;

	СтруктураСдвигУровняГруппировок=Новый Структура;
	СтруктураСдвигУровняГруппировок.Вставить("Номенклатура", 0);
	СтруктураСдвигУровняГруппировок.Вставить("ХарактеристикаНоменклатуры", 1);

	// Области строки отчета - табличные документы из макета отчета
	СтруктураПараметров.Вставить("ОбщийОтступ", Макет.ПолучитьОбласть("ОбщийОтступ|Строка"));
	СтруктураПараметров.Вставить("ЗначениеГруппировки", Макет.ПолучитьОбласть("Значение|Строка"));
	СтруктураПараметров.Вставить("ЗначенияПоказателя",  Макет.ПолучитьОбласть("Показатель|Строка"));
	СтруктураПараметров.Вставить("СтруктураСдвигУровняГруппировок",  СтруктураСдвигУровняГруппировок);
	СтруктураПараметров.Вставить("ВсегоГруппировок", 1);
	СтруктураПараметров.Вставить("ТипЗаказа", ТипЗаказа);

	// Табличный документ - результат отчета
	СтруктураПараметров.Вставить("ТабДок",    ДокументРезультат);
	
	// Наклонный шрифт для групп
	СтруктураПараметров.Вставить("ШрифтГрупп", Новый Шрифт(Макет.Область("Строка|Показатель").Шрифт,,,Истина));

	// Вывод шапки отчета
	ОбластьЗначение   = Макет.ПолучитьОбласть("ШапкаЗаголовок");

	ОбластьЗначение.Параметры.ЗаголовокОтчета = "Состояние заказа по документу "
			+ Заказ+Символы.ПС+" на "
			+ ?(ДатаАнализа='00010101000000',"момент последнего движения",Формат(ДатаАнализа,"ДФ=""дд ММММ гггг 'г.' ЧЧ:мм:сс'"""));

	ДокументРезультат.Присоединить(ОбластьЗначение);

	Если Не ТипЗаказа = "Внутренний" Тогда
	
		ОбластьЗначение   = Макет.ПолучитьОбласть("ШапкаКонтрагент");
		
		ОбластьЗначение.Параметры.Контрагент = "Контрагент:"+Заказ.Контрагент;
		ОбластьЗначение.Параметры.РасшифровкаКонтрагент=Заказ.Контрагент;
		ОбластьЗначение.Параметры.Договор = "Договор контрагента: "+Заказ.ДоговорКонтрагента;
		ОбластьЗначение.Параметры.РасшифровкаДоговор = Заказ.ДоговорКонтрагента;

		ДокументРезультат.Присоединить(ОбластьЗначение);
		
	КонецЕсли;

	ДокументРезультат.Присоединить(Макет.ПолучитьОбласть("ШапкаНоменклатура"));

	// Вывод строк отчета
	ДокументРезультат.НачатьАвтогруппировкуСтрок();

	СтруктураПараметров.Вставить("ЕстьНоменклатура", Истина);
	
	ВывестиВыборку(Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам), СтруктураПараметров, 0);

	ДокументРезультат.ЗакончитьАвтогруппировкуСтрок();

	ДокументРезультат.Вывести(Макет.ПолучитьОбласть("Подвал"));

	Если Не ТипЗаказа = "Внутренний" Тогда
		
		// Получаем результат запроса по взаиморасчетам
		Результат = ПолучитьРезультатЗапросаПоВзаиморасчетам(Заказ, ДатаАнализа);

		СтруктураСдвигУровняГруппировок=Новый Структура;
		СтруктураСдвигУровняГруппировок.Вставить("ОБЩИЕ", 0);
		СтруктураСдвигУровняГруппировок.Вставить("Заказ", 1);

		СтруктураДанныхТекущегоЗаказа=Новый Структура;

		СтруктураДанных=Новый Структура;
		СтруктураДанных.Вставить("Запланировано",0);
		СтруктураДанных.Вставить("ЗапланированоПредоплата",0);
		СтруктураДанных.Вставить("Оплачено",0);
		СтруктураДанных.Вставить("ОплатитьВсего",0);
		СтруктураДанных.Вставить("ОплатитьВсегоПредоплата",0);

		СтруктураДанныхТекущегоЗаказа.Вставить("ДанныеЗаказа",СтруктураДанных);
		СтруктураДанныхТекущегоЗаказа.Вставить("Всего",СтруктураДанных);

		// Области строки отчета - табличные документы из макета отчета
		СтруктураПараметров.Вставить("ОбщийОтступ", Макет.ПолучитьОбласть("ОбщийОтступ|СтрокаДеньги"));
		СтруктураПараметров.Вставить("ЗначениеГруппировки",   Макет.ПолучитьОбласть("Значение|СтрокаДеньги"));
		СтруктураПараметров.Вставить("ЗначенияПоказателя",    Макет.ПолучитьОбласть("Показатель|СтрокаДеньги"));
		СтруктураПараметров.Вставить("СтруктураСдвигУровняГруппировок",  СтруктураСдвигУровняГруппировок);
		СтруктураПараметров.Вставить("СтруктураСдвигУровняГруппировок",  СтруктураСдвигУровняГруппировок);
		СтруктураПараметров.Вставить("СтруктураДанныхТекущегоЗаказа",  СтруктураДанныхТекущегоЗаказа);
		СтруктураПараметров.Вставить("ВсегоГруппировок",  1);
		СтруктураПараметров.Вставить("НомерОбхода",  1);
	   
		ДокументРезультат.Вывести(Макет.ПолучитьОбласть("ОбщийОтступ|ШапкаДеньги"));

		// Вывод шапки таблицы по состоянию взаиморасчетов.
		ОбластьЗначение   = Макет.ПолучитьОбласть("Значение|ШапкаДеньги");

		ДокументРезультат.Присоединить(ОбластьЗначение);

		ОбластьПоказатель = Макет.ПолучитьОбласть("Показатель|ШапкаДеньги");
		ОбластьПоказатель.Параметры.ПредоплатаТекст = "Предоплата  "
					+	Формат(Заказ.ДоговорКонтрагента.ПроцентПредоплаты,"ЧЦ=5; ЧДЦ=2; ЧН=""0,00""")+"%";
		ОбластьПоказатель.Параметры.ВалютаВзаиморасчетов ="Валюта взаиморасчетов: "
					+ 	Заказ.ДоговорКонтрагента.ВалютаВзаиморасчетов;
		ДокументРезультат.Присоединить(ОбластьПоказатель);

		// Вывод строк таблицы по состоянию взаиморасчетов.
		ДокументРезультат.НачатьАвтогруппировкуСтрок();

		СтруктураПараметров.Вставить("ЕстьНоменклатура", Ложь);
		
		ВывестиВыборку(Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам), СтруктураПараметров, 0);
		СтруктураПараметров.Вставить("НомерОбхода",  2);
		ВывестиВыборку(Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам), СтруктураПараметров, 0);

		ДокументРезультат.ЗакончитьАвтогруппировкуСтрок();

		//Вывод итоговой строки таблицы по состоянию взаиморасчетов.

		ДокументРезультат.Вывести(СтруктураПараметров.ОбщийОтступ);

		СтруктураПараметров.ЗначениеГруппировки.Параметры.ЗначениеГруппировки = "Всего";

		ДокументРезультат.Присоединить(СтруктураПараметров.ЗначениеГруппировки);

		ФорматПоказателя = "ЧЦ = 15 ; ЧДЦ = 2 ; ЧН = ""0,00""";
		
		СтруктураОбщихДанных=СтруктураПараметров.СтруктураДанныхТекущегоЗаказа.Всего;
		
		ЗначениеЗапланировано 				= Формат(СтруктураОбщихДанных.Запланировано, ФорматПоказателя);
		ЗначениеЗапланированоПредоплата  	= Формат(СтруктураОбщихДанных.ЗапланированоПредоплата, ФорматПоказателя);
		ЗначениеОплачено  					= Формат(СтруктураОбщихДанных.Оплачено, ФорматПоказателя);
		ЗначениеОплатитьВсего				= Формат(СтруктураОбщихДанных.ОплатитьВсего, ФорматПоказателя);
		ЗначениеОплатитьВсегоПредоплата		= Формат(СтруктураОбщихДанных.ОплатитьВсегоПредоплата, ФорматПоказателя);

		СтруктураПараметров.ЗначенияПоказателя.Параметры.Запланировано 				= СокрЛП(ЗначениеЗапланировано);
		СтруктураПараметров.ЗначенияПоказателя.Параметры.ЗапланированоПредоплата  	= СокрЛП(ЗначениеЗапланированоПредоплата);
		СтруктураПараметров.ЗначенияПоказателя.Параметры.Оплачено   				= СокрЛП(ЗначениеОплачено);
		СтруктураПараметров.ЗначенияПоказателя.Параметры.ОплатитьВсего 				= СокрЛП(ЗначениеОплатитьВсего);
		СтруктураПараметров.ЗначенияПоказателя.Параметры.ОплатитьВсегоПредоплата 	= СокрЛП(ЗначениеОплатитьВсегоПредоплата);

		ДокументРезультат.Присоединить(СтруктураПараметров.ЗначенияПоказателя);
		ДокументРезультат.Область(ДокументРезультат.ВысотаТаблицы,  2, ДокументРезультат.ВысотаТаблицы, ДокументРезультат.ШиринаТаблицы).Шрифт=СтруктураПараметров.ШрифтГрупп;

		ДокументРезультат.Вывести(Макет.ПолучитьОбласть("ОбщийОтступ|ПодвалДеньги"));

		// Вывод подвала таблицы по состоянию взаиморасчетов.
		ОбластьЗначение = Макет.ПолучитьОбласть("Значение|ПодвалДеньги");
		
		ДокументРезультат.Присоединить(ОбластьЗначение);

		ДокументРезультат.Присоединить(Макет.ПолучитьОбласть("Показатель|ПодвалДеньги"));

		//Для договоров, по которым установлен контроль дебиторской задолженности, выводится текущее состояние задолженности.
		Если Заказ.ДоговорКонтрагента.КонтролироватьСуммуЗадолженности Тогда

			//Расчет текущей задолженности

			Запрос=Новый Запрос;
			Если ТипЗаказа = "Покупателя" Тогда
				Запрос.Текст="ВЫБРАТЬ
				|	КонтрагентыВзаиморасчетыКомпанииОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВалОстаток
				|ИЗ
				|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.Остатки(&ДатаАнализа,ДоговорКонтрагента=&ДоговорКонтрагента)
				|	КАК КонтрагентыВзаиморасчетыКомпанииОстатки";
			Иначе
				Запрос.Текст="ВЫБРАТЬ
				|	 - КонтрагентыВзаиморасчетыКомпанииОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВалОстаток
				|ИЗ
				|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.Остатки(&ДатаАнализа,ДоговорКонтрагента=&ДоговорКонтрагента)
				|	КАК КонтрагентыВзаиморасчетыКомпанииОстатки";
			КонецЕсли;

			Запрос.УстановитьПараметр("ДатаАнализа",?(ДатаАнализа='00010101000000','00010101000000',ДатаАнализа));
			Запрос.УстановитьПараметр("ДоговорКонтрагента",Заказ.ДоговорКонтрагента);

			СуммаВзаиморасчетовВал=0;

			Результат = Запрос.Выполнить();
			Выборка=Результат.Выбрать();
			Если Выборка.Следующий() Тогда
				СуммаВзаиморасчетовВал=Выборка["СуммаВалОстаток"];
			КонецЕсли;

			ДопустимаяЗадолженность=Заказ.ДоговорКонтрагента.ДопустимаяСуммаЗадолженности;
			ТекущаяЗадолженность=?(ПустаяСтрока(СуммаВзаиморасчетовВал),0,СуммаВзаиморасчетовВал);
			ОбъемОтгрузки=?((ДопустимаяЗадолженность-ТекущаяЗадолженность)>0,(ДопустимаяЗадолженность-ТекущаяЗадолженность),0);

			ЗначениеДопустимаяЗадолженность		= Формат(ДопустимаяЗадолженность, ФорматПоказателя);
			ЗначениеТекущаяЗадолженность	  	= Формат(ТекущаяЗадолженность, ФорматПоказателя);
			ЗначениеОбъемОтгрузки	  			= Формат(ОбъемОтгрузки, ФорматПоказателя);

			ДокументРезультат.Вывести(Макет.ПолучитьОбласть("ОбщийОтступ|КонтрольЗадолженности"));

			// Вывод области контроля задолженности
			ОбластьЗначение = Макет.ПолучитьОбласть("Значение|КонтрольЗадолженности");
			
			ДокументРезультат.Присоединить(ОбластьЗначение);

			ОбластьКонтрольЗадолженности=Макет.ПолучитьОбласть("Показатель|КонтрольЗадолженности");

			ОбластьКонтрольЗадолженности.Параметры.ДопустимаяЗадолженность = СокрЛП(ЗначениеДопустимаяЗадолженность);
			ОбластьКонтрольЗадолженности.Параметры.ТекущаяЗадолженность  	= СокрЛП(ЗначениеТекущаяЗадолженность);
			ОбластьКонтрольЗадолженности.Параметры.ОбъемОтгрузки   		= СокрЛП(ЗначениеОбъемОтгрузки);

			ДокументРезультат.Присоединить(ОбластьКонтрольЗадолженности);

		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗаказа = "Поставщику" Тогда

		ОбластьЗначение=Макет.ПолучитьОбласть("ПодвалКачество");
		ДокументРезультат.Вывести(ОбластьЗначение);

	КонецЕсли;
	
	// Первую колонку не печатаем
	ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
	ДокументРезультат.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
    ДокументРезультат.ТекущаяОбласть = ДокументРезультат.Область(1,2,1,2);
КонецПроцедуры // СформироватьОтчет()
#КонецЕсли
