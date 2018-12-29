﻿//#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

//#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	
	ВладелецХарактеристики = ЭтотОбъект.Владелец;
	
	Если ЗначениеЗаполнено(ВладелецХарактеристики) Тогда
		
		Запрос = Новый Запрос;
		ФлагКонтролироватьДублиХарактеристик = Ложь;
		
		Если ТипЗнч(ВладелецХарактеристики) = Тип("СправочникСсылка._ВидыНоменклатуры_УТ11") Тогда
			ФлагКонтролироватьДублиХарактеристик = ВладелецХарактеристики.КонтролироватьДублиХарактеристик; 
		ИначеЕсли ТипЗнч(ВладелецХарактеристики) = Тип("СправочникСсылка._Номенклатура_УТ11") Тогда
			ФлагКонтролироватьДублиХарактеристик = ВладелецХарактеристики.ВидНоменклатуры.КонтролироватьДублиХарактеристик; 			
		Иначе
			Возврат;
		КонецЕсли;
		
		Если ФлагКонтролироватьДублиХарактеристик Тогда
			стрНаименование = НРег(СокрЛП(ЭтотОбъект.Наименование));
			//НайденЭлемент = Справочники._Номенклатура_УТ11.НайтиПоНаименованию(стрНаименование, Истина);
			НайденЭлемент = Справочники._ХарактеристикиНоменклатуры_УТ11.ПустаяСсылка();
			
			Запрос = Новый Запрос;
			Запрос.Текст = 
				"ВЫБРАТЬ
				|	Характеристика_УТ11.Ссылка
				|ИЗ
				|	Справочник._ХарактеристикиНоменклатуры_УТ11 КАК Характеристика_УТ11
				|ГДЕ
				|	Характеристика_УТ11.Владелец = &Владелец
				|	И Характеристика_УТ11.Ссылка <> &ОбъектСсылка
				|	И Характеристика_УТ11.Наименование = &Наименование
				|";						
			Запрос.УстановитьПараметр("Владелец", 		ВладелецХарактеристики);
			Запрос.УстановитьПараметр("ОбъектСсылка", 	ЭтотОбъект.Ссылка);
			Запрос.УстановитьПараметр("Наименование", 	СокрЛП(стрНаименование));
			
			РезультатЗапроса = Запрос.Выполнить();                 	
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();   	
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				НайденЭлемент = ВыборкаДетальныеЗаписи.Ссылка;
			КонецЦикла;
			
			Если НайденЭлемент <> Справочники._ХарактеристикиНоменклатуры_УТ11.ПустаяСсылка() Тогда
				Сообщить("В базе уже есть характеристика с наименованием """ + стрНаименование + """!");
				Отказ = Истина;
			КонецЕсли;	
		КонецЕсли;	
	КонецЕсли;
	
	// не переводить в нижний регистр!
	//Если Найти(НРег(Строка(ЭтотОбъект.Владелец)), "размер") > 0 Тогда
	//Иначе	
	//	ЭтотОбъект.Наименование = НРег(СокрЛП(ЭтотОбъект.Наименование));
	//КонецЕсли;

	Если ЗначениеЗаполнено(ЭтотОбъект.Наименование) Тогда
		ЭтотОбъект.НаименованиеПолное = ЭтотОбъект.Наименование;
	КонецЕсли;

	//ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	//
	//ФормироватьРабочееНаименование =		Не (ДополнительныеСвойства.Свойство("РабочееНаименованиеСформировано"));
	//ФормироватьНаименованиеДляПечати =		Не (ДополнительныеСвойства.Свойство("НаименованиеДляПечатиСформировано"));
	//
	//Если ФормироватьРабочееНаименование
	//	Или ФормироватьНаименованиеДляПечати Тогда
	//	
	//	СтруктураРеквизитов = Новый Структура;
	//	
	//	Если ТипЗнч(Владелец) = Тип("СправочникСсылка.ВидыНоменклатуры") Тогда
	//		СтруктураРеквизитов.Вставить("ШаблонРабочегоНаименованияХарактеристики");
	//		СтруктураРеквизитов.Вставить("ЗапретРедактированияРабочегоНаименованияХарактеристики");
	//		СтруктураРеквизитов.Вставить("ШаблонНаименованияДляПечатиХарактеристики");
	//		СтруктураРеквизитов.Вставить("ЗапретРедактированияНаименованияДляПечатиХарактеристики");
	//	Иначе 
	//		СтруктураРеквизитов.Вставить("ШаблонРабочегоНаименованияХарактеристики","ВидНоменклатуры.ШаблонРабочегоНаименованияХарактеристики");
	//		СтруктураРеквизитов.Вставить("ЗапретРедактированияРабочегоНаименованияХарактеристики","ВидНоменклатуры.ЗапретРедактированияРабочегоНаименованияХарактеристики");
	//		СтруктураРеквизитов.Вставить("ШаблонНаименованияДляПечатиХарактеристики","ВидНоменклатуры.ШаблонНаименованияДляПечатиХарактеристики");
	//		СтруктураРеквизитов.Вставить("ЗапретРедактированияНаименованияДляПечатиХарактеристики","ВидНоменклатуры.ЗапретРедактированияНаименованияДляПечатиХарактеристики");
	//	КонецЕсли;
	//
	//	РеквизитыОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Владелец, СтруктураРеквизитов);
	//	
	//	Если ФормироватьРабочееНаименование 
	//		И ЗначениеЗаполнено(РеквизитыОбъекта.ШаблонРабочегоНаименованияХарактеристики) 
	//		И (РеквизитыОбъекта.ЗапретРедактированияРабочегоНаименованияХарактеристики 
	//		Или Не ЗначениеЗаполнено(Наименование)) Тогда
	//		ШаблонНаименования = РеквизитыОбъекта.ШаблонРабочегоНаименованияХарактеристики;
	//		Наименование = НоменклатураСервер.НаименованиеПоШаблону(ШаблонНаименования, ЭтотОбъект);
	//	КонецЕсли;
	//	
	//	Если ФормироватьНаименованиеДляПечати
	//		И ЗначениеЗаполнено(РеквизитыОбъекта.ШаблонНаименованияДляПечатиХарактеристики) 
	//		И (РеквизитыОбъекта.ЗапретРедактированияНаименованияДляПечатиХарактеристики 
	//		Или Не ЗначениеЗаполнено(НаименованиеПолное)) Тогда
	//		ШаблонНаименованияДляПечати = РеквизитыОбъекта.ШаблонНаименованияДляПечатиХарактеристики;
	//		НаименованиеПолное = НоменклатураСервер.НаименованиеПоШаблону(ШаблонНаименованияДляПечати, ЭтотОбъект);
	//	КонецЕсли;
	//	
	//КонецЕсли;
	//
	//Если Не ЗначениеЗаполнено(Наименование) Тогда
	//	ТекстИсключения = НСтр("ru='Поле ""Рабочее наименование"" не заполнено'");
	//	ВызватьИсключение ТекстИсключения; 
	//	Отказ = Истина;
	//КонецЕсли;
	//
	//КонтролироватьРабочееНаименование = Константы.КонтролироватьУникальностьРабочегоНаименованияНоменклатурыИХарактеристик.Получить()
	//И Не (ДополнительныеСвойства.Свойство("РабочееНаименованиеПроверено"));
	//
	//Если КонтролироватьРабочееНаименование
	//	И Не Отказ Тогда
	//	Если Не Справочники.ХарактеристикиНоменклатуры.РабочееНаименованиеУникально(ЭтотОбъект) Тогда
	//		ТекстИсключения = НСтр("ru='Значение поля ""Рабочее наименование"" не уникально'");
	//		ВызватьИсключение ТекстИсключения; 
	//		Отказ = Истина;
	//	КонецЕсли;
	//КонецЕсли;
	//
	//// Обработка смены пометки удаления.
	//Если Не ЭтоНовый() Тогда

	//	Если ПометкаУдаления <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ПометкаУдаления") Тогда
	//		Справочники.КлючиАналитикиУчетаНоменклатуры.УстановитьПометкуУдаления(Новый Структура("Характеристика", Ссылка), ПометкаУдаления);
	//	КонецЕсли;

	//КонецЕсли;
	//
	//ЗапрашиваемыеРеквизиты  = Новый Структура;
	//
	//Если ТипЗнч(Владелец) = Тип("СправочникСсылка.ВидыНоменклатуры") Тогда
	//	ЗапрашиваемыеРеквизиты.Вставить("ВариантОказанияУслуг");
	//	ЗапрашиваемыеРеквизиты.Вставить("ТипНоменклатуры");
	//Иначе 
	//	ЗапрашиваемыеРеквизиты.Вставить("ВариантОказанияУслуг","ВидНоменклатуры.ВариантОказанияУслуг");
	//	ЗапрашиваемыеРеквизиты.Вставить("ТипНоменклатуры");
	//КонецЕсли;
	//
	//РеквизитыОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Владелец, ЗапрашиваемыеРеквизиты);
	//
	//Если РеквизитыОбъекта.ВариантОказанияУслуг <> Перечисления.ВариантыОказанияУслуг.ОрганизациейПродавцом
	//	И РеквизитыОбъекта.ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Услуга
	//	И НЕ ЗначениеЗаполнено(Принципал) 
	//Тогда 
	//	ТекстИсключения = НСтр("ru='Не указан принципал'");
	//		ВызватьИсключение ТекстИсключения; 
	//		Отказ = Истина;
	//КонецЕсли;
	//
	//Если ЗначениеЗаполнено(Принципал)
	//	И ТипЗнч(Принципал) = Тип("СправочникСсылка.Организации")
	//Тогда
	//	Контрагент = Принципал;
	//КонецЕсли;

КонецПроцедуры // ПередЗаписью()

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод
	|ИЗ
	|	РегистрСведений._ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|ГДЕ
	|	ШтрихкодыНоменклатуры.Характеристика = &Характеристика";
	
	Запрос.УстановитьПараметр("Характеристика", Ссылка);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		НаборЗаписей = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Штрихкод.Значение = Выборка.Штрихкод;
		НаборЗаписей.Отбор.Штрихкод.Использование = Истина;
		НаборЗаписей.Записать();
	КонецЦикла;
	
КонецПроцедуры // ПередУдалением()

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	МассивНепроверяемыхРеквизитов = Новый Массив;
	МассивНепроверяемыхРеквизитов.Добавить("Наименование");
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
КонецПроцедуры

//#КонецОбласти

//#КонецЕсли