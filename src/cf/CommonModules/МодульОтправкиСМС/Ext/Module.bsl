﻿
Процедура ОтправитьСМСУпрощённая(НомерТелефона, ТекстСмс, РезультатОтправки) Экспорт 
	   
	  SMSC_LOGIN = "5lb";
	  SMSC_PASSWORD = "kxEormpFahWM51PF";//***{+Редактирования}*** Тасмаджиев 15/11/2018// ->> //"3fR5bVc0zQ";	
	  Транслит = Ложь;
	  ДатаОтправкиСтрока = "";
	  флФлэш  = Ложь;
	  SMSC_Отправитель = "";
	  SMSC_ЧасовойПояс = 0;
	  СрокЖизниSMS = 24;
	  
	  СтрокаСообщений = НомерТелефона+":"+ТекстСмс;
	  
	  
	  Ответ = ПослатьSMS("", "", Транслит, ДатаОтправкиСтрока, 0, флФлэш, SMSC_Отправитель, "tz=" + SMSC_ЧасовойПояс + "&valid=" + СрокЖизниSMS + "&list=" + URLEncode(СтрокаСообщений));
	  
	  
КонецПроцедуры


Функция ПослатьSMS(Телефоны, Сообщение, Транслит = Ложь, Время = "", ИД = 0, ФорматСообщения = 0, Отправитель = "", ДопПараметры = "")
		SMSC_DEBUG = Ложь;
	
    Ответ = _SMSC_ПослатьКоманду ("send", "cost=3&phones=" + URLEncode(Телефоны) + "&mes=" + URLEncode(Сообщение) + 
                    "&translit=" + ?(Транслит,1,0) + "&id=" + XMLСТрока(ИД) + ?(ФорматСообщения > 0, "&" + ФорматыСообщений(ФорматСообщения), "") +
					?(ПустаяСтрока(Отправитель), "", "&sender=" + URLEncode(Отправитель)) + 
                    ?(ПустаяСтрока(Время), "", "&time=" + URLEncode(Время)) +
					?(ПустаяСтрока(ДопПараметры), "", "&" + ДопПараметры));

    // (id, cnt, cost, balance) или (id, -error)

    Если SMSC_DEBUG = 1 Тогда

		РезИД = Число(Ответ[0].Значение);
		Рез = Число(Ответ[1].Значение);
		Если (Рез > 0) Тогда
            Сообщить ("Сообщение отправлено успешно. ID: " + РезИД + ", всего SMS: " + Ответ[1].Значение + 
					", стоимость: " + Ответ[2].Значение + " руб., баланс: " + Ответ[3].Значение + " руб.");
        Иначе       
            Сообщить ("Ошибка № " + Строка(-Рез) + ?(РезИД > 0, ", ID: " + РезИД, ""));
		КонецЕсли;	

	КонецЕсли;

    Возврат Ответ;
	
КонецФункции // ПослатьSMS()

Функция _SMSC_ПослатьКоманду(Команда, Аргументы = "") 
	 SMSC_LOGIN = "5lb";
	  SMSC_PASSWORD = "kxEormpFahWM51PF"; //***{+Редактирования}*** Тасмаджиев 15/11/2018// ->> //"3fR5bVc0zQ"; 
	SMSC_DEBUG = Ложь;
	Сервер = "smsc.ru";
	Ресурс = "/sys/" + Команда + ".php";
	_Параметры = "login=" + СокрЛП(URLEncode(SMSC_LOGIN)) + "&psw=" + СокрЛП(URLEncode(SMSC_PASSWORD)) + "&fmt=1&charset=utf-16" +
		?(Не ПустаяСтрока(Аргументы), "&" + СокрЛП(Аргументы), "");
	Для Сч = 1 По 5 Цикл
    	
		Если Сч > 1 Тогда
			Сервер = "www" + Сч + ".smsc.ru";
		КонецЕсли;	
			
		Сообщить("URL: "+ Сервер + Ресурс);
		Рез = _SMSC_ПрочитатьАдрес(Сервер, Ресурс, _Параметры);
		
		Если НЕ ПустаяСтрока(Рез) Тогда
		    Прервать;
		КонецЕсли;
		
	КонецЦикла;                       
	
	Если ПустаяСтрока (Рез)  Тогда

		Если SMSC_DEBUG = 1 Тогда
	        Сообщить("Ошибка чтения адреса: "+ Сервер + Ресурс + "?" + _Параметры);
		КонецЕсли;                                                    
		
		Рез = "," // Фиктивный ответ
		
	КонецЕсли;                       
	
	Возврат Строка2Список(Рез);
	
КонецФункции // _SMSC_ПослатьКоманду() 

Функция _SMSC_ПрочитатьАдрес(Сервер, РесурсНаСервере, _Параметры) Экспорт
	Перем Рез;
	
	ПРОКСИ_ЛОГИН = Неопределено;
	ПРОКСИ_ПАРОЛЬ = Неопределено;
	ПРОКСИ_АДРЕС = Неопределено;
	ПРОКСИ_ПОРТ = Неопределено;
	SMSC_HTTPS = 1;	
	
		 
	
	ЕСТЬ_ПРОКСИ = Ложь;
	
	Прокси = Неопределено;
	Если ЕСТЬ_ПРОКСИ Тогда
        Прокси = Новый ИнтернетПрокси;
        Прокси.НеИспользоватьПроксиДляЛокальныхАдресов = Истина;
        Прокси.Пользователь = ПРОКСИ_ЛОГИН; 
        Прокси.Пароль = ПРОКСИ_ПАРОЛЬ; 
		Прокси.Установить("http" + ?(SMSC_HTTPS=1, "s", ""), ПРОКСИ_АДРЕС, ПРОКСИ_ПОРТ);
	КонецЕсли;
	Попытка
		Если SMSC_HTTPS = 0 Тогда
        	Соединение = Новый HTTPСоединение(Сервер, , , , Прокси, Ложь);
		Иначе
			Соединение = Новый HTTPСоединение(Сервер, , , , Прокси, 10, Новый ЗащищенноеСоединениеOpenSSL);
		Конецесли;
	Исключение
	    Сообщить("Не удалось установить соединение с сервером:" 
	        + Символы.ПС + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
	    Возврат "";
	КонецПопытки;

	ИмяФайлаРезультата = ПолучитьИмяВременногоФайла();
	
	РесурсПараметры = РесурсНаСервере+"?"+_Параметры;
	Если СтрДлина(РесурсПараметры) < 2000 Тогда // GET 
		
		Попытка
			Соединение.Получить(РесурсПараметры, ИмяФайлаРезультата);
		    Соединение = Неопределено;
		Исключение 
			Сообщить("Не удалось получить данные с сервера", СтатусСообщения.Важное);
			Возврат "";
		КонецПопытки;
			
	Иначе // POST	
		
		//Создаём файл отправки - содержимое POST-запроса. 
		ИмяФайлаОтправки = ПолучитьИмяВременногоФайла();
		ФайлОтправки = Новый ЗаписьТекста(ИмяФайлаОтправки, КодировкаТекста.ANSI, Символы.ПС, ЛОЖЬ);
		ФайлОтправки.Записать(_Параметры);
		ФайлОтправки.Закрыть();

		//Формируем заголовок POST-запроса.
	    ЗаголовокHTTP = Новый Соответствие();
	    ЗаголовокHTTP.Вставить("Content-Type", "application/x-www-form-urlencoded");
	    ФайлОтправки = Новый Файл(ИмяФайлаОтправки); 
	    РазмерФайлаОтправки = XMLСтрока(ФайлОтправки.Размер()); 
		ЗаголовокHTTP.Вставить("Content-Length", Строка(РазмерФайлаОтправки)); 

		Попытка
	 		Соединение.ОтправитьДляОбработки(ИмяФайлаОтправки, РесурсНаСервере, ИмяФайлаРезультата, ЗаголовокHTTP);
			Соединение = Неопределено;
		Исключение 
			Сообщить("Не удалось получить данные с сервера:" + Символы.ПС + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
			Возврат "";
		КонецПопытки;
		
	КонецЕсли;	
		
	ФайлРезультата = Новый ЧтениеТекста(ИмяФайлаРезультата);
	Рез = ФайлРезультата.ПрочитатьСтроку();
	
	Возврат Рез;
	
КонецФункции //_SMSC_ПрочитатьАдрес()



функция Hex(КС)
	
	_Hex = Новый Массив(16);
	_Hex[0]="0";
	_Hex[1]="1";
	_Hex[2]="2";
	_Hex[3]="3";
	_Hex[4]="4";
	_Hex[5]="5";
	_Hex[6]="6";
	_Hex[7]="7";
	_Hex[8]="8";
	_Hex[9]="9";
	_Hex[10]="A";
	_Hex[11]="B";
	_Hex[12]="C";
	_Hex[13]="D";
	_Hex[14]="E";
	_Hex[15]="F";	
	
	возврат(_Hex[Цел(КС/16)] + _Hex[Цел(КС%16)]);
	
конецфункции


Функция URLEncode(Стр1)
             
	Рез = ""; 
	Стр= СокрЛП(Стр1);
	Для Сч=1 По СтрДлина(Стр) Цикл
           
		Символ = Сред(Стр, Сч, 1);
		КС = КодСимвола(Символ);
		
		Рез = Рез + "%"+ Hex(Цел(КС/256)) + "%"+ Hex(КС%256);
		
	КонецЦикла;
 
	Возврат Рез;
КонецФункции // URLEncode() 

функция ФорматыСообщений(_фс)
	//перем _ФорматыСообщений;
	//_ФорматыСообщений = Новый Массив(7);
	//_ФорматыСообщений[1] = "flash=1";
	//_ФорматыСообщений[2] = "push=1";
	//_ФорматыСообщений[3] = "hlr=1";
	//_ФорматыСообщений[4] = "bin=1";
	//_ФорматыСообщений[5] = "bin=2";
	//_ФорматыСообщений[6] = "ping=1";	
	возврат(?(_фс,"flash=1",""));
конецфункции

Функция Строка2Список(Стр)       
	
	Перем Рез;
	    
	Рез = Новый СписокЗначений;
	Сч = 1;
	
	Для Сч = 1 По 4 Цикл
	    
		Поз = Найти(Стр, ","); 
		
		Если Поз = 0 Тогда
		    Рез.Добавить(Стр);
		    Прервать;                 
		Иначе	
			Рез.Добавить(Лев(Стр,Поз-1));
		КонецЕсли;	 
		
		Стр = Сред(Стр, Поз+1, СтрДлина(Стр)-Поз);
		
	КонецЦикла;
	
	Возврат Рез;
	
КонецФункции // Строка2Список()

