﻿
Перем мЭтоНовыйЭлемент;
Перем мМонопольныйРежимПередЗаписью;

Функция СообщитьИнформациюПользователюПослеСозданияНовогоУзла() Экспорт
	
	НужноПерезапуститьВсеПодключенияКИБ = Ложь;
	
	Если мЭтоНовыйЭлемент 
		И НЕ ПараметрыСеанса.ИспользованиеРИБ
		И НЕ мМонопольныйРежимПередЗаписью Тогда
		
		НужноПерезапуститьВсеПодключенияКИБ = Истина;
		
	КонецЕсли;	
	
	Если НужноПерезапуститьВсеПодключенияКИБ Тогда
		
		Если мМонопольныйРежимПередЗаписью Тогда
			
			ПолныеПрава.ОпределитьПараметрыСеансаДляОбменаДанными();
			Возврат "";
			
		Иначе	
			
			Возврат "Для корректной работы механизма обмена данными необходимо завершить работу всех пользователей и перезапустить текущий сеанс работы 1С:Предприятия.";	
			
		КонецЕсли;
		
	Иначе
		
		Если мЭтоНовыйЭлемент Тогда
			
			ПолныеПрава.ОпределитьПараметрыСеансаДляОбменаДанными();	
			
		КонецЕсли;
		
		Возврат "";
		
	КонецЕсли;
	
КонецФункции

Процедура ПередЗаписью(Отказ)
	
	мЭтоНовыйЭлемент = ЭтоНовый();
	мМонопольныйРежимПередЗаписью = ОбщегоНазначения.ОпределитьТекущийРежимРаботыМонопольный();
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	СтрокаСообщенияПользователю = СообщитьИнформациюПользователюПослеСозданияНовогоУзла();
	
	#Если Клиент Тогда
	Сообщить(СтрокаСообщенияПользователю);
	#КонецЕсли		
		
КонецПроцедуры

Процедура ОпределитьТипОтправкиДанных(ЭлементДанных, ОтправкаЭлемента) Экспорт
КонецПроцедуры





Процедура ОбработатьСообщение1() Экспорт
	 
	  // ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();      
	  // Если ЧтениеСообщения.Отправитель <> Ссылка Тогда     
	  //  ВызватьИсключение "Неверный узел";     
	  // КонецЕсли;
      

// 	ПланыОбмена.УдалитьРегистрациюИзменений(ЧтениеСообщения.Отправитель,ЧтениеСообщения.НомерПринятого);
      

	  //  // Читаем данные из сообщения
	  //

	  //  // *** XML-сериализация
	  //

	  //  Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
	  //

	  //  	// Читаем очередное значение
	  //

	  //  	Данные = ПрочитатьXML(ЧтениеXML);	
	  //

	  //  	// Записать полученные данные
	  //

	  //  	Данные.ОбменДанными.Отправитель = ЧтениеСообщения.Отправитель;
	  //

	  //  	Данные.ОбменДанными.Загрузка = Истина;
	  //

	  //  	Данные.Записать();
	  //

	  //  КонецЦикла;
	  //

	  //  ЧтениеСообщения.ЗакончитьЧтение();
	  //

	  //  ЧтениеXML.Закрыть();
	  //

	  //  УдалитьФайлы(ИмяФайла);
	  //

//	  //  Сообщить("-------- Конец загрузки------------");
//	ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();
//ЧтениеСообщения.НачатьЧтение(
//	
//	
//	ЗаписьСообщения = ПланыОбмена.СоздатьЗаписьСообщения();    
//	//ЗаписьСообщения.НачатьЗапись(ЗаписьXML, Ссылка);      
//    //Сообщить("Номер сообщения: " + ЗаписьСообщения.НомерСообщения);    
//   	// Получить выборку измененных данных                                
//   	// *** Механизм регистрации изменений      
//    ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(ЗаписьСообщения.Получатель, 
//        ЗаписьСообщения.НомерСообщения);      

//   	Пока ВыборкаИзменений.Следующий() Цикл
//      

//    		// Записать данные в сообщение
//      

//    		// *** XML-сериализация
//     G = 1; 

//   // 		ЗаписатьXML(ЗаписьXML, ВыборкаИзменений.Получить());
//      

//   	КонецЦикла;


КонецПроцедуры 

