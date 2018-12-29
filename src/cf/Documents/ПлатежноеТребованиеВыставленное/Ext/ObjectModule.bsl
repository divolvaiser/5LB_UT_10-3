﻿Перем мУдалятьДвижения;

// Текущие курс и кратность валюты документа для расчетов
Перем КурсДокумента Экспорт;
Перем КратностьДокумента Экспорт;

Перем мВалютаРегламентированногоУчета Экспорт;
Перем АвтоЗначенияРеквизитов Экспорт;

// Хранят группировочные признаки вида операции
Перем ЕстьРасчетыСКонтрагентами Экспорт;
Перем ЕстьРасчетыПоКредитам Экспорт;

// Хранит таблицу, использующуюся при проведении документа
Перем ТаблицаПлатежейУпр;

//Определение периода движений документа
Перем ДатаДвижений;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Формирует печатную форму 
// платежного поручения
//
// Параметры:
//  ТабДок - табличный документ
//
Функция ПечатьПлатежногоТребования() Экспорт

	Если Организация.Пустая() Тогда
		Сообщить("Не указана организация.", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;

	Если Контрагент.Пустая() Тогда
		Сообщить("Не указан контрагент.", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;
	
	НомерПечать=ОбщегоНазначения.ПолучитьНомерНаПечать(ЭтотОбъект);
	
	Если Прав(НомерПечать,3)="000" Тогда
		Сообщить("Номер платежного требования не может оканчиваться на ""000""!", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПлатежноеТребование_ПлатежноеТребование";
	
	Макет = ПолучитьОбщийМакет("ПлатежноеТребование");
	Обл   = Макет.ПолучитьОбласть("ЗаголовокТаблицы");

	МесяцПрописью   = СчетОрганизации.МесяцПрописью;
	СуммаБезКопеек  = СчетОрганизации.СуммаБезКопеек;
	ФорматДаты      = "ДФ=" + ?(МесяцПрописью = 1,"'дд ММММ гггг'","'дд.ММ.гггг'");
	БанкОрганизации = ?(НЕ ЗначениеЗаполнено(СчетОрганизации.БанкДляРасчетов), СчетОрганизации.Банк, СчетОрганизации.БанкДляРасчетов);
	БанкКонтрагента = ?(НЕ ЗначениеЗаполнено(СчетКонтрагента.БанкДляРасчетов), СчетКонтрагента.Банк, СчетКонтрагента.БанкДляРасчетов);

	Обл.Параметры.НаименованиеНомер       = "ПЛАТЕЖНОЕ ТРЕБОВАНИЕ № " + НомерПечать;
	Обл.Параметры.ДатаДокумента           = Формат(Дата,ФорматДаты);
	Обл.Параметры.ВидПлатежа              = ВидПлатежа;
	Обл.Параметры.СуммаЧислом             = ФорматироватьСумму(СуммаДокумента,СуммаБезКопеек);
	Обл.Параметры.СуммаПрописью           = ФорматироватьСуммуПрописи(СуммаДокумента,СуммаБезКопеек);

	Обл.Параметры.ПлательщикИНН           = "ИНН " + ?(ПустаяСтрока(ИННПлательщика), Контрагент.ИНН, СокрЛП(ИННПлательщика));
	Обл.Параметры.Плательщик              = ?(ПустаяСтрока(ТекстПлательщика),Контрагент.НаименованиеПолное,СокрЛП(ТекстПлательщика));
	Обл.Параметры.БанкПлательщика         = "" + БанкКонтрагента + " " + БанкКонтрагента.Город;

	Обл.Параметры.НомерСчетаПлательщика   = ВернутьРасчетныйСчет(СчетКонтрагента);

	Обл.Параметры.БикБанкаПлательщика     = БанкКонтрагента.Код;
	Обл.Параметры.СчетБанкаПлательщика    = БанкКонтрагента.КоррСчет;

	Обл.Параметры.ПолучательИНН           = "ИНН " + ?(ПустаяСтрока(ИННПолучателя), Организация.ИНН, СокрЛП(ИННПолучателя));
	Обл.Параметры.Получатель              = ?(ПустаяСтрока(ТекстПолучателя),Организация.НаименованиеПолное,СокрЛП(ТекстПолучателя));

	Обл.Параметры.БанкПолучателя          = "" + БанкОрганизации + " " + БанкОрганизации.Город;
	Обл.Параметры.БикБанкаПолучателя      = БанкОрганизации.Код;
	Обл.Параметры.СчетБанкаПолучателя     = БанкОрганизации.КоррСчет;

    Обл.Параметры.НомерСчетаПолучателя    = ВернутьРасчетныйСчет(СчетОрганизации);

	Обл.Параметры.НазначениеПлатежа       = СокрЛП(НазначениеПлатежа);
	Обл.Параметры.Очередность             = ОчередностьПлатежа;

	Обл.Параметры.УсловиеОплаты=""+УсловиеОплаты+?(УсловиеОплаты=Перечисления.УсловияОплатыРасчетныхДокументов.БезАкцепта,Символы.ПС+ОснованиеДляБезакцептногоСписания,"");
	Обл.Параметры.СрокДляАкцепта=?(СрокДляАкцепта>0,СрокДляАкцепта,"");
	Обл.Параметры.ДатаОтсылкиДокументов= Формат(ДатаОтсылкиДокументов,ФорматДаты);

	ТабДокумент.Вывести(Обл);

	Возврат ТабДокумент;

КонецФункции // ПечатьПлатежногоПоручения()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт

	Если ЭтоНовый() Тогда
		Предупреждение("Документ можно распечатать только после его записи");
		Возврат;
	ИначеЕсли Не УправлениеДопПравамиПользователей.РазрешитьПечатьНепроведенныхДокументов(Проведен) Тогда
		Предупреждение("Недостаточно полномочий для печати непроведенного документа!");
		Возврат;
	КонецЕсли;

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

		// Получить экземпляр документа на печать
	Если ИмяМакета = "Платежное требование" ИЛИ ИмяМакета = "ПлатежноеТребование" Тогда

		// Управленческая печатная форма документа
		ТабДокумент = ПечатьПлатежногоТребования();
		
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат;
		КонецЕсли;
	
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("ПлатежноеТребование","Платежное требование");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Форматирует сумму прописью документа
//
// Параметры:
//  СуммаДок - число - реквизит, который надо представить прописью 
//  СуммаБезКопеек - булево - флаг представления суммы без копеек
//
// Возвращаемое значение
//  Отформатированную строку
//
Функция ФорматироватьСуммуПрописи(СуммаДок,СуммаБезКопеек)
	
	Результат     = СуммаДок;
	ЦелаяЧасть    = Цел(СуммаДок);
	ФорматСтрока  = "Л=ru_RU; ДП=Ложь";
	ПарамПредмета = "рубль, рубля, рублей, м, копейка, копейки, копеек, ж";
	
	Если (Результат - ЦелаяЧасть) = 0 Тогда
		Если СуммаБезКопеек Тогда
			Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
			Результат = Лев(Результат,Найти(Результат,"0")-1);
		Иначе
			Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
		КонецЕсли;
	Иначе
		Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции // ФорматироватьСуммуПрописи()

// Форматирует сумму  документа
//
// Параметры:
//  СуммаДок - число - реквизит, который надо отформатировать
//  СуммаБезКопеек - булево - флаг представления суммы без копеек
//
// Возвращаемое значение
//  Отформатированную строку
//
Функция ФорматироватьСумму(СуммаДок,СуммаБезКопеек)
	
	Результат  = СуммаДок;
	ЦелаяЧасть = Цел(СуммаДок);
	
	Если (Результат - ЦелаяЧасть) = 0 Тогда
		Если СуммаБезКопеек Тогда
			Результат = Формат(Результат,"ЧДЦ=2; ЧРД='='; ЧГ=0");
			Результат = Лев(Результат,Найти(Результат,"="));
		Иначе
			Результат = Формат(Результат,"ЧДЦ=2; ЧРД='-'; ЧГ=0");
		КонецЕсли;
	Иначе
		Результат = Формат(Результат,"ЧДЦ=2; ЧРД='-'; ЧГ=0");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции // ФорматироватьСумму()

// Определяет номер расчетного счета по
// переданному банковскому счету
//
// Параметры:
//  СчетКонтра - справочник.БанковскиеСчета
//
// Возвращаемое значение
//  Номер расчетного счета
//
Функция ВернутьРасчетныйСчет(СчетКонтрагента)
	
	БанкДляРасчетов = СчетКонтрагента.БанкДляРасчетов;
	Результат       = ?(БанкДляРасчетов.Пустая(), СчетКонтрагента.НомерСчета, СчетКонтрагента.Банк.КоррСчет);

	Возврат Результат;
	
КонецФункции // ВернутьРасчетныйСчет()

// Формирует структуру полей, обязательных для заполнения при отражении фактического
// движения средств по банку.
//
// Возвращаемое значение:
//   СтруктураОбязательныхПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейОплатаУпр()

	СтруктураПолей=Новый Структура;
	СтруктураПолей.Вставить("СчетОрганизации");
	СтруктураПолей.Вставить("СуммаДокумента");
	СтруктураПолей.Вставить("ДатаОплаты","Не указана дата оплаты документа банком!");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплатаУпр()

// Формирует структуру полей, обязательных для заполнения при отражении операции во 
// взаиморасчетах
// Возвращаемое значение:
//   СтруктурахПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейРасчетыУпр()

	СтруктураПолей = Новый Структура("Организация, Контрагент, СуммаДокумента");
	СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейРасчетыУпр()

// Проверяет значение, необходимое при проведении
Процедура ПроверитьЗначение(Значение, Отказ, Заголовок, ИмяРеквизита)
	
	Если НЕ ЗначениеЗаполнено(Значение) Тогда 
		
		ОбщегоНазначения.СообщитьОбОшибке("Не заполнено значение реквизита """+ИмяРеквизита+"""",Отказ, Заголовок);
		
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗначение()

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧ(Отказ, Заголовок)

	Для Каждого Платеж Из РасшифровкаПлатежа Цикл

		ПроверитьЗначение(Платеж.ДоговорКонтрагента,Отказ, Заголовок,"Договор");
		ПроверитьЗначение(Платеж.СуммаВзаиморасчетов,Отказ, Заголовок,"Сумма взаиморасчетов");
		
		Если Не Отказ Тогда
			
			// Сделка должна быть заполнена, если учет взаиморасчетов ведется по заказам.
			Если Платеж.ДоговорКонтрагента.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоЗаказам Тогда
				
				ТекстСделка=?(УправлениеДенежнымиСредствами.ОпределитьПараметрыВыбораСделки(ВидОперации).ТипЗаказа="ЗаказПокупателя","Заказ покупателя","Заказ поставщику");
				ПроверитьЗначение(Платеж.Сделка,Отказ, Заголовок,ТекстСделка);
				
				Если Отказ Тогда
				
					Сообщить("По договору "+Строка(Платеж.ДоговорКонтрагента)+" установлен способ ведения взаиморасчетов ""по заказам""! 
					|Заполните поле """+ТекстСделка+"""!");
					
				КонецЕсли;
				
			ИначеЕсли Платеж.ДоговорКонтрагента.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоСчетам Тогда
				
				ТекстСделка=?(УправлениеДенежнымиСредствами.ОпределитьПараметрыВыбораСделки(ВидОперации).ТипЗаказа="ЗаказПокупателя","Счет покупателя","Счет поставщику");
				ПроверитьЗначение(Платеж.Сделка,Отказ, Заголовок,ТекстСделка);

				Если Отказ Тогда
					Сообщить("По договору "+Строка(Платеж.ДоговорКонтрагента)+" установлен способ ведения взаиморасчетов ""по счетам""! 
					|Заполните поле """+ТекстСделка+"""!");
				КонецЕсли;
						
			КонецЕсли;

			Если ЗначениеЗаполнено(Организация) 
				И Организация <> Платеж.ДоговорКонтрагента.Организация Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Выбран договор контрагента, не соответствующий организации, указанной в документе!", Отказ, Заголовок);
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры // ПроверитьЗаполнениеТЧ

// Формирует движения по регистрам
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//  Режим 					  - режим проведения документа
//
Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)

	ДвиженияПоРегистрамУпр(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента);

	Если ЕстьРасчетыСКонтрагентами или ЕстьРасчетыПоКредитам Тогда
		ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
	КонецЕсли; 

	//Движения по расчетам для ДНС
	Если ЕстьРасчетыСКонтрагентами и ОтражатьВБухгалтерскомУчете и Оплачено Тогда
		ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, Заголовок)
	
	Если СтруктураШапкиДокумента.ОрганизацияНеЯвляетсяПлательщикомНДС тогда
		// Движения по этому документу делать не нужно
		Возврат;
	КонецЕсли;

	СтруктураПараметров = БухгалтерскийУчетРасчетовСКонтрагентами.ПодготовкаСтруктурыПараметровДляДвиженияДенег(Ссылка, мВалютаРегламентированногоУчета, Заголовок);
	
	Если СтруктураПараметров = Ложь Тогда
	    //Ошибка при подготовке табдлиц. 
		// Указанный вид операции не влияет на расчеты с контрагентами.
		Возврат;
	КонецЕсли; 
	
	БухгалтерскийУчетРасчетовСКонтрагентами.ДвижениеДенег(СтруктураПараметров, ЭтотОбъект);

КонецПроцедуры

Процедура ДвиженияПоРегистрамУпр(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	РасчетыВозврат = УправлениеДенежнымиСредствами.НаправленияДвиженияДляДокументаДвиженияДенежныхСредствУпр(ВидОперации);
	КоэффициентСторно = ?(РасчетыВозврат=Перечисления.РасчетыВозврат.Возврат,-1,1);
	
	РасчетыСКонтрагентами = ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам;
	
	ДвиженияПоСтатьям = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоПланируемымПлатежам = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоРезерву = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоКонтрагентам = ТаблицаПлатежейУпр.Скопировать();
	
	ДвиженияПоПланируемымПлатежам.Свернуть("ДокументПланированияПлатежа,ВключатьВПлатежныйКалендарь,ДоговорКонтрагента,Сделка,ДокументРасчетовСКонтрагентом,ВестиПоДокументамРасчетовСКонтрагентом,СтатьяДвиженияДенежныхСредств,Проект","СуммаПлатежа,СуммаВзаиморасчетов,СуммаПлатежаПлан,СуммаУпр");
	ДвиженияПоКонтрагентам.Свернуть("ДоговорКонтрагента,Сделка,ДокументРасчетовСКонтрагентом,ВидДоговора,КонтролироватьДенежныеСредстваКомитента,Проект","СуммаВзаиморасчетов,СуммаУпр,СуммаРегл,СуммаВзаиморасчетовОстаток,СуммаУпрОстаток");
	ДвиженияПоСтатьям.Свернуть("СтатьяДвиженияДенежныхСредств","СуммаПлатежа");
	ДвиженияПоРезерву.Свернуть("ДокументПланированияПлатежа","СуммаПлатежа");
	
	Если Оплачено Тогда
		
		// По регистру "Денежные средства"
		НаборДвиженийОстатки 		= Движения.ДенежныеСредства;
		ТаблицаДвиженийОстатки 		= НаборДвиженийОстатки.ВыгрузитьКолонки();
		
		// По регистру "Денежные средства к получению"
		НаборДвиженийПолучение   = Движения.ДенежныеСредстваКПолучению;
		ТаблицаДвиженийПолучение = НаборДвиженийПолучение.Выгрузить();
		
		СтрокаКурсыВалют=ТаблицаПлатежейУпр[0];
		
		СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СуммаДокумента, ВалютаДокумента,
											глЗначениеПеременной("ВалютаУправленческогоУчета"), 
											СтрокаКурсыВалют.КурсДокумента,
											СтрокаКурсыВалют.КурсУпрУчета, 
											СтрокаКурсыВалют.КратностьДокумента,
											СтрокаКурсыВалют.КратностьУпрУчета);
		
		СтрокаДвиженийОстатки = ТаблицаДвиженийОстатки.Добавить();
		СтрокаДвиженийОстатки.БанковскийСчетКасса = СчетОрганизации;
		СтрокаДвиженийОстатки.Организация 		  = Организация;
		СтрокаДвиженийОстатки.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
		СтрокаДвиженийОстатки.Сумма               = СуммаДокумента;
		СтрокаДвиженийОстатки.СуммаУпр            = СуммаУпр;
		
		НаборДвиженийОстатки.мПериод              = ДатаДвижений;
		НаборДвиженийОстатки.мТаблицаДвижений     = ТаблицаДвиженийОстатки;
		Движения.ДенежныеСредства.ВыполнитьПриход();
		
		// По регистру "Денежные средства к получению"
		Для Каждого СтрокаДвижение Из ДвиженияПоСтатьям Цикл
			
			СтрокаДвиженийПолучение = ТаблицаДвиженийПолучение.Добавить();
			СтрокаДвиженийПолучение.БанковскийСчетКасса = СчетОрганизации;
			СтрокаДвиженийПолучение.Организация 		  = Организация;
			СтрокаДвиженийПолучение.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
			СтрокаДвиженийПолучение.Сумма               = СтрокаДвижение.СуммаПлатежа;
			СтрокаДвиженийПолучение.ДокументПолучения    = Ссылка;
			СтрокаДвиженийПолучение.СтатьяДвиженияДенежныхСредств=СтрокаДвижение.СтатьяДвиженияДенежныхСредств;
			
		КонецЦикла;
		
		НаборДвиженийПолучение.мПериод              = ДатаДвижений;
		НаборДвиженийПолучение.мТаблицаДвижений     = ТаблицаДвиженийПолучение;
		Движения.ДенежныеСредстваКПолучению.ВыполнитьРасход();
		
		Для Каждого СтрокаРезерв ИЗ ДвиженияПоРезерву Цикл
			
			// Резервируем денежные средства, если приход планировался и по нему размещались заявки
			Если НЕ СтрокаРезерв.ДокументПланированияПлатежа.Пустая() Тогда
				
				Запрос=Новый Запрос;
				Запрос.Текст="ВЫБРАТЬ
				|	РазмещениеЗаявокНаРасходованиеСредствОстатки.ДокументРезервирования КАК Заявка,
				|	РазмещениеЗаявокНаРасходованиеСредствОстатки.СуммаОстаток КАК СуммаОстаток,
				|	РазмещениеЗаявокНаРасходованиеСредствОстатки.ДокументРезервирования.ДатаРасхода КАК ДокументРезервированияДатаРасхода
				|ИЗ
				|	РегистрНакопления.РазмещениеЗаявокНаРасходованиеСредств.Остатки(, ДокументПланирования=&ДокументПланирования) КАК РазмещениеЗаявокНаРасходованиеСредствОстатки
				|
				|УПОРЯДОЧИТЬ ПО
				|	ДокументРезервированияДатаРасхода";
				
				Запрос.УстановитьПараметр("ДокументПланирования",СтрокаРезерв.ДокументПланированияПлатежа);
				
				Результат=Запрос.Выполнить();
				
				Если НЕ Результат.Пустой() Тогда
					
					СуммаРезерв=СтрокаРезерв.СуммаПлатежа;
					
					НаборРазмещение=Движения.РазмещениеЗаявокНаРасходованиеСредств;
					ТаблицаРазмещение=НаборРазмещение.ВыгрузитьКолонки();
					
					НаборРезерв=Движения.ДенежныеСредстваВРезерве;
					ТаблицаРезерв=НаборРезерв.ВыгрузитьКолонки();
					
					Выборка=Результат.Выбрать();
					
					Пока Выборка.Следующий() Цикл
						
						Если Выборка.СуммаОстаток>=СуммаРезерв Тогда
							
							СтрокаРазмещение=ТаблицаРазмещение.Добавить();
							СтрокаРазмещение.ДокументПланирования=СтрокаРезерв.ДокументПланированияПлатежа;
							СтрокаРазмещение.ДокументРезервирования=Выборка.Заявка;
							СтрокаРазмещение.Сумма=СуммаРезерв;
							
							СтрокаРезерв=ТаблицаРезерв.Добавить();
							СтрокаРезерв.БанковскийСчетКасса=СчетОрганизации;
							СтрокаРезерв.Организация = Организация;
							СтрокаРезерв.ВидДенежныхСредств=Перечисления.ВидыДенежныхСредств.Безналичные;
							СтрокаРезерв.ДокументРезервирования=Выборка.Заявка;
							СтрокаРезерв.Сумма=СуммаРезерв;
							
							Прервать;
							
						Иначе
							
							СтрокаРазмещение=ТаблицаРазмещение.Добавить();
							СтрокаРазмещение.ДокументПланирования=СтрокаРезерв.ДокументПланированияПлатежа;
							СтрокаРазмещение.ДокументРезервирования=Выборка.Заявка;
							СтрокаРазмещение.Сумма=Выборка.СуммаОстаток;
							
							СтрокаРезерв=ТаблицаРезерв.Добавить();
							СтрокаРезерв.БанковскийСчетКасса=СчетОрганизации;
							СтрокаРезерв.Организация = Организация;
							СтрокаРезерв.ВидДенежныхСредств=Перечисления.ВидыДенежныхСредств.Безналичные;
							СтрокаРезерв.ДокументРезервирования=Выборка.Заявка;
							СтрокаРезерв.Сумма=Выборка.СуммаОстаток;
							
							СуммаРезерв=СуммаРезерв-Выборка.СуммаОстаток;
							
						КонецЕсли;
						
					КонецЦикла;
					
					НаборРазмещение.мПериод=ДатаДвижений;
					НаборРазмещение.мТаблицаДвижений=ТаблицаРазмещение;
					Движения.РазмещениеЗаявокНаРасходованиеСредств.ВыполнитьРасход();
					
					НаборРезерв.мПериод=ДатаДвижений;
					НаборРезерв.мТаблицаДвижений=ТаблицаРезерв;
					Движения.ДенежныеСредстваВРезерве.ВыполнитьПриход();
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если ОтраженоВОперУчете Тогда

		// По регистру "Денежные средства к получению"
		НаборДвиженийДС   = Движения.ДенежныеСредстваКПолучению;
		ТаблицаДвиженийДС = НаборДвиженийДС.ВыгрузитьКолонки();

		Для Каждого СтрокаДвижение Из ДвиженияПоСтатьям Цикл
			
			СтрокаДвиженийДС = ТаблицаДвиженийДС.Добавить();
			СтрокаДвиженийДС.БанковскийСчетКасса = СчетОрганизации;
			СтрокаДвиженийДС.Организация 		 = Организация;
			СтрокаДвиженийДС.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
			СтрокаДвиженийДС.Сумма               = СтрокаДвижение.СуммаПлатежа;
			СтрокаДвиженийДС.ДокументПолучения    = Ссылка;
			СтрокаДвиженийДС.СтатьяДвиженияДенежныхСредств=СтрокаДвижение.СтатьяДвиженияДенежныхСредств;
			
		КонецЦикла;

		НаборДвиженийДС.мПериод              = ?(Оплачено,Мин(ДатаДвижений,Дата),Дата);
		НаборДвиженийДС.мТаблицаДвижений     = ТаблицаДвиженийДС;
		Движения.ДенежныеСредстваКПолучению.ВыполнитьПриход();
		
		// По регистру "Планируемые поступления денежных средств"
		НаборДвиженийПлан  = Движения.ПланируемыеПоступленияДенежныхСредств;
		ТаблицаДвиженийПлан = НаборДвиженийПлан.ВыгрузитьКолонки();
		
		// Подготовим таблицу для движений по регистру "РасчетыСКонтрагентами"
		НаборДвиженийКонтрагенты   = Движения.РасчетыСКонтрагентами;
		ТаблицаДвиженийКонтрагенты = НаборДвиженийКонтрагенты.ВыгрузитьКолонки();
		
		// По строкам табличной части
		Для Каждого СтрокаПлатеж ИЗ ДвиженияПоПланируемымПлатежам Цикл
			
			ЕстьПланПоступление=Ложь;
			ЕстьРасчеты=Ложь;
			
			ТекущаяСделка = УправлениеДенежнымиСредствами.ОпределитьСделкуСтрокиТЧ (ЭтотОбъект,СтрокаПлатеж);
			
			Если НЕ СтрокаПлатеж.ДокументПланированияПлатежа.Пустая() Тогда
				
				СуммаПлатежа=СтрокаПлатеж.СуммаПлатежаПлан;
				СтрокаДвиженийЗаявки = ТаблицаДвиженийПлан.Добавить();
				СтрокаДвиженийЗаявки.СуммаУпр            			= СтрокаПлатеж.СуммаУпр;
				СтрокаДвиженийЗаявки.Сумма                			= СтрокаПлатеж.СуммаПлатежаПлан;
				СтрокаДвиженийЗаявки.СуммаВзаиморасчетов  			= СтрокаПлатеж.СуммаВзаиморасчетов;
				СтрокаДвиженийЗаявки.ДокументПланирования 			= СтрокаПлатеж.ДокументПланированияПлатежа;
				СтрокаДвиженийЗаявки.СтатьяДвиженияДенежныхСредств 	= СтрокаПлатеж.СтатьяДвиженияДенежныхСредств;
				СтрокаДвиженийЗаявки.Проект						 	= СтрокаПлатеж.Проект;
				СтрокаДвиженийЗаявки.ДоговорКонтрагента				= СтрокаПлатеж.ДоговорКонтрагента;
				СтрокаДвиженийЗаявки.Организация 		 			= Организация;
				СтрокаДвиженийЗаявки.Контрагент 		 			= Контрагент;

				СтрокаДвиженийЗаявки.Сделка							= СтрокаПлатеж.Сделка;
				Если СтрокаПлатеж.ВестиПоДокументамРасчетовСКонтрагентом Тогда
					СтрокаДвиженийЗаявки.ДокументРасчетовСКонтрагентом = ?(НЕ ЗначениеЗаполнено(СтрокаПлатеж.ДокументРасчетовСКонтрагентом),
																			Ссылка,
																			СтрокаПлатеж.ДокументРасчетовСКонтрагентом);
				КонецЕсли;
				
				ЕстьПланПоступление = Истина;
				
				Если НЕ СтрокаПлатеж.ВключатьВПлатежныйКалендарь Тогда // Документ не был проведен по оперативным взаиморасчетам
					ЕстьРасчеты=Истина;
				КонецЕсли;
				
			КонецЕсли;
			
			Если ((Не ЕстьПланПоступление) ИЛИ ЕстьРасчеты) И РасчетыСКонтрагентами Тогда // Первое упоминание о планируемом платеже в системе
				
				// По регистру "РасчетыСКонтрагентами"
				
				СтрокаДвиженийКонтрагенты = ТаблицаДвиженийКонтрагенты.Добавить();
				СтрокаДвиженийКонтрагенты.ДоговорКонтрагента  = СтрокаПлатеж.ДоговорКонтрагента;
				СтрокаДвиженийКонтрагенты.Контрагент  		  = Контрагент;
				СтрокаДвиженийКонтрагенты.Организация  	   	  = Организация;

				СтрокаДвиженийКонтрагенты.РасчетыВозврат      = РасчетыВозврат;
				СтрокаДвиженийКонтрагенты.Сделка              = ?(НЕ ЗначениеЗаполнено(СтрокаПлатеж.Сделка),ТекущаяСделка,СтрокаПлатеж.Сделка);
				СтрокаДвиженийКонтрагенты.СуммаВзаиморасчетов = СтрокаПлатеж.СуммаВзаиморасчетов*КоэффициентСторно;
				СтрокаДвиженийКонтрагенты.СуммаУпр            = СтрокаПлатеж.СуммаУпр*КоэффициентСторно;
				СтрокаДвиженийКонтрагенты.Период			  = Дата;
				СтрокаДвиженийКонтрагенты.ВидДвижения		  = ?(КоэффициентСторно = 1,ВидДвиженияНакопления.Расход,ВидДвиженияНакопления.Приход);
				СтрокаДвиженийКонтрагенты.Активность		  = Истина;
				
				ЕстьРасчеты = Истина;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ТаблицаДвиженийПлан.Количество()>0 Тогда
			
			НаборДвиженийПлан.мПериод          = Дата;
			НаборДвиженийПлан.мТаблицаДвижений = ТаблицаДвиженийПлан;
			Движения.ПланируемыеПоступленияДенежныхСредств.ВыполнитьРасход();
			
		КонецЕсли;
		
		Если ТаблицаДвиженийКонтрагенты.Количество()>0 Тогда
			
			НаборДвиженийКонтрагенты.мТаблицаДвижений	= ТаблицаДвиженийКонтрагенты;
			НаборДвиженийКонтрагенты.ВыполнитьДвижения();
			
		КонецЕсли;
		
		Если Оплачено Тогда  // Проводим по фактическим взаиморасчетам
			
			// По регистру "Движения денежных средств"
			НаборДвижений = Движения.ДвиженияДенежныхСредств;
			
			// Получим таблицу значений, совпадающую со структурой набора записей регистра.
			ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();
			
			// Заполним таблицу движений. 
			
			ДвиженияДенежныхСредств=ТаблицаПлатежейУпр.Скопировать();
			
			Если СтруктураШапкиДокумента.ВедениеУчетаПоПроектам Тогда
				
				ДвиженияДенежныхСредств.Свернуть("ДокументПланированияПлатежа,ДоговорКонтрагента,Сделка,ДокументРасчетовСКонтрагентом,ВестиПоДокументамРасчетовСКонтрагентом,СтатьяДвиженияДенежныхСредств,Проект","СуммаПлатежа,СуммаУпр");
				ДвиженияДенежныхСредств.Колонки["СуммаПлатежа"].Имя="Сумма";
				
				УправлениеПроектами.ОтразитьДвиженияПоПроектам(ДвиженияДенежныхСредств,ТаблицаДвижений,Неопределено,ДатаДвижений,"ДенежныеСредстваПоступление",Ссылка);
				
			Иначе
				
				ДвиженияДенежныхСредств.Свернуть("ДокументПланированияПлатежа,ДоговорКонтрагента,Сделка,ДокументРасчетовСКонтрагентом,ВестиПоДокументамРасчетовСКонтрагентом,СтатьяДвиженияДенежныхСредств","СуммаПлатежа,СуммаУпр");
				ДвиженияДенежныхСредств.Колонки["СуммаПлатежа"].Имя="Сумма";
				
				Для каждого СтрокаПлатеж Из ДвиженияДенежныхСредств Цикл
					
					УправлениеПроектами.ОпределитьРасчетныйДокумент(СтрокаПлатеж,Ссылка);
					
				КонецЦикла; 
				
				ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ДвиженияДенежныхСредств, ТаблицаДвижений);
				
			КонецЕсли;
			
			
			// Недостающие поля.
			ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.ВидыДенежныхСредств.Безналичные,"ВидДенежныхСредств");
			ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.ВидыДвиженийПриходРасход.Приход,"ПриходРасход");
			ТаблицаДвижений.ЗаполнитьЗначения(СчетОрганизации,"БанковскийСчетКасса");
			ТаблицаДвижений.ЗаполнитьЗначения(Организация,"Организация");
			ТаблицаДвижений.ЗаполнитьЗначения(Ссылка,"ДокументДвижения");
			ТаблицаДвижений.ЗаполнитьЗначения(Контрагент,"Контрагент");
			
			НаборДвижений.мПериод            = ДатаДвижений;
			НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
			
			Движения.ДвиженияДенежныхСредств.ВыполнитьДвижения();
			
			Если РасчетыСКонтрагентами Тогда
				
				// По регистру "ВзаиморасчетыСКонтрагентами"
				НаборДвижений = Движения.ВзаиморасчетыСКонтрагентами;
				ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();

				// По регистру "ДенежныеСредстваКомитента"
				
				ЕстьРасчетыСКомиссионером=Ложь;
				НаборДвиженийКомиссионер = Движения.ДенежныеСредстваКомиссионера;
				ТаблицаДвиженийКомиссионер = НаборДвиженийКомиссионер.Выгрузить();
				
				// По строкам табличной части
				Для Каждого СтрокаПлатеж ИЗ ДвиженияПоКонтрагентам Цикл
					
					ТекущаяСделка = УправлениеДенежнымиСредствами.ОпределитьСделкуСтрокиТЧ (ЭтотОбъект,СтрокаПлатеж);
					
					СтрокаДвижений = ТаблицаДвижений.Добавить();
					СтрокаДвижений.ДоговорКонтрагента  = СтрокаПлатеж.ДоговорКонтрагента;
                    СтрокаДвижений.Контрагент  		   = Контрагент;
					СтрокаДвижений.Организация  	   = Организация;

					СтрокаДвижений.Сделка              = ТекущаяСделка;
					
					СтрокаДвижений.СуммаВзаиморасчетов = СтрокаПлатеж.СуммаВзаиморасчетов*КоэффициентСторно;
					СтрокаДвижений.СуммаУпр            = СтрокаПлатеж.СуммаУпр*КоэффициентСторно;
					
					Если СтрокаПлатеж.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером
						И СтрокаПлатеж.КонтролироватьДенежныеСредстваКомитента Тогда
						
						СтрокаДвиженийКомиссионер = ТаблицаДвиженийКомиссионер.Добавить();
						СтрокаДвиженийКомиссионер.ДоговорКонтрагента  = СтрокаПлатеж.ДоговорКонтрагента;
						СтрокаДвиженийКомиссионер.Организация  	   	  = Организация;
						СтрокаДвиженийКомиссионер.Контрагент  		   = Контрагент;
						
						СтрокаДвиженийКомиссионер.Сделка              = ТекущаяСделка;
						СтрокаДвиженийКомиссионер.СуммаВзаиморасчетов = СтрокаПлатеж.СуммаВзаиморасчетов*КоэффициентСторно;
						СтрокаДвиженийКомиссионер.СуммаУпр            = СуммаУпр*КоэффициентСторно;
						
						ЕстьРасчетыСКомиссионером=Истина;
						
					КонецЕсли;
					
				КонецЦикла;
				
				НаборДвижений.мПериод            = ДатаДвижений;
				НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
				
				Если КоэффициентСторно=1 Тогда
					Движения.ВзаиморасчетыСКонтрагентами.ВыполнитьРасход();
				Иначе
					Движения.ВзаиморасчетыСКонтрагентами.ВыполнитьПриход();
				КонецЕсли;
				
				Если ЕстьРасчетыСКомиссионером Тогда
					
					НаборДвиженийКомиссионер.мПериод          = ДатаДвижений;
					НаборДвиженийКомиссионер.мТаблицаДвижений = ТаблицаДвиженийКомиссионер;
					
					Если КоэффициентСторно=1 Тогда
						Движения.ДенежныеСредстваКомиссионера.ВыполнитьРасход();
					Иначе
						Движения.ДенежныеСредстваКомиссионера.ВыполнитьПриход();
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	Если НЕ (Оплачено И ОтраженоВОперУчете) Тогда
		Возврат;
	КонецЕсли;
	
	ВидДвижения = ВидДвиженияНакопления.Расход;
	Если СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ВозвратДенежныхСредствПоставщиком Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоПриобретению;
	ИначеЕсли СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ОплатаПокупателя Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоРеализации;
	Иначе
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.Прочее;
	КонецЕсли;
	СтруктураШапкиДокумента.Вставить("РежимПроведения", РежимПроведения);
	
	УправлениеВзаиморасчетами.ОтражениеОплатыВРегистреОперативныхРасчетовПоДокументам(СтруктураШапкиДокумента, ДатаДвижений, "РасшифровкаПлатежа", ВидРасчетовПоОперации, ВидДвижения, Движения, Отказ, Заголовок);

КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаУпр(Отказ, Заголовок)

	Если НЕ РасшифровкаПлатежа.Итог("СуммаПлатежа")= СуммаДокумента Тогда
		Сообщить(Заголовок+" 
		|не совпадают сумма документа и ее расшифровка.");

		Отказ = Истина;

	КонецЕсли;

	Если Оплачено Тогда
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейОплатаУпр(), Отказ, Заголовок);
	КонецЕсли;

	Если ОтраженоВОперУчете Тогда
		
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейРасчетыУпр(), Отказ, Заголовок);
		
		Если ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам Тогда
			
			ПроверитьЗаполнениеТЧ(Отказ, Заголовок);
			
			Если Не Отказ Тогда
				УправлениеДенежнымиСредствами.КонтрольОстатковПоТЧ(Дата, ТаблицаПлатежейУпр, Отказ, Заголовок,,Истина);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента)

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке      = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "ВедениеВзаиморасчетов"                         , "ВедениеВзаиморасчетов");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "ВалютаВзаиморасчетов"                          , "ВалютаВзаиморасчетов");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "Организация"                       			, "ДоговорОрганизация");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "ВидДоговора"                       			, "ВидДоговора");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "КонтролироватьДенежныеСредстваКомитента"       , "КонтролироватьДенежныеСредстваКомитента");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика"     , "ВедениеУчетаПоПроектам"                     , "ВедениеУчетаПоПроектам");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Организации"         , "ОтражатьВРегламентированномУчете"              , "ОтражатьВРегламентированномУчете");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);
	СтруктураШапкиДокумента.Вставить("ОтражатьВУправленческомУчете",Истина); // Банковские документы всегда отражаются в упр. учете
	
	Если ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами ИЛИ
		ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам Тогда
		
		КурсДокумента      = РасшифровкаПлатежа[0].КурсВзаиморасчетов;
		КратностьДокумента = РасшифровкаПлатежа[0].КратностьВзаиморасчетов;

	Иначе	
		СтруктураКурсаДокумента = МодульВалютногоУчета.ПолучитьКурсВалюты(ВалютаДокумента,Дата);
		
		КурсДокумента      = СтруктураКурсаДокумента.Курс;
		КратностьДокумента = СтруктураКурсаДокумента.Кратность;
	КонецЕсли;
	СтруктураШапкиДокумента.Вставить("КурсДокумента"		, КурсДокумента);
	СтруктураШапкиДокумента.Вставить("КратностьДокумента"	, КратностьДокумента);
	
	ДатаДвижений=?(Оплачено,УправлениеДенежнымиСредствами.ПолучитьДатуДвижений(Дата,ДатаОплаты),Дата);
	СтруктураШапкиДокумента.Вставить("ДатаОплаты",ДатаДвижений);

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента);

КонецПроцедуры
 
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	// Заполним реквизиты из стандартного набора по документу основанию.
	ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);
	УправлениеДенежнымиСредствами.ЗаполнитьПриходПоОснованию(ЭтотОбъект, Основание, УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный"));

КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаПроведения(Отказ, Режим)

	Перем Заголовок, СтруктураШапкиДокумента;
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента);
	
	ЕстьРасчетыСКонтрагентами=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);
	
	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);

	Если НЕ ОтраженоВОперУчете И НЕ Оплачено Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не выбрано правило проведения (""Отразить в опер. учете"",""Оплачено"")",Отказ, Заголовок);
	КонецЕсли;
	
	ТаблицаПлатежейУпр = УправлениеДенежнымиСредствами.ПолучитьТаблицуПлатежейУпр(ДатаДвижений,ВалютаДокумента,Ссылка, "ПлатежноеТребованиеВыставленное");
	
	ПроверитьЗаполнениеДокументаУпр(Отказ, Заголовок);

	//Проверим на возможность проведения в БУ и НУ
	Если СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете или СтруктураШапкиДокумента.ОтражатьВНалоговомУчете тогда
		Для каждого СтрокаОплаты из ТаблицаПлатежейУпр Цикл
			УправлениеВзаиморасчетами.ПроверкаВозможностиПроведенияВ_БУ_НУ(СтрокаОплаты.ДоговорКонтрагента, СтруктураШапкиДокумента.ВалютаДокумента,
			СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете,СтруктураШапкиДокумента.ОтражатьВНалоговомУчете,
			мВалютаРегламентированногоУчета, Истина, Отказ, Заголовок, "Строка " + СтрокаОплаты.НомерСтроки + " - ",
			СтрокаОплаты.ВалютаВзаиморасчетов, СтрокаОплаты.РасчетыВУсловныхЕдиницах);
		КонецЦикла;
	КонецЕсли;
	
	// Движения по документу
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	мУдалятьДвижения = НЕ ЭтоНовый();

	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

	СтруктураДействий = Новый Структура("ПроверитьНомер, УстановитьДоговор");
	УправлениеДенежнымиСредствами.ВыполнитьДействияПередЗаписьюПлатежногоДокумента(ЭтотОбъект, СтруктураДействий, Отказ, РежимЗаписи, РежимПроведения);

КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	Если ЧастичнаяОплата Тогда
		// Сформируем структуру реквизитов шапки документа
		СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

		Сообщить("По документу "+ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента)+" уже прошла частичная оплата.
		|Перед отменой проведения документа необходимо отменить проведение платежных ордеров.");
		Отказ=Истина;
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);

КонецПроцедуры

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");

