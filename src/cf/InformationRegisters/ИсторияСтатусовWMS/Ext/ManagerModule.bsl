﻿
// Функция получает текущий статус WMS документа 
//
// Параметры:
//           - "СсылкаНаОбъект" - ссылка на объект БД (Обязательный)
//           - "НаДату"         - дата, на которую необходимо определить статус WMS объекта
Функция ПолучитьТекущийСтатусWMS(СсылкаНаОбъект, НаДату = Неопределено) Экспорт
	
	Если НаДату = Неопределено Тогда
		Возврат РегистрыСведений.ИсторияСтатусовWMS.ПолучитьПоследнее(, Новый Структура("Объект", СсылкаНаОбъект)).Статус;
	Иначе
		Возврат РегистрыСведений.ИсторияСтатусовWMS.ПолучитьПоследнее(НаДату, Новый Структура("Объект", СсылкаНаОбъект)).Статус;
	КонецЕсли;
	
КонецФункции	

// Процедура добавляет для объекта новый статус 
//
// Параметры:
//           - "СсылкаНаОбъект" - ссылка на объект БД (Обязательный)
//           - "НовыйСтатус"    - Новый статус WMS для объекта (Перечисление "СтатусыWMS") (Обязательный)
Процедура ДобавитьОбъектуНовыйСтатусWMS(СсылкаНаОбъект, НовыйСтатус) Экспорт
	
	новМенЗаписиСтатусаWMS = РегистрыСведений.ИсторияСтатусовWMS.СоздатьМенеджерЗаписи();
	новМенЗаписиСтатусаWMS.Период = ТекущаяДата();
	новМенЗаписиСтатусаWMS.Объект = СсылкаНаОбъект; 
	новМенЗаписиСтатусаWMS.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	новМенЗаписиСтатусаWMS.Статус = НовыйСтатус;
	новМенЗаписиСтатусаWMS.Записать();
	
КонецПроцедуры