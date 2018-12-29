﻿Функция URLEncode(стр) Экспорт	
	
	Длина=СтрДлина(Стр);
	Итог="";
	Для Н=1 По Длина Цикл
		Знак=Сред(Стр,Н,1);
		Код=КодСимвола(Знак);
		
		если ((Знак>="a")и(Знак<="z")) или
			 ((Знак>="A")и(Знак<="Z")) или
			 ((Знак>="0")и(Знак<="9")) тогда
			Итог=Итог+Знак;
		Иначе
			Если (Код>=КодСимвола("А"))И(Код<=КодСимвола("п")) Тогда
				Итог=Итог+"%"+ПреобразоватьвСистему(208,16)+"%"+ПреобразоватьвСистему(144+Код-КодСимвола("А"),16);
			ИначеЕсли (Код>=КодСимвола("р"))И(Код<=КодСимвола("я")) Тогда
				Итог=Итог+"%"+ПреобразоватьвСистему(209,16)+"%"+ПреобразоватьвСистему(128+Код-КодСимвола("р"),16);
			ИначеЕсли (Знак="ё") Тогда
				Итог=Итог+"%"+ПреобразоватьвСистему(209,16)+"%"+ПреобразоватьвСистему(145,16);
			ИначеЕсли (Знак="Ё") Тогда
				Итог=Итог+"%"+ПреобразоватьвСистему(208,16)+"%"+ПреобразоватьвСистему(129,16);
			Иначе
				Итог=Итог+"%"+ПреобразоватьвСистему(Код,16);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат Итог;
	
КонецФункции

Функция URLDecoder(URL, WindowsFileURI=Истина)Экспорт

    ДлинаСтроки = СтрДлина(URL);
    Инд = 1;
    Результат = "";
    ПолныйКод = 0;
    ОсталосьСимволов = 0;

    Пока Инд <= ДлинаСтроки Цикл

        Код = КодСимвола(URL, Инд);

        Если Код = 37 Тогда
            // Символ(37) = "%"
            Код = Из16ВЧисло(Сред(URL, Инд+1, 2));
            Инд = Инд + 2;
        ИначеЕсли ОсталосьСимволов = 0 Тогда
            Если (Код = 43) и (не WindowsFileURI) Тогда
                // Символ(43) = "+"
                Код = 32; // Символ(32) = " " (пробел)
            КонецЕсли;
            Результат = Результат + Символ(Код);
            Инд = Инд + 1;
            Продолжить;
        КонецЕсли;

        Если Код <= 127 Тогда
            // Код = 0b0ххххххх
            Результат = Результат + Символ(Код);
        ИначеЕсли Код <= 191 Тогда
            // Код = 0b10хххххх
            ПолныйКод = (ПолныйКод*64) + (Код%64); // shl(ПолныйКод, 6) + (Код & 0x3F)
            ОсталосьСимволов = ОсталосьСимволов - 1;
            Если ОсталосьСимволов = 0 Тогда
                Результат = Результат + Символ(ПолныйКод);
            КонецЕсли;
        ИначеЕсли Код <= 223 Тогда
            // Код = 0b110ххххх
            ПолныйКод = Код % 32; // Код & 0x1F
            ОсталосьСимволов = 1;
        ИначеЕсли Код <= 239 Тогда
            // Код = 0b1110хххх
            ПолныйКод = Код % 16; // Код & 0x0F
            ОсталосьСимволов = 2;
        ИначеЕсли Код <= 247 Тогда
            // Код = 0b11110ххх
            ПолныйКод = Код % 8; // Код & 0x07
            ОсталосьСимволов = 3;
        ИначеЕсли Код <= 251 Тогда
            // Код = 0b111110хх
            ПолныйКод = Код % 4; // Код & 0x03
            ОсталосьСимволов = 4;
        ИначеЕсли Код <= 253 Тогда
            // Код = 0b1111110х
            ПолныйКод = Код % 2; // Код & 0x01
            ОсталосьСимволов = 5;
        КонецЕсли;

        Инд = Инд + 1;
    КонецЦикла;

    Возврат Результат;
КонецФункции

Функция УТФвСтроку(ВхСтр)Экспорт
	
	ВыхСтр="";
	
	поз=1;
    Пока поз<=СтрДлина(ВхСтр) Цикл
		
		симв=Сред(ВхСтр,поз,1);
		
		Если симв="\" И Сред(ВхСтр,поз+1,1)="u" Тогда
           поз=поз+2;
           Вес=4096;
           ВыхКод=0;
           Для п=0 По 3 Цикл
               кодСимв=КодСимвола(ВхСтр,поз+п);
               Если кодСимв>96 Тогда // a-f
                  кодСимв=кодСимв-87;
               ИначеЕсли кодСимв>64 Тогда // A-F
                  кодСимв=кодСимв-55;
               Иначе
                  кодСимв=кодСимв-48; // 0-9
              КонецЕсли;
              ВыхКод=ВыхКод+кодСимв*Вес;
              Вес=Вес/16;
          КонецЦикла;
          ВыхСтр=ВыхСтр+Символ(ВыхКод);
          поз=поз+4;
        Иначе
           ВыхСтр=ВыхСтр+симв;
           поз=поз+1;
	   КонецЕсли;
	   
	КонецЦикла;
	
    Возврат ВыхСтр;
	
КонецФункции

Функция ПреобразоватьвСистему(Число10,система) Экспорт
	
	Если система > 36 или система < 2 тогда
		Сообщить("Выбранная система исчисления не поддерживается");
		Возврат -1;
	КонецЕсли;
	
	СтрокаЗначений = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	СтрокаСистема = "";
	Пока Число10 > 0 цикл
		РезДеления = Число10/система;
		ЧислоСистема = цел(РезДеления);
		остатокОтДеления = Число10 - система*(ЧислоСистема);
		СтрокаСистема = сред(СтрокаЗначений,остатокОтДеления+1,1)+ СтрокаСистема;
		Число10 = ?(ЧислоСистема=0,0,РезДеления); 
	КонецЦикла;
	
	Нечётное = стрДлина(СтрокаСистема) - цел(стрДлина(СтрокаСистема)/2)*2;
	Если Нечётное тогда
		СтрокаСистема = "0"+СтрокаСистема;
	КонецЕсли;
	
	Возврат СтрокаСистема;
	
КонецФункции

Функция Из16ВЧисло(Знач Значение)

    Результат = 0;
    Множитель = 1;
    Пока Значение <> "" Цикл
        Результат = Результат + Множитель * (Найти("0123456789ABCDEF", Прав(Значение,1))-1);
        Множитель = Множитель * 16;
        Значение = Лев(Значение,СтрДлина(Значение)-1);
    КонецЦикла;
    Возврат Результат;

КонецФункции

Функция СформироватьСтрокуJSONИзМассива(Объект)
	
	СтрокаJSON = "[";
	
	Для каждого Элемент Из Объект Цикл
		
		Если ТипЗнч(Элемент) = Тип("Строка") Тогда
			СтрокаJSON = СтрокаJSON + """" + Элемент + """";
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("Число") Тогда
			СтрокаJSON = СтрокаJSON + СтрЗаменить(Строка(Элемент), Символы.НПП, "");
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("Булево") Тогда
			СтрокаJSON = СтрокаJSON + Формат(Элемент, "БЛ=false; БИ=true");
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("Дата") Тогда
			// преобразование в unixtime
			СтрокаJSON = СтрокаJSON + Формат(Элемент - Дата(1970,1,1,1,0,0), "ЧГ=0");
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("Массив") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент);
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("Структура") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент);
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("ТаблицаЗначений") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент);
			
		Иначе
			СтрокаJSON = СтрокаJSON + """" + URLEncode(Строка(Элемент)) + """";
			
		КонецЕсли;
		
		СтрокаJSON = СтрокаJSON + ",";
	КонецЦикла;
	
	Если Прав(СтрокаJSON, 1) = "," Тогда
		СтрокаJSON = Лев(СтрокаJSON, СтрДлина(СтрокаJSON)-1);
	КонецЕсли;
	
	Возврат СтрокаJSON + "]";
	
КонецФункции

Функция СформироватьСтрокуJSONИзСтруктуры(Объект)
	
	СтрокаJSON = "{";
	
	Для каждого Элемент Из Объект Цикл
		
		Если Элемент.Значение = "" Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаJSON = СтрокаJSON + """" + Элемент.Ключ + """" + ":";
		
		Если ТипЗнч(Элемент.Значение) = Тип("Строка") Тогда
			СтрокаJSON = СтрокаJSON + """" + Элемент.Значение + """";
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Число") Тогда
			СтрокаJSON = СтрокаJSON + СтрЗаменить(Строка(Элемент.Значение), Символы.НПП, "");
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Булево") Тогда
			СтрокаJSON = СтрокаJSON + Формат(Элемент.Значение, "БЛ=false; БИ=true");
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Дата") Тогда
			// преобразование в unixtime
			СтрокаJSON = СтрокаJSON + Формат(Элемент.Значение - Дата(1970,1,1,1,0,0), "ЧГ=0");
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент.Значение);
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Структура") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент.Значение);
			
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("ТаблицаЗначений") Тогда
			СтрокаJSON = СтрокаJSON + СформироватьСтрокуJSON(Элемент.Значение);
			
		Иначе
			СтрокаJSON = СтрокаJSON + """" + URLEncode(Строка(Элемент.Значение)) + """";
			
		КонецЕсли;
		
		СтрокаJSON = СтрокаJSON + ",";
		
	КонецЦикла;
	
	Если Прав(СтрокаJSON, 1) = "," Тогда
		СтрокаJSON = Лев(СтрокаJSON, СтрДлина(СтрокаJSON)-1);
	КонецЕсли;
	
	Возврат СтрокаJSON + "}";
	
КонецФункции

Функция СформироватьСтрокуJSON(Объект) Экспорт
	
	СтрокаJSON = "";
	
	Если ТипЗнч(Объект) = Тип("Массив") Тогда
		СтрокаJSON = СформироватьСтрокуJSONИзМассива(Объект);
		
	ИначеЕсли ТипЗнч(Объект) = Тип("Структура") Тогда
		СтрокаJSON = СформироватьСтрокуJSONИзСтруктуры(Объект);
		
	ИначеЕсли ТипЗнч(Объект) = Тип("ТаблицаЗначений") Тогда
		// преобразуем таблицу значений в массив структур - работает дольше, но кода меньше
		// если нужна скорость, то нужно отдельно обработать таблицу значений
		
		СоставСтруктуры = "";
		Для каждого Колонка Из Объект.Колонки Цикл
			СоставСтруктуры = СоставСтруктуры + ?(ЗначениеЗаполнено(СоставСтруктуры), ",", "") + Колонка.Имя;
		КонецЦикла;
		
		МассивСтрок = Новый Массив;
		Для каждого Строка Из Объект Цикл
			СтруктураКолонок = Новый Структура(СоставСтруктуры);
			ЗаполнитьЗначенияСвойств(СтруктураКолонок, Строка);
			МассивСтрок.Добавить(СтруктураКолонок);
		КонецЦикла;
		
		СтрокаJSON = СформироватьСтрокуJSONИзМассива(МассивСтрок);
		
	КонецЕсли;
	
	Возврат СтрокаJSON;
	
КонецФункции

Процедура ЗаполнитьДанныеИзОтветаJSON(Результат, ТекстJSON, ТипДанных)
	
	ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));	// удалим открывающий символ структуры(массива)
	
	НомерЗначения = 0;
	
	Пока ТекстJSON <> "" Цикл
		
		ПервыйСимвол = Лев(ТекстJSON, 1);
		Если ПервыйСимвол = "{" Тогда
			// вложенная структура
			Значение = Новый Структура;
			ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Структура");
			
			Если ТипДанных = "Структура" Тогда
				Результат.Вставить("Значение" + ?(НомерЗначения = 0, "", НомерЗначения), Значение);
				НомерЗначения = НомерЗначения + 1;
			ИначеЕсли ТипДанных = "Массив" Тогда
				Результат.Добавить(Значение);
			КонецЕсли;
		
		ИначеЕсли ПервыйСимвол = "[" Тогда
			// вложенный массив
			Значение = Новый Массив;
			ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Массив");
			
			Если ТипДанных = "Структура" Тогда
				Результат.Вставить("Значение" + ?(НомерЗначения = 0, "", НомерЗначения), Значение);
				НомерЗначения = НомерЗначения + 1;
			Иначе
				Результат.Добавить(Значение);
			КонецЕсли;
			
		ИначеЕсли ПервыйСимвол = "}" И ТипДанных = "Структура" Тогда
			// структура закончилась
			ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));
			Если Лев(ТекстJSON, 1) = "," Тогда
				ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));
			КонецЕсли;
			
			Возврат;
			
		ИначеЕсли ПервыйСимвол = "]" И ТипДанных = "Массив" Тогда
			// массив закончился
			ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));
			Если Лев(ТекстJSON, 1) = "," Тогда
				ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));
			КонецЕсли;
			
			Возврат;
			
		Иначе
			
			Если ТипДанных = "Структура" Тогда
				
				Поз = Найти(ТекстJSON, ":");
				Если Поз = 0 Тогда
					// неверный формат, прервемся
					Прервать;
				КонецЕсли;
				
				ИмяЗначения = СокрЛП(Лев(ТекстJSON, Поз-1));
				
				ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз+1));
				
				Если Лев(ТекстJSON, 1) = "{" Тогда
					// значение является структурой
					Значение = Новый Структура;
					ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Структура");
					
				ИначеЕсли Лев(ТекстJSON, 1) = "[" Тогда
					// значение является массивом
					Значение = Новый Массив;
					ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Массив");
					
				Иначе
					// обычное значение
					Поз = 0;
					Для Сч = 1 По СтрДлина(ТекстJSON) Цикл
						Символ = Сред(ТекстJSON, Сч, 1);
						Если Символ = "," ИЛИ Символ = "]" ИЛИ Символ = "}" Тогда
							Поз = Сч;
							Прервать;
						КонецЕсли;
					КонецЦикла;
					
					Если Поз = 0 Тогда
						Значение = ТекстJSON;
						ТекстJSON = "";
						
					Иначе
						Значение = Лев(ТекстJSON, Поз-1);
						ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз + ?(Сред(ТекстJSON, Поз, 1) = ",", 1, 0)));
						
					КонецЕсли;
					
					Значение = СокрЛП(Значение);
					//Если ОбщегоНазначения.ТолькоЦифрыВСтроке(Значение) Тогда
					//	Значение = Число(Значение);
					//КонецЕсли;
					
				КонецЕсли;
				
				//ИмяЗначенияЭтоЧисло = Ложь;
				//Попытка
				//	ЧислоИмяЗначение = Число(ИмяЗначения);
				//	ИмяЗначенияЭтоЧисло = Истина;
				//Исключение
				//КонецПопытки;
				
				//Результат.Вставить(?(ИмяЗначенияЭтоЧисло = Истина,"НомерСтроки" + ИмяЗначения,ИмяЗначения), Значение);
				Результат.Вставить(ИмяЗначения,Значение);
			ИначеЕсли ТипДанных = "Массив" Тогда
				
				// обычное значение
				Поз = 0;
				Для Сч = 1 По СтрДлина(ТекстJSON) Цикл
					Символ = Сред(ТекстJSON, Сч, 1);
					Если Символ = "," ИЛИ Символ = "]" ИЛИ Символ = "}" Тогда
						Поз = Сч;
						Прервать;
					КонецЕсли;
				КонецЦикла;
				
				Если Поз = 0 Тогда
					Значение = ТекстJSON;
					ТекстJSON = "";
					
				Иначе
					Значение = Лев(ТекстJSON, Поз-1);
					ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз + ?(Сред(ТекстJSON, Поз, 1) = ",", 1, 0)));
					
				КонецЕсли;
				
				Значение = СокрЛП(Значение);
				
				Результат.Добавить(Значение);
				
			КонецЕсли;
				
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЗаполнитьСтруктуруИзОтветаJSON1(Знач ТекстJSON) Экспорт
	
	Результат = Новый Структура;
	
	ТекстJSON = СтрЗаменить(ТекстJSON, "\""", """");	// заменим последовательность \" на "
	ТекстJSON = СтрЗаменить(ТекстJSON, """", "");		// а теперь удалим все кавычки
	
	Если Лев(ТекстJSON, 1) = "{" Тогда
		// начало структуры
		ЗаполнитьДанныеИзОтветаJSON(Результат, ТекстJSON, "Структура");
		
	ИначеЕсли Лев(ТекстJSON, 1) = "[" Тогда
		// начало массива
		МассивДанных = Новый Массив;
		ЗаполнитьДанныеИзОтветаJSON(МассивДанных, ТекстJSON, "Массив");
		
		Результат.Вставить("Значение", МассивДанных);
		
	КонецЕсли;
		
	Возврат Результат;
	
КонецФункции

Функция ЗаполнитьСтруктуруИзОтветаJSON(Знач ТекстJSON) Экспорт
    
    ЧтениеJSON = Новый ЧтениеJSON;
    ЧтениеJSON.УстановитьСтроку(ТекстJSON);
    
    СтруктураДанных = ПрочитатьJSON(ЧтениеJSON);
    
    // тест на неизвестную ошибку - пустой ответ сейл плей
    Попытка
        ЕстьПолеСтатус = СтруктураДанных.Свойство("status");
    Исключение
        ЕстьПолеСтатус = Ложь;
    КонецПопытки; 
    
    Если НЕ ЕстьПолеСтатус = ИСТИНА Тогда
        СтруктураДанных.Вставить("status","unknown error");
    КонецЕсли; 
    
    Попытка
        ЕстьПолеСтатусКод = СтруктураДанных.Свойство("status_code");
    Исключение
        ЕстьПолеСтатусКод = Ложь;
    КонецПопытки; 
    
    Если НЕ ЕстьПолеСтатусКод = ИСТИНА Тогда
        СтруктураДанных.Вставить("status_code","unknown error");
    КонецЕсли; 
    
    Попытка
        ЕстьПолеМесседж = СтруктураДанных.Свойство("message");
    Исключение
        ЕстьПолеМесседж = Ложь;
    КонецПопытки; 
    
    Если НЕ ЕстьПолеМесседж = ИСТИНА Тогда
        СтруктураДанных.Вставить("message","unknown error");
    КонецЕсли; 
    
    СтруктураДанных.status_code = SailPlay_Модуль.ПолучитьСтрокуstatus_code(СтруктураДанных.status_code);
    // тест на неизвестную ошибку
    
    Возврат СтруктураДанных;
КонецФункции