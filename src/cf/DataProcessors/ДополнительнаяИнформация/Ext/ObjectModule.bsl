﻿#Если Клиент Тогда

Перем КаталогДопИнфо Экспорт;
Перем ТаблицаСтраниц Экспорт;

// Функция КонфигурацияБазовая определяет, является ли 
// данная конфигурация базовой
//
// Возвращаемое значение:
//   <Булево>   – Истина, если конфигурация базовая, Ложь - ПРОФ
//
Функция КонфигурацияБазовая()Экспорт
	Возврат ?(Найти(НРег(Метаданные.Имя),"базовая")>0,Истина,Ложь);
КонецФункции // ВидКонфигурации()

// Процедура выгружает данные страницы во временные файлы
// и заменяет ссылки в виде идентификаторов на имена файлов
//
// Параметры
//   Каталог   - имя каталога, в кот. устанавливается доп инфо
//   ИмяМакета - имя макета стартовой страницы, как он указан в описателе
Процедура ИзвлечьСтраницу(Каталог, ИмяМакета) Экспорт
	Попытка
		Макет = ПолучитьМакет(ИмяМакета);
		Макет.Записать(Каталог + "\tmp.zip");
	Исключение
		Возврат;
	КонецПопытки;
	Архив = Новый ЧтениеZipФайла(Каталог+"\tmp.zip",);
	Архив.ИзвлечьВсе(Каталог,РежимВосстановленияПутейФайловZIP.Восстанавливать);
	УдалитьФайлы(Каталог,"tmp.zip");
КонецПроцедуры

// Выполняет обработку описателя дополнительной информации
// и заполняет таблицу значений данными страницы
Процедура ОбработкаОписателя() Экспорт 
	Попытка
		ТекстОписателя = ПолучитьМакет("Описатель").ПолучитьОбласть("ДанныеОписателя");
	Исключение
		Возврат;
	КонецПопытки;
	// получить таблицу страниц
	Для Н=1 По ТекстОписателя.ВысотаТаблицы Цикл 
		СтрОписания = ТаблицаСтраниц.Добавить();
		СтрОписания.Идентификатор = Н;
		Для К=2 По 11 Цикл
			Стр = СокрЛП(ТекстОписателя.Область("R"+Н+"C"+К).Текст);
			Если К=2 Тогда
				СтрОписания.ИмяМакета = Стр;
			ИначеЕсли К=3 Тогда
				СтрОписания.Раздел = Стр;
			ИначеЕсли К=4 Тогда
				СтрОписания.НаименованиеСтартовойСтраницы = Стр;
			ИначеЕсли К=5 Тогда
				СтрОписания.ИмяФайлаСтартовойСтраницы = Стр;
			ИначеЕсли К=6 Тогда
				СтрОписания.ТипСтраницы = ?(ПустаяСтрока(Стр),0,Стр);
			ИначеЕсли К=7 Тогда
				СтрОписания.ФормаПоказа = ?(ПустаяСтрока(Стр),0,Стр);
			ИначеЕсли К=8 Тогда
				СтрОписания.ДатаНачалаПоказа = ?(ПустаяСтрока(Стр),Дата("00010101"),Дата(Стр));
			ИначеЕсли К=9 Тогда
				СтрОписания.ДатаОкончанияПоказа = ?(ПустаяСтрока(Стр),Дата("21010101"),Дата(Стр));
			ИначеЕсли К=10 Тогда
				СтрОписания.ВключатьВПервыйПоказ = ?(ПустаяСтрока(Стр),0,Стр);
			ИначеЕсли К=11 Тогда
				СтрОписания.ПоказВКонфигурации = ?(ПустаяСтрока(Стр),0,Стр);
			КонецЕсли;
		КонецЦикла;
		Если Не ДанныеАктуальны(СтрОписания) Тогда
			ТаблицаСтраниц.Удалить(СтрОписания);
		КонецЕсли;
	КонецЦикла;
	ТаблицаСтраниц.Сортировать("Раздел,Идентификатор");
КонецПроцедуры

// ДанныеАктуальны
//  Проверяет актуальность данных допонительной информации
// Параметры
//  <СтрОписания>  – <ТаблицаЗначений / Справочник.СхемаПоказаДополнительнойИнформации> 
//        содержит информацию, по кот. определяется актуальность полученных данных
//
// Возвращаемое значение:
//   <Булево>   – Истина - данные актуальны
//
Функция ДанныеАктуальны(СтрОписания) Экспорт
	Если СтрОписания.ДатаНачалаПоказа<ТекущаяДата() 
			И СтрОписания.ДатаОкончанияПоказа>=НачалоДня(ТекущаяДата()) 
			И СтрОписания.ТипСтраницы<>3 
			И ?(СтрОписания.ПоказВКонфигурации=0,Истина,
				(КонфигурацияБазовая() И СтрОписания.ПоказВКонфигурации=2) 
					ИЛИ (НЕ КонфигурацияБазовая() И СтрОписания.ПоказВКонфигурации=1)) Тогда
		Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
КонецФункции 

// Показ страницы в текущей форме или в форме в режиме рабочего стола
// 
Процедура ПросмотрФинальнойСтраницы(Идентификатор)
	Отбор = Новый Структура();
	Отбор.Вставить("Идентификатор",Идентификатор);
	СтрокаТаблицаСтраниц = ТаблицаСтраниц.НайтиСтроки(Отбор);
	Если СтрокаТаблицаСтраниц.Количество()>0 Тогда
		ИзвлечьСтраницу(КаталогДопИнфо, СтрокаТаблицаСтраниц[0].ИмяМакета);
		ИмяФайлаСтартовойСтраницы = СтрокаТаблицаСтраниц[0].ИмяФайлаСтартовойСтраницы;
		Если ИмяФайлаСтартовойСтраницы<>"" Тогда
			Файл = Новый Файл(КаталогДопИнфо + "\" + ИмяФайлаСтартовойСтраницы);
			Если Файл.Существует() Тогда
				ЗапуститьПриложение(КаталогДопИнфо + "\" + ИмяФайлаСтартовойСтраницы);
			КонецЕсли;
		Иначе
			Сообщить("Данные страницы "+ИмяФайлаСтартовойСтраницы+" не найдены");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Осуществляет случайный выбор страницы (индекса) 
//  из массива страниц
// 
Функция ВыборСтраницы(МассивСтраниц) Экспорт
	Если МассивСтраниц.Количество()>1 Тогда
		ТМП = Час(ТекущаяДата())*60*60+Минута(ТекущаяДата())*60+Секунда(ТекущаяДата());
		Индекс = ТМП - Цел(ТМП/МассивСтраниц.Количество())*МассивСтраниц.Количество();
	Иначе
		Индекс = 0;
	КонецЕсли;
	Возврат МассивСтраниц[Индекс];
КонецФункции

Процедура ВыполнитьДействие() Экспорт
	ОбработкаОписателя();
	Если ТаблицаСтраниц.Количество()=0 Тогда
		// нет показываемых страниц; обработку можно не открывать
		Возврат;
	КонецЕсли;
	
	// страницы есть
	МассивФинальныхРекламныхСтраниц = Новый Массив;
	// обработать таблицу страниц и сформировать командную панель
	ТекРаздел = "";
	Для Каждого СтрокаТаблицы из ТаблицаСтраниц Цикл
		Если СтрокаТаблицы.ТипСтраницы = 1 Тогда
			МассивФинальныхРекламныхСтраниц.Добавить(СтрокаТаблицы.Идентификатор);
		КонецЕсли;
	КонецЦикла;
	
	СоздатьКаталог(КаталогДопИнфо);
	УдалитьФайлы(КаталогДопИнфо,"*.*");
	Если МассивФинальныхРекламныхСтраниц.Количество()>0 Тогда
		ПросмотрФинальнойСтраницы(ВыборСтраницы(МассивФинальныхРекламныхСтраниц));
	КонецЕсли;
КонецПроцедуры

ПрефиксПользователя = ИмяПользователя() + Строка(НомерСоединенияИнформационнойБазы()) + "\";

КаталогДопИнфо = КаталогВременныхФайлов()+ АдресРесурсовОбозревателя+"\"+ПрефиксПользователя+"DopInfo";

ТаблицаСтраниц = Новый ТаблицаЗначений;
ТаблицаСтраниц.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
ТаблицаСтраниц.Колонки.Добавить("ИмяМакета", Новый ОписаниеТипов("Строка"));
ТаблицаСтраниц.Колонки.Добавить("Раздел", Новый ОписаниеТипов("Строка"));
ТаблицаСтраниц.Колонки.Добавить("НаименованиеСтартовойСтраницы", Новый ОписаниеТипов("Строка"));
ТаблицаСтраниц.Колонки.Добавить("ИмяФайлаСтартовойСтраницы", Новый ОписаниеТипов("Строка")); // имя запускаемого файла
ТаблицаСтраниц.Колонки.Добавить("ТипСтраницы", Новый ОписаниеТипов("Число")); // 0-стартовая; 1-финальная; 2-вспомогательная
ТаблицаСтраниц.Колонки.Добавить("ФормаПоказа", Новый ОписаниеТипов("Число")); // 0–рабочий стол; 1–обычная форма; 2–прикрепляемая)
ТаблицаСтраниц.Колонки.Добавить("ДатаНачалаПоказа", Новый ОписаниеТипов("Дата")); // не указана - сразу
ТаблицаСтраниц.Колонки.Добавить("ДатаОкончанияПоказа", Новый ОписаниеТипов("Дата")); // не указана без ограничений
ТаблицаСтраниц.Колонки.Добавить("ВключатьВПервыйПоказ", Новый ОписаниеТипов("Число")); // 0-не включать; =1-включать (при открытии формы)
ТаблицаСтраниц.Колонки.Добавить("ПоказВКонфигурации", Новый ОписаниеТипов("Число")); // 0 - везде; 1 показывать только в ПРОФ; 2 - в базовой

#КонецЕсли