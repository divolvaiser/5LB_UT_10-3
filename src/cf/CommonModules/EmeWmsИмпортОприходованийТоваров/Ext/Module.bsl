﻿// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	Процедура ИмпортироватьОприходованияТоваров импортирует оприходования товаров.
Процедура ИмпортироватьОприходованияТоваров(ERPData) Экспорт
	
	ЗаголовкиСообщений = Новый ТаблицаЗначений();
	EmeWmsERPEngine.GetHeaders(ERPData, "wms", "erp", "receipt", "NEW,WRN", ЗаголовкиСообщений);
	
	Счетчик = 0;
	Для Каждого ЗаголовокСообщения Из ЗаголовкиСообщений Цикл
		
		//	ВАЖНО! Транзакция источника сообщения должна быть внешней	
		EmeWmsERPEngine.BeginImport(ERPData, "wms", "erp", "receipt", ЗаголовокСообщения.id);
		Попытка
			НовоеСообщение = (ЗаголовокСообщения.state = "NEW");
			Трассировка = "";
			ТемаСообщения = "";
			НачатьТранзакцию();
			Попытка
				Пока EmeWmsERPEngine.NextHeaderLine(ERPData) <> 0 Цикл
					Если ERPData.header.asn_id = "" Тогда
						ИмпортироватьОприходованиеТоваров(ERPData, Трассировка, ТемаСообщения);
						Счетчик = Счетчик + 1;
					КонецЕсли
				КонецЦикла;
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение(ОписаниеОшибки());
			КонецПопытки;
			EmeWmsERPEngine.CommitImport(ERPData);
			Если НовоеСообщение И ТемаСообщения <> "" Тогда
				EmeWmsУтилиты.СообщитьПоПочте(
					ТемаСообщения,
					"ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +
					"ID: " + ЗаголовокСообщения.id + Символы.ПС +
					Трассировка);
			КонецЕсли
		Исключение
			EmeWmsERPEngine.RollbackImport(ERPData);
			Ошибка = ОписаниеОшибки();
			Сообщить(Ошибка);
			ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений RECEIPT-коррекция: " + Ошибка);
			EmeWmsУтилиты.СообщитьПоПочте(
				"Критическая ошибка импорта сообщения RECEIPT-коррекция",
				"ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +
				"ID: " + ЗаголовокСообщения.id + Символы.ПС +
				Ошибка);
		КонецПопытки;
		
	КонецЦикла;
	
	Если Счетчик <> 0 Тогда
		Сообщить("Проимпортировали сообщения RECEIPT-коррекция (" + Счетчик + "шт)");
	КонецЕсли
	
КонецПроцедуры

Процедура ИмпортироватьОприходованиеТоваров(ERPData, Трассировка, ТемаСообщения)
	
	//*** Делаем проверки ***

	НомерEME = ERPData.header.id;
	
	Если Не EmeWmsУтилиты.ПолучитьОприходованиеТоваров(НомерEME).Пустая() Тогда
		EmeWmsERPEngine.Success(ERPData);		
		Возврат
	КонецЕсли;
	
	СкладСсылка = Справочники.Склады.НайтиПоРеквизиту("EmeWmsКод", ERPData.header.whs_to_code);
	Если СкладСсылка.Пустая() Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "WHSBAD");
		Возврат
	КонецЕсли;
		
	ОрганизацияСсылка = EmeWmsУтилиты.ПолучитьСсылкуНаОрганизацию();
	Если ОрганизацияСсылка.Пустая() Тогда
		EmeWmsERPEngine.ErrorHeader(ERPData, "VNDBAD");
		Возврат
	КонецЕсли;
	
	//	Соберем товары и количества в карту соответствий (ключ - ссылка на товар, значение - количество)
	КоличестваТоваров = Новый Соответствие();
	EmeWmsERPEngine.SelectChild(ERPData, "lines");
	EmeWmsУтилиты.ПолучитьКоличестваТоваров(ERPData, КоличестваТоваров, "receipt_qty", Ложь);
	
	//	Если были ошибки в номенклатуре - выйдем
	Если EmeWmsERPEngine.HasErrors(ERPData) Тогда
		Возврат
	КонецЕсли;
							
	//*** Проверки сделали, пишем в базу данных 1C ***
	
	Оприходование = Документы.ОприходованиеТоваров.СоздатьДокумент();
	Оприходование.Дата = ТекущаяДата();
	Оприходование.Склад = СкладСсылка;
	Оприходование.Организация = ОрганизацияСсылка;
	Оприходование.ОтражатьВУправленческомУчете = Истина;
	Оприходование.ОтражатьВБухгалтерскомУчете = Истина;
	Оприходование.ОтражатьВНалоговомУчете = Истина;
	Оприходование.Комментарий = "Создан автоматом на основании документа прихода EME: " +
		НомерEME + " (" + ERPData.header.comment + ")";
	Оприходование.EmeWmsНомер = НомерEME;
	Оприходование.EmeWmsДатаИмпорта = ТекущаяДата();
	
	СоздатьТабличнуюЧасть(Оприходование, КоличестваТоваров);

	Оприходование.Записать(РежимЗаписиДокумента.Запись);
	Трассировка = Трассировка + Оприходование + Символы.ПС;
	ТемаСообщения = "Необходимо провести документ по приходу EME " + НомерEME;
	
	EmeWmsERPEngine.Success(ERPData);
		
КонецПроцедуры

Процедура СоздатьТабличнуюЧасть(Оприходование, КоличестваТоваров) Экспорт
	
	//	Добавим недостающие товары
	Для Каждого КоличествоТовара Из КоличестваТоваров Цикл
		
		СтрокаОприходование 				= Оприходование.Товары.Добавить();
		СтрокаОприходование.Номенклатура 	= КоличествоТовара.Ключ;
		СтрокаОприходование.Количество 		= КоличествоТовара.Значение;
		СтрокаОприходование.Коэффициент = 1;
		СтрокаОприходование.ЕдиницаИзмерения = EmeWmsУтилиты.ПолучитьЕдиницуИзмерения(
			СтрокаОприходование.Номенклатура,
			СтрокаОприходование.Номенклатура.БазоваяЕдиницаИзмерения);
			
		//	Симитируем вставку номенклатуры в ФормеДокумента
		ТоварыНоменклатураПриИзменении(Оприходование, СтрокаОприходование)
		
	КонецЦикла;
	
КонецПроцедуры
	
//	Дальнейший код взят из ОприходованиеТоваров.ФормаДокумента
//	ЭтотОбъект заменен на Оприходование

// Производит заполнение и установку необходимых полей при изменении товара в табличной части.
// Вызывается из:
//  ТоварыНоменклатураПриИзменении()
//  ВнешнееСобытие()
//
Процедура ПриИзмененииНоменклатурыТоваров(Оприходование, СтрокаТабличнойЧасти)

	// Заполняем по типу цен
	ОбработкаТабличныхЧастей.ЗаполнитьЕдиницуЦенуПродажиТабЧасти(СтрокаТабличнойЧасти, Оприходование,
		Оприходование.ПолучитьВалютуРегламентированногоУчета(), Оприходование.ПолучитьВалютуУпрУчета());

	// Рассчитываем реквизиты табличной части.
	ОбработкаТабличныхЧастей.ЗаполнитьПроцентРозничнойНаценкиТабЧасти(СтрокаТабличнойЧасти, Оприходование);
	ОбработкаТабличныхЧастей.РассчитатьРозничнуюЦенуТабЧасти(СтрокаТабличнойЧасти, Оприходование, 
		Оприходование.ПолучитьВалютуРегламентированногоУчета());

КонецПроцедуры

// Процедура - обработчик события "ПриИзменении" поля ввода номенклатуры
// в строке табличной части "Товары".
//
Процедура ТоварыНоменклатураПриИзменении(Оприходование, СтрокаТабличнойЧасти)

	//СтрокаТабличнойЧасти = ЭлементыФормы.Товары.ТекущиеДанные;

	// Выполнить общие действия для всех документов при изменении номенклатуры.
	ОбработкаТабличныхЧастей.ПриИзмененииНоменклатурыТабЧасти(СтрокаТабличнойЧасти, Оприходование);

	ПриИзмененииНоменклатурыТоваров(Оприходование, СтрокаТабличнойЧасти);

	ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, Оприходование);

	СтрокаТабличнойЧасти.Качество = Справочники.Качество.Новый;

КонецПроцедуры // ТоварыНоменклатураПриИзменении()
