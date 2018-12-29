﻿
///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

#Если Клиент Тогда
#КонецЕсли

// Дополняет строку указанным символом до указанной длины
//
// Параметры: 
//  Стр            - Дополняемая строка
//  Длина          - Требуемая длина результирующей строки
//  Чем            - Символ, которым дополняется строка
//
// Возвращаемое значение:
//  Строка дополненная указанным символом до указанной длины
//
Функция ДополнитьСтроку(Знач Стр, Длина, Чем=" ", Режим = 0) Экспорт
	
	СимволовДополнить = Длина -  СтрДлина(Стр);
	Добавок = "";
	Для Н=1 по СимволовДополнить Цикл
		Добавок =	Добавок + Чем;
	КонецЦикла;
	Возврат ?(Режим=0, Добавок + Стр, Стр + Добавок);
	
КонецФункции 

// Выполянет преобразование цифры в римскую нотацию 
//
// Параметры
//		Цифра - число, целое, от 0 до 9
//      РимскаяЕдиница,РимскаяПятерка,РимскаяДесятка - строки, соответствующие римские цифры
//
// Возвращаемое значение
//		строка
//
// Описание
//		записывает "обычную" цифру римскими цифрами,
//		например:
//				ПреобразоватьЦифруВРимскуюНотацию(7,"I","V","X") = "VII"
//
Функция ПреобразоватьЦифруВРимскуюНотацию(Цифра,РимскаяЕдиница,РимскаяПятерка,РимскаяДесятка) Экспорт

	РимскаяЦифра="";
	Если Цифра = 1 Тогда
	   РимскаяЦифра = РимскаяЕдиница
	ИначеЕсли Цифра = 2 Тогда
	   РимскаяЦифра = РимскаяЕдиница + РимскаяЕдиница;
	ИначеЕсли Цифра = 3 Тогда
	   РимскаяЦифра = РимскаяЕдиница + РимскаяЕдиница + РимскаяЕдиница;
	ИначеЕсли Цифра = 4 Тогда
	   РимскаяЦифра = РимскаяЕдиница + РимскаяПятерка;
	ИначеЕсли Цифра = 5 Тогда
	   РимскаяЦифра = РимскаяПятерка;
	ИначеЕсли Цифра = 6 Тогда
	   РимскаяЦифра = РимскаяПятерка + РимскаяЕдиница;
	ИначеЕсли Цифра = 7 Тогда
	   РимскаяЦифра = РимскаяПятерка + РимскаяЕдиница + РимскаяЕдиница;
	ИначеЕсли Цифра = 8 Тогда
	   РимскаяЦифра = РимскаяПятерка + РимскаяЕдиница + РимскаяЕдиница + РимскаяЕдиница;
	ИначеЕсли Цифра = 9 Тогда
	   РимскаяЦифра = РимскаяЕдиница + РимскаяДесятка;
	КонецЕсли;
	Возврат РимскаяЦифра;

КонецФункции //ПреобразоватьЦифруВРимскуюНотацию

// Выполянет преобразование арабского числа в римское 
//
// Параметры
//		АрабскоеЧисло - число, целое, от 0 до 999
//
// Возвращаемое значение
//		строка
//
// Описание
//		записывает "обычное" число римскими цифрами,
//		например:
//				ПреобразоватьЧислоВРимскуюНотацию(17) = "ХVII"
//
Функция ПреобразоватьЧислоВРимскуюНотацию(АрабскоеЧисло) Экспорт
    
	РимскоеЧисло="";
	cRab = ДополнитьСтроку(АрабскоеЧисло,3);

	c1 = "1";c5 = "У";c10 = "Х";c50 = "Л";c100 ="С";c500 = "М";c1000 = "Д";

	nEd = Число(Сред(cRab,3,1));
	nDs = Число(Сред(cRab,2,1));
	nSt = Число(Сред(cRab,1,1));

	РимскоеЧисло = РимскоеЧисло + ПреобразоватьЦифруВРимскуюНотацию(nSt,c100,c500,c1000);
	РимскоеЧисло = РимскоеЧисло + ПреобразоватьЦифруВРимскуюНотацию(nDs,c10,c50,c100);
	РимскоеЧисло = РимскоеЧисло + ПреобразоватьЦифруВРимскуюНотацию(nEd,c1,c5,c10);

	Возврат РимскоеЧисло;
	
КонецФункции //ПреобразоватьЧислоВРимскуюНотацию

// Выполянет преобразование римского числа в арабское
//
// Параметры
//		РимскоеЧисло - строка, число, записанное римскими цифрами
//
// Возвращаемое значение
//		число
//
// Описание
//		преобразует число, записанное римскими цифрами, в "обычное" число,
//		например:
//				ПреобразоватьЧислоВАрабскуюНотацию("ХVII") = 17
//
Функция ПреобразоватьЧислоВАрабскуюНотацию(РимскоеЧисло) Экспорт
    
	АрабскоеЧисло=0;

	c1 = "1";c5 = "У";c10 = "Х";c50 = "Л";c100 ="С";c500 = "М";c1000 = "Д";

	РимскоеЧисло = СокрЛП(РимскоеЧисло);
	ЧислоСимволов = СтрДлина(РимскоеЧисло);

	Для Сч=1 По ЧислоСимволов Цикл
	   Если Сред(РимскоеЧисло,Сч,1) = c1000 Тогда
	      АрабскоеЧисло = АрабскоеЧисло+1000;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c500 Тогда
	      АрабскоеЧисло = АрабскоеЧисло+500;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c100 Тогда
	      Если (Сч < ЧислоСимволов) И ((Сред(РимскоеЧисло,Сч+1,1) = c500) ИЛИ (Сред(РимскоеЧисло,Сч+1,1) = c1000)) Тогда
	         АрабскоеЧисло = АрабскоеЧисло-100;
	      Иначе
	         АрабскоеЧисло = АрабскоеЧисло+100;
	      КонецЕсли;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c50 Тогда
	      АрабскоеЧисло = АрабскоеЧисло+50;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c10 Тогда
	      Если (Сч < ЧислоСимволов) И ((Сред(РимскоеЧисло,Сч+1,1) = c50) ИЛИ (Сред(РимскоеЧисло,Сч+1,1) = c100)) Тогда
	         АрабскоеЧисло = АрабскоеЧисло-10;
	      Иначе
	         АрабскоеЧисло = АрабскоеЧисло+10;
	      КонецЕсли;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c5 Тогда
	      АрабскоеЧисло = АрабскоеЧисло+5;
	   ИначеЕсли Сред(РимскоеЧисло,Сч,1) = c1 Тогда
	      Если (Сч < ЧислоСимволов) И ((Сред(РимскоеЧисло,Сч+1,1) = c5) ИЛИ (Сред(РимскоеЧисло,Сч+1,1) = c10)) Тогда
	         АрабскоеЧисло = АрабскоеЧисло-1;
	      Иначе
	         АрабскоеЧисло = АрабскоеЧисло+1;
	      КонецЕсли;
	   КонецЕсли;
	КонецЦикла;
	Возврат АрабскоеЧисло;
КонецФункции //ПреобразоватьЧислоВАрабскуюНотацию

//Проверяет на наличие только русских букв (допускаются пробелы и дефис и некоторые спец символы)
Функция СтрокаНаписанаПоРусски(Знач СтрокаПараметр) Экспорт

	СтрокаПараметр = СокрЛП(СтрокаПараметр);	

	СписокДопустимыхЗначений = Новый СписокЗначений;
	СписокДопустимыхЗначений.Добавить(184); 
	СписокДопустимыхЗначений.Добавить(168);
	СписокДопустимыхЗначений.Добавить(45);
	СписокДопустимыхЗначений.Добавить(46);
	СписокДопустимыхЗначений.Добавить(32);
	СписокДопустимыхЗначений.Добавить(48);
	СписокДопустимыхЗначений.Добавить(49);
	СписокДопустимыхЗначений.Добавить(50);
	СписокДопустимыхЗначений.Добавить(51);
	СписокДопустимыхЗначений.Добавить(52);
	СписокДопустимыхЗначений.Добавить(53);
	СписокДопустимыхЗначений.Добавить(54);
	СписокДопустимыхЗначений.Добавить(55);
	СписокДопустимыхЗначений.Добавить(56);
	СписокДопустимыхЗначений.Добавить(57);

	Для Сч=1 По СтрДлина(СтрокаПараметр) Цикл
		Код = КодСимвола(СтрокаПараметр,Сч);
		Если (Код<192) И (СписокДопустимыхЗначений.НайтиПоЗначению(Код) = Неопределено) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;

	Возврат Истина;
КонецФункции 

// Проверяет, написана ли строка только русскими и латинскими буквами 
//
// Параметры:
//  СтрокаПараметр - строка, проверяемая строка.
//
// Возвращаемое значение:
//		Истина - строка состоит из допустимых символов
//		Ложь - в строке встречаются недопустимые символы
// 
// Описание:
//		Строка проверяется на наличие только русских и латинских букв;
//		кроме того,	допускаются дефис, "Ё", "ё".
//
Функция СтрокаНаписанаРусскимиИлиЛатинскими(Знач СтрокаПараметр) Экспорт
	
	СтрокаПараметр = СокрЛП(СтрокаПараметр);	

	Русские = 0;     
	КоличествоСимволов = СтрДлина(СтрокаПараметр);
	
	Если  КоличествоСимволов > 0 Тогда
		ПервыйСимвол = КодСимвола(Лев(СтрокаПараметр,1)); 
		Если  (ПервыйСимвол >= 192) или (ПервыйСимвол = 184) или (ПервыйСимвол = 168) Тогда
			Русские = 1;
		КонецЕсли;
	КонецЕсли;
	
	СписокДопустимыхЗначений = Новый СписокЗначений;
	СписокДопустимыхЗначений.Добавить(184);   // ё
	СписокДопустимыхЗначений.Добавить(168);   // Ё
	СписокДопустимыхЗначений.Добавить(45);   //  "-"

	Для Сч = 1 По КоличествоСимволов Цикл
		Код = КодСимвола(Сред(СтрокаПараметр,Сч));   
		// Большие латинские буквы: 65 - 90
		// Маленькие латинские буквы: 97 - 122
		// Русские буквы: 192 и больше
		
		//русские:
		Если (Русские = 1) Тогда
			Если (СписокДопустимыхЗначений.НайтиПоЗначению(Код) = Неопределено) и (Код < 192)  Тогда
				Возврат 0;
			КонецЕсли;

		// латинские:	
		Иначе 
			Если (Код <> 45) и 
			((Код < 65) или	(Код > 90) и (Код < 97) или (Код > 122))  Тогда    
				Возврат 0;
			КонецЕсли;
		КонецЕсли;
			
	КонецЦикла;
	
	Возврат 1;

КонецФункции // СтрокаНаписанаРусскимиИлиЛатинскими()

//Выполняет в строке ГДЕ замену символов ЧТО на соответствующие по номерам символы из строки НаЧто
Функция ЗаменитьОдниСимволыДругими(Что,Где,НаЧто) Экспорт
	Рез = Где;
	Для Сч=1 По СтрДлина(Что) Цикл
		Рез = СтрЗаменить(Рез,Сред(Что,Сч,1),Сред(НаЧто,Сч,1));
	КонецЦикла;
	Возврат Рез;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ПРЕОБРАЗОВАНИЯ ЗНАЧЕНИЙ

//Функция раскладывает строку с данными о месте рождения на элементы структуры
Функция РазложитьМестоРождения(Знач СтрокаМестоРождения, ВерхнийРегистр = Истина) Экспорт

	Особое = 0;НаселенныйПункт	= "";Район	= "";Область	= "";Страна	= "";

	МассивМестоРождения	=	ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(?(ВерхнийРегистр, Врег(СтрокаМестоРождения), СтрокаМестоРождения));
	
	ЭлементовВМассиве = МассивМестоРождения.Количество();   
	Если ЭлементовВМассиве	>	0	тогда
		Если СокрЛП(МассивМестоРождения[0]) = "1" тогда
			Особое	=	1;
		КонецЕсли;	 
	КонецЕсли;
	Если ЭлементовВМассиве	>	1	тогда
		НаселенныйПункт	=	СокрЛП(МассивМестоРождения[1]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	2	тогда
		Район	=	СокрЛП(МассивМестоРождения[2]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	3	тогда
		Область	=	СокрЛП(МассивМестоРождения[3]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	4	тогда
		Страна	=	СокрЛП(МассивМестоРождения[4]);
	КонецЕсли;

	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Особое",Особое);
	СтруктураВозврата.Вставить("НаселенныйПункт",НаселенныйПункт);
	СтруктураВозврата.Вставить("Район",Район);
	СтруктураВозврата.Вставить("Область",Область);
	СтруктураВозврата.Вставить("Страна",Страна);
	Возврат СтруктураВозврата;
	
КонецФункции	 

//Функция раскладывает строку с данными об адресе (в формате 9 запятых) на элементы структуры
Функция РазложитьАдрес(Знач СтрокаАдрес) Экспорт
	
	Страна = "";
	Индекс = "";
	Регион = "";
	Район = "";
	Город = "";
	НаселенныйПункт = "";
	Улица ="";
	Дом ="";
	Корпус ="";
	Квартира ="";

	МассивАдрес	=	ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(СтрокаАдрес);
	ЭлементовВМассиве = МассивАдрес.Количество();   

	Если ЭлементовВМассиве	>	0	тогда
		Страна	=	СокрЛП(МассивАдрес[0]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	1	тогда
		Индекс	=	СокрЛП(МассивАдрес[1]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	2	тогда
		Регион	=	СокрЛП(МассивАдрес[2]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	3	тогда
		Район	=	СокрЛП(МассивАдрес[3]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	4	тогда
		Город	=	СокрЛП(МассивАдрес[4]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	5	тогда
		НаселенныйПункт	=	СокрЛП(МассивАдрес[5]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	6	тогда
		Улица	=	СокрЛП(МассивАдрес[6]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	7	тогда
		Дом	=	СокрЛП(МассивАдрес[7]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	8	тогда
		Корпус	=	СокрЛП(МассивАдрес[8]);
	КонецЕсли;
	Если ЭлементовВМассиве	>	9	тогда
		Квартира	=	СокрЛП(МассивАдрес[9]);
	КонецЕсли;

	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Страна",Страна);
	СтруктураВозврата.Вставить("Индекс",Индекс);
	СтруктураВозврата.Вставить("Регион",Регион);
	СтруктураВозврата.Вставить("Район",Район);
	СтруктураВозврата.Вставить("Город",Город);
	СтруктураВозврата.Вставить("НаселенныйПункт",НаселенныйПункт);
	СтруктураВозврата.Вставить("Улица",Улица);
	СтруктураВозврата.Вставить("Дом",Дом);
	СтруктураВозврата.Вставить("Корпус",Корпус);
	СтруктураВозврата.Вставить("Квартира",Квартира);

	Возврат СтруктураВозврата;
	
КонецФункции	 

//Собирает из элементов структуры адреса строку записи адреса в формате 9 запятых
Функция СобратьАдрес(Знач СтруктураАдрес) Экспорт

	Возврат ""+ СтруктураАдрес.Страна + "," + СтруктураАдрес.Индекс + ","+ СтруктураАдрес.Регион + ","
	+ СтруктураАдрес.Район  + "," + СтруктураАдрес.Город  + ","+ СтруктураАдрес.НаселенныйПункт + ","
	+ СтруктураАдрес.Улица  + "," + СтруктураАдрес.Дом    + ","+ СтруктураАдрес.Корпус + "," + СтруктураАдрес.Квартира

КонецФункции	 

//Разбивает серию документа удостоверяющего личность на 2 части: до и после разделителя
Функция РазложитьСериюДокумента(Знач ВидДокумента, Знач СерияДокумента) Экспорт

	Часть1 = "";
	Часть2 = "";
	
	Если ЗначениеЗаполнено(ВидДокумента) тогда
		
		КодДока = ВидДокумента.КодИМНС;

		Если (КодДока = "01") или (КодДока = "03")  Тогда
			//Свидетельство о рождении или Паспорт гражданина СССР. . Разделитель групп - "-"
			Разделитель = Найти(СерияДокумента, "-");
			Часть1 = ?(Разделитель = 0, СерияДокумента, ЗаменитьОдниСимволыДругими("1УХЛС", ВРег(СокрЛП(Лев(СерияДокумента, Разделитель-1))), "IVXLC"));
			Часть2 = ?(Разделитель = 0, "", СокрЛП(Сред(СерияДокумента, Разделитель + 1)));
		ИначеЕсли (КодДока = "02") Или (КодДока = "22") Тогда
			//Загранпаспорт гражданина СССР и РФ - первая часть не заполняется, заполняется только вторая часть
			Часть2 = СерияДокумента;
		ИначеЕсли КодДока = "21"  Тогда
			//Паспорт гражданина Российской Федерации. Разделитель групп - " "
			Разделитель = Найти(СерияДокумента, " ");
			Часть1 = ?(Разделитель = 0, СерияДокумента, СокрЛП(Лев(СерияДокумента, Разделитель - 1)));
			Часть2 = ?(Разделитель = 0, "", СокрЛП(Сред(СерияДокумента, Разделитель + 1)));
		Иначе	
			Часть1 = СерияДокумента;
		КонецЕсли;
		
	КонецЕсли;	 

	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Часть1",Часть1);
	СтруктураВозврата.Вставить("Часть2",Часть2);
	Возврат СтруктураВозврата;
	
КонецФункции	 

//Представляет адрес в "удобочитаемом" виде	для отражения в формах
//
//	Параметры: 
//		АдреснаяСтрока (строка), адрес представление которого нужно вернуть.
//		Способ - способ представления адреса (если=1, то возвращает представление адреса без индекса)
//
//	Возвращаемое значение:
//		строку - представление адреса
//
//	Описание:
//		Предназначена для формирования адресной строки в "удобочитаемом" виде
//		для отражения в формах.
//
Функция ПредставлениеАдреса(Знач АдреснаяСтрока, Способ = 0, ПредставлениеПустого = "<<Адрес не задан>>") Экспорт

	Если НЕ ЗначениеЗаполнено(СтрЗаменить(АдреснаяСтрока,",","")) Тогда
		Возврат ПредставлениеПустого;
	КонецЕсли;

	СтруктураАдрес = РазложитьАдрес(АдреснаяСтрока);
	Если АдресСоответствуетТребованиям(СтруктураАдрес) Тогда
		Адрес = "";
		Если ЗначениеЗаполнено(СтруктураАдрес.Страна) Тогда
			СсылкаНаСтрану = Справочники.КлассификаторСтранМира.НайтиПоКоду(СтруктураАдрес.Страна);
			Если НЕ СсылкаНаСтрану.Пустая() Тогда
				Адрес = Адрес +", "+ СсылкаНаСтрану.Наименование;
			Иначе
				Адрес = Адрес +", "+ СтруктураАдрес.Страна;
			КонецЕсли;
		КонецЕсли;

		Если ЗначениеЗаполнено(СтруктураАдрес.Индекс)и(Способ<>1) тогда
			Адрес = Адрес + СтруктураАдрес.Индекс;
		КонецЕсли;	 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Регион),", "+СтруктураАдрес.Регион,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Район),", "+СтруктураАдрес.Район,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Город),", "+СтруктураАдрес.Город,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.НаселенныйПункт),", "+СтруктураАдрес.НаселенныйПункт,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Улица),", "+СтруктураАдрес.Улица,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Дом),", д."+СтруктураАдрес.Дом,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Корпус),", корп. "+СтруктураАдрес.Корпус,""); 
		Адрес =Адрес + ?(ЗначениеЗаполнено(СтруктураАдрес.Квартира),", кв. "+СтруктураАдрес.Квартира,""); 

		Адрес = Сред(Адрес,1);//Убрали первую запятую
	Иначе
		Адрес = СтрЗаменить(АдреснаяСтрока, Символы.ПС, ", ");
	КонецЕсли;
	Возврат Адрес;
КонецФункции	// глПредставлениеАдреса

//Возвращает строковое представление места рождения
Функция ПредставлениеМестаРождения(Знач СтрокаМестоРождения) Экспорт

	СтруктураМестоРождения = РазложитьМестоРождения(СтрокаМестоРождения, Ложь);

    Если СтруктураМестоРождения.Особое = 1 Тогда
	
		Представление	=	"особое" +
		?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.НаселенныйПункт),		"",	"  "	+	СокрЛП(СтруктураМестоРождения.НаселенныйПункт))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Район),	"",	"  "	+	СокрЛП(СтруктураМестоРождения.Район))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Область),	"",	"  "	+	СокрЛП(СтруктураМестоРождения.Область))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Страна),	"",	"  "	+	СокрЛП(СтруктураМестоРождения.Страна));
	
	Иначе
	
		Представление	= "" + ?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.НаселенныйПункт),		"",	"Населенный пункт: " + СокрЛП(СтруктураМестоРождения.НаселенныйПункт))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Район),	"",	", район:  " + СокрЛП(СтруктураМестоРождения.Район))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Область),	"",	", область: "	+	СокрЛП(СтруктураМестоРождения.Область))
		+?(НЕ ЗначениеЗаполнено(СтруктураМестоРождения.Страна),	"",	", страна: "	+	СокрЛП(СтруктураМестоРождения.Страна));
		
		Если Лев(Представление, 1) = ","  Тогда
			Представление = Сред(Представление, 2)
		КонецЕсли;
			
	КонецЕсли; 

	Возврат Представление;
КонецФункции	 

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ПРОВЕРКИ КОРРЕКТНОСТИ ЗАПОЛНЕНИЯ ДАННЫХ

//Проверяет номер страхового свидетельства на соответствие требованиям ПФР
Функция СтраховойНомерПФРСоответствуетТребованиям(СтраховойНомер) Экспорт
	
	Результат = Истина;
	
	СтрокаЦифр=СтрЗаменить(Лев(СтраховойНомер,11),"-","");
	
	Попытка
		П1 = Число(СтрокаЦифр);	
		КонтрольноеЧисло=Число(Прав(СтраховойНомер,2));
	Исключение
		Возврат Ложь;
	КонецПопытки; 
	
	Если ПустаяСтрока(СтрокаЦифр)=0  Тогда
		Если Число(Лев(СтрокаЦифр,9)) > 1001998 Тогда
			Всего=0;
			Для Сч = 1 По 9 Цикл
				Всего=Всего+Число(Сред(СтрокаЦифр,10-Сч,1))*Сч
			КонецЦикла;
			Остаток=Всего%101;
			Остаток=?(Остаток=100,0,Остаток);
			Если Остаток<>КонтрольноеЧисло Тогда
				Результат = Ложь;
			КонецЕсли;
		КонецЕсли;
	Иначе
		Результат = Ложь;
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

//Определяет соответствие основных параметров адреса требованиям МНС
Функция АдресСоответствуетТребованиям(Знач СтруктураАдрес) Экспорт
	
	Город = СтруктураАдрес.Город;
	Город = СтрЗаменить(Город,"с/с","");
	Город = СтрЗаменить(Город,"с/а","");  
	Город = СтрЗаменить(Город,"с/мо","");
	Город = СтрЗаменить(Город,"с/о",""); 
	НаселенныйПункт = СтруктураАдрес.НаселенныйПункт;
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"ж/д_","");
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"ж/д","");  
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"п/р","");
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"п/ст",""); 
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"п/о",""); 

	// Элементы классификатора KLADR. Встречаются элементы с "/". "(", ")".
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"/","");
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,"(",""); 
	НаселенныйПункт = СтрЗаменить(НаселенныйПункт,")",""); 

	Улица = СтруктураАдрес.Улица; 

	// Элементы классификатора сокращений.
	Улица = СтрЗаменить(Улица,"ж/д_","");
	Улица = СтрЗаменить(Улица,"ж/д","");  
	Улица = СтрЗаменить(Улица,"п/о","");
	Улица = СтрЗаменить(Улица,"п/ст",""); 
	Улица = СтрЗаменить(Улица,"п/р","");

	// Элементы классификатора STREET. Встречаются улицы с "/". "(", ")". 
	Улица = СтрЗаменить(Улица,"/","");
	Улица = СтрЗаменить(Улица,"(","");
	Улица = СтрЗаменить(Улица,")","");

	Если СтруктураАдрес.Количество()<>10 Тогда // должно быть 10 элементов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Страна) > 3  Тогда   // код страны не > 3 символов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Индекс) > 6  Тогда   // индекс не > 6 символов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Регион) > 30 Тогда   // наим.региона не > 30 символов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Район) > 35 Тогда   // наим.района не > 35 символов
		Возврат Ложь;
	ИначеЕсли НЕ СтрокаНаписанаПоРусски(СтруктураАдрес.Район) Тогда   // наим.района написано не русскими буквами
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Город) > 35 Тогда   // наим.города не > 35 символов
		Возврат Ложь;
	ИначеЕсли НЕ СтрокаНаписанаПоРусски(Город) Тогда   // наим.города написано не русскими буквами
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.НаселенныйПункт) > 45 Тогда   // наим.нас.пункта не > 45 символов
		Возврат Ложь;
	ИначеЕсли НЕ СтрокаНаписанаПоРусски(НаселенныйПункт) Тогда   // наим.нас.пункта написано не русскими буквами
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Улица) > 45 Тогда   // наим.улицы не > 45 символов
		Возврат Ложь;
	ИначеЕсли НЕ СтрокаНаписанаПоРусски(Улица) Тогда   // наим.улицы написано не русскими буквами
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Дом) > 10 Тогда   // номер дома не > 10 символов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Корпус) > 10 Тогда   // номер корпуса не > 10 символов
		Возврат Ложь;
	ИначеЕсли СтрДлина(СтруктураАдрес.Квартира)> 10 Тогда   // номер квартиры не > 10 символов
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции	

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ВЫБОРКИ ДАННЫХ 

// Извлекает сведения об организации по списку, переданному в параметре.
// 
// Параметры:
//  Показатели     - Список значений. Содержит в виде представлений перечень 
//                   сведений, которые надо получить. В первом элемент списка
//                   
// 
// Описание:
//  Функция умеет обрабатыать следующие мнемонические имена:
//  ФИОРук
//  ИННРук
//  ФИОБух
//  ИННБух
//
//
Функция ПолучитьСведенияОбОрганизации(Организация, ДатаЗначения, СписокПоказателей) Экспорт

	Перем ОргСведения;
	Перем Значение;

	// Структура, в которой будут возвращаться найденые значения
	ОргСведения = Новый Структура;

	Для каждого ЭлементСписка Из СписокПоказателей Цикл
		ИмяПоказателя = ЭлементСписка.Представление;

		Если ИмяПоказателя = "ФИОРук" Тогда
			Данные = Новый Структура("СтруктурнаяЕдиница",Организация, 
			                         "ОтветственноеЛицо", Перечисления.ОтветственныеЛицаОрганизации.Руководитель);

			ОтвЛица = РегистрыСведений.ОтветственныеЛицаОрганизации.СрезПоследних(ДатаЗначения, Данные);

			Результат = ОтвЛица.Найти(Перечисления.ОтветственныеЛицаОрганизации.Руководитель);

			Если Результат <> Неопределено Тогда
				Значение = Результат.ФизическоеЛицо;
			КонецЕсли;

		ИначеЕсли ИмяПоказателя = "ИННРук" Тогда

			Данные = Новый Структура("СтруктурнаяЕдиница",Организация, 
			                         "ОтветственноеЛицо", Перечисления.ОтветственныеЛицаОрганизации.Руководитель);

			ОтвЛица = РегистрыСведений.ОтветственныеЛицаОрганизации.СрезПоследних(ДатаЗначения, Данные);

			Результат = ОтвЛица.Найти(Перечисления.ОтветственныеЛицаОрганизации.Руководитель);

			Если Результат <> Неопределено Тогда
				Значение = Результат.ФизическоеЛицо.ИНН;
			КонецЕсли;

		ИначеЕсли ИмяПоказателя = "ФИОБух" Тогда
			Данные = Новый Структура("СтруктурнаяЕдиница",Организация, 
			                         "ОтветственноеЛицо", Перечисления.ОтветственныеЛицаОрганизации.ГлавныйБухгалтер);

			ОтвЛица = РегистрыСведений.ОтветственныеЛицаОрганизации.СрезПоследних(ДатаЗначения, Данные);

			Результат = ОтвЛица.Найти(Перечисления.ОтветственныеЛицаОрганизации.ГлавныйБухгалтер);

			Если Результат <> Неопределено Тогда
				Значение = Результат.ФизическоеЛицо;
			КонецЕсли;

		ИначеЕсли ИмяПоказателя = "ИННБух" Тогда
			Данные = Новый Структура("СтруктурнаяЕдиница",Организация, 
			                         "ОтветственноеЛицо", Перечисления.ОтветственныеЛицаОрганизации.ГлавныйБухгалтер);

			ОтвЛица = РегистрыСведений.ОтветственныеЛицаОрганизации.СрезПоследних(ДатаЗначения, Данные);

			Результат = ОтвЛица.Найти(Перечисления.ОтветственныеЛицаОрганизации.ГлавныйБухгалтер);

			Если Результат <> Неопределено Тогда
				Значение = Результат.ФизическоеЛицо.ИНН;
			КонецЕсли;

		Иначе
			Значение = Неопределено;
		КонецЕсли;

		ОргСведения.Вставить(ИмяПоказателя, Значение);

	КонецЦикла;

	Возврат ОргСведения;

КонецФункции // ПолучитьСведенияОбОрганизации()

//Функция возвращает информацию об ответственных лицах организации и их должностях 
Функция ОтветственныеЛицаОрганизации(Организация, ДатаСреза, Исполнитель = Неопределено) Экспорт

	Результат = Новый Структура("Руководитель, РуководительДолжность, ГлавныйБухгалтер, Кассир");
	
    Если Организация <> Неопределено тогда

  		ЗапросПоЛицам = Новый Запрос();
    	ЗапросПоЛицам.УстановитьПараметр("Организация", Организация);
    	ЗапросПоЛицам.УстановитьПараметр("ДатаСреза",   ДатаСреза);
    	ЗапросПоЛицам.Текст = "
    	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
    	|	ОтветственныеЛицаОрганизацииСрезПоследних.ОтветственноеЛицо,
    	|	ОтветственныеЛицаОрганизацииСрезПоследних.Должность.Наименование КАК Должность,
    	|	ВЫБОР КОГДА (ФИОФизЛицСрезПоследних.ФизЛицо) ЕСТЬ NULL  ТОГДА ОтветственныеЛицаОрганизацииСрезПоследних.ФизическоеЛицо.Наименование ИНАЧЕ ФИОФизЛицСрезПоследних.Фамилия + ВЫБОР КОГДА ПОДСТРОКА(ФИОФизЛицСрезПоследних.Имя, 1, 1) <> """" ТОГДА "" "" + ПОДСТРОКА(ФИОФизЛицСрезПоследних.Имя, 1, 1) + ""."" ИНАЧЕ """" КОНЕЦ + ВЫБОР КОГДА ПОДСТРОКА(ФИОФизЛицСрезПоследних.Отчество, 1, 1) <> """" ТОГДА "" "" + ПОДСТРОКА(ФИОФизЛицСрезПоследних.Отчество, 1, 1) + ""."" ИНАЧЕ """" КОНЕЦ КОНЕЦ КАК ФИОПолное
    	|ИЗ
    	|	РегистрСведений.ОтветственныеЛицаОрганизации.СрезПоследних(&ДатаСреза, СтруктурнаяЕдиница = &Организация) КАК ОтветственныеЛицаОрганизацииСрезПоследних
    	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ФИОФизЛиц.СрезПоследних(&ДатаСреза, ФизЛицо ССЫЛКА Справочник.ФизическиеЛица) КАК ФИОФизЛицСрезПоследних
    	|		ПО ОтветственныеЛицаОрганизацииСрезПоследних.ФизическоеЛицо = ФИОФизЛицСрезПоследних.ФизЛицо";
    			
    	Выборка = ЗапросПоЛицам.Выполнить().Выбрать();
    			
    	Пока Выборка.Следующий() Цикл

  			Если Выборка.ОтветственноеЛицо = Перечисления.ОтветственныеЛицаОрганизации.Руководитель Тогда
    			Результат.Руководитель            = Выборка.ФИОПолное;
    			Результат.РуководительДолжность   = Выборка.Должность;

  			ИначеЕсли Выборка.ОтветственноеЛицо = Перечисления.ОтветственныеЛицаОрганизации.ГлавныйБухгалтер Тогда
    			Результат.ГлавныйБухгалтер        = Выборка.ФИОПолное;

  			ИначеЕсли Выборка.ОтветственноеЛицо = Перечисления.ОтветственныеЛицаОрганизации.Кассир Тогда
    			Результат.Кассир                  = Выборка.ФИОПолное;

  			КонецЕсли;

  		КонецЦикла;
	КонецЕсли;

	Возврат Результат;

КонецФункции // ОтветственныеЛицаОрганизации()

#Если Клиент Тогда

// записывает в рег-р сведений новые фамилию, имя и отчество
Процедура ЗаписатьДанныеФИОВРегистр(Ссылка, Фамилия, Имя, Отчество) Экспорт
	
	ФИОСрез = РегистрыСведений.ФИОФизЛиц.ПолучитьПоследнее(,Новый Структура("ФизЛицо",Ссылка));
	
	СтрокаСреза = ФИОСрез.Фамилия + ФИОСрез.Имя + ФИОСрез.Отчество;
	
	Если СтрокаСреза <> (Фамилия + Имя + Отчество) Тогда
		
		МенеджерЗаписи = РегистрыСведений.ФИОФизЛиц.СоздатьМенеджерЗаписи();
		
		МенеджерЗаписи.ФизЛицо = Ссылка;
		Если ПустаяСтрока(СтрокаСреза) Тогда
			МенеджерЗаписи.Период = '19000101';
		Иначе
			МенеджерЗаписи.Период = РабочаяДата;
		КонецЕсли;
		
		МенеджерЗаписи.Фамилия = Фамилия;
		МенеджерЗаписи.Имя = Имя;
		МенеджерЗаписи.Отчество = Отчество;
		
		МенеджерЗаписи.Записать(Истина);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С ФАЙЛАМИ СВЕДЕНИЙ

//Получает текст файла сведений из регистра
Функция ПолучитьТекстФайлаИзРегистра(ДокументСсылка) 

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка" , ДокументСсылка);

	Запрос.Текст = "ВЫБРАТЬ
	|	АрхивДанныхРегламентированнойОтчетности.Данные
	|ИЗ
	|	РегистрСведений.АрхивДанныхРегламентированнойОтчетности КАК АрхивДанныхРегламентированнойОтчетности
	|
	|ГДЕ
	|	АрхивДанныхРегламентированнойОтчетности.Объект = &ДокументСсылка";

	ВыборкаДанных = Запрос.Выполнить().Выбрать();

	Если ВыборкаДанных.Следующий() тогда
		Возврат ВыборкаДанных.Данные;
	Иначе	
		Возврат "";
	КонецЕсли;	 

КонецФункции	

//Получает текст файла сведений, сформированного по данным документа
Функция ПолучитьТекстФайла(ДокументОбъект,Отказ) Экспорт
	
	Если ДокументОбъект.Проведен тогда
		//Для проведенного документа берём сохраненный ранее текст файла 
		Отказ = Ложь;
		Возврат ПолучитьТекстФайлаИзРегистра(ДокументОбъект.Ссылка);
	Иначе 
		Возврат ДокументОбъект.СформироватьВыходнойФайл(Отказ);
	КонецЕсли;	 
	
КонецФункции	

//Печатает файл сведений документа
Процедура РаспечататьФайлДокумента(ДокументОбъект) Экспорт
	Вопрос = "Перед печатью необходимо записать документ. Записать?";
	Если НЕ ТребованиеЗаписиДокументаУдовлетворено(ДокументОбъект,Вопрос) тогда
		Возврат;
	КонецЕсли;	
	ДокументОбъект.ПечатьФайла();
КонецПроцедуры 

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С ДИАЛОГАМИ

//Выполняет запись документа в случае подтверждения пользователем
Функция ТребованиеЗаписиДокументаУдовлетворено(ДокументОбъект,ТекстВопросаПодтверждения) Экспорт
	Если ДокументОбъект.ЭтоНовый() или ДокументОбъект.Модифицированность() Тогда
		Ответ  = Вопрос(ТекстВопросаПодтверждения, РежимДиалогаВопрос.ОКОтмена);
		Если Ответ = КодВозвратаДиалога.ОК Тогда
			ДокументОбъект.Записать();
		Иначе
			Возврат ложь;
		КонецЕсли;
	КонецЕсли;
	Возврат Истина;
КонецФункции	 

#КонецЕсли

// Проверяет соответствие ИНН требованиям
// Параметры:
//		ИНН - строка - проверяемый индивидуальный номер налогоплательщика,
//		ВладелецИНН - ПеречислениеСсылка.ЮрФизЛицо - тип владельца ИНН: физлицо или юрлицо
Функция ИННсоответствуетТребованиям(Знач ИНН, ВладелецИНН) Экспорт

	ИНН = СокрЛП(ИНН);
	ДлинаИНН =  СтрДлина(ИНН);
	
	ИННбезНулей = СтрЗаменить(ИНН,"0","1");
	Попытка
	    ЧислоИНН = Число(ИННбезНулей);
	Исключение
		Возврат Ложь;// В ИНН имеются символы, отличные от цифр (0..9)
	КонецПопытки; 
	
	
	Если ДлинаИНН =10  и ВладелецИНН = Перечисления.ЮрФизЛицо.ЮрЛицо Тогда
		
		КонтрольнаяСумма = 0;
		
		Для Н=1 По 9 Цикл
			
			Если 	  Н = 1 Тогда
				Множитель = 2;
			ИначеЕсли Н = 2 Тогда
				Множитель = 4;
			ИначеЕсли Н = 3 Тогда
				Множитель = 10;
			ИначеЕсли Н = 4 Тогда
				Множитель = 3;
			ИначеЕсли Н = 5 Тогда
				Множитель = 5;
			ИначеЕсли Н = 6 Тогда
				Множитель = 9;
			ИначеЕсли Н = 7 Тогда
				Множитель = 4;
			ИначеЕсли Н = 8 Тогда
				Множитель = 6;
			ИначеЕсли Н = 9 Тогда
				Множитель = 8;
			КонецЕсли; 
			
			Цифра = Число(Сред(ИНН,Н,1));
			КонтрольнаяСумма = КонтрольнаяСумма + Цифра * Множитель;
			
		КонецЦикла; 
		
		КонтрольныйРазряд = (КонтрольнаяСумма %11) %10;
		
		Если КонтрольныйРазряд <> Число(Сред(ИНН,10,1)) Тогда
			Возврат Ложь;
		КонецЕсли; 
		
	ИначеЕсли ДлинаИНН =12 и ВладелецИНН = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
		
		КонтрольнаяСумма11 = 0;
		КонтрольнаяСумма12 = 0;
		
		Для Н=1 По 11 Цикл
			
			// Расчет множителя для 11-го и 12-го разрядов
			Если Н = 1 Тогда
				Множитель11 = 7;
				Множитель12 = 3;
			ИначеЕсли Н = 2 Тогда
				Множитель11 = 2;
				Множитель12 = 7;
			ИначеЕсли Н = 3 Тогда
				Множитель11 = 4;
				Множитель12 = 2;
			ИначеЕсли Н = 4 Тогда
				Множитель11 = 10;
				Множитель12 = 4;
			ИначеЕсли Н = 5 Тогда
				Множитель11 = 3;
				Множитель12 = 10;
			ИначеЕсли Н = 6 Тогда
				Множитель11 = 5;
				Множитель12 = 3;
			ИначеЕсли Н = 7 Тогда
				Множитель11 = 9;
				Множитель12 = 5;
			ИначеЕсли Н = 8 Тогда
				Множитель11 = 4;
				Множитель12 = 9;
			ИначеЕсли Н = 9 Тогда
				Множитель11 = 6;
				Множитель12 = 4;
			ИначеЕсли Н = 10 Тогда
				Множитель11 = 8;
				Множитель12 = 6;
			ИначеЕсли Н = 11 Тогда
				Множитель11 = 0;
				Множитель12 = 8;
			КонецЕсли; 
			
			Цифра = Число(Сред(ИНН,Н,1));
			КонтрольнаяСумма11 = КонтрольнаяСумма11 + Цифра * Множитель11;
			КонтрольнаяСумма12 = КонтрольнаяСумма12 + Цифра * Множитель12;
			
		КонецЦикла; 
		
		КонтрольныйРазряд11 = (КонтрольнаяСумма11 %11) %10;
		КонтрольныйРазряд12 = (КонтрольнаяСумма12 %11) %10;
		
		Если КонтрольныйРазряд11 <> Число(Сред(ИНН,11,1))
			ИЛИ КонтрольныйРазряд12 <> Число(Сред(ИНН,12,1)) Тогда
			Возврат Ложь;
		КонецЕсли; 
		
	Иначе	
		
		Возврат Ложь;
		
	КонецЕсли; 
	
	Возврат Истина;
	
КонецФункции

// формирует список значений, описывающий государственные праздники РФ
//
// Параметры
//  КалендарныйГод - число - год, за который возвращается список праздников
//
// Возвращаемое значение:
//   список значений, содержащий строки-месяцедни праздников
//
Функция ПолучитьСписокПраздниковРФ(КалендарныйГод) Экспорт

	СписокПраздников = Новый СписокЗначений();
	Если КалендарныйГод < 2005 Тогда
		СписокПраздников.Добавить("0101", "Новый Год");
		СписокПраздников.Добавить("0102", "Новый Год");
		СписокПраздников.Добавить("0107", "Рождество Христово");
		СписокПраздников.Добавить("0223", "День защитника Отечества");
		СписокПраздников.Добавить("0308", "Международный женский день");
		СписокПраздников.Добавить("0501", "Праздник Весны и Труда");
		СписокПраздников.Добавить("0502", "Праздник Весны и Труда");
		СписокПраздников.Добавить("0509", "День Победы");
		СписокПраздников.Добавить("0612", "День России");
		СписокПраздников.Добавить("1107", "День согласия и примирения");
		СписокПраздников.Добавить("1212", "День Конституции РФ");
	Иначе  // Федеральный закон №201-ФЗ от 29 декабря 2004 года
		СписокПраздников.Добавить("0101", "Новогодние каникулы");
		СписокПраздников.Добавить("0102", "Новогодние каникулы");
		СписокПраздников.Добавить("0103", "Новогодние каникулы");
		СписокПраздников.Добавить("0104", "Новогодние каникулы");
		СписокПраздников.Добавить("0105", "Новогодние каникулы");
		СписокПраздников.Добавить("0107", "Рождество Христово");
		СписокПраздников.Добавить("0223", "День защитника Отечества");
		СписокПраздников.Добавить("0308", "Международный женский день");
		СписокПраздников.Добавить("0501", "Праздник Весны и Труда");
		СписокПраздников.Добавить("0509", "День Победы");
		СписокПраздников.Добавить("0612", "День России");
		СписокПраздников.Добавить("1104", "День народного единства");
	КонецЕсли;

	Возврат СписокПраздников

КонецФункции // ПолучитьСписокПраздниковРФ()
