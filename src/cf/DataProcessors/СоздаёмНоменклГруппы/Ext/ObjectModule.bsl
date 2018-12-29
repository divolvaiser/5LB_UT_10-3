﻿
Процедура СоздатьГруппу (Наименование,Размер) Экспорт
	Если Справочники.НоменклатурныеГруппы.НайтиПоНаименованию(СокрЛП(Наименование),Истина) = Справочники.НоменклатурныеГруппы.ПустаяСсылка() Тогда
		НачатьТранзакцию();
		НомГрупп = Справочники.НоменклатурныеГруппы.СоздатьЭлемент();
		НомГрупп.Наименование = СокрЛП(Наименование);
		НомГрупп.БазоваяЕдиницаИзмерения = Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("796");
		Попытка
			НомГрупп.Записать();
		Исключение
			Сообщить (ОписаниеОшибки());
			ОтменитьТранзакцию();
			возврат;
		КонецПопытки;
		Ед = Справочники.ЕдиницыИзмерения.СоздатьЭлемент();
		Ед.Владелец = НомГрупп.Ссылка;
		Ед.ЕдиницаПоКлассификатору = Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("796");
		Ед.Коэффициент = 1;
		Ед.Наименование = "шт";
		Попытка
			Ед.Записать();
		Исключение
			Сообщить (ОписаниеОшибки());
			ОтменитьТранзакцию();
			возврат;
		КонецПопытки;
		НомГрупп.ЕдиницаХраненияОстатков = Ед.Ссылка;
		Попытка
			НомГрупп.Записать();
		Исключение
			Сообщить (ОписаниеОшибки());
			ОтменитьТранзакцию();
		КонецПопытки;
		
		Свво = РегистрыСведений.ЗначенияСвойствОбъектов.СоздатьМенеджерЗаписи();
		Свво.Объект = НомГрупп.Ссылка;
		Свво.Свойство = ПланыВидовХарактеристик.СвойстваОбъектов.НайтиПоНаименованию("Размер",Истина);
		Свво.Значение = СокрЛП(Размер);
		Попытка
			Свво.Записать();
			ЗафиксироватьТранзакцию();
		Исключение
			Сообщить (ОписаниеОшибки());
			ОтменитьТранзакцию();
		КонецПопытки;
	Иначе
		Ответ = Вопрос ("Эта группа ужЕ существует. Обновить её?", РежимДиалогаВопрос.ДаНет);
		Если Ответ = КодВозвратаДиалога.Да Тогда
			ТекГрупп = Справочники.НоменклатурныеГруппы.НайтиПоНаименованию(СокрЛП(Наименование),Истина).ПолучитьОбъект();
			ТекГрупп.Наименование = Наименование;
			Отбор = Новый Структура("Объект");
			Отбор.Объект = ТекГрупп.Ссылка; 
			ВыбРег = РегистрыСведений.ЗначенияСвойствОбъектов.Выбрать(Отбор);
			Пока ВыбРег.Следующий() Цикл
				Если СокрЛП(ВыбРег.Свойство.Наименование) = СокрЛП("Размер")	Тогда
					Запись = ВыбРег.ПолучитьМенеджерЗаписи();
					Запись.Значение = Размер;
					Запись.Записать();
				КонецЕсли;
			КонецЦикла;
			ТекГрупп.Записать();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура Распределить (Наименование, Описалово) Экспорт
	
	Для каждого стр из СписАк Цикл
		Об = стр.Номенклатура.ПолучитьОбъект();
		Об.НоменклатурнаяГруппа = Справочники.НоменклатурныеГруппы.НайтиПоНаименованию(СокрЛП(Наименование),Истина);
		Об.ДополнительноеОписаниеНоменклатуры = Описалово;
		Попытка
			Об.Записать();
		Исключение
			Сообщить (ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;
		

КонецПроцедуры

