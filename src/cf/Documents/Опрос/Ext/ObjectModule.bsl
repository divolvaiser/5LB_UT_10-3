﻿////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Если Клиент Тогда

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт
	
	
	Если ИмяМакета = "Опрос" Тогда
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьОпрос();
		УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект,Метаданные().Синоним));
		
	ИначеЕсли ИмяМакета = "HTML" Тогда
		
		ИмяФайла     = "opros"+Число(Номер)+".xml";
		Если ТиповаяАнкета.Пустая() Тогда
			Сообщить("Не выбрана анкета!");
			Возврат;
		КонецЕсли;
		Анкетирование.СформироватьВложение(ТиповаяАнкета, ОпрашиваемоеЛицо, "", , Ссылка, ИмяФайла, Истина);
		ЗапуститьПриложение("explorer " + КаталогВременныхФайлов() + ИмяФайла);
		
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект,Метаданные().Синоним));
		
	КонецЕсли;
	
КонецПроцедуры

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//	Структура, каждая строка которой соответствует одному из вариантов печати
//
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	СтруктураМакетов = Новый Структура;
	СтруктураМакетов.Вставить("Опрос",	"Опрос");
	СтруктураМакетов.Вставить("HTML",	"Просмотр HTML");
	
	Возврат СтруктураМакетов;
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Назначает тип ответа в зависимости от вопроса.
//
// Параметры:
//	Вопрос - Собственно, сам вопрос
//
// Возвращаемое значение:
//	нет
//
Процедура НазначитьТипОтвета(Вопрос) Экспорт
	
	Вопрос.ТиповойОтвет = Вопрос.Вопрос.ТипЗначения.ПривестиЗначение();
	
КонецПроцедуры // НазначитьТипОтвета()

// Загружает вопросы по образцу указанной анкеты.
//
// Параметры: 
//	ОбразецЗаполнения	- анкета-образец
//
// Возвращаемое значение:
//	нет
//
Процедура ЗаполнитьВопросыАнкеты(ОбразецЗаполнения) Экспорт
	
	Вопросы.Загрузить(ОбразецЗаполнения.ВопросыАнкеты.Выгрузить());
	
	Для Каждого Вопрос Из Вопросы Цикл
		
		Если НЕ ЗначениеЗаполнено(Вопрос.ТиповойОтвет) тогда
			НазначитьТипОтвета(Вопрос);
		Конецесли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПроверитьОбязательноЗаполняемыеОтветы(ПоВопросу = Неопределено, НеПроверкаНаУсловноНеЗапольнять = Истина) Экспорт
	
	ЕстьОшибки = Ложь;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Опрос",				Ссылка);
	Запрос.УстановитьПараметр("Анкета",				ТиповаяАнкета);
	Запрос.УстановитьПараметр("ПоВопросу",			ПоВопросу);
	Запрос.УстановитьПараметр("Обязательный",		Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.ОбязателенКЗаполнению);
	Запрос.УстановитьПараметр("УсловноОбязательный",Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.УсловноОбязателенКЗаполнению);
	Запрос.УстановитьПараметр("УсловноНеЗаполнять",	Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.УсловноНеЗаполнять);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОпросВопросы.Вопрос КАК Вопрос,
	|	ТиповыеАнкетыВопросыАнкеты.Обязательный КАК Обязательный,
	|	ТиповыеАнкетыВопросыАнкеты.ВопросУсловия КАК ВопросУсловия,
	|	ТиповыеАнкетыВопросыАнкеты.УсловиеОтвета КАК УсловиеОтвета,
	|	ТиповыеАнкетыВопросыАнкеты.ОтветУсловия КАК ОтветУсловия,
	|	ОтветУсловияВопроса.ТиповойОтвет КАК ТиповойОтветУсловияВопроса,
	|	ОпросВопросы.ТиповойОтвет КАК ТиповойОтвет,
	|	ТиповыеАнкетыСписокЗначенийУсловия.ЗначениеСписка КАК ЗначениеСписка
	|ИЗ
	|	Документ.Опрос.Вопросы КАК ОпросВопросы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ТиповыеАнкеты.ВопросыАнкеты КАК ТиповыеАнкетыВопросыАнкеты
	|			ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|				МАКСИМУМ(ОпросВопросы.ТиповойОтвет) КАК ТиповойОтвет,
	|				ОпросВопросы.ВопросУсловия КАК ВопросУсловия
	|			ИЗ
	|				(ВЫБРАТЬ
	|					ОпросВопросы.ТиповойОтвет КАК ТиповойОтвет,
	|					ОпросВопросы.Вопрос КАК ВопросУсловия
	|				ИЗ
	|					Документ.Опрос.Вопросы КАК ОпросВопросы
	|				ГДЕ
	|					ОпросВопросы.Ссылка = &Опрос
	|					И ОпросВопросы.Ссылка.ТиповаяАнкета = &Анкета
	|					И ОпросВопросы.Вопрос В
	|							(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|								ТиповыеАнкетыВопросыАнкеты.ВопросУсловия
	|							ИЗ
	|								Справочник.ТиповыеАнкеты.ВопросыАнкеты КАК ТиповыеАнкетыВопросыАнкеты
	|							ГДЕ
	|								ТиповыеАнкетыВопросыАнкеты.Ссылка = &Анкета
	|								//ОТБОР_ПО_ВОПРОСУ
	|							)
	|				
	|				ОБЪЕДИНИТЬ ВСЕ
	|				
	|				ВЫБРАТЬ
	|					NULL,
	|					ТиповыеАнкетыВопросыАнкеты.ВопросУсловия
	|				ИЗ
	|					Справочник.ТиповыеАнкеты.ВопросыАнкеты КАК ТиповыеАнкетыВопросыАнкеты
	|				ГДЕ
	|					ТиповыеАнкетыВопросыАнкеты.Ссылка = &Анкета
	|					//ОТБОР_ПО_ВОПРОСУ
	|				) КАК ОпросВопросы
	|			
	|			СГРУППИРОВАТЬ ПО
	|				ОпросВопросы.ВопросУсловия) КАК ОтветУсловияВопроса
	|			ПО ТиповыеАнкетыВопросыАнкеты.ВопросУсловия = ОтветУсловияВопроса.ВопросУсловия
	|		ПО ТиповыеАнкетыВопросыАнкеты.Ссылка = ОпросВопросы.Ссылка.ТиповаяАнкета
	|			И ТиповыеАнкетыВопросыАнкеты.Вопрос = ОпросВопросы.Вопрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ТиповыеАнкеты.СписокЗначенийУсловия КАК ТиповыеАнкетыСписокЗначенийУсловия
	|		ПО ОпросВопросы.Ссылка.ТиповаяАнкета = ТиповыеАнкетыСписокЗначенийУсловия.Ссылка
	|			И ОпросВопросы.Вопрос = ТиповыеАнкетыСписокЗначенийУсловия.ВопросВладелец
	|ГДЕ
	|	ТиповыеАнкетыВопросыАнкеты.Ссылка = &Анкета
	|	И ОпросВопросы.Ссылка = &Опрос
	|	И (ТиповыеАнкетыВопросыАнкеты.Обязательный = &Обязательный
	|			ИЛИ ТиповыеАнкетыВопросыАнкеты.Обязательный = &УсловноОбязательный
	|			ИЛИ ТиповыеАнкетыВопросыАнкеты.Обязательный = &УсловноНеЗаполнять)
	|ИТОГИ
	|	МАКСИМУМ(Обязательный),
	|	МАКСИМУМ(ВопросУсловия),
	|	МАКСИМУМ(УсловиеОтвета),
	|	МАКСИМУМ(ОтветУсловия),
	|	МАКСИМУМ(ТиповойОтветУсловияВопроса),
	|	МАКСИМУМ(ТиповойОтвет)
	|ПО
	|	Вопрос";
	
	Если ПоВопросу <> Неопределено Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ОТБОР_ПО_ВОПРОСУ", "И ТиповыеАнкетыВопросыАнкеты.ВопросУсловия = &ПоВопросу");
	КонецЕсли;
	
	ВыборкаПоОбязательнымОтветам = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
	Пока ВыборкаПоОбязательнымОтветам.Следующий() Цикл
		// 0 – пустое значение
		// 1 - любой ответ
		// 2 - равно
		// 3 - не равно
		// 4 – больше 
		// 5 – больше либо равно
		// 6 – меньше
		// 7 – меньше либо равно
		// 8 – в списке
		// 9 – не в списке
		Если ВыборкаПоОбязательнымОтветам.Обязательный = Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.ОбязателенКЗаполнению тогда
			Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
				Если НеПроверкаНаУсловноНеЗапольнять Тогда
					Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос+""" должен быть обязательно заполнен");
				КонецЕсли;
				ЕстьОшибки = Истина;
			КонецЕсли;
			
		Иначе
			Если ВыборкаПоОбязательнымОтветам.Обязательный = Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.ОбязателенКЗаполнению Тогда
				ТекстОбязательности =  """ должен быть обязательно заполнен, если ";
				
			Иначе
				ТекстОбязательности =  """ не должен заполнятся, если ";
				
			КонецЕсли;
			
			// тут условно-обязательные вопросы
			Если ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 0 тогда
				// 0 – пустое значение
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если НЕ ЗначениеЗаполнено(ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса) тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос+ ТекстОбязательности + "не указан ответ на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 1 тогда
				// 1 – любой ответ, кроме пустого значения
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ЗначениеЗаполнено(ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса) тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности + "указан любой ответ на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 2 тогда
				// 2 - равно
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса = ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности +"указан ответ " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 3 тогда
				// 3 - не равно
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса <> ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности +"указан любой ответ, кроме " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 4 тогда
				// 4 – больше
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса > ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности + "в качестве ответа указано значение больше, чем " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 5 тогда
				// 5 - больше либо равно
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса >= ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности + "в качестве ответа указано значение больше либо равное " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 6 тогда
				// 6 - меньше
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса < ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """+ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности + "в качестве ответа указано значение меньше, чем " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 7 тогда
				// 7 - меньше либо равно
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					Если ВыборкаПоОбязательнымОтветам.ТиповойОтветУсловияВопроса <= ВыборкаПоОбязательнымОтветам.ОтветУсловия тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """ + ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности + "в качестве ответа указано значение меньше либо равное " + ВыборкаПоОбязательнымОтветам.ОтветУсловия + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 8 тогда
				// 8 - в списке
				ЕстьВСписке = Ложь;
				СтрокаЗначенийСписка = "(";
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					// подготовим список значений
					ВыборкаЗначенийСписка = ВыборкаПоОбязательнымОтветам.Выбрать(ОбходРезультатаЗапроса.Прямой);
					Пока ВыборкаЗначенийСписка.Следующий() Цикл
						СтрокаЗначенийСписка = "" + СтрокаЗначенийСписка + ВыборкаЗначенийСписка.ЗначениеСписка + " ";
						Если ВыборкаЗначенийСписка.ТиповойОтветУсловияВопроса = ВыборкаЗначенийСписка.ЗначениеСписка тогда
							ЕстьВСписке = Истина;
							Прервать;
						КонецЕсли;
					КонецЦикла;
					СтрокаЗначенийСписка = СтрокаЗначенийСписка + ")";
					Если ЕстьВСписке тогда
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """ + ВыборкаПоОбязательнымОтветам.Вопрос + ТекстОбязательности +"в качестве ответа указан один из вариантов ответа " + СтрокаЗначенийСписка + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					Иначе
						Продолжить;
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли ВыборкаПоОбязательнымОтветам.УсловиеОтвета = 9 тогда
				// 9 - не в списке
				ЕстьВСписке = Ложь;
				СтрокаЗначенийСписка = "(";
				Если УдовлетворяетУсловию(ВыборкаПоОбязательнымОтветам.Вопрос, ВыборкаПоОбязательнымОтветам.ТиповойОтвет,ВыборкаПоОбязательнымОтветам.Обязательный,НеПроверкаНаУсловноНеЗапольнять) тогда
					// подготовим список значений
					ВыборкаЗначенийСписка = ВыборкаПоОбязательнымОтветам.Выбрать(ОбходРезультатаЗапроса.Прямой);
					Пока ВыборкаЗначенийСписка.Следующий() Цикл
						СтрокаЗначенийСписка = "" + СтрокаЗначенийСписка + ВыборкаЗначенийСписка.ЗначениеСписка + " ";
						Если ВыборкаЗначенийСписка.ТиповойОтветУсловияВопроса = ВыборкаЗначенийСписка.ЗначениеСписка тогда
							ЕстьВСписке = Истина;
							Прервать;
						КонецЕсли;
					КонецЦикла;
					СтрокаЗначенийСписка = СтрокаЗначенийСписка + ")";
					Если ЕстьВСписке тогда
						Продолжить;
					Иначе
						Если НеПроверкаНаУсловноНеЗапольнять Тогда
							Сообщить("Ответ на вопрос """ + ВыборкаПоОбязательнымОтветам.Вопрос + """ должен быть обязательно заполнен, если в качестве ответа не указан ни один из вариантов ответа " + СтрокаЗначенийСписка + " на вопрос """+ ВыборкаПоОбязательнымОтветам.ВопросУсловия + """");
						КонецЕсли;
						ЕстьОшибки = Истина;
					КонецЕсли;
				КонецЕсли;
				
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ЕстьОшибки;
	
КонецФункции // ПроверитьОбязательноЗаполняемыеОтветы()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

#Если Клиент Тогда

Функция ПечатьОпрос()

	Запрос = Новый Запрос;

	Запрос.УстановитьПараметр("ТиповаяАнкета",	ТиповаяАнкета);
	Запрос.УстановитьПараметр("Опрос",			Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТиповыеАнкетыВопросыАнкеты.Ссылка,
	|	ОпросВопросы.Ответ,
	|	ОпросВопросы.ТиповойОтвет,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос КАК Вопрос,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ТипЗначения,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.ТипОтветаНаВопрос,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.КоличествоСтрокТаблицы,
	|	ТиповыеАнкетыВопросыАнкеты.НомерСтроки КАК НомерСтрокиВАнкете,
	|	ТиповыеАнкетыВопросыАнкеты.Вопрос.Код КАК КодВопроса,
	|	ОпросСоставнойОтвет.НомерСтрокиВТаблице,
	|	ОпросСоставнойОтвет.Ответ КАК ОтветВТаблицу,
	|	ОпросСоставнойОтвет.ТиповойОтвет КАК ТиповойОтветВТаблицу,
	|	ВопросыДляАнкетированияКолонкиТаблицы.НомерСтроки КАК НомерКолонки,
	|	ВопросыДляАнкетированияКолонкиТаблицы.КолонкаТаблицы,
	|	ОпросВопросы.ТиповойОтвет.Код КАК КодВариантаОтвета,
	|	ОпросСоставнойОтвет.ТиповойОтвет.Код КАК КодВариантаОтветаНесколько,
	|	ВариантыОтветовОпросов.Код
	|ИЗ
	|	Справочник.ТиповыеАнкеты.ВопросыАнкеты КАК ТиповыеАнкетыВопросыАнкеты
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Опрос.Вопросы КАК ОпросВопросы
	|		ПО ТиповыеАнкетыВопросыАнкеты.Вопрос = ОпросВопросы.Вопрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Опрос.СоставнойОтвет КАК ОпросСоставнойОтвет
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыОтветовОпросов КАК ВариантыОтветовОпросов
	|			ПО ОпросСоставнойОтвет.ТиповойОтвет = ВариантыОтветовОпросов.Ссылка
	|				И (ОпросСоставнойОтвет.Ссылка = &Опрос)
	|			ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.ВопросыДляАнкетирования.КолонкиТаблицы КАК ВопросыДляАнкетированияКолонкиТаблицы
	|			ПО ОпросСоставнойОтвет.Вопрос = ВопросыДляАнкетированияКолонкиТаблицы.КолонкаТаблицы
	|				И ОпросСоставнойОтвет.ВопросВладелец = ВопросыДляАнкетированияКолонкиТаблицы.Ссылка
	|		ПО ТиповыеАнкетыВопросыАнкеты.Вопрос = ОпросСоставнойОтвет.ВопросВладелец
	|			И (ОпросСоставнойОтвет.Ссылка = &Опрос)
	|ГДЕ
	|	ОпросВопросы.Ссылка = &Опрос
	|	И ТиповыеАнкетыВопросыАнкеты.Ссылка = &ТиповаяАнкета
	|ИТОГИ ПО
	|	НомерСтрокиВАнкете,
	|	Вопрос";
	
	МакетАнкеты = ТиповаяАнкета.МакетАнкеты.Получить();
	Если МакетАнкеты = Неопределено Тогда
		МакетАнкеты = Новый ТабличныйДокумент();
		
		Если НЕ ЗначениеЗаполнено(ТиповаяАнкета) Тогда
			Сообщить("Документ не может быть распечатан. Выберите типовую анкету.");
			Возврат Неопределено;
		КонецЕсли;
		
		МакетАнкеты = ТиповаяАнкета.ПолучитьОбъект().СформироватьМакет(МакетАнкеты);
		
	ИначеЕсли ТипЗнч(МакетАнкеты) = Тип("ТабличныйДокумент") тогда
		Если МакетАнкеты.ВысотаТаблицы = 0 Тогда
			МакетАнкеты = Новый ТабличныйДокумент();
			МакетАнкеты = ТиповаяАнкета.ПолучитьОбъект().СформироватьМакет(МакетАнкеты);
		КонецЕсли;
		
	КонецЕсли;

	ОбластьНомераДокумента			= МакетАнкеты.Области["ОбластьНомераДокумента"];
	ОбластьНомераДокумента.Текст	= "Документ Опрос №"+Номер;

	ВыборкаЗапросаПоНомерамСтрок 	= Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "НомерСтрокиВАнкете");
	Пока ВыборкаЗапросаПоНомерамСтрок.Следующий() Цикл
		ВыборкаЗапросаПоВопросам = ВыборкаЗапросаПоНомерамСтрок.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "Вопрос");
		Пока ВыборкаЗапросаПоВопросам.Следующий() Цикл
			Если ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.ОдинИзВариантовОтвета или 
				 ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.НесколькоВариантовОтвета тогда
				ВыборкаЗапросаПоВариантамОтвета = ВыборкаЗапросаПоВопросам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "");
				Пока ВыборкаЗапросаПоВариантамОтвета.Следующий() Цикл
					Если ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.НесколькоВариантовОтвета тогда
						ИмяОбласти = "Вопрос" + ВыборкаЗапросаПоВариантамОтвета.КодВопроса + "ВариантОтвета" + ВыборкаЗапросаПоВариантамОтвета.КодВариантаОтветаНесколько;
					Иначе
						ИмяОбласти = "Вопрос" + ВыборкаЗапросаПоВариантамОтвета.КодВопроса + "ВариантОтвета" + ВыборкаЗапросаПоВариантамОтвета.КодВариантаОтвета;
					КонецЕсли;
					Попытка
					ОбластьОтвета=МакетАнкеты.Области[ИмяОбласти];
					ОбластьЧекБокса = МакетАнкеты.Область("R"+ОбластьОтвета.Верх+"C"+(ОбластьОтвета.Лево));
					ОбластьЧекБокса.Текст = "R";
					ОбластьРазвернутогоОтвета = МакетАнкеты.Область("R"+ОбластьОтвета.Верх+"C"+(ОбластьОтвета.Право+1));
					ОбластьРазвернутогоОтвета.Текст = ОбластьРазвернутогоОтвета.Текст +"   "+ ВыборкаЗапросаПоВариантамОтвета.Ответ + ВыборкаЗапросаПоВариантамОтвета.ОтветВТаблицу;
					Исключение
					КонецПопытки;
				КонецЦикла;
				
			ИначеЕсли ВыборкаЗапросаПоВопросам.ВопросТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Табличный тогда
				ВыборкаЗапросаПоОтветам = ВыборкаЗапросаПоВопросам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "");
				Пока ВыборкаЗапросаПоОтветам.Следующий() Цикл
					Если ВыборкаЗапросаПоОтветам.НомерКолонки = NULL тогда
						Продолжить;
					КонецЕсли;
					ИмяОбласти = "Вопрос" + ВыборкаЗапросаПоОтветам.КодВопроса+"ОтветТаблицы"+ВыборкаЗапросаПоОтветам.НомерКолонки+"Строка"+ВыборкаЗапросаПоОтветам.НомерСтрокиВТаблице;
					Попытка
						//МакетАнкеты.Области[ИмяОбласти].Текст = ВыборкаЗапросаПоОтветам.ТиповойОтветВТаблицу;
						МакетАнкеты.Параметры[ИмяОбласти] = ВыборкаЗапросаПоОтветам.ТиповойОтветВТаблицу;;
					Исключение
						ОбщегоНазначения.СообщитьОбОшибке("Набор вопросов в анкете и в документе ""Опрос"" различны! Не найден вопрос с кодом " + ВыборкаЗапросаПоОтветам.КодВопроса);
					КонецПопытки;
				КонецЦикла;
				
			Иначе
				ВыборкаЗапросаПоОтветам = ВыборкаЗапросаПоВопросам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "");
				Пока ВыборкаЗапросаПоОтветам.Следующий() Цикл
					ИмяОбласти = "ТиповойОтвет" + ВыборкаЗапросаПоОтветам.КодВопроса;
					Попытка
						//МакетАнкеты.Области[ИмяОбласти].Текст = СтрЗаменить(""+ВыборкаЗапросаПоОтветам.ТиповойОтвет, "¤", ",");
						ТиповойОтвет = ?(ВыборкаЗапросаПоОтветам.ТиповойОтвет = Истина, "Да", ВыборкаЗапросаПоОтветам.ТиповойОтвет);
						ТиповойОтвет = ?(ВыборкаЗапросаПоОтветам.ТиповойОтвет = Ложь, "Нет", ВыборкаЗапросаПоОтветам.ТиповойОтвет);
						МакетАнкеты.Параметры[ИмяОбласти] = СтрЗаменить(""+ТиповойОтвет, "¤", ",");
					Исключение
						ОбщегоНазначения.СообщитьОбОшибке("Набор вопросов в анкете и в документе ""Опрос"" различны! Не найден вопрос с кодом " + ВыборкаЗапросаПоОтветам.КодВопроса);
					КонецПопытки;
				КонецЦикла;
				
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	МакетПечати = Новый ТабличныйДокумент();
	Если МакетАнкеты = Неопределено Тогда
		МакетАнкеты = Новый ТабличныйДокумент();
		Если НЕ ЗначениеЗаполнено(ТиповаяАнкета) Тогда
			Сообщить("Документ не может быть распечатан. Выберите типовую анкету.");
			Возврат Неопределено;
		КонецЕсли;
		МакетАнкеты = ТиповаяАнкета.ПолучитьОбъект().СформироватьМакет(МакетАнкеты);
	КонецЕсли;
	МакетПечати.Вывести(МакетАнкеты);
	
	Возврат МакетПечати;

КонецФункции // ПечатьОпрос()

#КонецЕсли

Функция УдовлетворяетУсловию(Вопрос, Параметр, Обязательный = Неопределено, НеПроверкаНаУсловноНеЗапольнять = Ложь)
	
	Если НЕ НеПроверкаНаУсловноНеЗапольнять Тогда
		Возврат Обязательный = Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.УсловноНеЗаполнять;
	КонецЕсли;
	
	Если Обязательный = Перечисления.ОбязательностьЗаполненияОтветаНаВопрос.УсловноНеЗаполнять Тогда
		
		Если Вопрос.ТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Табличный Тогда
			СтрокиПоиска = СоставнойОтвет.НайтиСтроки(Новый Структура("ВопросВладелец", Вопрос));
			
			Для Каждого СтрокаСоставногоОтвета Из СтрокиПоиска Цикл
				Если ЗначениеЗаполнено(СтрокаСоставногоОтвета.ТиповойОтвет) Тогда
					Возврат Истина;
				КонецЕсли;
			КонецЦикла;
			Возврат Ложь;
			
		Иначе
			Возврат ЗначениеЗаполнено(Параметр);
			
		КонецЕсли;
		
	Иначе
		Если Вопрос.ТипОтветаНаВопрос = Перечисления.ТипыОтветаНаВопросАнкеты.Табличный Тогда
			СтрокиПоиска = СоставнойОтвет.НайтиСтроки(Новый Структура("ВопросВладелец", Вопрос));
			
			Для Каждого СтрокаСоставногоОтвета Из СтрокиПоиска Цикл
				Если ЗначениеЗаполнено(СтрокаСоставногоОтвета.ТиповойОтвет) Тогда
					Возврат Ложь;
				КонецЕсли;
			КонецЦикла;
			
			Возврат Истина;
			
		Иначе
			Возврат НЕ ЗначениеЗаполнено(Параметр);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции // УдовлетворяетУсловию()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаЗаполнения(Основание)
	
	Если ТипЗнч(Основание) = Тип("СправочникСсылка.ТиповыеАнкеты") Тогда
		ТиповаяАнкета = Основание;
		ЗаполнитьВопросыАнкеты(Основание);
	КонецЕсли;
	
КонецПроцедуры // ОбработкаЗаполнения()

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ОбщегоНазначения.ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры // ПриУстановкеНовогоНомера()

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
