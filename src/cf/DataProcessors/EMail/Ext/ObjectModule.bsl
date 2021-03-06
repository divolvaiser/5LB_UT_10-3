﻿Перем ЧистаяПобеда Экспорт;

Процедура Отправимка_Письмо (ТекстОШ) Экспорт
	ЧистаяПобеда = 0;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ЗаказПокупателя.Ссылка,
	|	ЗаказПокупателя.УдалитьНапомнитьОСобытии,
	|	ЗаказПокупателя.Номер,
	|	ЗаказПокупателя.Дата,
	|	ЗаказПокупателя.Манагер,
	|	ЗаказПокупателя.СтатусыСборкиЗаказа
	|ИЗ
	|	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	|ГДЕ
	|   ЗаказПокупателя.Проведен = ИСТИНА
	|	И ЗаказПокупателя.УдалитьНапомнитьОСобытии=ЛОЖЬ
	|   И ЗаказПокупателя.СтатусыСборкиЗаказа В (&Списак)";
	
	
	Массив = Новый Массив;
	Массив.Добавить(Перечисления.СтатусыСборкиЗаказа.Отказ);
	Массив.Добавить(Перечисления.СтатусыСборкиЗаказа.Перенос);
	Массив.Добавить(Перечисления.СтатусыСборкиЗаказа.Недостача);
	Запрос.УстановитьПараметр("Списак", Массив);
	
	Выб = Запрос.Выполнить().Выбрать();
	
	Если Выб.Количество()=0 Тогда
		ЧистаяПобеда=1;
		возврат;
	КонецЕсли;
	
	Печкин = Справочники.УчетныеЗаписиЭлектроннойПочты.НайтиПоКоду("000000007");
	Профиль = УправлениеЭлектроннойПочтой.ПолучитьИнтернетПочтовыйПрофиль(Печкин);
	Подключились = 0;
	
	ИнтернетПочта = Новый ИнтернетПочта;
	
	Попытка
		ИнтернетПочта.Подключиться(Профиль);
		Подключились = 1;
	Исключение
		Подключились = 0;
		ТекстОШ = "Не подключились "+ОписаниеОшибки();
	КонецПопытки;
	
	Если Подключились=0 Тогда
		возврат;
	КонецЕсли; 
	
	ПочтовоеСообщение = Новый ИнтернетПочтовоеСообщение;
	
	ПочтовоеСообщение.Кодировка = "utf-8";
	ПочтовоеСообщение.ИмяОтправителя  = Печкин.Наименование;
	ПочтовоеСообщение.Отправитель     = Печкин.АдресЭлектроннойПочты;
	ПочтовоеСообщение.Тема            = "Отказы, переносы и недостачи "+ТекущаяДата();
	
	Получатель = ПочтовоеСообщение.Получатели.Добавить();
	Получатель.Адрес           = "robot1c@rambler.ru";
	Получатель.ОтображаемоеИмя = "The-Test";
	Получатель.Кодировка       = "utf-8";
	
	//Получатель = ПочтовоеСообщение.Получатели.Добавить();
	//Получатель.Адрес           = "surrogate98@gmail.com";
	//Получатель.ОтображаемоеИмя = "The-Test2";
	//Получатель.Кодировка       = "utf-8";

	
	ТекстСообщения = ПочтовоеСообщение.Тексты.Добавить();
	ТекстСообщения.Кодировка = "utf-8";
	ТекстСообщения.Текст     = "Перечисленным ниже заказам установлены статусы ""Отказ"", ""Перенос"" или ""Недостача""";
	ТекстСообщения.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;                        
	
	Сбой=0;
	НачатьТранзакцию();
	Пока Выб.Следующий() Цикл
		ОбЗаказ = Выб.Ссылка.ПолучитьОбъект();
		ОбЗаказ.УдалитьНапомнитьОСобытии = Истина;
		Попытка
			ОбЗаказ.Записать(РежимЗаписиДокумента.Запись);
			ТекстСообщения = ПочтовоеСообщение.Тексты.Добавить();
			ТекстСообщения.Кодировка = "utf-8";
			ТекстСообщения.Текст     = "Заказу "+Выб.Номер+" от "+Выб.Дата+" присвоен статус "+Выб.СтатусыСборкиЗаказа+". Менеджер "+?(Выб.Манагер=Справочники.Пользователи.ПустаяСсылка(),"Не указан",Выб.Манагер);
			ТекстСообщения.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;
		Исключение
			Сбой = 1;
			ТекстОШ = "Исключение в попытке записать док "+ОписаниеОшибки();
			прервать;
		КонецПопытки;
	КонецЦикла;
	
	Если Сбой = 1 Тогда
		ОтменитьТранзакцию();
		возврат;
	КонецЕсли;
	
	Попытка
		ИнтернетПочта.Послать(ПочтовоеСообщение);
		ЧистаяПобеда = 1;
		ЗафиксироватьТранзакцию();
	Исключение
		ТекстОШ = "Исключение в попытке послать всех:) "+ОписаниеОшибки();
		ОтменитьТранзакцию();
	КонецПопытки;


КонецПроцедуры