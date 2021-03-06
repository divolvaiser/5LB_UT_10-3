﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	Для Каждого ТекСтрокаСотрудники Из Сотрудники Цикл
		// регистр Штрафы 
		Движение = Движения.Штрафы.Добавить();
		Движение.Период = ТекСтрокаСотрудники.ДатаШ;
		Движение.Сотрудник = ТекСтрокаСотрудники.Сотрудник;
		Движение.Сумма = ТекСтрокаСотрудники.СуммаШ;
		Движение.Причина = ТекСтрокаСотрудники.ПричинаШ;
		Движение.Магазин = Магазин;
	КонецЦикла;
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ЕстьОШ=0;
	Отказ=Ложь;
	Если Магазин = Справочники.Склады.ПустаяСсылка() Тогда
		Предупреждение ("Необходимо указать принадлежность к магазину");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	Если Сотрудники.Количество()=0 Тогда
		Сообщить ("Документ не заполнен!");
		Отказ = Истина;
		возврат;
	КонецЕсли;
	Для Каждого ТекСтр из Сотрудники Цикл
		Если Формат(ТекСтр.ДатаШ,"ДФ=ММММ") <> Месяц Тогда
			Если ТекСтр.НомерСтроки = Сотрудники.Количество() Тогда
				Предупреждение ("Месяц штрафа должен соответствовать указанному в документе месяцу!");
			КонецЕсли;
			Сообщить ("Ошибка в строке "+ТекСтр.НомерСтроки);
			ЕстьОШ = 1;
		КонецЕсли;
		Если (ТекСтр.ПричинаШ=Справочники.ПричиныШтрафов.ПустаяСсылка()) ИЛИ (ТекСтр.СуммаШ=0) ИЛИ (ТекСтр.Сотрудник=Справочники.Пользователи.ПустаяСсылка()) Тогда
			Сообщить ("В строке "+ТекСтр.НомерСтроки+" не все поля заполнены");
			ЕстьОШ=1;
		КонецЕсли;
	КонецЦикла;
	Если ЕстьОШ=1 Тогда
		Отказ=Истина;
	КонецЕсли;
			
КонецПроцедуры


Процедура ПриКопировании(ОбъектКопирования)
	Сообщить ("Данный документ нельзя копировать!");
	
КонецПроцедуры


		
