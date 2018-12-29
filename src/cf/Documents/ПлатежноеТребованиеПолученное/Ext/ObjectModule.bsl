﻿Перем мУдалятьДвижения;

// Текущие курс и кратность валюты документа для расчетов
Перем КурсДокумента Экспорт;
Перем КратностьДокумента Экспорт;

Перем мВалютаРегламентированногоУчета Экспорт;

// Хранят группировочные признаки вида операции
Перем ЕстьРасчетыСКонтрагентами Экспорт;
Перем ЕстьРасчетыПоКредитам Экспорт;

Перем ТаблицаПлатежейУпр;

//Определение периода движений документа
Перем ДатаДвижений;

Перем РасчетыВозврат;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА
 
////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
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

	Если ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат;
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Формирует структуру полей, обязательных для заполнения при отражении фактического
// движения средств по банку.
//
// Возвращаемое значение:
//   СтруктураОбязательныхПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейОплата()

	СтруктураПолей=Новый Структура;
	СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");
	СтруктураПолей.Вставить("СуммаДокумента");
	СтруктураПолей.Вставить("ДатаОплаты","Не указана дата оплаты документа банком!");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплата()

// Формирует структуру полей, обязательных для заполнения при отражении операции во 
// взаиморасчетах
// Возвращаемое значение:
//   СтруктурахПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейРасчеты()

	СтруктураПолей = Новый Структура("Организация, Контрагент, СуммаДокумента");
	СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплата()

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
	
	КоэффициентСторно = ?(РасчетыВозврат=Перечисления.РасчетыВозврат.Возврат,-1,1);
	
	РасчетыСКонтрагентами = ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам;
	
	ДвиженияПоСтатьям = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоЗаявкам = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоРезерву = ТаблицаПлатежейУпр.Скопировать();
	ДвиженияПоКонтрагентам = ТаблицаПлатежейУпр.Скопировать();
	
	ДвиженияПоЗаявкам.Свернуть("ДокументПланированияПлатежа,ВключатьВПлатежныйКалендарь,ДоговорКонтрагента,ВестиПоДокументамРасчетовСКонтрагентом,Сделка,ДокументРасчетовСКонтрагентом,СтатьяДвиженияДенежныхСредств,Проект","СуммаПлатежа,СуммаВзаиморасчетов,СуммаПлатежаПлан,СуммаУпр");
	ДвиженияПоКонтрагентам.Свернуть("ДоговорКонтрагента,ВестиПоДокументамРасчетовСКонтрагентом,Сделка,ДокументРасчетовСКонтрагентом,ДокументРасчетовСКонтрагентом,ВидДоговора, КонтролироватьДенежныеСредстваКомитента,Проект","СуммаВзаиморасчетов,СуммаУпр,СуммаРегл,СуммаВзаиморасчетовОстаток,СуммаУпрОстаток");
	ДвиженияПоСтатьям.Свернуть("СтатьяДвиженияДенежныхСредств","СуммаПлатежа");
	ДвиженияПоРезерву.Свернуть("ДокументПланированияПлатежа","СуммаПлатежаПлан");
		
	Если Оплачено Тогда
		
		// По регистру "Денежные средства"
		НаборДвиженийОстатки 		= Движения.ДенежныеСредства;
		ТаблицаДвиженийОстатки 		= НаборДвиженийОстатки.ВыгрузитьКолонки();
		
		// По регистру "Денежные средства к списанию"
		НаборДвиженийСписание   = Движения.ДенежныеСредстваКСписанию;
		ТаблицаДвиженийСписание = НаборДвиженийСписание.Выгрузить();
		
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
		
		// По регистру "Денежные средства к списанию"
		Для Каждого СтрокаДвижение Из ДвиженияПоСтатьям Цикл
			
			СтрокаДвиженийСписание = ТаблицаДвиженийСписание.Добавить();
			СтрокаДвиженийСписание.БанковскийСчетКасса = СчетОрганизации;
			СтрокаДвиженийСписание.Организация 		   = Организация;
			СтрокаДвиженийСписание.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
			СтрокаДвиженийСписание.Сумма               = СтрокаДвижение.СуммаПлатежа;
			СтрокаДвиженийСписание.ДокументСписания    = Ссылка;
			СтрокаДвиженийСписание.СтатьяДвиженияДенежныхСредств=СтрокаДвижение.СтатьяДвиженияДенежныхСредств;
			
		КонецЦикла;
		
		НаборДвиженийОстатки.мПериод              = ДатаДвижений;
		НаборДвиженийОстатки.мТаблицаДвижений     = ТаблицаДвиженийОстатки;
		Движения.ДенежныеСредства.ВыполнитьРасход();
		
		НаборДвиженийСписание.мПериод              = ДатаДвижений;
		НаборДвиженийСписание.мТаблицаДвижений     = ТаблицаДвиженийСписание;
		Движения.ДенежныеСредстваКСписанию.ВыполнитьРасход();
		
	КонецЕсли;

	Если ОтраженоВОперУчете Тогда

		// По регистру "Денежные средства к списанию"
		НаборДвиженийДС   = Движения.ДенежныеСредстваКСписанию;
		ТаблицаДвиженийДС = НаборДвиженийДС.ВыгрузитьКолонки();

		Для Каждого СтрокаДвижение Из ДвиженияПоСтатьям Цикл
			
			СтрокаДвиженийДС = ТаблицаДвиженийДС.Добавить();
			СтрокаДвиженийДС.БанковскийСчетКасса = СчетОрганизации;
			СтрокаДвиженийДС.Организация 		 = Организация;
			СтрокаДвиженийДС.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
			СтрокаДвиженийДС.Сумма               = СтрокаДвижение.СуммаПлатежа;
			СтрокаДвиженийДС.ДокументСписания    = Ссылка;
			СтрокаДвиженийДС.СтатьяДвиженияДенежныхСредств=СтрокаДвижение.СтатьяДвиженияДенежныхСредств;
			
		КонецЦикла;

		НаборДвиженийДС.мПериод              = ?(Оплачено,Мин(ДатаДвижений,Дата),Дата);
		НаборДвиженийДС.мТаблицаДвижений     = ТаблицаДвиженийДС;
		Движения.ДенежныеСредстваКСписанию.ВыполнитьПриход();
		
		ЕстьРезерв=Ложь;
		ЕстьРазмещение=Ложь;
		
		// По регистру "Денежные средства в резерве"
		НаборДвиженийРезерв   = Движения.ДенежныеСредстваВРезерве;
		ТаблицаДвиженийРезерв = НаборДвиженийРезерв.ВыгрузитьКолонки();
		
		// По регистру "Размещение заявок на расходование средств"
		НаборДвиженийРазмещение  = Движения.РазмещениеЗаявокНаРасходованиеСредств;
		ТаблицаДвиженийРазмещение = НаборДвиженийРазмещение.ВыгрузитьКолонки();
		
		// По регистру "Заявки на расходование средств"
		НаборДвиженийЗаявки   = Движения.ЗаявкиНаРасходованиеСредств;
		ТаблицаДвиженийЗаявки = НаборДвиженийЗаявки.ВыгрузитьКолонки();
		
		// Проверим необходимость списания суммы платежного поручения по заявкам из регистра "ДенежныеСредстваРезерв"
		Для Каждого СтрокаЗаявка Из ДвиженияПоРезерву Цикл
			
			Если НЕ СтрокаЗаявка.ДокументПланированияПлатежа.Пустая() Тогда
				
				Запрос = Новый Запрос;
				Запрос.УстановитьПараметр("ДокументЗаявка",СтрокаЗаявка.ДокументПланированияПлатежа);
				Запрос.УстановитьПараметр("БанковскийСчетКасса",СчетОрганизации);
				Запрос.Текст = "ВЫБРАТЬ
				|	ДенежныеСредстваВРезервеОстатки.СуммаОстаток КАК СуммаОстаток
				|ИЗ
				|	РегистрНакопления.ДенежныеСредстваВРезерве.Остатки(, ДокументРезервирования = &ДокументЗаявка И БанковскийСчетКасса=&БанковскийСчетКасса) КАК ДенежныеСредстваВРезервеОстатки";
				Результат = Запрос.Выполнить().Выбрать();
				
				Если Результат.Следующий() И (НЕ Результат.СуммаОстаток=NULL) Тогда
					
					СтрокаДвижений = ТаблицаДвиженийРезерв.Добавить();
					СтрокаДвижений.БанковскийСчетКасса = СчетОрганизации;
					СтрокаДвижений.Организация 		 	= Организация;
					СтрокаДвижений.ВидДенежныхСредств  = Перечисления.ВидыДенежныхСредств.Безналичные;
					СтрокаДвижений.Сумма               = ?(Результат.СуммаОстаток <СтрокаЗаявка.СуммаПлатежаПлан,Результат.СуммаОстаток,СтрокаЗаявка.СуммаПлатежаПлан);
					СтрокаДвижений.ДокументРезервирования = СтрокаЗаявка.ДокументПланированияПлатежа;
					
					ЕстьРезерв=Истина;
					
				КонецЕсли;
				
				Запрос=Новый Запрос;
				Запрос.Текст="ВЫБРАТЬ
				|	РазмещениеЗаявок.ДокументПланирования КАК ДокументПланирования,
				|	РазмещениеЗаявок.СуммаОстаток КАК СуммаОстаток,
				// Ранжируем планиуемые поступления для закрытия. Первыми закрывается размещение по планируемым поступлениям,
				// у которых совпадает счет, затем форма оплаты, затем организация.
				|	(ВЫБОР КОГДА РазмещениеЗаявок.ДокументПланирования.БанковскийСчетКасса=&СчетОрганизации
				|		Тогда 4
				|	Иначе 0
				|	Конец
				|  + ВЫБОР КОГДА РазмещениеЗаявок.ДокументПланирования.ФормаОплаты=&ФормаОплаты
				|		Тогда 2
				|	Иначе 0
				|	Конец
				|  + ВЫБОР КОГДА РазмещениеЗаявок.ДокументПланирования.Организация=&Организация
				|		Тогда 1
				|	Иначе 0
				|	Конец) КАК Релевантность,
				|	РазмещениеЗаявок.ДокументПланирования.ДатаПоступления КАК ДатаПоступления
				|ИЗ
				|	РегистрНакопления.РазмещениеЗаявокНаРасходованиеСредств.Остатки(, ДокументРезервирования=&ДокументРезервирования) КАК РазмещениеЗаявок
				|ГДЕ НЕ((РазмещениеЗаявок.СуммаОстаток) ЕСТЬ NULL )";
				
				Запрос.УстановитьПараметр("СчетОрганизации",СчетОрганизации);
				Запрос.УстановитьПараметр("ФормаОплаты",Перечисления.ВидыДенежныхСредств.Безналичные);
				Запрос.УстановитьПараметр("Организация",Организация);
				Запрос.УстановитьПараметр("ДокументРезервирования",СтрокаЗаявка.ДокументПланированияПлатежа);
				
				ТабРазмещение=Запрос.Выполнить().Выгрузить();
				
				ТабРазмещение.Сортировать("Релевантность Убыв,ДатаПоступления Возр");
				
				СуммаКСписанию=СтрокаЗаявка.СуммаПлатежаПлан;
				
				Для Каждого Строка Из ТабРазмещение Цикл
					
					ЕстьРазмещение=Истина;
					
					СтрокаДвижение=ТаблицаДвиженийРазмещение.Добавить();
					СтрокаДвижение.ДокументПланирования=Строка.ДокументПланирования;
					СтрокаДвижение.ДокументРезервирования=СтрокаЗаявка.ДокументПланированияПлатежа;
					
					Если Строка.СуммаОстаток>=СуммаКСписанию Тогда
						
						СтрокаДвижение.Сумма=СуммаКСписанию;
						Прервать;
						
					Иначе
						
						СтрокаДвижение.Сумма=Строка.СуммаОстаток;
						СуммаКСписанию=СуммаКСписанию-Строка.СуммаОстаток;
						
					КонецЕсли;
					
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ЕстьРезерв тогда
			
			НаборДвиженийРезерв.мПериод          = Дата;
			НаборДвиженийРезерв.мТаблицаДвижений = ТаблицаДвиженийРезерв;	
			Движения.ДенежныеСредстваВРезерве.ВыполнитьРасход();
			
		КонецЕсли;
		
		Если ЕстьРазмещение Тогда
			
			НаборДвиженийРазмещение.мПериод          = Дата;
			НаборДвиженийРазмещение.мТаблицаДвижений = ТаблицаДвиженийРазмещение;	
			Движения.РазмещениеЗаявокНаРасходованиеСредств.ВыполнитьРасход();
			
		КонецЕсли;
		
		// Подготовим таблицу для движений по регистру "РасчетыСКонтрагентами"
		НаборДвиженийКонтрагенты   = Движения.РасчетыСКонтрагентами;
		ТаблицаДвиженийКонтрагенты = НаборДвиженийКонтрагенты.ВыгрузитьКолонки();
		
		// По строкам табличной части
		Для Каждого СтрокаПлатеж ИЗ ДвиженияПоЗаявкам Цикл
			
			ЕстьЗаявка=Ложь;
			ЕстьРасчеты=Ложь;
			
			ТекущаяСделка = УправлениеДенежнымиСредствами.ОпределитьСделкуСтрокиТЧ (ЭтотОбъект,СтрокаПлатеж);
			
			Если НЕ СтрокаПлатеж.ДокументПланированияПлатежа.Пустая() Тогда
				
				СуммаПлатежа=СтрокаПлатеж.СуммаПлатежаПлан;
				СтрокаДвиженийЗаявки = ТаблицаДвиженийЗаявки.Добавить();
				СтрокаДвиженийЗаявки.СуммаУпр            			= СтрокаПлатеж.СуммаУпр;
				СтрокаДвиженийЗаявки.Сумма                			= СтрокаПлатеж.СуммаПлатежаПлан;
				СтрокаДвиженийЗаявки.СуммаВзаиморасчетов  			= СтрокаПлатеж.СуммаВзаиморасчетов;
				СтрокаДвиженийЗаявки.ЗаявкаНаРасходование 			= СтрокаПлатеж.ДокументПланированияПлатежа;
				СтрокаДвиженийЗаявки.СтатьяДвиженияДенежныхСредств 	= СтрокаПлатеж.СтатьяДвиженияДенежныхСредств;
				СтрокаДвиженийЗаявки.Проект						 	= СтрокаПлатеж.Проект;
				СтрокаДвиженийЗаявки.ДоговорКонтрагента				= СтрокаПлатеж.ДоговорКонтрагента;
				СтрокаДвиженийЗаявки.Организация					= Организация;
				СтрокаДвиженийЗаявки.Контрагент						= Контрагент;

				СтрокаДвиженийЗаявки.Сделка							= СтрокаПлатеж.Сделка;
				Если СтрокаПлатеж.ВестиПоДокументамРасчетовСКонтрагентом Тогда
					СтрокаДвиженийЗаявки.ДокументРасчетовСКонтрагентом = СтрокаПлатеж.ДокументРасчетовСКонтрагентом;
					//СтрокаДвиженийЗаявки.ДокументРасчетовСКонтрагентом = ?(НЕ ЗначениеЗаполнено(СтрокаПлатеж.ДокументРасчетовСКонтрагентом),
					//														Ссылка,
					//														СтрокаПлатеж.ДокументРасчетовСКонтрагентом);
				КонецЕсли;
				
				ЕстьЗаявка = Истина;
				
				Если НЕ СтрокаПлатеж.ВключатьВПлатежныйКалендарь Тогда // Документ не был проведен по оперативным взаиморасчетам
					ЕстьРасчеты=Истина;
				КонецЕсли;
				
			КонецЕсли;
			
			Если ((Не ЕстьЗаявка) ИЛИ ЕстьРасчеты) И РасчетыСКонтрагентами Тогда // Первое упоминание о планируемом платеже в системе
				
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
				СтрокаДвиженийКонтрагенты.ВидДвижения		  = ?(КоэффициентСторно = 1,ВидДвиженияНакопления.Приход,ВидДвиженияНакопления.Расход);
				СтрокаДвиженийКонтрагенты.Активность		  = Истина;
				
				ЕстьРасчеты = Истина;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ТаблицаДвиженийЗаявки.Количество()>0 Тогда
			
			НаборДвиженийЗаявки.мПериод          = Дата;
			НаборДвиженийЗаявки.мТаблицаДвижений = ТаблицаДвиженийЗаявки;
			Движения.ЗаявкиНаРасходованиеСредств.ВыполнитьРасход();
			
		КонецЕсли;
		
		Если ТаблицаДвиженийКонтрагенты.Количество()>0 Тогда
			
			НаборДвиженийКонтрагенты.мТаблицаДвижений	= ТаблицаДвиженийКонтрагенты;
			НаборДвиженийКонтрагенты.ВыполнитьДвижения();
			
		КонецЕсли;
		
	КонецЕсли;

	Если Оплачено И ОтраженоВОперУчете Тогда  // Проводим по фактическим взаиморасчетам

		// По регистру "Движения денежных средств"
		НаборДвижений = Движения.ДвиженияДенежныхСредств;
		
		// Получим таблицу значений, совпадающую со структурой набора записей регистра.
		ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();
		
		// Заполним таблицу движений. 
		
		ДвиженияДенежныхСредств=ТаблицаПлатежейУпр.Скопировать();
		
		Если СтруктураШапкиДокумента.ВедениеУчетаПоПроектам Тогда
			
			ДвиженияДенежныхСредств.Свернуть("ДокументПланированияПлатежа,ДоговорКонтрагента,Сделка,ДокументРасчетовСКонтрагентом,ВестиПоДокументамРасчетовСКонтрагентом,СтатьяДвиженияДенежныхСредств,Проект","СуммаПлатежа,СуммаУпр");
			ДвиженияДенежныхСредств.Колонки["СуммаПлатежа"].Имя="Сумма";
			
			УправлениеПроектами.ОтразитьДвиженияПоПроектам(ДвиженияДенежныхСредств,ТаблицаДвижений,Неопределено,ДатаДвижений,"ДенежныеСредстваСписание",Ссылка);
			
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
		ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.ВидыДвиженийПриходРасход.Расход,"ПриходРасход");
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
			
			ЕстьРасчетыСКомитентом=Ложь;
			НаборДвиженийКомитент = Движения.ДенежныеСредстваКомитента;
			ТаблицаДвиженийКомитент = НаборДвиженийКомитент.Выгрузить();
		
			// По строкам табличной части
			Для Каждого СтрокаПлатеж ИЗ ДвиженияПоКонтрагентам Цикл

				ТекущаяСделка = УправлениеДенежнымиСредствами.ОпределитьСделкуСтрокиТЧ (ЭтотОбъект,СтрокаПлатеж);

				СтрокаДвижений = ТаблицаДвижений.Добавить();
				СтрокаДвижений.ДоговорКонтрагента  = СтрокаПлатеж.ДоговорКонтрагента;
				СтрокаДвижений.Контрагент  		   = Контрагент;
				СтрокаДвижений.Организация  	   = Организация;

				СтрокаДвижений.Сделка              = ТекущаяСделка;
				
				//Если СтрокаПлатеж.ВестиПоДокументамРасчетовСКонтрагентом Тогда
				//	СтрокаДвижений.ДокументРасчетовСКонтрагентом = ?(ЗначениеЗаполнено(СтрокаПлатеж.ДокументРасчетовСКонтрагентом),
				//													СтрокаПлатеж.ДокументРасчетовСКонтрагентом,
				//													Ссылка);
				//КонецЕсли;
				
				СтрокаДвижений.СуммаВзаиморасчетов = СтрокаПлатеж.СуммаВзаиморасчетов*КоэффициентСторно;
				СтрокаДвижений.СуммаУпр            = СтрокаПлатеж.СуммаУпр*КоэффициентСторно;
				
				Если СтрокаПлатеж.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом
					И СтрокаПлатеж.КонтролироватьДенежныеСредстваКомитента Тогда
					
					СтрокаДвиженийКомитент = ТаблицаДвиженийКомитент.Добавить();
					СтрокаДвиженийКомитент.ДоговорКонтрагента  = СтрокаПлатеж.ДоговорКонтрагента;

					СтрокаДвиженийКомитент.Организация		   = Организация;
					СтрокаДвиженийКомитент.Контрагент		   = Контрагент;
					СтрокаДвиженийКомитент.Сделка              = ТекущаяСделка;
					СтрокаДвиженийКомитент.СуммаВзаиморасчетов = СтрокаПлатеж.СуммаВзаиморасчетов*КоэффициентСторно;
					СтрокаДвиженийКомитент.СуммаУпр            = СуммаУпр*КоэффициентСторно;
					
					ЕстьРасчетыСКомитентом=Истина;
					
				КонецЕсли;
				
			КонецЦикла;

			НаборДвижений.мПериод            = ДатаДвижений;
			НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
		
			Если КоэффициентСторно=1 Тогда
				Движения.ВзаиморасчетыСКонтрагентами.ВыполнитьПриход();
			Иначе
				Движения.ВзаиморасчетыСКонтрагентами.ВыполнитьРасход();
			КонецЕсли;
			
			Если ЕстьРасчетыСКомитентом Тогда
				
				НаборДвиженийКомитент.мПериод          = ДатаДвижений;
				НаборДвиженийКомитент.мТаблицаДвижений = ТаблицаДвиженийКомитент;
				
				Если КоэффициентСторно=1 Тогда
					Движения.ДенежныеСредстваКомитента.ВыполнитьРасход();
				Иначе
					Движения.ДенежныеСредстваКомитента.ВыполнитьПриход();
				КонецЕсли;
				
			КонецЕсли;

		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	Если НЕ (Оплачено И ОтраженоВОперУчете) Тогда
		Возврат;
	КонецЕсли;
	
	ВидДвижения = ВидДвиженияНакопления.Приход;
	Если СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ВозвратДенежныхСредствПокупателю Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоРеализации;
	ИначеЕсли СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ОплатаПоставщику Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоПриобретению;
	Иначе
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.Прочее;
	КонецЕсли;
	СтруктураШапкиДокумента.Вставить("РежимПроведения", РежимПроведения);
	
	УправлениеВзаиморасчетами.ОтражениеОплатыВРегистреОперативныхРасчетовПоДокументам(СтруктураШапкиДокумента, ДатаДвижений, "РасшифровкаПлатежа", ВидРасчетовПоОперации, ВидДвижения, Движения, Отказ, Заголовок);

КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаУпр(Отказ, Режим, Заголовок)
	
	Если ОтраженоВОперУчете И (ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам) Тогда
		
		ПроверитьЗаполнениеТЧ(Отказ, Заголовок);
		
		Если Не Отказ Тогда
			УправлениеДенежнымиСредствами.КонтрольОстатковПоТЧ(Дата, ТаблицаПлатежейУпр, Отказ, Заголовок,РасчетыВозврат);
		КонецЕсли;

	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента)

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
	
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами ИЛИ
		ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам Тогда
		
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
	УправлениеДенежнымиСредствами.ЗаполнитьРасходПоОснованию(ЭтотОбъект, Основание, УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный"));

КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Перем Заголовок, СтруктураШапкиДокумента;
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента);

	ЕстьРасчетыСКонтрагентами=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);
	РасчетыВозврат = УправлениеДенежнымиСредствами.НаправленияДвиженияДляДокументаДвиженияДенежныхСредствУпр(ВидОперации);
	
	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	Если НЕ ОтраженоВОперУчете И НЕ Оплачено Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не выбрано правило проведения (""Отразить в опер. учете"",""Оплачено"")",Отказ, Заголовок);
	КонецЕсли;
	
	Если НЕ РасшифровкаПлатежа.Итог("СуммаПлатежа")= СуммаДокумента Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не совпадают сумма документа и ее расшифровка.",Отказ, Заголовок);
	КонецЕсли;
	
	Если Оплачено Тогда
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейОплата(), Отказ, Заголовок);
	КонецЕсли;
	
	Если ОтраженоВОперУчете Тогда
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейРасчеты(), Отказ, Заголовок);
	КонецЕсли;
 	
	ТаблицаПлатежейУпр=УправлениеДенежнымиСредствами.ПолучитьТаблицуПлатежейУпр(ДатаДвижений,ВалютаДокумента,Ссылка, "ПлатежноеТребованиеПолученное");
	
	ПроверитьЗаполнениеДокументаУпр(Отказ, Режим, Заголовок);

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

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	Если ЧастичнаяОплата Тогда
		// Сформируем структуру реквизитов шапки документа.
		СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

		Сообщить("По документу "+ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента)+" уже прошла частичная оплата.
		|Перед отменой проведения документа необходимо отменить проведение платежных ордеров.");
		Отказ=Истина;
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	мУдалятьДвижения = НЕ ЭтоНовый();

	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

	СтруктураДействий = Новый Структура("УстановитьДоговор");
	УправлениеДенежнымиСредствами.ВыполнитьДействияПередЗаписьюПлатежногоДокумента(ЭтотОбъект, СтруктураДействий, Отказ, РежимЗаписи, РежимПроведения);

КонецПроцедуры // ПередЗаписью

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");

