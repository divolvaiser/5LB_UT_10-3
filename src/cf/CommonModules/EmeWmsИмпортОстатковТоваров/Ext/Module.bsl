// Copyright (C) 2012-2016 Engineer Mareev Enterprises

//	ЗаполнитьФактИзEMEНаСервере возвращает дату остатков.
Процедура ЗаполнитьФактИзEMEНаСервере(Склад, ДатаОстатков, КоличестваТоваров) Экспорт
	
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
	
	//	ВАЖНО! Транзакция источника сообщения должна быть внешней
	
	EmeWmsERPEngine.BeginImport(ERPData, "wms", "erp", "remains");
	
	Попытка
		НачатьТранзакцию();
		Попытка
			Пока EmeWmsERPEngine.NextHeaderLine(ERPData) <> 0 Цикл
				Если  ERPData.header.is_manually <> 0 И ERPData.header.whs_code = Склад.EmeWmsКод Тогда
					
					Если ДатаОстатков = Неопределено Тогда
						ДатаОстатков = ERPData.header.created_at;
					Иначе
						EmeWmsERPEngine.SelectChild(ERPData, "registers");
						Пока EmeWmsERPEngine.NextChildLine(ERPData) Цикл
							
							УИДТовара = ERPData.registers.goods_id;
							Если УИДТовара = "" Тогда
								EmeWmsERPEngine.ErrorChild(ERPData, "GDSNUL");
								Продолжить
							КонецЕсли;
							
							ТоварСсылка = EmeWmsУтилиты.ПолучитьСсылкуНаТовар(УИДТовара);
							Если ТоварСсылка.Пустая() Тогда
								EmeWmsERPEngine.ErrorChild(ERPData, "GDSBAD");
								Продолжить
							КонецЕсли;
							
							Количество = ERPData.registers.remains_qty;
							СтароеКоличество = КоличестваТоваров.Получить(ТоварСсылка);
							Если СтароеКоличество = Неопределено Тогда
								НовоеКоличество = Количество;
							Иначе
								НовоеКоличество = СтароеКоличество + Количество;
							КонецЕсли;
							
							КоличестваТоваров.Вставить(ТоварСсылка, НовоеКОличество);
							
						КонецЦикла;
						
						Если EmeWmsERPEngine.HasErrors(ERPData) Тогда
							ДатаОстатков = Неопределено;
						КонецЕсли;
					КонецЕсли;
					
					Прервать;
				КонецЕсли;
			КонецЦикла;
		
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение(ОписаниеОшибки());
		КонецПопытки;
		EmeWmsERPEngine.CommitImport(ERPData);
		
	Исключение
		EmeWmsERPEngine.RollbackImport(ERPData);
		Ошибка = ОписаниеОшибки();
		Сообщить(Ошибка);
	КонецПопытки;
	
	EmeWmsERPEngine.Disconnect(ERPData);
	
КонецПроцедуры
