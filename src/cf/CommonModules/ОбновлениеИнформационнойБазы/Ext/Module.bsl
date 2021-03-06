﻿///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБНОВЛЕНИЯ ИБ 

// Процедура проверяет, есть ли необходимость выполнять обновление информационной базы.
// Если необходимо - выполняется обновление.
// Если обновление не удалось выполнить, то
// - предлагает завершить работу системы (в режиме клиента);
// - выбрасывает исключение с описанием ошибки (в режиме внешнего соединения).
//
// Вызывается в режиме клиента или внешнего соединения.
//
// Параметры:
//  Нет.
//
Функция ВыполнитьОбновлениеИнформационнойБазы() Экспорт
	Перем ВыполненноСОшибками;
	ВыполненноСОшибками = Ложь;

	// Проверка необходимости обновления информационной базы.
	НомерВерсии = Константы.НомерВерсииКонфигурации.Получить();
	ПервыйЗапуск = (НомерВерсии = "");

	Если НЕ (НЕ ПустаяСтрока(Метаданные.Версия)
		И НомерВерсии <> Метаданные.Версия) Тогда
		Возврат ВыполненноСОшибками;
	КонецЕсли;

	// < 02.08.17 Вялов - ручное обновление
	
	//// Проверка легальности получения обновления.
	//Если НЕ ОбщегоНазначения.ПроверитьЛегальностьПолученияОбновления(НомерВерсии) Тогда
	//	ВыполненноСОшибками = Истина;
	//	Возврат ВыполненноСОшибками;
	//КонецЕсли;

	//БазоваяПоставка = (Найти(ВРег(Метаданные.Имя), "БАЗОВАЯ") > 0);

	//// Установка монопольного режима для обновления информационной базы.
	//Если НЕ БазоваяПоставка Тогда
	//	// Проверка наличия прав для обновления информационной базы.
	//	Если НЕ ПравоДоступа("МонопольныйРежим", Метаданные) 
	//	 ИЛИ НЕ ПравоДоступа("Использование",    Метаданные.Обработки.ОбновлениеИнформационнойБазы) 
	//	 ИЛИ НЕ ПравоДоступа("Просмотр",         Метаданные.Обработки.ОбновлениеИнформационнойБазы) Тогда
	//		ВыполненноСОшибками = Истина;
	//		ТекстСообщения = "Недостаточно прав для выполнения обновления. Работа системы будет завершена.";
	//		#Если Клиент Тогда
	//		Предупреждение(ТекстСообщения);
	//		глЗапрашиватьПодтверждениеПриЗакрытии = Ложь;
	//		ЗавершитьРаботуСистемы();
	//		#Иначе
	//		ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
	//		ВызватьИсключение ТекстСообщения;
	//		#КонецЕсли
	//		Возврат ВыполненноСОшибками;
	//	КонецЕсли;

	//	// Установка монопольного режима для обновления информационной базы.
	//	Попытка
	//		УстановитьМонопольныйРежим(Истина);
	//	Исключение
	//		ВыполненноСОшибками = Истина;
	//		#Если Клиент Тогда
	//		Сообщить(ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
	//		Предупреждение("Не удалось установить монопольный режим. Работа системы будет завершена.");
	//		глЗапрашиватьПодтверждениеПриЗакрытии = Ложь;
	//		ЗавершитьРаботуСистемы();
	//		#Иначе
	//		ТекстСообщения = "Не удалось установить монопольный режим. Работа системы завершена.";
	//		ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
	//		ВызватьИсключение;
	//		#КонецЕсли
	//		Возврат ВыполненноСОшибками;
	//	КонецПопытки;

	//КонецЕсли;

	//// Обновление информационной базы.
	//Обработки.ОбновлениеИнформационнойБазы.Создать().ВыполнитьОбновление();

	//// Откючение монопольного режима.
	//Если НЕ БазоваяПоставка Тогда
	//	УстановитьМонопольныйРежим(Ложь);
	//КонецЕсли;

	//// Проверка выполнения обновления информационной базы.
	//Если Константы.НомерВерсииКонфигурации.Получить() <> Метаданные.Версия Тогда
	//	#Если Клиент Тогда
	//	Действие = ?(ПервыйЗапуск, "начальное заполнение", "обновление");
	//	
	//	Сообщить("Не выполнено " + Действие + " информационной базы .", СтатусСообщения.Важное);

	//	Текст = "Не выполнено " + Действие + " информационной базы! Завершить работу системы?";
	//	Ответ = Вопрос(Текст, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да, );

	//	Если Ответ = КодВозвратаДиалога.Да Тогда
	//		глЗапрашиватьПодтверждениеПриЗакрытии = Ложь;
	//		ЗавершитьРаботуСистемы();
	//		ВыполненноСОшибками = Истина;
	//	КонецЕсли;
	//	#Иначе
	//	ТекстСообщения = "Не выполнено обновление информационной базы. Работа системы завершена.";
	//	ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
	//	ВызватьИсключение ТекстСообщения;
	//	#КонецЕсли
	//Иначе
	//	ТекстСообщения = "Обновление информационной базы выполнено успешно.";
	//	#Если Клиент Тогда
	//	Сообщить(ТекстСообщения, СтатусСообщения.Информация);
	//	#Иначе
	//	ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Информация, , , ТекстСообщения);
	//	#КонецЕсли
	//КонецЕсли;
	
	НоваяВерсия = Метаданные.Версия; 
	Если НомерВерсии <> НоваяВерсия Тогда
		Попытка
			Константы.НомерВерсииКонфигурации.Установить(НоваяВерсия);
			ТекстСообщения = "Обновление информационной базы выполнено успешно " + НоваяВерсия;
			ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Информация, , , ТекстСообщения);
		Исключение
			ТекстСообщения = "Не выполнено обновление информационной базы. Работа системы завершена.";
			ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
			ЗавершитьРаботуСистемы();
			ВыполненноСОшибками = Истина;
		КонецПопытки;
	КонецЕсли;

	// 02.08.17 Вялов - ручное обновление >

	возврат ВыполненноСОшибками;

КонецФункции

