﻿// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	Процедура Импортировать импортирует все сообщения из EME.WMS.
Процедура Импортировать() Экспорт
	
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	//	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		//EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслуг(ERPData);            //НМА 01.07.17
		EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслугПоступления(ERPData);   //НМА 01.07.17
		EmeWmsИмпортРасходныхОрдеров.ИмпортироватьРасходныеОрдера(ERPData);
		EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакПриходы(ERPData);
		EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакОтгрузки(ERPData);
		EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьВозвратыТоваровОтПокупателей(ERPData);
		EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьИСоздатьВозвратыТоваровОтПокупателей(ERPData); //НМА 04.12.17
		EmeWmsИмпортВозвратовТоваровПоставщикам.ИмпортироватьВозвратыТоваровПоставщикамКакОтгрузки(ERPData);  //НМА 04.12.17
		//EmeWmsИмпортКомплектацийНоменклатуры.ИмпортироватьКомплектацииНоменклатуры(ERPData);
		//EmeWmsИмпортСписанийТоваров.ИмпортироватьСписанияТоваров(ERPData);
		//EmeWmsИмпортОприходованийТоваров.ИмпортироватьОприходованияТоваров(ERPData);
		//EmeWmsИмпортИнвентаризацийТоваров.ИмпортироватьИнвентаризацииТоваров(ERPData);
	Исключение
			Ошибка = ОписаниеОшибки();
			Сообщить(Ошибка);
			ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
			ТемаСообщения 	= "Критическая ошибка импорта сообщений";
			ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
			EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
				
	EmeWmsERPEngine.Disconnect(ERPData);
	
КонецПроцедуры

//НМА 13.09.17 >>
Процедура РегламентИмпортироватьПоступленияТоваров() Экспорт
	//ERPData = Новый Структура;
	//EmeWmsERPEngine.Create(ERPData);
	//
	////	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	//ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	//Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
	//	Сообщить("Не найден файл ERPEngine.xml!"); //НМА 05.09.17
	//	ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); //НМА 05.09.17
	//	Возврат;
	//КонецЕсли;
	//
	//Ошибка = EmeWmsERPEngine.Connect(ERPData);
	//Если Ошибка <> "" Тогда
	//	Сообщить(Ошибка);
	//	ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
	//	Возврат;
	//КонецЕсли;
	//
	//Попытка
	//	////EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслуг(ERPData);            //НМА 01.07.17
		//EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслугПоступления(ERPData);   //НМА 01.07.17
	//	//EmeWmsИмпортРасходныхОрдеров.ИмпортироватьРасходныеОрдера(ERPData);
	//	//EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакПриходы(ERPData);
	//	//EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакОтгрузки(ERPData);
	//	//EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьВозвратыТоваровОтПокупателей(ERPData);
	//	////EmeWmsИмпортКомплектацийНоменклатуры.ИмпортироватьКомплектацииНоменклатуры(ERPData);
	//	////EmeWmsИмпортСписанийТоваров.ИмпортироватьСписанияТоваров(ERPData);
	//	////EmeWmsИмпортОприходованийТоваров.ИмпортироватьОприходованияТоваров(ERPData);
	//	////EmeWmsИмпортИнвентаризацийТоваров.ИмпортироватьИнвентаризацииТоваров(ERPData);
	//Исключение
	//		Ошибка = ОписаниеОшибки();
	//		Сообщить(Ошибка);
	//		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
	//		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
	//		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
	//		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	//КонецПопытки;
	//			
	//EmeWmsERPEngine.Disconnect(ERPData);
	
	////////////////////////////////////
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!");
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!");
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслугПоступления_new(ERPData); 
	Исключение
			Ошибка = ОписаниеОшибки();
			Сообщить(Ошибка);
			ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
			ТемаСообщения 	= "Критическая ошибка импорта сообщений";
			ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
			EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
				
	EmeWmsERPEngine.Disconnect(ERPData);
КонецПроцедуры
//НМА 13.09.17 <<

//НМА 06.12.17 >>
Процедура РегламентИмпортироватьЗаказыПокупателей_despatch() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	//	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортРасходныхОрдеров.ИмпортироватьРасходныеОрдера(ERPData);
		EmeWmsИмпортРасходныхОрдеров.ИмпортироватьВозвратыЗаказов(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);
КонецПроцедуры

Процедура РегламентИмпортироватьПеремещенияСоСкладаНаМагазины_despatch() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	//	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		////EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслуг(ERPData);            //НМА 01.07.17
		//EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслугПоступления(ERPData);   //НМА 01.07.17
		//EmeWmsИмпортРасходныхОрдеров.ИмпортироватьРасходныеОрдера(ERPData);
		//EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакПриходы(ERPData);
		EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакОтгрузки(ERPData);
		//EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьВозвратыТоваровОтПокупателей(ERPData);
		//EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьИСоздатьВозвратыТоваровОтПокупателей(ERPData);
		////EmeWmsИмпортКомплектацийНоменклатуры.ИмпортироватьКомплектацииНоменклатуры(ERPData);
		////EmeWmsИмпортСписанийТоваров.ИмпортироватьСписанияТоваров(ERPData);
		////EmeWmsИмпортОприходованийТоваров.ИмпортироватьОприходованияТоваров(ERPData);
		////EmeWmsИмпортИнвентаризацийТоваров.ИмпортироватьИнвентаризацииТоваров(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);	
КонецПроцедуры
//НМА 06.12.17 <<

Процедура РегламентИмпортироватьВнутренниеПеремещения() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); 
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакВнутренние(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
    КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);	
КонецПроцедуры


Процедура РегламентИмпортироватьПеремещенияИзМагазиновНаСклад() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	//	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); 
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); 
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакПриходы(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);	
КонецПроцедуры


//НМА 07.12.17 >>
Процедура РегламентИмпортироватьВозвратыПоставщикам_despatch() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	//	Если файл ERPEngine.xml находится не в C:\inetpub\ERPWebInterface\Settings\	укажите путь до него
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); //НМА 05.09.17
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		//EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслуг(ERPData);            //НМА 01.07.17
		//EmeWmsИмпортПоступленийТоваровУслуг.ИмпортироватьПоступленияТоваровУслугПоступления(ERPData);   //НМА 01.07.17
		//EmeWmsИмпортРасходныхОрдеров.ИмпортироватьРасходныеОрдера(ERPData);
		//EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакПриходы(ERPData);
		//EmeWmsИмпортПеремещенийТоваров.ИмпортироватьПеремещенияТоваровКакОтгрузки(ERPData);
		//EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьВозвратыТоваровОтПокупателей(ERPData);
		//EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьИСоздатьВозвратыТоваровОтПокупателей(ERPData); //НМА 04.12.17
		EmeWmsИмпортВозвратовТоваровПоставщикам.ИмпортироватьВозвратыТоваровПоставщикамКакОтгрузки(ERPData);  //НМА 04.12.17
		//EmeWmsИмпортКомплектацийНоменклатуры.ИмпортироватьКомплектацииНоменклатуры(ERPData);
		//EmeWmsИмпортСписанийТоваров.ИмпортироватьСписанияТоваров(ERPData);
		//EmeWmsИмпортОприходованийТоваров.ИмпортироватьОприходованияТоваров(ERPData);
		//EmeWmsИмпортИнвентаризацийТоваров.ИмпортироватьИнвентаризацииТоваров(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
		EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);
КонецПроцедуры
//НМА 07.12.17 <<

Процедура РегламентИмпортироватьВозвратыТоваровОтПокупателей_despatch() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		Сообщить("Не найден файл ERPEngine.xml!"); 
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Не найден файл ERPEngine.xml!"); 
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортВозвратовТоваровОтПокупателей.ИмпортироватьВозвратыТоваровОтПокупателей(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
		ТемаСообщения 	= "Критическая ошибка импорта сообщений";
		ТекстСообщения 	= "ИБ: " +  СтрокаСоединенияИнформационнойБазы() + Символы.ПС +	Ошибка;
		//EmeWmsУтилиты.ОтправитьСообщениеПоЭлектроннойПочте(ТемаСообщения, ТекстСообщения);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);
КонецПроцедуры


Процедура EmeWmsИмпортироватьИнвентаризации() Экспорт
	ERPData = Новый Структура;
	EmeWmsERPEngine.Create(ERPData);
	
	ERPData.Config = EmeWmsУтилиты.ПутьДоERPEngine();
	Если ERPData.Config = Неопределено Или ERPData.Config = "" Тогда
		ЗаписьЖурналаРегистрации("Экспорт в EME.WMS",,,,"Не найден файл ERPEngine.xml!"); 
		Возврат;
	КонецЕсли;
	
	Ошибка = EmeWmsERPEngine.Connect(ERPData);
	Если Ошибка <> "" Тогда
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Подключение к SQL базе данных: " + Ошибка);
		Возврат;
	КонецЕсли;
	
	Попытка
		EmeWmsИмпортИнвентаризацийТоваров.ИмпортироватьИнвентаризацииТоваров(ERPData);
	Исключение
		Ошибка = ОписаниеОшибки();
		ЗаписьЖурналаРегистрации("Импорт из EME.WMS",,,,"Импорт сообщений: " + Ошибка);
    КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);
КонецПроцедуры

