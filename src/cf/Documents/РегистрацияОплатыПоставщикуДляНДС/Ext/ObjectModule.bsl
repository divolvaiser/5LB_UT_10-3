﻿Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;

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
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ АВТОЗАПОЛНЕНИЯ ТАБЛИЧНОЙ ЧАСТИ ДОКУМЕНТА

// Вызавается из процедуры ЗаполнитьСтрокиРаспределенияОплат
//
Функция ПолучитьРасшифровкуПлатежа(Документ, РасшифровкаПлатежаПоДокументам)
	Если РасшифровкаПлатежаПоДокументам[Документ] = Неопределено Тогда
		СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(Документ);
		МетаданныеДокумента = Документ.Метаданные();
		Если МетаданныеДокумента.ТабличныеЧасти.Найти("РасшифровкаПлатежа") <> Неопределено Тогда
			Расшифровка = Документ.РасшифровкаПлатежа.Выгрузить();
			Расшифровка.Индексы.Добавить("ДоговорКонтрагента");
		ИначеЕсли МетаданныеДокумента.ТабличныеЧасти.Найти("ОплатаПоставщикам") <> Неопределено Тогда
			Расшифровка = Документ.ОплатаПоставщикам.Выгрузить();
			Расшифровка.Индексы.Добавить("ДоговорКонтрагента");
		Иначе
			Расшифровка = Ложь; 
		КонецЕсли;

		РасшифровкаПлатежаПоДокументам.Вставить(Документ, Расшифровка);
	КонецЕсли; 
	
	Возврат РасшифровкаПлатежаПоДокументам[Документ];

КонецФункции // ПолучитьРасшифровкуПлатежа(СтрокаРасчетов.Документ)()

// Вызавается из процедуры ЗаполнитьСтрокиРаспределенияОплат
//
Функция ПолучитьДокументыРасчетовСКонтрагентом(Документ, ДокументыРасчетовСКонтрагентомПоДокументам)
	Если ДокументыРасчетовСКонтрагентомПоДокументам[Документ] = Неопределено Тогда
		МетаданныеДокумента = Документ.Метаданные();
		Если МетаданныеДокумента.ТабличныеЧасти.Найти("ДокументыРасчетовСКонтрагентом") <> Неопределено Тогда
			Расшифровка = Документ.ДокументыРасчетовСКонтрагентом.Выгрузить();
		Иначе
			Расшифровка = Ложь; 
		КонецЕсли;

		ДокументыРасчетовСКонтрагентомПоДокументам.Вставить(Документ, Расшифровка);
	КонецЕсли; 
	
	Возврат ДокументыРасчетовСКонтрагентомПоДокументам[Документ];

КонецФункции // ПолучитьРасшифровкуПлатежа(СтрокаРасчетов.Документ)()
 
// Процедура вызывается по кнопке "Заполнить" в форме диалога документа.
// В процедуре реализуется алгоритм автоматического заполнения строк табличной части документа.
//
Процедура ЗаполнитьСтрокиРаспределенияОплат() Экспорт 
	
	ТаблицаРезультатов = Состав.ВыгрузитьКолонки();
	
	НераспределенныеРасчеты = ПолучитьИнформациюПоНепогашеннойЗадолженностиИНераспределеннымОплатам();
	
	Если НераспределенныеРасчеты.Строки.Количество()=0 Тогда
		// Дальнейшая обработка не требуется, не обнаружены нераспределенные расчеты.
		Состав.Очистить();
		Возврат;
	КонецЕсли;
	
	НепогашеннаяЗадолженность = новый ТаблицаЗначений();
	НепогашеннаяЗадолженность.Колонки.Добавить("ДатаДокумента", ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	НепогашеннаяЗадолженность.Колонки.Добавить("Документ", 		Документы.ТипВсеСсылки());
	НепогашеннаяЗадолженность.Колонки.Добавить("Сделка", 		Документы.ТипВсеСсылки());
	НепогашеннаяЗадолженность.Колонки.Добавить("Сумма",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	НепогашеннаяЗадолженность.Колонки.Добавить("Валюта",		Новый ОписаниеТипов("СправочникСсылка.Валюты"));
	НепогашеннаяЗадолженность.Колонки.Добавить("ВалютнаяСумма",	ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	
	НепогашеннаяЗадолженность.Индексы.Добавить("Документ");
	
	НераспределенныеОплаты  = НепогашеннаяЗадолженность.Скопировать();
	
	// Временное хранение расшифровок платежа по документа оплаты (при ведении расчетов по документам)
	РасшифровкаПлатежаПоДокументам = новый Соответствие;
	ДокументыРасчетовСКонтрагентомПоДокументам = новый Соответствие;
	
	Для каждого РасчетыПоДоговору Из НераспределенныеРасчеты.Строки Цикл
		РасчетыВВалютеРегУчета = (НЕ ЗначениеЗаполнено(РасчетыПоДоговору.ВалютаВзаиморасчетов) или РасчетыПоДоговору.ВалютаВзаиморасчетов = мВалютаРегламентированногоУчета);
		КолонкаЗачета = ?(РасчетыВВалютеРегУчета,"Сумма","ВалютнаяСумма");
		КолонкаРаспределения = ?(РасчетыВВалютеРегУчета,"ВалютнаяСумма","Сумма");
		
		Если РасчетыПоДоговору[КолонкаЗачета] = 0 или РасчетыПоДоговору["Оплата"+КолонкаЗачета] = 0 Тогда
			// Не обнаружена непогашенная задолженность или нераспределенная оплата
			Продолжить;
		КонецЕсли; 
		НепогашеннаяЗадолженность.Очистить();
		НераспределенныеОплаты.Очистить();
		
		ПроводитьОтборПоСделке = РасчетыПоДоговору.ВедениеВзаиморасчетов <> Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
		ПроводитьОтборПоСделкеРасшифровки = РасчетыПоДоговору.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоЗаказам;
		ПроводитьОтборПоДокументуРасчетов = РасчетыПоДоговору.ВестиПоДокументамРасчетовСКонтрагентом;
		
		Для каждого СтрокаРасчетов  Из РасчетыПоДоговору.Строки Цикл
			Если СтрокаРасчетов.ЭтоОплата Тогда
				Если не НепогашеннаяЗадолженность.Итог(КолонкаЗачета) = 0 Тогда
					
					РасшифровкаПлатежа = Ложь;
					Если ПроводитьОтборПоДокументуРасчетов Тогда
						РасшифровкаПлатежа = ПолучитьРасшифровкуПлатежа(СтрокаРасчетов.Документ, РасшифровкаПлатежаПоДокументам);
					КонецЕсли;
					Если не РасшифровкаПлатежа = Ложь Тогда
						СтруктураОтбораРасшифровки = Новый Структура("ДоговорКонтрагента",СтрокаРасчетов.ДоговорКонтрагента);
						Если ПроводитьОтборПоСделкеРасшифровки Тогда
							СтруктураОтбораРасшифровки.Вставить("Сделка", СтрокаРасчетов.Сделка); 
						КонецЕсли;
						
						СтрокиПоДоговору = РасшифровкаПлатежа.НайтиСтроки(СтруктураОтбораРасшифровки);
						Для каждого СтрокаПоДоговору Из СтрокиПоДоговору Цикл
							Если СтрокаПоДоговору.СуммаВзаиморасчетов = 0  Тогда
								Продолжить;
							ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаПоДоговору.ДокументРасчетовСКонтрагентом) Тогда
								Продолжить;
							КонецЕсли; 
							
							СтруктураОтбораЗадолженности = новый структура("Документ",СтрокаПоДоговору.ДокументРасчетовСКонтрагентом);
							Если ПроводитьОтборПоСделке Тогда
								СтруктураОтбораЗадолженности.Вставить("Сделка", СтрокаРасчетов.Сделка); 
							КонецЕсли;
							
							СтрокиЗадолженностиПоОтбору = НепогашеннаяЗадолженность.НайтиСтроки(СтруктураОтбораЗадолженности);
							Для каждого СтрокаЗадолженности Из СтрокиЗадолженностиПоОтбору Цикл
								СуммаЗачета = Макс(0,мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаЗадолженности.ВалютнаяСумма,СтрокаРасчетов.ОплатаВалютнаяСумма));
								
								Если СуммаЗачета = 0 Тогда
									Продолжить;
								КонецЕсли; 
								
								СтрокаРаспределения = ТаблицаРезультатов.Добавить();
								СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
								СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
								СтрокаРаспределения.СчетФактура			= СтрокаЗадолженности.Документ;
								СтрокаРаспределения.ЗачетАванса			= Ложь;
								СтрокаРаспределения.ДатаОплаты			= СтрокаРасчетов.ДатаДокумента;
								СтрокаРаспределения.ДокументОплаты		= СтрокаРасчетов.Документ;
								СтрокаРаспределения.ВалютаРасчетов		= СтрокаРасчетов.Валюта;
								СтрокаРаспределения.Сделка				= СтрокаРасчетов.Сделка;
								
								СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
								СтрокаРаспределения[КолонкаРаспределения]=  Окр(СтрокаЗадолженности[КолонкаРаспределения]*СуммаЗачета/СтрокаЗадолженности[КолонкаЗачета],2);
								
								СтрокаРасчетов["Оплата"+КолонкаРаспределения]	= СтрокаРасчетов["Оплата"+КолонкаРаспределения] - Окр(СтрокаРасчетов["Оплата"+КолонкаРаспределения]*СуммаЗачета/СтрокаРасчетов["Оплата"+КолонкаЗачета],2);
								СтрокаЗадолженности[КолонкаРаспределения]= СтрокаЗадолженности[КолонкаРаспределения] - СтрокаРаспределения[КолонкаРаспределения];
								СтрокаРасчетов["Оплата"+КолонкаЗачета]	= СтрокаРасчетов["Оплата"+КолонкаЗачета] - СуммаЗачета;
								СтрокаЗадолженности[КолонкаЗачета]		= СтрокаЗадолженности[КолонкаЗачета] - СуммаЗачета;
								
								СтрокаПоДоговору.СуммаВзаиморасчетов = СтрокаПоДоговору.СуммаВзаиморасчетов - СуммаЗачета;
								
							КонецЦикла; 
							
						КонецЦикла; 
						
					Иначе
						Для каждого СтрокаЗадолженности Из НепогашеннаяЗадолженность Цикл
							Если СтрокаЗадолженности[КолонкаЗачета] = 0 Тогда
								Продолжить;
							КонецЕсли;
							Если ПроводитьОтборПоСделке 
								И Не СтрокаЗадолженности.Сделка = СтрокаРасчетов.Сделка тогда
								Продолжить;
							КонецЕсли;
							
							СуммаЗачета = Макс(0,мин(СтрокаЗадолженности[КолонкаЗачета], СтрокаРасчетов["Оплата"+КолонкаЗачета]));
							Если СуммаЗачета = 0 Тогда
								Продолжить;
							КонецЕсли; 
							
							СтрокаРаспределения = ТаблицаРезультатов.Добавить();
							СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
							СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
							СтрокаРаспределения.СчетФактура			= СтрокаЗадолженности.Документ;
							СтрокаРаспределения.ЗачетАванса			= Ложь;
							СтрокаРаспределения.ДатаОплаты			= СтрокаРасчетов.ДатаДокумента;
							СтрокаРаспределения.ДокументОплаты		= СтрокаРасчетов.Документ;
							СтрокаРаспределения.ВалютаРасчетов		= СтрокаРасчетов.Валюта;
							СтрокаРаспределения.Сделка				= СтрокаРасчетов.Сделка;
							
							СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
							СтрокаРаспределения[КолонкаРаспределения]=  Окр(СтрокаЗадолженности[КолонкаРаспределения]*СуммаЗачета/СтрокаЗадолженности[КолонкаЗачета],2);
							
							
							СтрокаРасчетов["Оплата"+КолонкаРаспределения]	= СтрокаРасчетов["Оплата"+КолонкаРаспределения] - Окр(СтрокаРасчетов["Оплата"+КолонкаРаспределения]*СуммаЗачета/СтрокаРасчетов["Оплата"+КолонкаЗачета],2);
							СтрокаЗадолженности[КолонкаРаспределения]= СтрокаЗадолженности[КолонкаРаспределения] - СтрокаРаспределения[КолонкаРаспределения];
							СтрокаРасчетов["Оплата"+КолонкаЗачета]	= СтрокаРасчетов["Оплата"+КолонкаЗачета] - СуммаЗачета;
							СтрокаЗадолженности[КолонкаЗачета]		= СтрокаЗадолженности[КолонкаЗачета] - СуммаЗачета;
							
						КонецЦикла; 
						
					КонецЕсли;
					
					
				КонецЕсли; 
				Если не СтрокаРасчетов["Оплата"+КолонкаЗачета] = 0 Тогда
					НераспределеннаяСтрока = НераспределенныеОплаты.Добавить();
					НераспределеннаяСтрока.ДатаДокумента	= СтрокаРасчетов.ДатаДокумента;
					НераспределеннаяСтрока.Документ			= СтрокаРасчетов.Документ;
					НераспределеннаяСтрока.Сумма			= СтрокаРасчетов.ОплатаСумма;
					НераспределеннаяСтрока.Валюта			= СтрокаРасчетов.Валюта;
					НераспределеннаяСтрока.ВалютнаяСумма	= СтрокаРасчетов.ОплатаВалютнаяСумма;
					НераспределеннаяСтрока.Сделка			= СтрокаРасчетов.Сделка;
				КонецЕсли; 
				
			Иначе	
				Если не НераспределенныеОплаты.Итог(КолонкаЗачета)=0 
					//и не (ПроводитьОтборПоСделке и НЕ ЗначениеЗаполнено(СтрокаРасчетов.Сделка))
					Тогда
					
					РасшифровкаПлатежа = Ложь;
					Если ПроводитьОтборПоДокументуРасчетов Тогда
						РасшифровкаПлатежа = ПолучитьДокументыРасчетовСКонтрагентом(СтрокаРасчетов.Документ, ДокументыРасчетовСКонтрагентомПоДокументам);
					КонецЕсли;
					Если не РасшифровкаПлатежа = Ложь Тогда
						
						Если ПроводитьОтборПоСделкеРасшифровки Тогда
							СтрокиПоДоговору = РасшифровкаПлатежа.НайтиСтроки(Новый Структура("Сделка", СтрокаРасчетов.Сделка));
						Иначе
							СтрокиПоДоговору = РасшифровкаПлатежа;	
						КонецЕсли;
						
						Для каждого СтрокаПоДоговору Из СтрокиПоДоговору Цикл
							Если СтрокаПоДоговору.СуммаВзаиморасчетов = 0  Тогда
								Продолжить;
							КонецЕсли; 
							
							СтруктураОтбораОплат = новый структура("Документ",СтрокаПоДоговору.ДокументРасчетовСКонтрагентом);
							
							Если ПроводитьОтборПоСделке Тогда
								СтруктураОтбораОплат.Вставить("Сделка", СтрокаРасчетов.Сделка); 
							КонецЕсли;
							
							СтрокиОплатПоОтбору = НераспределенныеОплаты.НайтиСтроки(СтруктураОтбораОплат);
							Для каждого СтрокаОплаты Из СтрокиОплатПоОтбору Цикл
								Если СтрокаОплаты[КолонкаЗачета] = 0 Тогда
									Продолжить;
								КонецЕсли; 
								
								СуммаЗачета = Макс(0,мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаОплаты.ВалютнаяСумма,СтрокаРасчетов.ВалютнаяСумма));
								
								Если СуммаЗачета = 0 Тогда
									Продолжить;
								КонецЕсли; 
								
								СтрокаРаспределения = ТаблицаРезультатов.Добавить();
								СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
								СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
								СтрокаРаспределения.СчетФактура			= СтрокаРасчетов.Документ;
								СтрокаРаспределения.ЗачетАванса			= Истина;
								СтрокаРаспределения.ДатаОплаты			= СтрокаОплаты.ДатаДокумента;
								СтрокаРаспределения.ДокументОплаты		= СтрокаОплаты.Документ;
								СтрокаРаспределения.ВалютаРасчетов		= СтрокаРасчетов.Валюта;
								СтрокаРаспределения.Сделка				= СтрокаРасчетов.Сделка;
								
								СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
								СтрокаРаспределения[КолонкаРаспределения]=  Окр(СтрокаРасчетов[КолонкаРаспределения]*СуммаЗачета/СтрокаРасчетов[КолонкаЗачета],2);
								
								
								СтрокаРасчетов[КолонкаРаспределения]	= СтрокаРасчетов[КолонкаРаспределения] - СтрокаРаспределения[КолонкаРаспределения];
								СтрокаОплаты[КолонкаРаспределения]		= СтрокаОплаты[КолонкаРаспределения] - Окр(СтрокаОплаты[КолонкаРаспределения]*СуммаЗачета/СтрокаОплаты[КолонкаЗачета],2);
								СтрокаРасчетов[КолонкаЗачета]			= СтрокаРасчетов[КолонкаЗачета] - СуммаЗачета;
								СтрокаОплаты[КолонкаЗачета]				= СтрокаОплаты[КолонкаЗачета] - СуммаЗачета;
								
								СтрокаПоДоговору.СуммаВзаиморасчетов = СтрокаПоДоговору.СуммаВзаиморасчетов - СуммаЗачета;
								
							КонецЦикла;
						КонецЦикла;
					Иначе
						Для каждого СтрокаОплаты Из НераспределенныеОплаты Цикл
							Если СтрокаОплаты[КолонкаЗачета] = 0 Тогда
								Продолжить;
							ИначеЕсли ПроводитьОтборПоСделке и не СтрокаРасчетов.Сделка = СтрокаОплаты.Сделка Тогда
								Продолжить;
							КонецЕсли; 
							
							СуммаЗачета = Макс(0,мин(СтрокаОплаты[КолонкаЗачета], СтрокаРасчетов[КолонкаЗачета]));
							Если СуммаЗачета = 0 Тогда
								Продолжить;
							КонецЕсли; 
							
							СтрокаРаспределения = ТаблицаРезультатов.Добавить();
							СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
							СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
							СтрокаРаспределения.СчетФактура			= СтрокаРасчетов.Документ;
							СтрокаРаспределения.ЗачетАванса			= Истина;
							СтрокаРаспределения.ДатаОплаты			= СтрокаОплаты.ДатаДокумента;
							СтрокаРаспределения.ДокументОплаты		= СтрокаОплаты.Документ;
							СтрокаРаспределения.ВалютаРасчетов		= СтрокаРасчетов.Валюта;
							СтрокаРаспределения.Сделка				= СтрокаРасчетов.Сделка;
							
							СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
							СтрокаРаспределения[КолонкаРаспределения]=  Окр(СтрокаРасчетов[КолонкаРаспределения]*СуммаЗачета/СтрокаРасчетов[КолонкаЗачета],2);
							
							
							СтрокаРасчетов[КолонкаРаспределения]	= СтрокаРасчетов[КолонкаРаспределения] - СтрокаРаспределения[КолонкаРаспределения];
							СтрокаОплаты[КолонкаРаспределения]		= СтрокаОплаты[КолонкаРаспределения] - Окр(СтрокаОплаты[КолонкаРаспределения]*СуммаЗачета/СтрокаОплаты[КолонкаЗачета],2);
							СтрокаРасчетов[КолонкаЗачета]			= СтрокаРасчетов[КолонкаЗачета] - СуммаЗачета;
							СтрокаОплаты[КолонкаЗачета]				= СтрокаОплаты[КолонкаЗачета] - СуммаЗачета;
						КонецЦикла; 
					КонецЕсли;
					
					
				КонецЕсли; 
				
				Если не СтрокаРасчетов[КолонкаЗачета] = 0 Тогда
					НераспределеннаяСтрока = НепогашеннаяЗадолженность.Добавить();
					НераспределеннаяСтрока.ДатаДокумента	= СтрокаРасчетов.ДатаДокумента;
					НераспределеннаяСтрока.Документ			= СтрокаРасчетов.Документ;
					НераспределеннаяСтрока.Сумма			= СтрокаРасчетов.Сумма;
					НераспределеннаяСтрока.Валюта			= СтрокаРасчетов.Валюта;
					НераспределеннаяСтрока.ВалютнаяСумма	= СтрокаРасчетов.ВалютнаяСумма;
					НераспределеннаяСтрока.Сделка			= СтрокаРасчетов.Сделка;
				КонецЕсли; 
				
			КонецЕсли; 
			
			
		КонецЦикла; 
	КонецЦикла; 	
	
	Состав.Загрузить(ТаблицаРезультатов);
	
КонецПроцедуры // ЗаполнитьСтрокиРаспределенияОплат()

// Функция вызывается из процедуры "ЗаполнитьСтрокиРаспределенияОплат".
// Формирует таблицу непогашенной задолженности по органнизации по данным регистра "НДСРасчетыСПоставщиками".
// Возвращаемое значение:
//   ДеревоЗначений - Дерево непогашенной задолженности и нераспределенной оплаты в разрезе договоров
//
Функция ПолучитьИнформациюПоНепогашеннойЗадолженностиИНераспределеннымОплатам()
    Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик КАК Поставщик,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента КАК ДоговорКонтрагента,
		|	НДСРасчетыСПоставщикамиОстатки.Документ КАК Документ,
		|	НДСРасчетыСПоставщикамиОстатки.Документ.Дата КАК ДатаДокумента,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов КАК Валюта,
		|	СУММА(НДСРасчетыСПоставщикамиОстатки.СуммаОстаток) КАК Сумма,
		|	СУММА(НДСРасчетыСПоставщикамиОстатки.ВалютнаяСуммаОстаток) КАК ВалютнаяСумма,
		|	СУММА(0) КАК ОплатаСумма,
		|	СУММА(0) КАК ОплатаВалютнаяСумма,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах, ЛОЖЬ) КАК РасчетыВУсловныхЕдиницах,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВедениеВзаиморасчетов КАК ВедениеВзаиморасчетов,
		|	ЛОЖЬ КАК ЭтоОплата,
		|	НДСРасчетыСПоставщикамиОстатки.Сделка,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВестиПоДокументамРасчетовСКонтрагентом, ЛОЖЬ) КАК ВестиПоДокументамРасчетовСКонтрагентом,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК ВалютаВзаиморасчетов
		|ИЗ
		|	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(
		|		&КонецПериода,
		|		Организация = &Организация
		|			И РасчетыСБюджетом = ЛОЖЬ) КАК НДСРасчетыСПоставщикамиОстатки
		|ГДЕ
		|	ВЫБОР
		|			КОГДА НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах
		|				ТОГДА НДСРасчетыСПоставщикамиОстатки.СуммаОстаток > 0
		|			ИНАЧЕ НДСРасчетыСПоставщикамиОстатки.ВалютнаяСуммаОстаток > 0
		|		КОНЕЦ
		|
		|СГРУППИРОВАТЬ ПО
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
		|	НДСРасчетыСПоставщикамиОстатки.Документ,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов,
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.Документ.Дата,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВедениеВзаиморасчетов,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВестиПоДокументамРасчетовСКонтрагентом, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.Сделка,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
		|	НДСРасчетыСПоставщикамиОстатки.Документ,
		|	ВЫБОР
		|		КОГДА НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты ЕСТЬ NULL 
		|			ТОГДА НДСРасчетыСПоставщикамиОстатки.Документ.Дата
		|		ИНАЧЕ ВЫБОР
		|				КОГДА НАЧАЛОПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты, ДЕНЬ) = НАЧАЛОПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.Дата, ДЕНЬ)
		|						И &ИспользоватьВремяДокумента
		|					ТОГДА НДСРасчетыСПоставщикамиОстатки.Документ.Дата
		|				ИНАЧЕ КОНЕЦПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты, ДЕНЬ)
		|			КОНЕЦ
		|	КОНЕЦ,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов,
		|	СУММА(0),
		|	СУММА(0),
		|	СУММА(-1 * НДСРасчетыСПоставщикамиОстатки.СуммаОстаток),
		|	СУММА(-1 * НДСРасчетыСПоставщикамиОстатки.ВалютнаяСуммаОстаток),
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВедениеВзаиморасчетов,
		|	ИСТИНА,
		|	НДСРасчетыСПоставщикамиОстатки.Сделка,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВестиПоДокументамРасчетовСКонтрагентом, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов
		|ИЗ
		|	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(
		|		&КонецПериода,
		|		Организация = &Организация
		|			И РасчетыСБюджетом = ЛОЖЬ) КАК НДСРасчетыСПоставщикамиОстатки
		|ГДЕ
		|	ВЫБОР
		|			КОГДА НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах
		|				ТОГДА НДСРасчетыСПоставщикамиОстатки.СуммаОстаток < 0
		|			ИНАЧЕ НДСРасчетыСПоставщикамиОстатки.ВалютнаяСуммаОстаток < 0
		|		КОНЕЦ
		|
		|СГРУППИРОВАТЬ ПО
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик,
		|	НДСРасчетыСПоставщикамиОстатки.Документ,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВедениеВзаиморасчетов,
		|	ЕСТЬNULL(НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВестиПоДокументамРасчетовСКонтрагентом, ЛОЖЬ),
		|	НДСРасчетыСПоставщикамиОстатки.Сделка,
		|	ВЫБОР
		|		КОГДА НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты ЕСТЬ NULL 
		|			ТОГДА НДСРасчетыСПоставщикамиОстатки.Документ.Дата
		|		ИНАЧЕ ВЫБОР
		|				КОГДА НАЧАЛОПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты, ДЕНЬ) = НАЧАЛОПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.Дата, ДЕНЬ)
		|						И &ИспользоватьВремяДокумента
		|					ТОГДА НДСРасчетыСПоставщикамиОстатки.Документ.Дата
		|				ИНАЧЕ КОНЕЦПЕРИОДА(НДСРасчетыСПоставщикамиОстатки.Документ.ДатаОплаты, ДЕНЬ)
		|			КОНЕЦ
		|	КОНЕЦ,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов
		|
		|УПОРЯДОЧИТЬ ПО
		|	ДатаДокумента,
		|	Документ
		|ИТОГИ
		|	СУММА(Сумма),
		|	СУММА(ВалютнаяСумма),
		|	СУММА(ОплатаСумма),
		|	СУММА(ОплатаВалютнаяСумма)
		|ПО
		|	ДоговорКонтрагента";
	
	Запрос.УстановитьПараметр("КонецПериода", Новый Граница(КонецДня(Дата),ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Организация",  Организация);
	
	ПриСовпаденииДатыИДатыОплатыИспользоватьВремяДокумента = ложь;
	
	//Обработка настройки учетной политики орагнизации "Способ отражения платежей погашаемых в течение дня"
	ОшибкаПолученияУчетнойПолитики = Ложь;
	УчетнаяПолитика = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(КонецДня(Дата), ОшибкаПолученияУчетнойПолитики, Организация, "Упр");
	Если не ОшибкаПолученияУчетнойПолитики Тогда
		ПриСовпаденииДатыИДатыОплатыИспользоватьВремяДокумента = (УчетнаяПолитика.ОпределениеВремениПроведенияПлатежногоДокумента = перечисления.СпособыОпределенияВремениПроведенияПлатежногоДокумента.ПоВремениРегистрацииДокумента);
	КонецЕсли; 
	
	Запрос.УстановитьПараметр("ИспользоватьВремяДокумента",  ПриСовпаденииДатыИДатыОплатыИспользоватьВремяДокумента);
	
	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);

КонецФункции // ПолучитьИнформациюПоНепогашеннойЗадолженности()
 
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

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
	
	// Вызовем общую процедуру для проверки проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
//
Функция ПодготовитьТаблицуПоОплатам(РезультатЗапросаПоОплатам)

	ТаблицаОплат = РезультатЗапросаПоОплатам.Выгрузить();
	
	Возврат ТаблицаОплат;

КонецФункции // ПодготовитьТаблицуПоОплатам()

// Проверяет правильность заполнения строк табличной части.
//
//
Процедура ПроверитьЗаполнениеТабличнойЧастиПоОплатам(ТаблицаПоОплатам, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Поставщик,ДоговорКонтрагента, ВалютаРасчетов, СчетФактура, ДокументОплаты");//ВидЦенности, , Событие, СтавкаНДС
	
	// Вызовем общую процедуру для проверки проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Состав", СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

Функция ПолучитьТаблицуЗадолженностиВалютныеДоговора(СтруктураШапкиДокумента, ТаблицаПоОплатам)
	
	МассивСФ = Новый Массив;
	МассивПокупателей = Новый Массив;
	МассивДоговоров = Новый Массив;
	МассивДокументовОплаты = Новый Массив;
	МассивВалют = Новый Массив;
	
	Для Каждого СтрокаТаблицы Из ТаблицаПоОплатам Цикл
		Если //Не СтрокаТаблицы.ДоговорКонтрагента.РасчетыВУсловныхЕдиницах И
			Не СтрокаТаблицы.ВалютаРасчетов = СтруктураШапкиДокумента.ВалютаРегламентированногоУчета Тогда
			МассивДокументовОплаты.Добавить(СтрокаТаблицы.ДокументОплаты);
			МассивПокупателей.Добавить(СтрокаТаблицы.Поставщик);
			МассивДоговоров.Добавить(СтрокаТаблицы.ДоговорКонтрагента);
			МассивВалют.Добавить(СтрокаТаблицы.ВалютаРасчетов);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивДокументовОплаты.Количество() > 0 Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
		|	НДСРасчетыСПоставщикамиОстатки.Документ КАК ДокументОплаты,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов,
		|	СУММА(НДСРасчетыСПоставщикамиОстатки.СуммаОстаток) КАК Сумма,
		|	СУММА(НДСРасчетыСПоставщикамиОстатки.ВалютнаяСуммаОстаток) КАК ВалютнаяСумма
		|ИЗ
		|	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(
		|		&Дата,
		|		Организация = &Организация
		|			И ПОставщик В (&СписокПокупателей)
		|			И ДоговорКонтрагента В (&СписокДоговоров)
		|			И Документ В (&СписокДокументовОплаты)
		|			И ВалютаРасчетов В (&СписокВалют)) КАК НДСРасчетыСПоставщикамиОстатки
		|
		|СГРУППИРОВАТЬ ПО
		|	НДСРасчетыСПоставщикамиОстатки.Организация,
		|	НДСРасчетыСПоставщикамиОстатки.Документ,
		|	НДСРасчетыСПоставщикамиОстатки.ДоговорКонтрагента,
		|	НДСРасчетыСПоставщикамиОстатки.Поставщик,
		|	НДСРасчетыСПоставщикамиОстатки.ВалютаРасчетов";
		
		Запрос.УстановитьПараметр("Дата", Новый Граница(КонецДня(СтруктураШапкиДокумента.Дата), ВидГраницы.Включая));
		Запрос.УстановитьПараметр("Организация", СтруктураШапкиДокумента.Организация);
		Запрос.УстановитьПараметр("СписокПокупателей", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(МассивПокупателей));
		Запрос.УстановитьПараметр("СписокДоговоров", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(МассивДоговоров));
		Запрос.УстановитьПараметр("СписокДокументовОплаты", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(МассивДокументовОплаты));
		Запрос.УстановитьПараметр("СписокВалют", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(МассивВалют));
		
		Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
	
КонецФункции // ПолучитьТаблицуЗадолженностиВалютныеДоговора

// По результату запроса по шапке документа формируем движения по регистрам.
//
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОплатам, Отказ, Заголовок);
	
	ТаблицаДвижений_НДСРасчетыСПоставщиками = Движения.НДСРасчетыСПоставщиками.Выгрузить();
	ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам = Движения.НДСУчетРаспределенныхОплатПоставщикам.Выгрузить();
	
	ТаблицаЗадолженности = ПолучитьТаблицуЗадолженностиВалютныеДоговора(СтруктураШапкиДокумента, ТаблицаПоОплатам);
	Если ТаблицаЗадолженности <> Неопределено Тогда
		ТаблицаЗадолженности.Индексы.Добавить("Поставщик, ДоговорКонтрагента, ДокументОплаты, ВалютаРасчетов");
	КонецЕсли;
	СтруктураОтбора = Новый Структура("Поставщик, ДоговорКонтрагента, ДокументОплаты, ВалютаРасчетов");
	
	Для Каждого ТекСтрокаОплат Из ТаблицаПоОплатам Цикл
		
		// Погашение задолженности
		Движение = ТаблицаДвижений_НДСРасчетыСПоставщиками.Добавить();
		Движение.Период = ?(ТекСтрокаОплат.ЗачетАванса, ТекСтрокаОплат.СчетФактураДата,
							?(НЕ ЗначениеЗаполнено(ТекСтрокаОплат.ДатаОплаты), ТекСтрокаОплат.ДокументОплатыДата, ТекСтрокаОплат.ДатаОплаты));
		Движение.Организация		= СтруктураШапкиДокумента.Организация;
		Движение.Поставщик			= ТекСтрокаОплат.Поставщик;
		Движение.ДоговорКонтрагента	= ТекСтрокаОплат.ДоговорКонтрагента;
		Движение.Документ			= ТекСтрокаОплат.СчетФактура;
		Движение.ВалютаРасчетов		= ТекСтрокаОплат.ВалютаРасчетов;
		Движение.ВалютнаяСумма		= ТекСтрокаОплат.ВалютнаяСумма;
		Движение.Сделка				= ТекСтрокаОплат.Сделка;
		Движение.Сумма 				= ТекСтрокаОплат.Сумма;
		
		//Движение.ДокументОплаты = ТекСтрокаОплат.ДокументОплаты;
		Движение.ДатаСобытия		= СтруктураШапкиДокумента.Дата;
		Движение.ВидДвижения		= ВидДвиженияНакопления.Расход;
		
		// Погашение нераспределенной оплаты
		Движение = ТаблицаДвижений_НДСРасчетыСПоставщиками.Добавить();
		Движение.Период = ?(ТекСтрокаОплат.ЗачетАванса,ТекСтрокаОплат.СчетФактураДата,
							?(НЕ ЗначениеЗаполнено(ТекСтрокаОплат.ДатаОплаты), ТекСтрокаОплат.ДокументОплатыДата, ТекСтрокаОплат.ДатаОплаты));
		Движение.Организация		= СтруктураШапкиДокумента.Организация;
		Движение.Поставщик			= ТекСтрокаОплат.Поставщик;
		Движение.ДоговорКонтрагента = ТекСтрокаОплат.ДоговорКонтрагента;
//		Движение.СчетФактура = 	ТекСтрокаОплат.СчетФактура;
		Движение.Сделка				= ТекСтрокаОплат.Сделка;
		Движение.ВалютаРасчетов		= ТекСтрокаОплат.ВалютаРасчетов;
		
		Движение.Документ			= ТекСтрокаОплат.ДокументОплаты;
		Движение.ДатаСобытия		= СтруктураШапкиДокумента.Дата;
		
		СуммаДвижения = ТекСтрокаОплат.Сумма;
		// Если договор контрагента валютный, то требуется определить сумму списания, которая может быть не равна
		// регистрируемой сумме из-за курсовых разниц
		Если Не ТекСтрокаОплат.ВалютаРасчетов = СтруктураШапкиДокумента.ВалютаРегламентированногоУчета 
			И ТаблицаЗадолженности <> Неопределено 
			Тогда
			ЗаполнитьЗначенияСвойств(СтруктураОтбора, ТекСтрокаОплат);
			СтрокиЗадолженности = ТаблицаЗадолженности.НайтиСтроки(СтруктураОтбора);
			Если СтрокиЗадолженности.Количество() > 0 
				И НЕ СтрокиЗадолженности[0].ВалютнаяСумма = 0 
				Тогда
				СуммаДвижения = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(ТекСтрокаОплат.ВалютнаяСумма,
													ТекСтрокаОплат.ВалютаРасчетов,
													СтруктураШапкиДокумента.ВалютаРегламентированногоУчета,
													СтрокиЗадолженности[0].Сумма/СтрокиЗадолженности[0].ВалютнаяСумма, 1);
			КонецЕсли;
		КонецЕсли;
		
		Если ТекСтрокаОплат.ЗачетАванса Тогда
			Движение.ВалютнаяСумма	= ТекСтрокаОплат.ВалютнаяСумма;
			Движение.Сумма 			= СуммаДвижения;
			Движение.ВидДвижения	= ВидДвиженияНакопления.Приход;
		Иначе
			Движение.ВалютнаяСумма 	= (-1)*ТекСтрокаОплат.ВалютнаяСумма;
			Движение.Сумма 			= (-1)*СуммаДвижения;
			Движение.ВидДвижения	= ВидДвиженияНакопления.Расход;
		КонецЕсли;	
		
		// Отражение распределенной суммы
		Движение = ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам.Добавить();
		Движение.Период = ?(ТекСтрокаОплат.ЗачетАванса, ТекСтрокаОплат.СчетФактураДата,
							?(НЕ ЗначениеЗаполнено(ТекСтрокаОплат.ДатаОплаты), ТекСтрокаОплат.ДокументОплатыДата, ТекСтрокаОплат.ДатаОплаты));
		Движение.Организация = 	СтруктураШапкиДокумента.Организация;
		Движение.СчетФактура		= ТекСтрокаОплат.СчетФактура;
		Движение.ДокументОплаты		= ТекСтрокаОплат.ДокументОплаты;
		
		Движение.РаспределеннаяСумма= ТекСтрокаОплат.Сумма;
		//Движение.КурсоваяРазница	= СуммаДвижения - ТекСтрокаОплат.Сумма;
		
		Движение.ДатаСобытия		= СтруктураШапкиДокумента.Дата;
		Движение.ВидДвижения		= ВидДвиженияНакопления.Приход;
		
	КонецЦикла;
	
	Движения.НДСРасчетыСПоставщиками.мПериод = СтруктураШапкиДокумента.Дата;
	Движения.НДСРасчетыСПоставщиками.мТаблицаДвижений = ТаблицаДвижений_НДСРасчетыСПоставщиками;
	Движения.НДСРасчетыСПоставщиками.ДобавитьДвижение(Ложь);

	Движения.НДСУчетРаспределенныхОплатПоставщикам.мПериод = СтруктураШапкиДокумента.Дата;
	Движения.НДСУчетРаспределенныхОплатПоставщикам.мТаблицаДвижений = ТаблицаДвижений_НДСУчетРаспределенныхОплатПоставщикам;
	Движения.НДСУчетРаспределенныхОплатПоставщикам.ДобавитьДвижение(Ложь);
	
КонецПроцедуры // ДвиженияПоРегистрам()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ
//
Процедура ОбработкаПроведения(Отказ, Режим)

	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ДеревоПолейЗапросаПоШапке = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(Отказ, Заголовок);
	
	// Подготовим данные необходимые для проведения и проверки заполенения табличной части.
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Поставщик",		"Поставщик");
	СтруктураПолей.Вставить("ДоговорКонтрагента","ДоговорКонтрагента");
	СтруктураПолей.Вставить("СчетФактура",		"СчетФактура");
	СтруктураПолей.Вставить("СчетФактураДата",		"СчетФактура.Дата");
	СтруктураПолей.Вставить("ЗачетАванса",		"ЗачетАванса");
	СтруктураПолей.Вставить("ДатаСобытия",		"ДатаОплаты");
	СтруктураПолей.Вставить("ДатаОплаты",		"ДатаОплаты");
	СтруктураПолей.Вставить("ДокументОплаты",	"ДокументОплаты");
	СтруктураПолей.Вставить("ДокументОплатыДата",	"ДокументОплаты.Дата");
	СтруктураПолей.Вставить("Сделка",			"Сделка");
	
	СтруктураПолей.Вставить("ВалютаРасчетов",	"ВалютаРасчетов");
	СтруктураПолей.Вставить("Сумма",	"Сумма");
	СтруктураПолей.Вставить("ВалютнаяСумма",	"ВалютнаяСумма");
	
	РезультатЗапросаПоОплатам = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Состав", СтруктураПолей);
	ТаблицаПоОплатам = 			ПодготовитьТаблицуПоОплатам(РезультатЗапросаПоОплатам);
	
	ПроверитьЗаполнениеТабличнойЧастиПоОплатам(ТаблицаПоОплатам, Отказ, Заголовок);
	
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОплатам, Отказ, Заголовок);
	КонецЕсли;
 
КонецПроцедуры


// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	мУдалятьДвижения = НЕ ЭтоНовый();

КонецПроцедуры // ПередЗаписью()

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);

КонецПроцедуры

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");
