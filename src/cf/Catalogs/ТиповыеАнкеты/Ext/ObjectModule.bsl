﻿////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Если Клиент Тогда

Функция СформироватьМакет(ДокументМакет) Экспорт
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("ТиповаяАнкета",	Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТиповыеАнкетыВопросыАнкеты.Ссылка,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос КАК Вопрос,
	|	ТиповыеАнкетыВопросыАнкеты.Раздел КАК Раздел,
	|	ВариантыОтветовОпросов.Наименование,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ПолнаяФормулировка КАК ПолнаяФормулировка,
	|	ВариантыОтветовОпросов.ТребуетРазвернутыйОтвет,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.Представление,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.Код КАК КодВопроса,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ТипЗначения,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ТипОтветаНаВопрос,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ВидКонтактнойИнформации,
	|	ВариантыОтветовОпросов.Представление КАК ВариантОтветаПредставление,
	|	ТиповыеАнкетыВопросыАнкеты.НомерСтроки КАК НомерСтрокиВАнкете,
	|	ВариантыОтветовОпросов.Код КАК КодВариантаОтвета,
	|	ВопросыДляАнкетированияКолонкиТаблицы.НомерСтроки КАК НомерКолонки,
	|	ВопросыДляАнкетированияКолонкиТаблицы.КолонкаТаблицы,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.КоличествоСтрокТаблицы,
	|	ВопросыДляАнкетированияКолонкиТаблицы.КолонкаТаблицы.Представление
	|ИЗ
	|	Справочник.ТиповыеАнкеты.ВопросыАнкеты КАК ТиповыеАнкетыВопросыАнкеты
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыОтветовОпросов КАК ВариантыОтветовОпросов
	|		ПО ТиповыеАнкетыВопросыАнкеты.Вопрос = ВариантыОтветовОпросов.Владелец
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.ВопросыДляАнкетирования.КолонкиТаблицы КАК ВопросыДляАнкетированияКолонкиТаблицы
	|		ПО ТиповыеАнкетыВопросыАнкеты.Вопрос = ВопросыДляАнкетированияКолонкиТаблицы.Ссылка
	|ГДЕ
	|	ТиповыеАнкетыВопросыАнкеты.Ссылка = &ТиповаяАнкета
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтрокиВАнкете
	|ИТОГИ
	|	МАКСИМУМ(НомерСтрокиВАнкете)
	|ПО
	|	Раздел,
	|	Вопрос";
	
	МакетАнкетыДляПечати = ПолучитьМакет("ТиповаяАнкета");
	ДокументМакет.Очистить();
	
	МакетАнкетыДляПечати.Области.ИмяАнкеты.Текст	= ?(НаименованиеАнкеты = "", Наименование, НаименованиеАнкеты);
	МакетАнкетыДляПечати.Области.Вступление.Текст	= Вступление;
	
	ДокументМакет.ВставитьОбласть(МакетАнкетыДляПечати.Области.Заголовок, 		ДокументМакет.Область("R1C1"), , Ложь);
	
	НомерСтрокиВМакете = 4;
	Результат = Запрос.Выполнить();
	ВыборкаЗапросаПоРазделам = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Раздел");
	Пока ВыборкаЗапросаПоРазделам.Следующий() Цикл
		ОбластьРаздел = МакетАнкетыДляПечати.Область("R8");//МакетАнкетыДляПечати.Области.ВариантОтвета;
		ДокументМакет.ВставитьОбласть(ОбластьРаздел, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Истина);
		
		Если ВыборкаЗапросаПоРазделам.Раздел = Справочники.РазделыАнкеты.ПустаяСсылка() тогда
			НаименованиеРаздела = "";
			
		Иначе
			НаименованиеРаздела = Строка(Число(ВыборкаЗапросаПоРазделам.Раздел.Код)) + ". " + ВыборкаЗапросаПоРазделам.Раздел.Наименование;
			
		КонецЕсли;
		
		ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1").Текст 	= НаименованиеРаздела;
		НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
		ВыборкаЗапросаПоВопросам = ВыборкаЗапросаПоРазделам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "Вопрос");
		Пока ВыборкаЗапросаПоВопросам.Следующий() Цикл
				
			ОбластьВопрос 			= МакетАнкетыДляПечати.Область("R5");
			ОбластьТиповойОтвет 	= МакетАнкетыДляПечати.Область("R6");
			ОбластьВариантОтвета 	= МакетАнкетыДляПечати.Область("R7");
				
			ДокументМакет.ВставитьОбласть(ОбластьВопрос, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Истина);
			ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1").Текст 	= "№" + ВыборкаЗапросаПоВопросам.НомерСтрокиВАнкете + ". " + ?(ВыборкаЗапросаПоВопросам.ПолнаяФормулировка = "", ВыборкаЗапросаПоВопросам.ВопросПредставление, ВыборкаЗапросаПоВопросам.ПолнаяФормулировка);
				
			Если ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Дата или
				ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Число или
				ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Строка или
				ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Булево тогда
				НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
				ДокументМакет.ВставитьОбласть(ОбластьТиповойОтвет, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Ложь);
				ДокументМакет.Область("R"+НомерСтрокиВМакете+"C2").Заполнение = ТипЗаполненияОбластиТабличногоДокумента.Параметр;
				ДокументМакет.Область("R"+НомерСтрокиВМакете+"C2").Параметр	= "ТиповойОтвет" + ВыборкаЗапросаПоВопросам.КодВопроса;
				
			ИначеЕсли ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.ОдинИзВариантовОтвета или 
				ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.НесколькоВариантовОтвета тогда
				ВыборкаЗапросаПоВариантамОтвета = ВыборкаЗапросаПоВопросам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "");
				Пока ВыборкаЗапросаПоВариантамОтвета.Следующий() Цикл
					НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
					ДокументМакет.ВставитьОбласть(ОбластьВариантОтвета, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Ложь);
					ДокументМакет.Область("R"+НомерСтрокиВМакете+"C2").Имя = "Вопрос" + ВыборкаЗапросаПоВариантамОтвета.КодВопроса + "ВариантОтвета" + ВыборкаЗапросаПоВариантамОтвета.КодВариантаОтвета;
					ДокументМакет.Область("R"+НомерСтрокиВМакете+"C3").Заполнение = ТипЗаполненияОбластиТабличногоДокумента.Текст;
					ДокументМакет.Область("R"+НомерСтрокиВМакете+"C3").Параметр	= ВыборкаЗапросаПоВариантамОтвета.ВариантОтветаПредставление;
				КонецЦикла;
				
			ИначеЕсли ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Табличный тогда
				ВыборкаЗапросаПоКолонкамТаблицы = ВыборкаЗапросаПоВопросам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "");
				// формируем шапку таблицы
				НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
				НомерКолонки = 0;
				НомерКолонкиМакетаЛев = 0;
				НомерКолонкиМакетаПрав = 1;
				Пока ВыборкаЗапросаПоКолонкамТаблицы.Следующий() Цикл
					ОбластьШаблонКолонки = МакетАнкетыДляПечати.Область("R8C3");//МакетАнкетыДляПечати.Области.ШаблонКолонки;
					НомерКолонки = НомерКолонки + 1;
					НомерКолонкиМакетаЛев = НомерКолонкиМакетаЛев + 1;
					НомерКолонкиМакетаПрав = НомерКолонкиМакетаПрав + 1;
					Если НомерКолонкиМакетаЛев = 2 тогда
						НомерКолонкиМакетаЛев = НомерКолонкиМакетаЛев + 1;
					КонецЕсли;
					Если НомерКолонкиМакетаПрав = 1 тогда
						НомерКолонкиМакетаПрав = НомерКолонкиМакетаПрав + 1;
					КонецЕсли;
					ОбластьШаблонКолонкиДокумент					= ДокументМакет.Область("R"+НомерСтрокиВМакете+"C"+НомерКолонкиМакетаЛев+":R"+НомерСтрокиВМакете+"C"+НомерКолонкиМакетаПрав);
					ОбластьШаблонКолонкиДокумент.Объединить();
					ОбластьШаблонКолонкиДокумент.Текст				= ВыборкаЗапросаПоКолонкамТаблицы.КолонкаТаблицыПредставление;
					ОбластьШаблонКолонкиДокумент.Имя				= "Вопрос" + ВыборкаЗапросаПоКолонкамТаблицы.КодВопроса + "КолонкаТаблицы" + НомерКолонки;
					ОбластьШаблонКолонкиДокумент.Шрифт				= ОбластьШаблонКолонки.Шрифт;
					ОбластьШаблонКолонкиДокумент.РазмещениеТекста	= ТипРазмещенияТекстаТабличногоДокумента.Переносить;
					ЛинияРамки = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
					ОбластьШаблонКолонкиДокумент.ГраницаСлева	= ЛинияРамки;
					ОбластьШаблонКолонкиДокумент.ГраницаСправа	= ЛинияРамки;
					ОбластьШаблонКолонкиДокумент.ГраницаСверху	= ЛинияРамки;
					ОбластьШаблонКолонкиДокумент.ГраницаСнизу	= ЛинияРамки;
				КонецЦикла;
				// формируем строки таблицы
				КоличествоСтрокТаблицы = ВыборкаЗапросаПоВопросам.ВопросКоличествоСтрокТаблицы;
				НомерШапкиВМакете = НомерСтрокиВМакете;
				Для индСтрокиТаблицы = 1 По КоличествоСтрокТаблицы Цикл
					ОбластьШаблонСтрокиТаблицыДокумент	= ДокументМакет.ПолучитьОбласть("R"+НомерШапкиВМакете);
					ОбластиСтрокиТаблицы = ОбластьШаблонСтрокиТаблицыДокумент.Области;
					индОбласти = 0;
					МассивОбластей = Новый Массив();
					Для Каждого ОбластьСтрокиТаблицы Из ОбластиСтрокиТаблицы Цикл
						МассивОбластей.Добавить(ОбластьСтрокиТаблицы);
					КонецЦикла;
					Для Каждого ОбластьСтрокиТаблицы Из МассивОбластей Цикл
						ИмяОбласти = ОбластьСтрокиТаблицы.Имя;
						Если Найти(ИмяОбласти, "Строка") > 0 Тогда
							Продолжить;
						КонецЕсли;
						ИмяОбласти = СтрЗаменить(ИмяОбласти, "КолонкаТаблицы", "ОтветТаблицы");
						ИмяОбласти = ИмяОбласти+"Строка"+индСтрокиТаблицы;
						ОбластьСтрокиТаблицы.Текст		= "";
						ОбластьСтрокиТаблицы.Заполнение	= ТипЗаполненияОбластиТабличногоДокумента.Параметр;
						ОбластьСтрокиТаблицы.Параметр	= ИмяОбласти;
					КонецЦикла;
					НомерСтрокиВМакете		= НомерСтрокиВМакете + 1;
					ОбластьСтрокаТаблицы	= ОбластьШаблонСтрокиТаблицыДокумент.Область("R1");
					ДокументМакет.ВставитьОбласть(ОбластьСтрокаТаблицы, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Ложь);
				КонецЦикла;
				НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
				
			Иначе
				НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
				ДокументМакет.ВставитьОбласть(ОбластьТиповойОтвет, ДокументМакет.Область("R"+НомерСтрокиВМакете+"C1"), , Ложь);
				ДокументМакет.Область("R"+НомерСтрокиВМакете+"C2").Параметр	= "ТиповойОтвет" + ВыборкаЗапросаПоВопросам.КодВопроса;
				
			КонецЕсли;
				
			НомерСтрокиВМакете = НомерСтрокиВМакете + 1;
		КонецЦикла;
	КонецЦикла; // по разделам
	
	ДокументМакет.Область("C2").ШиринаКолонки = 3;
	
	ПараметрыМакета = ДокументМакет.Параметры;
	
	Возврат ДокументМакет;
	
КонецФункции // СформироватьМакет()

// Восстанавливает сохраненный ранее макет анкеты
//
// Параметры:
//	Нет.
//
// Возвращаемое значение:
//	Табличный документ, содержащий последний сохраненный вариант анкеты .
//
Функция ВосстановитьМакет() Экспорт
		
	ТабличныйДокумент = МакетАнкеты.Получить();
		
	Если ТипЗнч(ТабличныйДокумент) = Тип("ТабличныйДокумент") Тогда
		Возврат ТабличныйДокумент;
		
	Иначе
		Возврат Новый ТабличныйДокумент;
		
	КонецЕсли;
		
КонецФункции // ВосстановитьМакет()

// Сохраняет макет анкеты
//
Процедура СохранитьМакет(ТабличныйДокумент) Экспорт
		
	НовыйТабДок = Новый ТабличныйДокумент();
	НовыйТабДок.ВставитьОбласть(ТабличныйДокумент.Область(), НовыйТабДок.Область(), , Ложь);
		
	МакетАнкеты = Новый ХранилищеЗначения(НовыйТабДок, Новый СжатиеДанных());
		
КонецПроцедуры // СохранитьМакет()

// Процедура выводит на экран печатную форму анкеты
//
// Параметры:
//	Нет
//
// Возвращаемое значение:
//	Нет.
//
Процедура Печать() Экспорт
		
	ПечатныйДокумент = Новый ТабличныйДокумент;
	ПечатныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ТиповыеАнкеты";
	ПечатныйДокумент.Вывести(ВосстановитьМакет());
	
	// если макет еще был заполнен - сформируем его по умолчанию
	Если ПечатныйДокумент.ВысотаТаблицы = 0 Тогда
		ПечДок = Новый ТабличныйДокумент;
		СформироватьМакет(ПечДок);
		ПечатныйДокумент.Вывести(ПечДок);
	КонецЕсли;
	
	ПечатныйДокумент.Автомасштаб = Истина;
	УниверсальныеМеханизмы.НапечататьДокумент(ПечатныйДокумент,,,);
	
КонецПроцедуры // Печать()

#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
