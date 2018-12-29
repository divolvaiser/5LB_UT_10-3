﻿
Перем мНеРазрешитьНеуникальныеШтрихкоды;

// Обработчик события "ПередЗаписью".
//
Процедура ПередЗаписью(Отказ, Замещение)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	//Для Каждого ТекущаяЗапись Из ЭтотОбъект Цикл
	//	Если ТипЗнч(ТекущаяЗапись.Владелец) = Тип("СправочникСсылка.Номенклатура") И Не ЗначениеЗаполнено(ТекущаяЗапись.Качество) Тогда
	//		Сообщить("Для товара """ + СокрЛП(ТекущаяЗапись.Владелец) + """ со штрихкодом: " + ТекущаяЗапись.ШтрихКод + " не заполнено качество.");
	//		Отказ = Истина;
	//	КонецЕсли;
	//КонецЦикла;

	Если мНеРазрешитьНеуникальныеШтрихкоды Тогда
		Для Каждого ТекущаяЗапись Из ЭтотОбъект Цикл
			Если ЗначениеЗаполнено(ТекущаяЗапись.ШтрихКод) Тогда
					Запрос = Новый Запрос("
					|ВЫБРАТЬ ПЕРВЫЕ 1
					|	РегШтрихкоды.Владелец КАК Владелец,
					|	РегШтрихкоды.ШтрихКод КАК Штрихкод
					|ИЗ
					|	РегистрСведений.ШтрихкодыЗаказы КАК РегШтрихкоды
					|ГДЕ
					|	РегШтрихкоды.ШтрихКод = &ШтрихКод
					|");
								
				Запрос.УстановитьПараметр("ШтрихКод", ТекущаяЗапись.ШтрихКод);

				РезультатЗапроса = Запрос.Выполнить();
				Если Не РезультатЗапроса.Пустой() Тогда
					Выборка = РезультатЗапроса.Выбрать();
					Выборка.Следующий();

					Сообщить("Штрихкод: " + Выборка.ШтрихКод + " уже имеет владельца """ + СокрЛП(Выборка.Владелец) + """.");
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // ПередЗаписью()

мНеРазрешитьНеуникальныеШтрихкоды = Не Константы.РазрешитьНеуникальныеШтрихкоды.Получить();
