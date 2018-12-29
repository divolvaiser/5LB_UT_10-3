﻿Перем мОснование;

// Обработчик события ПриКопировании
//
Процедура ПриКопировании(ОбъектКопирования)

	Если НЕ ЭтотОбъект.ЭтоГруппа Тогда
		ЭтотОбъект.ОсновнойДоговорКонтрагента = Неопределено;
		ЭтотОбъект.ОсновнойБанковскийСчет     = Неопределено;
	КонецЕсли;

КонецПроцедуры

// Функция возвращает результат запроса по справочнику контрагентов с заданным головным контрагентом
//
// Параметры:
//  ГоловнойКонтрагент - заданный головной контрагент
//
// Возвращаемое значение:
//  Результат - результат работы запроса
// 
Функция ПолучитьКонтрагентовПоЗаданномуГоловномуКонтрагенту(ГоловнойКонтрагент) Экспорт
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("ГоловнойКонтрагент", ГоловнойКонтрагент);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Контрагенты.Ссылка КАК Контрагент
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|
	|ГДЕ
	|	Контрагенты.ГоловнойКонтрагент = &ГоловнойКонтрагент
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент";
	
	Результат = Запрос.Выполнить();
	
	Возврат Результат;
	
КонецФункции // ПолучитьКонтрагентовПоЗаданномуГоловномуКонтрагенту()

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если ТипЗнч(Основание) = Тип("СправочникСсылка.Организации") Тогда
		
		Наименование           = Основание.Наименование;
		ЮрФизЛицо              = Основание.ЮрФизЛицо;
		НаименованиеПолное     = Основание.НаименованиеПолное;
		ОсновнойБанковскийСчет = Основание.ОсновнойБанковскийСчет;
		ИНН                    = Основание.ИНН;
		КПП                    = Основание.КПП;
		КодПоОКПО              = Основание.КодПоОКПО;
		мОснование             = Основание;
		
	КонецЕсли;

КонецПроцедуры // ОбработкаЗаполнения()

Процедура ПередЗаписью(Отказ)
	Перем мСсылкаНового;
	
	//**********************************************************************************
	//******************                КОРРЕКТИРОВКА             **********************
	//**********************************************************************************
	//Добавлено Monstr 180708
#Если ТолстыйКлиентОбычноеПриложение Тогда	
	Если ЭтоНовый() Тогда
		Отказ = Истина;
		Предупреждение("В базе УТ запрещено создавать контрагентов. Обратитесь в бухгалтерию для создания контрагента.");
		Возврат;
	Иначе 
		Сообщить("Местом ввода данных в справочник Контрагенты являются базы БП. При обмене с БП изменения могут быть потеряны.");
	КонецЕсли;
	//Конец добавленного Monstr 180708
#КонецЕсли	
	Если НЕ ОбменДанными.Загрузка Тогда
		
		// Проверим основной вид деятельности контрагента
		Если ЗначениеЗаполнено(ОсновнойВидДеятельности) И ВидыДеятельности.Найти(ОсновнойВидДеятельности, "ВидДеятельности") = Неопределено Тогда
			ОсновнойВидДеятельности = Справочники.ВидыДеятельностиКонтрагентов.ПустаяСсылка();
		КонецЕсли;
		
		НастройкаПравДоступа.ПередЗаписьюНовогоОбъектаСПравамиДоступаПользователей(ЭтотОбъект, Отказ, Родитель, мСсылкаНового);
		
		// установим головного контрагента если он не заполнен
		Если НЕ ЭтоГруппа Тогда
			Если НЕ ЗначениеЗаполнено(ГоловнойКонтрагент) Тогда
				Если ЭтоНовый() Тогда
					ГоловнойКонтрагент = мСсылкаНового;
				Иначе
					ГоловнойКонтрагент = Ссылка;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если НЕ ОбменДанными.Загрузка Тогда
		
		Если ЗначениеЗаполнено(ГоловнойКонтрагент) И ГоловнойКонтрагент <> Ссылка Тогда
			
			Если ЗначениеЗаполнено(ГоловнойКонтрагент.ГоловнойКонтрагент) И ГоловнойКонтрагент.ГоловнойКонтрагент <> ГоловнойКонтрагент Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Контрагент "+СокрЛП(ГоловнойКонтрагент)+" не может быть выбран головным, 
								|так как для него уже был назначен головной контрагент "+СокрЛП(ГоловнойКонтрагент.ГоловнойКонтрагент)+"!");
				Отказ = Истина;
				Возврат;
			Иначе
				
				// надо проверить, что если указываем головного контрагента, то этот элемент уже не был установлен
				// в качестве головного у другого контрагента.
				ВыборкаПоГоловномуКонтрагенту = ПолучитьКонтрагентовПоЗаданномуГоловномуКонтрагенту(Ссылка).Выбрать();
				Если ВыборкаПоГоловномуКонтрагенту.Количество() <> 0 Тогда
					
					СообщениеОНевозможностиЗаписи = "Контрагент "+СокрЛП(ЭтотОбъект)+" не может иметь головного контрагента!
													|Этот контрагент уже установлен головным для: ";
					Пока ВыборкаПоГоловномуКонтрагенту.Следующий() Цикл
						СообщениеОНевозможностиЗаписи = СообщениеОНевозможностиЗаписи + Символы.ПС + СокрЛП(ВыборкаПоГоловномуКонтрагенту.Контрагент);
					КонецЦикла;
					
					ОбщегоНазначения.СообщитьОбОшибке(СообщениеОНевозможностиЗаписи);
					Отказ = Истина;
					Возврат;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(мОснование) Тогда
			НаборЗаписей = РегистрыСведений.СобственныеКонтрагенты.СоздатьНаборЗаписей();
			ЗаписьРегистра = НаборЗаписей.Добавить();
			ЗаписьРегистра.Контрагент = Ссылка;
			ЗаписьРегистра.ВидСвязи   = Перечисления.ВидыСобственныхКонтрагентов.Организация;
			ЗаписьРегистра.Объект     = мОснование;
			НаборЗаписей.Записать(Ложь);
			мОснование = "";
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры
