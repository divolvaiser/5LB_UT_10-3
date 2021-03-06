﻿//НМА 01.07.17

// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	Функция РазрешенКЭкспорту возвращает Истина, если поступление разрешен к экспорту.
Функция РазрешенКЭкспорту(ПоступлениеТоваров) Экспорт
	
	Если ПоступлениеТоваров.ПометкаУдаления Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ПоступлениеТоваров.Проведен Тогда
		Возврат Ложь;
	КонецЕсли;

	Если Не ПоступлениеТоваров.СкладОрдер.EmeWmsУчет Тогда
		Возврат Ложь;
	КонецЕсли;

	//Если Не ПоступлениеТоваров.СтатусПоступленияТоваров = Перечисления.СтатусыПоступленийТоваровИУслуг.КПоступлению Тогда
	//	Возврат Ложь;
	//КонецЕсли;
	Если Не ПоступлениеТоваров.СтатусПоступленияТоваров = Перечисления.СтатусыПоступленийТоваровИУслуг.ВПути Тогда
		Возврат Ложь;
	КонецЕсли;


	Возврат Истина;
	
КонецФункции

//	Процедура ПометитьКЭкспорту помечает поступление к экспорту.
Процедура ПометитьКЭкспорту(ПоступлениеТоваров) Экспорт

	Если Не РазрешенКЭкспорту(ПоступлениеТоваров) Тогда
		Возврат;
	КонецЕсли;
	
	НаборЗаписей = РегистрыСведений.EmeWmsПометкиКЭкспортуПоступленийТоваров.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ПоступлениеТоваров.Установить(ПоступлениеТоваров.Ссылка);
	НаборЗаписей.Прочитать();
	
	Для Каждого Запись Из НаборЗаписей Цикл
		Запись.КЭкспорту = Истина;
		НаборЗаписей.Записать();
		Возврат;
	КонецЦикла;
	
  	НоваяЗапись = РегистрыСведений.EmeWmsПометкиКЭкспортуПоступленийТоваров.СоздатьМенеджерЗаписи();
	НоваяЗапись.ПоступлениеТоваров = ПоступлениеТоваров.Ссылка;
	НоваяЗапись.КЭкспорту = Истина;
    НоваяЗапись.Записать(); 
		 
КонецПроцедуры

//	Функция ПомеченКЭкспорту возвращает Истина, если поступление помечен к экспорту.
Функция ПомеченКЭкспорту(ПоступлениеТоваров) Экспорт
	
	НаборЗаписей = РегистрыСведений.EmeWmsПометкиКЭкспортуПоступленийТоваров.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ПоступлениеТоваров.Установить(ПоступлениеТоваров.Ссылка);
	НаборЗаписей.Прочитать();
	
	Для Каждого Запись Из НаборЗаписей Цикл
		Возврат Запись.КЭкспорту;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

//	Процедура ПодтвердитьЭкспорт подтверждает экспорт поступление.
Процедура ПодтвердитьЭкспорт(ПоступлениеТоваров) Экспорт

	НаборЗаписей = РегистрыСведений.EmeWmsПометкиКЭкспортуПоступленийТоваров.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ПоступлениеТоваров.Установить(ПоступлениеТоваров.Ссылка);
	НаборЗаписей.Прочитать();
	
	Для Каждого Запись Из НаборЗаписей Цикл
		Запись.КЭкспорту = Ложь;
		Запись.ДатаЭкспорта = ТекущаяДата();
		НаборЗаписей.Записать();
		Возврат;
	КонецЦикла;
	
КонецПроцедуры

//	Процедура ПометитьКЭкспорту помечает поступление на событии при записи поступление.
Процедура ПометитьКЭкспортуПриЗаписиПоступление(Источник, Отказ) Экспорт

	ПометитьКЭкспорту(Источник);
		 
КонецПроцедуры

//	Процедура ЭкспортироватьПоступление экспортирует Поступления, помеченные к экспорту.
Процедура ЭкспортироватьПоступление(ERPData) Экспорт
	
    Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	EmeWmsПометкиКЭкспортуПоступленийТоваров.ПоступлениеТоваров.Ссылка КАК Ссылка
		|ИЗ
		|	РегистрСведений.EmeWmsПометкиКЭкспортуПоступленийТоваров КАК EmeWmsПометкиКЭкспортуПоступленийТоваров
		|ГДЕ
		|	EmeWmsПометкиКЭкспортуПоступленийТоваров.КЭкспорту";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Счетчик = 0;
	
	ОшибкиОбработки = "";
	
	Пока Выборка.Следующий() Цикл
		
		//	Защита от плохих данных
		Если Выборка.Ссылка = Null Тогда
			Продолжить;
		КонецЕсли;
			
		//	ВАЖНО! Транзакция источника сообщения должна быть внешней
		НачатьТранзакцию();
		Попытка    		
				
			EmeWmsERPEngine.BeginExport(ERPData, "erp", "wms", "asn");
			Попытка
				
				Если РазрешенКЭкспорту(Выборка.Ссылка) Тогда
					////	Вначале подтверждаем экспорт,
					//ПодтвердитьЭкспорт(Выборка.Ссылка);
					////	а только потом экспортируем, чтобы не потерять флажок КЭКспорту при параллельном изменении данных.
					ЭкспортироватьПоступлениеТоваров(ERPData, Выборка.Ссылка, ОшибкиОбработки);
					ПодтвердитьЭкспорт(Выборка.Ссылка); //НМА 06.12.17
					Счетчик = Счетчик + 1;
				КонецЕсли;
					
				EmeWmsERPEngine.CommitExport(ERPData);
				
			Исключение
				Сообщить(ОписаниеОшибки());
				EmeWmsERPEngine.RollbackExport(ERPData);
				ВызватьИсключение(ОписаниеОшибки());
			КонецПопытки;
				
			ЗафиксироватьТранзакцию();
			
		Исключение
			ОтменитьТранзакцию();
			Ошибка = ОписаниеОшибки();
			Сообщить(Ошибка);
			ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Экспорт сообщения ASN: " + Ошибка);
			ТекстСообщения = "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС + "No: " + Выборка.Ссылка + Символы.ПС + Ошибка;
			EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте("Критическая ошибка экспорта сообщения ASN", ТекстСообщения);
		КонецПопытки;
	
	КонецЦикла;
	
	Если Счетчик <> 0 Тогда
		Сообщить("Проэкспортировали сообщения ASN (" + Счетчик + "шт)");
	КонецЕсли;
	
	Если ОшибкиОбработки <> "" Тогда
		ОшибкиОбработки = "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС + ОшибкиОбработки;
		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте("Ошибки экспорта сообщений ASN", ОшибкиОбработки);
	КонецЕсли; 
	
КонецПроцедуры

//	Процедура ЭкспортироватьПоступлениеТоваров экспортирует одно Поступление.
Процедура ЭкспортироватьПоступлениеТоваров(ERPData, Поступление, ОшибкиОбработки = "")
	
	//	Заголовок Поступления
	EmeWmsERPEngine.AppendHeaderLine(ERPData);
	ERPData.header.id             = Поступление.УникальныйИдентификатор();
	ERPData.header.asn_reg_no	  =	Поступление.Номер;
	ERPData.header.whs_to_code 	  =	EmeWmsУтилиты.ПолучитьКодСклада(Поступление.СкладОрдер);
	Если СокрЛП(Поступление.СкладОрдер.Код) = "000000005" Тогда
		ERPData.header.vendor_to_code =	"7715948131";
	Иначе
		ERPData.header.vendor_to_code =	"1313131313";
	КонецЕсли;
	ERPData.header.supplier_id    =	EmeWmsУтилиты.ПолучитьКод(Поступление.Контрагент);
	ERPData.header.supplier_code  =	EmeWmsУтилиты.ПолучитьКод(Поступление.Контрагент);
	ERPData.header.supplier_name  =	Поступление.Контрагент.Наименование;
	ERPData.header.comment        =	Лев(Поступление.Комментарий, 128);
	
	//	Строки Поступления
	EmeWmsERPEngine.SelectChild(ERPData, "lines");
	КодСтроки = 0;
	////НМА 270717 свернем строки по ГТД перед отправкой в WMS >>
	//ТЗ_ПоступлениеТовары = Поступление.Товары.Выгрузить();
	//ТЗ_ПоступлениеТовары.Свернуть("Номенклатура,Цена,ЕдиницаИзмерения,Коэффициент","Количество");
	//Для Каждого СтрокаТовара Из ТЗ_ПоступлениеТовары Цикл
	////НМА 270717 свернем строки по ГТД перед отправкой в WMS <<
	Для Каждого СтрокаТовара Из Поступление.Товары Цикл
		EmeWmsERPEngine.AppendChildLine(ERPData);
		КодСтроки = КодСтроки + 1;
		ERPData.lines.id			= КодСтроки;
		ERPData.lines.asn_line_no	= СтрокаТовара.НомерСтроки;  //НМА 270717 пометить на удаление
		ERPData.lines.goods_id		= EmeWmsУтилиты.ПолучитьКод(СтрокаТовара.Номенклатура);
		ERPData.lines.goods_code	= EmeWmsУтилиты.ПолучитьКодСпрНоменклатура_НеДляСинхронизации(СтрокаТовара.Номенклатура);
		ERPData.lines.lot_no		= ("-");
		////НМА 190717 ГТД
		//ERPData.lines.gtd_reg_no	= (СтрокаТовара.НомерГТДПоставщика); 
		//ERPData.lines.gtd_line_no   = (СтрокаТовара.КодНоменклатурыПоставщика);
		////НМА 190717 ГТД
		
		ЕдиницаИзмерения = Справочники.ЕдиницыИзмерения.ПустаяСсылка();
		
		// выберем как базовую Единицу измерения с коэффициентом 1
		ЕдИзм_К1 = EmeWmsУтилиты.ПолучитьБазовуюЕдиницуИзмеренияК1(СтрокаТовара.Номенклатура);
		
		Если СтрокаТовара.ЕдиницаИзмерения = ЕдИзм_К1 Тогда // берем кол-во в базовых единицах
			ERPData.lines.quantity		= СтрокаТовара.Количество;
			ERPData.lines.price			= СтрокаТовара.Цена;
			ЕдиницаИзмерения 			= ЕдИзм_К1;
		Иначе
			Если ЕдИзм_К1 <> Неопределено Тогда
				ERPData.lines.quantity	= СтрокаТовара.Количество * СтрокаТовара.Коэффициент; // берем кол-во в базовых единицах
				ERPData.lines.price		= СтрокаТовара.Цена / СтрокаТовара.Коэффициент;
				ЕдиницаИзмерения 		= ЕдИзм_К1;
			Иначе
				ERPData.lines.quantity	= СтрокаТовара.Количество;  // не нашли базовую единицу берем кол-во в текущих единицах (ОШИБКА!)
				ERPData.lines.price		= СтрокаТовара.Цена;
				ЕдиницаИзмерения 		= СтрокаТовара.ЕдиницаИзмерения;
				ОшибкиОбработки = ОшибкиОбработки + Символы.ПС + Поступление + ", не найдена Базовая единица (К = 1) измерения у " + СтрокаТовара.Номенклатура + "";
				ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Экспорт док-та: """ + Поступление + """, не найдена Базовая единица измерения у """ + СтрокаТовара.Номенклатура + """");
			КонецЕсли; 
		КонецЕсли; 
		Если ЗначениеЗаполнено(ЕдиницаИзмерения.ЕдиницаПоКлассификатору.емеКодСинхронизации) Тогда
			ERPData.lines.mu_code		= ЕдиницаИзмерения.ЕдиницаПоКлассификатору.емеКодСинхронизации;
		Иначе
			ERPData.lines.mu_code		= ЕдиницаИзмерения.ЕдиницаПоКлассификатору.Наименование;
		КонецЕсли; 
		
	КонецЦикла;		
	
КонецПроцедуры
