﻿
///////////////////////////////////////////////////////
// ***

// Является ли текущий пользователь магазином
Функция ЭтоУчетнаяЗаписьМагазина()	Экспорт
	
  	РезПроверки = Ложь;	
	
	МагазинПользователь  = ПараметрыСеанса.ТекущийПользователь;

	Запрос = Новый Запрос;
	Запрос.Текст="
		|ВЫБРАТЬ ЗначениеНастроек.Значение КАК ЗначениеНастройки
		|ИЗ РегистрСведений.НастройкиПользователей КАК ЗначениеНастроек
		|ГДЕ ЗначениеНастроек.Пользователь = &Пользователь
		|И  ЗначениеНастроек.Настройка = &Настройка";
	Запрос.УстановитьПараметр("Пользователь", МагазинПользователь);
	Запрос.УстановитьПараметр("Настройка", ПланыВидовХарактеристик.НастройкиПользователей.УчетнаяЗаписьМагазина);
		
	Рез = Запрос.Выполнить();
	Если Рез.Пустой() Тогда
	Иначе
		Выборка = Рез.Выбрать();
		Пока Выборка.Следующий() Цикл
			РезПроверки = Выборка.ЗначениеНастройки;
			Прервать;
		КонецЦикла;
	КонецЕсли;
		
	Возврат РезПроверки;
	
КонецФункции

// Магазин - справочник "Контрагенты"
Функция ПолучитьСоответствиеМагазинПользователь(МагазинСсылка) Экспорт
	
	РезСтруктура = Новый Структура;
	
	ПсевдонимыРаздел = Справочники.ПсевдонимыРазделы.НайтиПоНаименованию("Пользователь-Магазин", Истина);
	Если НЕ ЗначениеЗаполнено(ПсевдонимыРаздел) Тогда		     
		Возврат РезСтруктура;
	КонецЕсли;     
	
	Если МагазинСсылка = Неопределено Тогда
		Возврат РезСтруктура;
	КонецЕсли;    
	
	РезСтруктура.Вставить("Магазин", Справочники.Контрагенты.ПустаяСсылка());
	РезСтруктура.Вставить("МагазинПользователь", Справочники.Пользователи.ПустаяСсылка());	
		
	// определяем пользователь и контрагент
	Если ТипЗнч(МагазинСсылка) = Тип("СправочникСсылка.Контрагенты") Тогда
		РезСтруктура.Магазин = МагазинСсылка;
		РезСтруктура.МагазинПользователь = ОбщегоНазначения5LB.НайтиПсевдонимПоЗначению(МагазинСсылка, ПсевдонимыРаздел);
	ИначеЕсли ТипЗнч(МагазинСсылка) = Тип("СправочникСсылка.Пользователи") Тогда					
		РезСтруктура.Магазин = ОбщегоНазначения5LB.ПолучитьПсевдоним(МагазинСсылка, ПсевдонимыРаздел, Справочники.Контрагенты.ПустаяСсылка());
		РезСтруктура.МагазинПользователь = МагазинСсылка;
	КонецЕсли;
	
	Возврат РезСтруктура;
	
КонецФункции


// Возвращает ссылку на продавца, работающего в магазине (контрагент или пользователь) на дату
Функция ПродавецРаботающийНаДатуВМагазине(НаДату=Неопределено, Магазин) Экспорт
	
	Рез = Справочники.Пользователи.ПустаяСсылка();
	
	Если НаДату = Неопределено Тогда
	    НаДату = ТекущаяДата();
	КонецЕсли;	
	
	Запрос = Новый Запрос;

	Если Магазин = Неопределено Тогда
		стрМагазинОтбор = "";
	Иначе		
		СтруктураМагазинПользователь = ПолучитьСоответствиеМагазинПользователь(Магазин);
		Если СтруктураМагазинПользователь.Количество() = 0 Тогда
			Возврат Рез;
		Иначе
			//стрМагазинОтбор = "И ИсторияРаботыПродавцов.Пользователь = &МагазинПользователь";
			Запрос.УстановитьПараметр("МагазинПользователь", СтруктураМагазинПользователь.МагазинПользователь);
		КонецЕсли;  	
	КонецЕсли;    
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИсторияРаботыПродавцовСрезПоследних.Пользователь,
		|	МАКСИМУМ(ИсторияРаботыПродавцовСрезПоследних.Период) КАК ДатаСобытия
		|ПОМЕСТИТЬ втСписокИстория
	    |ИЗ
	    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату, 
		|		Пользователь = &МагазинПользователь) КАК ИсторияРаботыПродавцовСрезПоследних		
		|СГРУППИРОВАТЬ ПО
		|	ИсторияРаботыПродавцовСрезПоследних.Пользователь
		|;		
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
	    |	ИсторияРаботы.Пользователь,
	    |	ИсторияРаботы.Продавец КАК Сотрудник
	    |ИЗ
	    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату,
		|		Пользователь = &МагазинПользователь) КАК ИсторияРаботы
		|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ втСписокИстория КАК Т1
		|	ПО ИсторияРаботы.Пользователь = Т1.Пользователь
		|	И ИсторияРаботы.Период = Т1.ДатаСобытия	
		|";
	
	Запрос.УстановитьПараметр("НаДату", НаДату);
	

	РезЗапроса = Запрос.Выполнить();	
	Выборка = РезЗапроса.Выбрать();		
	Пока Выборка.Следующий() Цикл
		Рез = Выборка.Сотрудник;
	КонецЦикла;
	
	Возврат Рез;
	
КонецФункции
	
// Возвращает таблицу значений продавцов, работающих на дату - поля "Продавец, Магазин"
Функция ПродавцыРаботающиеНаДату(НаДату=Неопределено, Магазин=Неопределено) Экспорт
	
	Рез = Новый ТаблицаЗначений();
	
	Если НаДату = Неопределено Тогда
	    НаДату = ТекущаяДата();
	КонецЕсли;	

	ПсевдонимыРаздел = Справочники.ПсевдонимыРазделы.НайтиПоНаименованию("Пользователь-Магазин", Истина);
	Если НЕ ЗначениеЗаполнено(ПсевдонимыРаздел) Тогда		     
		Возврат Рез;
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	
	Если Магазин = Неопределено Тогда
		стрМагазинОтбор = "";
	Иначе		
		СтруктураМагазинПользователь = ПолучитьСоответствиеМагазинПользователь(Магазин);
		Если СтруктураМагазинПользователь.Количество() = 0 Тогда
			Возврат Рез;
		Иначе
			стрМагазинОтбор = "И Псевдонимы.Значение = &Магазин";
			Запрос.УстановитьПараметр("Магазин", СтруктураМагазинПользователь.Магазин);
		КонецЕсли;                                                                     				
	КонецЕсли;            	

	Запрос.Текст =
	"ВЫБРАТЬ
		|	ИсторияРаботыПродавцовСрезПоследних.Пользователь,
		|	МАКСИМУМ(ИсторияРаботыПродавцовСрезПоследних.Период) КАК ДатаСобытия
		|ПОМЕСТИТЬ втСписокПродавцы
	    |ИЗ
	    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату,
//		|
		|		) КАК ИсторияРаботыПродавцовСрезПоследних		
		|СГРУППИРОВАТЬ ПО
		|	ИсторияРаботыПродавцовСрезПоследних.Пользователь
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Псевдонимы.ОбъектСсылка КАК ОбъектСсылка,
		|	Псевдонимы.Значение КАК Значение
		|ПОМЕСТИТЬ втСписокПсевдонимы
		|ИЗ
		|	РегистрСведений.Псевдонимы КАК Псевдонимы
		|ГДЕ
		|	Псевдонимы.Раздел = &Раздел
		|	" + стрМагазинОтбор + "
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
	    |	ИсторияРаботы.Пользователь КАК ПользовательМагазин,
	    |	ИсторияРаботы.Продавец КАК Продавец,
	    |	ИсторияРаботы.Продавец КАК Сотрудник,
	    |	ТП.Значение КАК Магазин
	    |ИЗ
	    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату, ) КАК ИсторияРаботы
		|		
		|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ втСписокПродавцы КАК Т1
		|	ПО ИсторияРаботы.Пользователь = Т1.Пользователь
		|	И ИсторияРаботы.Период = Т1.ДатаСобытия	
		|
		|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ втСписокПсевдонимы КАК ТП
		|	ПО ИсторияРаботы.Пользователь = ТП.ОбъектСсылка		
		|";                          	
	Запрос.УстановитьПараметр("НаДату", НаДату);	
	Запрос.УстановитьПараметр("Раздел", ПсевдонимыРаздел);
		
	Рез = Запрос.Выполнить().Выгрузить();	
		
	Возврат Рез;
	
КонецФункции

// Возвращает таблицу значений продавцов, работающих за период с кол-вом отраб.смен - поля "Продавец, КоличествоСмен"
Функция ПродавцыРаботающиеВМагазинеЗаПериод(ДатаС, ДатаПо, Магазин=Неопределено, ВключитьТолькоСКолСменБольшеИлиРавно=0) Экспорт
	
	Рез = Новый ТаблицаЗначений();
	
	Запрос = Новый Запрос;
	
	Если Магазин = Неопределено Тогда
		стрМагазинОтбор = "";
	Иначе		
		СтруктураМагазинПользователь = ПолучитьСоответствиеМагазинПользователь(Магазин);
		Если СтруктураМагазинПользователь.Количество() = 0 Тогда
			Возврат Рез;
		Иначе
			стрМагазинОтбор = "И ИсторияРаботыПродавцов.Пользователь = &МагазинПользователь";
			Запрос.УстановитьПараметр("МагазинПользователь", СтруктураМагазинПользователь.МагазинПользователь);
		КонецЕсли;  
	КонецЕсли;    
	
	Запрос.Текст = 
		"ВЫБРАТЬ 
		|	КОЛИЧЕСТВО(Т.ДеньСмены) КАК КоличествоСмен,
		|	Т.Продавец КАК Продавец
		|ИЗ		
		|(ВЫБРАТЬ
		|		РАЗЛИЧНЫЕ
		|	НАЧАЛОПЕРИОДА(ИсторияРаботыПродавцов.Период, ДЕНЬ) КАК ДеньСмены,
		|	ИсторияРаботыПродавцов.Пользователь,
		|	ИсторияРаботыПродавцов.Продавец КАК Продавец
		|ИЗ
		|	РегистрСведений.ИсторияРаботыПродавцов КАК ИсторияРаботыПродавцов
		|ГДЕ
		|	ИсторияРаботыПродавцов.Период МЕЖДУ &НачПериода И &КонПериода
		|	" + стрМагазинОтбор + "
		|) КАК Т
		|СГРУППИРОВАТЬ ПО
		|	Продавец
		|ИМЕЮЩИЕ
		|	КОЛИЧЕСТВО(ДеньСмены) > &КолСменБольшеИлиРавно
		|";
		
	// < 08.06 Вялов - если 1-е или 2-е число месяца - то брать за последние 5 дней
	Если День(ДатаПо) <= 3 Тогда
		ДатаС = НачалоДня(ДатаС - 5 * 24 * 60 * 60); 
	КонецЕсли;
	// 08.06 Вялов> 	
	Запрос.УстановитьПараметр("НачПериода", 			НачалоДня(ДатаС));
	Запрос.УстановитьПараметр("КонПериода",				КонецДня(ДатаПо));	
	Запрос.УстановитьПараметр("КолСменБольшеИлиРавно", 	ВключитьТолькоСКолСменБольшеИлиРавно);	
		
	Рез = Запрос.Выполнить().Выгрузить();	
		
	Возврат Рез;
	
КонецФункции


// Проверка текущего продавца, на то что он прикреплен к магазину на дату (если не задана - текущая)
Функция ТекущийПользовательПрикрепленКМагазину(НаДату=Неопределено, Магазин) Экспорт
	
	// если не продавец - то возврат Истина
	Попытка
		ТекПродавец = ПараметрыСеанса.ТекущийПродавец;
		Если НЕ ЗначениеЗаполнено(ТекПродавец) Тогда
			Возврат Истина;	
		КонецЕсли;
	Исключение	
		Возврат Истина;
	КонецПопытки;
	
	Если НаДату = Неопределено Тогда
	    НаДату = ТекущаяДата();
	КонецЕсли;	
	
	//МагазинПользователь = Неопределено;
	////Если ТипЗнч(Магазин) = Тип("СправочникСсылка.Склады") Тогда		
	////Иначе
	//Если ТипЗнч(Магазин) = Тип("СправочникСсылка.Пользователи") Тогда
	//	МагазинПользователь = Магазин;
	//ИначеЕсли ТипЗнч(Магазин) = Тип("СправочникСсылка.Контрагенты") Тогда
	//	СтруктураМагазинПользователь = ПолучитьСоответствиеМагазинПользователь(Магазин);
	//	Если СтруктураМагазинПользователь.Количество() = 0 Тогда
	//		МагазинПользователь = Неопределено;
	//	Иначе
	//		МагазинПользователь = СтруктураМагазинПользователь.МагазинПользователь;
	//	КонецЕсли;
	//КонецЕсли;
	// если магазин не нашли - возврат Истина
	//Если МагазинПользователь = Неопределено Тогда
	//	Возврат Истина;
	//КонецЕсли;	
	
	Если ТипЗнч(Магазин) <> Тип("СправочникСсылка.Контрагенты") Тогда
		Возврат Ложь;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КадроваяИсторияСрезПоследних.Сотрудник,
		|	КадроваяИсторияСрезПоследних.Магазин,
		|	КадроваяИсторияСрезПоследних.СтатусПродавца												
		|ИЗ
		|	РегистрСведений.КадроваяИстория.СрезПоследних(
		|			&НаДату,
		|			Сотрудник = &Сотрудник
		|			И Магазин = &Магазин
		|			И СтатусПродавца = &СтатусПродавца
		|	) КАК КадроваяИсторияСрезПоследних		
		|";
						
	Запрос.УстановитьПараметр("НаДату", НаДату + 1);
	Запрос.УстановитьПараметр("Сотрудник", ТекПродавец);
	Запрос.УстановитьПараметр("Магазин", Магазин);	
	Запрос.УстановитьПараметр("СтатусПродавца", Перечисления.СтатусПродавца.Прикреплен);

						
	//
	//Запрос = Новый Запрос;
	//Запрос.Текст = 
	//	"ВЫБРАТЬ
	//	|	ИсторияРаботыПродавцовСрезПоследних.Пользователь,
	//	|	МАКСИМУМ(ИсторияРаботыПродавцовСрезПоследних.Период) КАК ДатаСобытия
	//	|ПОМЕСТИТЬ втСписокИстория
	//    |ИЗ
	//    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату, 
	//	|		Пользователь = &МагазинПользователь И Продавец = &Продавец) КАК ИсторияРаботыПродавцовСрезПоследних		
	//	|СГРУППИРОВАТЬ ПО
	//	|	ИсторияРаботыПродавцовСрезПоследних.Пользователь
	//	|;		
	//	|////////////////////////////////////////////////////////////////////////////////
	//	|ВЫБРАТЬ
	//    |	ИсторияРаботы.Пользователь,
	//    |	ИсторияРаботы.Продавец КАК Продавец
	//    |ИЗ
	//    |	РегистрСведений.ИсторияРаботыПродавцов.СрезПоследних(&НаДату,
	//	|		Пользователь = &МагазинПользователь И Продавец = &Продавец) КАК ИсторияРаботы
	//	|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ втСписокИстория КАК Т1
	//	|	ПО ИсторияРаботы.Пользователь = Т1.Пользователь
	//	|	И ИсторияРаботы.Период = Т1.ДатаСобытия	
	//	|";
	//
	//Запрос.УстановитьПараметр("НаДату", НаДату);
	//Запрос.УстановитьПараметр("МагазинПользователь", МагазинПользователь);
	//Запрос.УстановитьПараметр("Продавец", ТекПродавец);
	

	РезЗапроса = Запрос.Выполнить();
	Рез = НЕ РезЗапроса.Пустой();
	
	Возврат Рез;
	
КонецФункции
	

Функция ПродавцовыПрикрепленныеКМагазину(Магазин=Неопределено, СУчетомОтпуска=Истина) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ 
		//|ИЗ
		//|	Справочник.Контрагенты		 		
		//РАЗЛИЧНЫЕ
		|	Кадры.Магазин,		
		|	Кадры.Сотрудник,
		|	Кадры.СтатусПродавца		
		|ИЗ
		|	РегистрСведений.КадроваяИстория.СрезПоследних(
		|			&НаДату,
	//	|			" + ?(Магазин=Неопределено, "", "Магазин = &Магазин") + "
		|	) КАК Кадры
		|ГДЕ
		|	Кадры.Магазин <> ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)
		|	И (Кадры.СтатусПродавца = ЗНАЧЕНИЕ(Перечисление.СтатусПродавца.Прикреплен)
		|	" + ?(СУчетомОтпуска, "ИЛИ Кадры.СтатусПродавца = ЗНАЧЕНИЕ(Перечисление.СтатусПродавца.ВОтпуске)", "") + ")		
		|	" + ?(Магазин <> Неопределено, "И Кадры.Магазин = &Магазин", "") + "	
		|";
		
	Если Магазин <> Неопределено Тогда
		Запрос.УстановитьПараметр("Магазин", Магазин);
	КонецЕсли;
	Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	//ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();	
	//Рез = ВыборкаДетальныеЗаписи.Количество();
	
	Рез = Запрос.Выполнить().Выгрузить();
	
	Возврат Рез;
	
	
КонецФункции



///////////////////////////////////////////////////////
// *** 
