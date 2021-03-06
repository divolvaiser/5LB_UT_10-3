﻿// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	Процедура ИмпортироватьИнвентаризацииТоваров импортирует инвентаризации товаров.
Процедура ИмпортироватьИнвентаризацииТоваров(ERPData) Экспорт
	
	ЗаголовкиСообщений = Новый ТаблицаЗначений();
	EmeWmsERPEngine.GetHeaders(ERPData, "wms", "erp", "inventory", "NEW,WRN", ЗаголовкиСообщений);
	
	Счетчик = 0;
	Для Каждого ЗаголовокСообщения Из ЗаголовкиСообщений Цикл
		
		//	ВАЖНО! Транзакция источника сообщения должна быть внешней	
		EmeWmsERPEngine.BeginImport(ERPData, "wms", "erp", "inventory", ЗаголовокСообщения.id);
		Попытка
			НовоеСообщение = (ЗаголовокСообщения.state = "NEW");
			Трассировка = "";
			ТемаСообщения = "";
			НачатьТранзакцию();
			Попытка
				Пока EmeWmsERPEngine.NextHeaderLine(ERPData) <> 0 Цикл
					ИмпортироватьИнвентаризациюТоваров(ERPData, Трассировка, ТемаСообщения);
					Счетчик = Счетчик + 1;
				КонецЦикла;
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение(ОписаниеОшибки());
			КонецПопытки;
			EmeWmsERPEngine.CommitImport(ERPData);
			//Если НовоеСообщение И ТемаСообщения <> "" Тогда
			//	EmeWmsУтилиты.СообщитьПоПочте(
			//		ТемаСообщения,
			//		"ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +
			//		"ID: " + ЗаголовокСообщения.id + Символы.ПС +
			//		Трассировка);
			//КонецЕсли
		Исключение
			EmeWmsERPEngine.RollbackImport(ERPData);
			Ошибка = ОписаниеОшибки();
			//Сообщить(Ошибка);
			ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений INVENTORY: " + Ошибка);
			//EmeWmsУтилиты.СообщитьПоПочте(
			//	"Критическая ошибка импорта сообщения INVENTORY",
			//	"ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +
			//	"ID: " + ЗаголовокСообщения.id + Символы.ПС +
			//	Ошибка);
		КонецПопытки;
		
	КонецЦикла;
	
	//Если Счетчик <> 0 Тогда
	//	Сообщить("Проимпортировали сообщения INVENTORY (" + Счетчик + "шт)");
	//КонецЕсли
	
КонецПроцедуры

Процедура ИмпортироватьИнвентаризациюТоваров(ERPData, Трассировка, ТемаСообщения)
	
	//*** Делаем проверки ***

	НомерEME = ERPData.header.id;
	Если НомерEME = "" Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "IDBAD");
		Возврат;
	КонецЕсли;
	
	Если НЕ ПолучитьИнвенту(НомерEME).Пустая() Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "IDEXST");
		Возврат;
	КонецЕсли;
	
	//СкладСсылка = Справочники.Склады.НайтиПоРеквизиту("EmeWmsКод", ERPData.header.whs_code);
	СкладСсылка = Справочники.Склады.НайтиПоКоду("000000005");
	Если СкладСсылка.Пустая() Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "WHSBAD");
		Возврат
	КонецЕсли;
	
	ОрганизацияСсылка = Справочники.Организации.НайтиПоКоду("000000001");//EmeWmsУтилиты.ПолучитьСсылкуНаОрганизацию();
	Если ОрганизацияСсылка.Пустая() Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "VNDBAD");
		Возврат
	КонецЕсли;
	
	//	Соберем товары и количества в карту соответствий (ключ - ссылка на товар, значение - количество)
	КоличестваТоваровПоУчету = Новый Соответствие();
	КоличестваТоваровПоФакту = Новый Соответствие();
	EmeWmsERPEngine.SelectChild(ERPData, "diff_lines");
	Пока EmeWmsERPEngine.NextChildLine(ERPData) Цикл
		
		//	Количества товаров по учету
		УИДТовара = ERPData.diff_lines.old_goods_id;
		Если УИДТовара = "" Тогда
			//EmeWmsERPEngine.ErrorChild(ERPData, "OLDNUL");
			Продолжить
		КонецЕсли;
		
		ТоварСсылка = EmeWmsУтилиты.ПолучитьСсылкуНаТовар(УИДТовара);
		Если ТоварСсылка.Пустая() Тогда
			//EmeWmsERPEngine.ErrorChild(ERPData, "OLDBAD");
			Продолжить
		КонецЕсли;
		
		Количество = ERPData.diff_lines.old_quantity;
		СтароеКоличество = КоличестваТоваровПоУчету.Получить(ТоварСсылка);
		Если СтароеКоличество = Неопределено Тогда
			НовоеКоличество = Количество;
		Иначе
			НовоеКоличество = СтароеКоличество + Количество;
		КонецЕсли;
		
		КоличестваТоваровПоУчету.Вставить(ТоварСсылка, НовоеКоличество);
		
		//	Количества товаров по факту
		УИДТовара = ERPData.diff_lines.new_goods_id;
		Если УИДТовара = "" Тогда
			//EmeWmsERPEngine.ErrorChild(ERPData, "NEWNUL");
			Продолжить
		КонецЕсли;
		
		ТоварСсылка = EmeWmsУтилиты.ПолучитьСсылкуНаТовар(УИДТовара);
		Если ТоварСсылка.Пустая() Тогда
			//EmeWmsERPEngine.ErrorChild(ERPData, "NEWBAD");
			Продолжить
		КонецЕсли;
		
		Количество = ERPData.diff_lines.new_quantity;
		СтароеКоличество = КоличестваТоваровПоФакту.Получить(ТоварСсылка);
		Если СтароеКоличество = Неопределено Тогда
			НовоеКоличество = Количество;
		Иначе
			НовоеКоличество = СтароеКоличество + Количество;
		КонецЕсли;
		
		КоличестваТоваровПоФакту.Вставить(ТоварСсылка, НовоеКоличество);
		
	КонецЦикла;
	
	//	Если были ошибки в номенклатуре - выйдем
	Если EmeWmsERPEngine.HasErrors(ERPData) Тогда
		Возврат
	КонецЕсли;
	
	Инвента = Документы.ИнвентаризацияТоваровНаСкладе.СоздатьДокумент();
	Инвента.EmeWmsНомер = СокрЛП(НомерEME);
	Инвента.Дата = ТекущаяДата();
	Инвента.Организация = ОрганизацияСсылка;
	Инвента.Склад = СкладСсылка;
	Инвента.Комментарий = "Загружен машиной из ЕМЕ ("+Строка(НомерEME)+"). Количество по данным учета из ЕМЕ!";
	
	//Добавляем строки в инвенту + оставляем только нужные строки для списания и оприходования
	Для Каждого КоличествоТовараПоУчету Из КоличестваТоваровПоУчету Цикл
		
		КоличествоПоФакту = КоличестваТоваровПоФакту.Получить(КоличествоТовараПоУчету.Ключ);
		
		СтрИнвента = Инвента.Товары.Добавить();
		СтрИнвента.ЕдиницаИзмерения = EmeWmsУтилиты.ПолучитьЕдиницуИзмерения(КоличествоТовараПоУчету.Ключ,КоличествоТовараПоУчету.Ключ.БазоваяЕдиницаИзмерения);
		СтрИнвента.Качество = Справочники.Качество.Новый;
		СтрИнвента.Количество = КоличествоПоФакту;
		СтрИнвента.КоличествоУчет = КоличествоТовараПоУчету.Значение;
		СтрИнвента.Коэффициент = СтрИнвента.ЕдиницаИзмерения.Коэффициент;
		СтрИнвента.Номенклатура = КоличествоТовараПоУчету.Ключ;
		СтрИнвента.Цена = ПолучитьСебест(КоличествоТовараПоУчету.Ключ);
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрИнвента, Инвента);
		СтрИнвента.СуммаРегл = СтрИнвента.СуммаУчет;
		
		Если КоличествоПоФакту = Неопределено Тогда
			КоличествоПоФакту = 0;
		КонецЕсли;
		
		КоличествоПоФакту = КоличествоПоФакту - КоличествоТовараПоУчету.Значение;
		Если КоличествоПоФакту = 0 Тогда
			КоличестваТоваровПоФакту.Удалить(КоличествоТовараПоУчету.Ключ);
		Иначе
			КоличестваТоваровПоФакту.Вставить(КоличествоТовараПоУчету.Ключ, КоличествоПоФакту);
		КонецЕсли;
		
	КонецЦикла;
		
	
	Если Инвента.Товары.Количество()>0 Тогда
		Попытка
			Инвента.Записать(РежимЗаписиДокумента.Запись);
		Исключение
			EmeWmsERPEngine.ErrorHeader(ERPData, "WriteErr1С");
			Возврат;
		КонецПопытки;
	Иначе
		EmeWmsERPEngine.Success(ERPData);
		Возврат;
	КонецЕсли;
	
	
	
	//	Раскидаем разницу (факт-учет) на оприходование и списание
	КоличестваТоваровСписания = Новый Соответствие();
	КоличестваТоваровОприходования = Новый Соответствие();
	Для Каждого КоличествоТовараПоФакту Из КоличестваТоваровПоФакту Цикл
		ТоваСсылка = КоличествоТовараПоФакту.Ключ;
		Количество = КоличествоТовараПоФакту.Значение;
		Если Количество < 0 Тогда
			КоличестваТоваровСписания.Вставить(ТоваСсылка, -Количество);
		ИначеЕсли Количество > 0 Тогда
			КоличестваТоваровОприходования.Вставить(ТоваСсылка, Количество);
		КонецЕсли
	КонецЦикла;
	
	//	Спишем товар, если нужно
	Если КоличестваТоваровСписания.Количество() <> 0 И
		EmeWmsУтилиты.ПолучитьСписаниеТоваров(НомерEME).Пустая() Тогда
		
		Списание = Документы.СписаниеТоваров.СоздатьДокумент();
		Списание.Дата = ТекущаяДата();
		Списание.Склад = СкладСсылка;
		Списание.ИнвентаризацияТоваровНаСкладе = Инвента.Ссылка;
		Списание.Организация = ОрганизацияСсылка;
		Списание.ОтражатьВУправленческомУчете = Истина;
		Списание.ОтражатьВБухгалтерскомУчете = Истина;
		Списание.ОтражатьВНалоговомУчете = Истина;
		Списание.Комментарий = "Загружен машиной из ЕМЕ ("+Строка(НомерEME)+")";
		Списание.EmeWmsНомер = НомерEME;
		Списание.EmeWmsДатаИмпорта = ТекущаяДата();
		
		Для Каждого КоличествоТовара Из КоличестваТоваровСписания Цикл
			
			СтрокаСписание 					= Списание.Товары.Добавить();
			СтрокаСписание.Номенклатура 	= КоличествоТовара.Ключ;
			СтрокаСписание.ЕдиницаИзмерения = EmeWmsУтилиты.ПолучитьЕдиницуИзмерения(СтрокаСписание.Номенклатура,СтрокаСписание.Номенклатура.БазоваяЕдиницаИзмерения);
			СтрокаСписание.Коэффициент      = СтрокаСписание.ЕдиницаИзмерения.Коэффициент;
			СтрокаСписание.Количество 		= КоличествоТовара.Значение;
			СтрокаСписание.Цена             = ПолучитьСебест(КоличествоТовара.Ключ);
			ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаСписание, Списание);
			
		КонецЦикла;
		
		Попытка
			Списание.Записать(РежимЗаписиДокумента.Запись);
		Исключение
		КонецПопытки;
		
	КонецЕсли;
	
	//	Оприходуем товар, если нужно
	Если КоличестваТоваровОприходования.Количество() <> 0 И
		EmeWmsУтилиты.ПолучитьОприходованиеТоваров(НомерEME).Пустая() Тогда
		
		Оприходование = Документы.ОприходованиеТоваров.СоздатьДокумент();
		Оприходование.Дата = ТекущаяДата();
		Оприходование.Склад = СкладСсылка;
		Оприходование.ИнвентаризацияТоваровНаСкладе = Инвента.Ссылка;
		Оприходование.Организация = ОрганизацияСсылка;
		Оприходование.ОтражатьВУправленческомУчете = Истина;
		Оприходование.ОтражатьВБухгалтерскомУчете = Истина;
		Оприходование.ОтражатьВНалоговомУчете = Истина;
		Оприходование.Комментарий = "Загружен машиной из ЕМЕ ("+Строка(НомерEME)+")";
		Оприходование.EmeWmsНомер = НомерEME;
				
		Для Каждого КоличествоТовара Из КоличестваТоваровОприходования Цикл
			
			СтрокаОприходование 				= Оприходование.Товары.Добавить();
			СтрокаОприходование.Номенклатура 	= КоличествоТовара.Ключ;
			СтрокаОприходование.Количество 		= КоличествоТовара.Значение;
			СтрокаОприходование.ЕдиницаИзмерения = EmeWmsУтилиты.ПолучитьЕдиницуИзмерения(СтрокаОприходование.Номенклатура,СтрокаОприходование.Номенклатура.БазоваяЕдиницаИзмерения);
			СтрокаОприходование.Коэффициент     = СтрокаОприходование.ЕдиницаИзмерения.Коэффициент;
			СтрокаОприходование.Цена            = ПолучитьСебест(КоличествоТовара.Ключ);
			ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаОприходование, Оприходование);
			СтрокаОприходование.СуммаРегл = СтрокаОприходование.Сумма;
			
		КонецЦикла;
		
		
		Попытка
			Оприходование.Записать(РежимЗаписиДокумента.Запись);
		Исключение
		КонецПопытки;
		
	КонецЕсли;
	
	EmeWmsERPEngine.Success(ERPData);
		
КонецПроцедуры

Функция ПолучитьСебест(Ном)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Рег.ДокументОприходования,
	|	Рег.СтоимостьОстаток,
	|	ЕСТЬNULL(Рег.КоличествоОстаток / Ед.Коэффициент, 1) КАК КоличествоОстаток,
	|	Рег.Номенклатура
	|ПОМЕСТИТЬ ТЗПартии
	|ИЗ
	|	РегистрНакопления.ПартииТоваровНаСкладах.Остатки(, Качество = &Новый) КАК Рег
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЕдиницыИзмерения КАК Ед
	|		ПО Рег.Номенклатура = Ед.Владелец
	|			И Рег.Номенклатура.БазоваяЕдиницаИзмерения = Ед.ЕдиницаПоКлассификатору
	|ГДЕ 
	|   <УсловиеПоНоменклатуреИлиНоменклатурнойГруппе> 
	|	И Рег.Склад <> &Развитие
	|   И Рег.Склад <> &Резервный
	|	И Рег.СтоимостьОстаток > 0
	|	И Рег.КоличествоОстаток > 0
	|	И Рег.ДокументОприходования.Дата МЕЖДУ ДОБАВИТЬКДАТЕ(&ТекДата, Год, -1) И &ТекДата
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СУММА(ТЗПартии.СтоимостьОстаток) / СУММА(ТЗПартии.КоличествоОстаток) КАК Себест
	|ИЗ
	|	ТЗПартии КАК ТЗПартии";
		
	Если (ЗначениеЗаполнено(Ном.НоменклатурнаяГруппа)) И (Ном.НоменклатурнаяГруппа.Родитель = Справочники.НоменклатурныеГруппы.НайтиПоКоду("000000717")) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "<УсловиеПоНоменклатуреИлиНоменклатурнойГруппе>", " Рег.Номенклатура.НоменклатурнаяГруппа = &Ном ");   
		Запрос.УстановитьПараметр("Ном",Ном.НоменклатурнаяГруппа);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "<УсловиеПоНоменклатуреИлиНоменклатурнойГруппе>", " Рег.Номенклатура = &Ном ");   
		Запрос.УстановитьПараметр("Ном",Ном);
	КонецЕсли;	
	
	Запрос.УстановитьПараметр("Новый",Справочники.Качество.Новый);	
	Запрос.УстановитьПараметр("Развитие",Справочники.Склады.НайтиПоКоду("547"));
	Запрос.УстановитьПараметр("ТекДата",КонецДня(ТекущаяДата()));
	
	Запрос.УстановитьПараметр("Резервный",Справочники.Склады.НайтиПоКоду("5"));
		
	Рез = Запрос.Выполнить().Выбрать();
	Рез.Следующий();
	Возврат Рез.Себест;
		 
 КонецФункции

Функция ПолучитьИнвенту(НомерEME) 
		
	Запрос = Новый Запрос();
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Инвента.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ИнвентаризацияТоваровНаСкладе КАК Инвента
		|ГДЕ
		|	Инвента.EmeWmsНомер = &НомерEME
		|	И НЕ Инвента.ПометкаУдаления";
	Запрос.УстановитьПараметр("НомерEME", СокрЛП(НомерEME));
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;

	Возврат Документы.ИнвентаризацияТоваровНаСкладе.ПустаяСсылка();
	
КонецФункции
