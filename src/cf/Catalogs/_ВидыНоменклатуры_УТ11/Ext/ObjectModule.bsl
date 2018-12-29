﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	//ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	//
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	//
	//Если Не ИспользоватьХарактеристики Тогда
	//	ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.НеИспользовать;
	//КонецЕсли;
	//
	//Если ИспользованиеХарактеристик <> Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
	//	ВладелецХарактеристик = Справочники.ВидыНоменклатуры.ПустаяСсылка();
	//КонецЕсли;
	
	
	АлкогольнаяПродукция = Истина;
	
	//
	//Если Не ИспользоватьСерии Тогда
	//	ПолитикиУчетаСерий.Очистить();
	//	ПолитикаУчетаСерийДляСкладов = Справочники.ПолитикиУчетаСерий.ПустаяСсылка();
	//	ПолитикаУчетаСерийДляПодразделений = Справочники.ПолитикиУчетаСерий.ПустаяСсылка();
	//	ИспользоватьНомерСерии             = Ложь;
	//	ИспользоватьСрокГодностиСерии      = Ложь;
	//	ИспользоватьКоличествоСерии        = Ложь;
	//	ТочностьУказанияСрокаГодностиСерии = Перечисления.ТочностиУказанияСрокаГодности.ПустаяСсылка();
	//	НастройкаИспользованияСерий        = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПустаяСсылка();
	//	НастройкиСерийБерутсяИзДругогоВидаНоменклатуры = Ложь;
	//	ВладелецСерий = Справочники.ВидыНоменклатуры.ПустаяСсылка();
	//Иначе
	//	
	//	Если НастройкиСерийБерутсяИзДругогоВидаНоменклатуры
	//		И Не ДополнительныеСвойства.Свойство("ПропуститьЗаполнениеТЧПолитикиУчетаСерий") Тогда
	//		
	//		Запрос = Новый Запрос;
	//		Запрос.Текст =
	//		"ВЫБРАТЬ
	//		|	ВидыНоменклатуры.НастройкаИспользованияСерий,
	//		|	ВидыНоменклатуры.ТочностьУказанияСрокаГодностиСерии
	//		|ИЗ
	//		|	Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
	//		|ГДЕ
	//		|	ВидыНоменклатуры.Ссылка = &ВладелецСерий
	//		|;
	//		|
	//		|////////////////////////////////////////////////////////////////////////////////
	//		|ВЫБРАТЬ
	//		|	ВидыНоменклатурыПолитикиУчетаСерий.Склад,
	//		|	ВидыНоменклатурыПолитикиУчетаСерий.ПолитикаУчетаСерий
	//		|ИЗ
	//		|	Справочник.ВидыНоменклатуры.ПолитикиУчетаСерий КАК ВидыНоменклатурыПолитикиУчетаСерий
	//		|ГДЕ
	//		|	ВидыНоменклатурыПолитикиУчетаСерий.Ссылка = &ВладелецСерий";
	//		
	//		Запрос.УстановитьПараметр("ВладелецСерий", ВладелецСерий);
	//		
	//		РезультатЗапроса = Запрос.ВыполнитьПакет();
	//		
	//		ВыборкаШапки = РезультатЗапроса[0].Выбрать();
	//		
	//		Если ВыборкаШапки.Следующий() Тогда
	//			НастройкаИспользованияСерий        = ВыборкаШапки.НастройкаИспользованияСерий;
	//			ТочностьУказанияСрокаГодностиСерии = ВыборкаШапки.ТочностьУказанияСрокаГодностиСерии;
	//			ПолитикиУчетаСерий.Загрузить(РезультатЗапроса[1].Выгрузить());
	//		КонецЕсли;
	//	КонецЕсли;	
	//	
	//	ИспользоватьНомерСерии = (НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ЭкземплярТовара
	//	                             Или НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеру
	//	                             Или НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеруИСрокуГодности);
	//	
	//	ИспользоватьСрокГодностиСерии = (НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеруИСрокуГодности
	//	                                    Или НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоСрокуГодности);
	//	
	//	ИспользоватьКоличествоСерии = (НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоСрокуГодности
	//	                                  Или НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеру
	//	                                  Или НастройкаИспользованияСерий = Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеруИСрокуГодности);
	//	
	//	Если Не ИспользоватьСрокГодностиСерии Тогда
	//		ТочностьУказанияСрокаГодностиСерии = Перечисления.ТочностиУказанияСрокаГодности.ПустаяСсылка();
	//	КонецЕсли;
	//КонецЕсли;
	//
	//Если Не	НастройкиСерийБерутсяИзДругогоВидаНоменклатуры Тогда
	//	ВладелецСерий = Справочники.ВидыНоменклатуры.ПустаяСсылка();
	//КонецЕсли;
	//
	//Если Не ТоварныеКатегорииОбщиеСДругимВидомНоменклатуры Тогда
	//	ВладелецТоварныхКатегорий = Справочники.ВидыНоменклатуры.ПустаяСсылка();
	//КонецЕсли;
	//
	//Если ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Услуга 
	//	И ВариантОказанияУслуг = Перечисления.ВариантыОказанияУслуг.ПустаяСсылка() Тогда
	//	ВариантОказанияУслуг = Перечисления.ВариантыОказанияУслуг.ОрганизациейПродавцом;
	//КонецЕсли;
	//
	//КонтролироватьДублиНоменклатуры = РеквизитыДляКонтроляНоменклатуры.НайтиСтроки(Новый Структура("Уникален", Истина)).Количество() > 0;
	//
	//// Обновим элементы справочника НаборыДополнительныхРеквизитовИСведений и ПВХ ДополнительныеРеквизитыИСведения
	//УправлениеСвойствамиУТ.ОбновитьПоляДополнительныхСвойств(ЭтотОбъект,
	//	"Справочник_Номенклатура");
	//УправлениеСвойствамиУТ.ОбновитьПоляДополнительныхСвойств(ЭтотОбъект,
	//	"Справочник_ХарактеристикиНоменклатуры",
	//	"НаборСвойствХарактеристик",
	//	НСтр("ru = ' (Для характеристик)'"),
	//	ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры
	//		ИЛИ ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ИндивидуальныеДляНоменклатуры);
	//УправлениеСвойствамиУТ.ОбновитьПоляДополнительныхСвойств(ЭтотОбъект,
	//	"Справочник_СерииНоменклатуры",
	//	"НаборСвойствСерий",
	//	НСтр("ru = ' (Для серий)'"));
	//	
	//ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый());
	//ДополнительныеСвойства.Вставить("ИспользоватьСерии", Ложь);
	//ДополнительныеСвойства.Вставить("НастройкиСерийБерутсяИзДругогоВидаНоменклатуры", Ложь);
	//
	//Если Не ЭтоНовый() Тогда
	//	СтарыеРеквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "ИспользоватьСерии,НастройкиСерийБерутсяИзДругогоВидаНоменклатуры");
	//	ЗаполнитьЗначенияСвойств(ДополнительныеСвойства, СтарыеРеквизиты);	
	//КонецЕсли;
	//	
	//ЗаполнитьТЧПолитикиУчетаСерийСкладамиИПодразделениями();
	//
КонецПроцедуры 

Процедура ПриКопировании(ОбъектКопирования)
	
	//МетаданныеОбъекта = Метаданные();
	//
	//Если Не ЭтоГруппа Тогда
	//	
	//	НаборСвойств              = Справочники.НаборыДополнительныхРеквизитовИСведений.ПустаяСсылка();
	//	НаборСвойствХарактеристик = Справочники.НаборыДополнительныхРеквизитовИСведений.ПустаяСсылка();
	//	НаборСвойствСерий         = Справочники.НаборыДополнительныхРеквизитовИСведений.ПустаяСсылка();
	//	
	//	ШаблонНаименованияДляПечатиНоменклатуры = МетаданныеОбъекта.Реквизиты.ШаблонНаименованияДляПечатиНоменклатуры.ЗначениеЗаполнения;
	//	ШаблонРабочегоНаименованияНоменклатуры = "";
	//	ЗапретРедактированияРабочегоНаименованияНоменклатуры = Ложь;
	//	ЗапретРедактированияНаименованияДляПечатиНоменклатуры = Ложь;
	//	
	//	ШаблонНаименованияДляПечатиХарактеристики = МетаданныеОбъекта.Реквизиты.ШаблонНаименованияДляПечатиХарактеристики.ЗначениеЗаполнения;
	//	ШаблонРабочегоНаименованияХарактеристики = "";
	//	ЗапретРедактированияРабочегоНаименованияХарактеристики = Ложь;
	//	ЗапретРедактированияНаименованияДляПечатиХарактеристики = Ложь;
	//	
	//	ШаблонРабочегоНаименованияСерии = "";
	//			
	//	Если ПолучитьФункциональнуюОпцию("ИспользоватьТоварныеКатегории") Тогда
	//		Если Не ОбъектКопирования.ТоварныеКатегорииОбщиеСДругимВидомНоменклатуры Тогда
	//			ТоварныеКатегорииОбщиеСДругимВидомНоменклатуры = Истина;
	//			ВладелецТоварныхКатегорий = ОбъектКопирования.Ссылка;
	//		КонецЕсли;
	//	КонецЕсли;
	//	
	//	Если ОбъектКопирования.ИспользоватьСерии Тогда
	//		Если Не ОбъектКопирования.НастройкиСерийБерутсяИзДругогоВидаНоменклатуры Тогда
	//			НастройкиСерийБерутсяИзДругогоВидаНоменклатуры = Истина;
	//			ВладелецСерий = ОбъектКопирования.Ссылка;
	//		КонецЕсли;
	//	КонецЕсли;
	//	
	//	Если ОбъектКопирования.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры Тогда
	//		ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры;
	//		ВладелецХарактеристик = ОбъектКопирования.Ссылка;
	//	КонецЕсли;
	//	
	//КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ЭтоГруппа Тогда
		Возврат;	
	КонецЕсли;
		
	//МассивНепроверяемыхРеквизитов = Новый Массив;
	//Если Не Справочники.ГруппыДоступаНоменклатуры.ИспользуютсяГруппыДоступа()
	//	ИЛИ Не ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоВидовНоменклатуры") Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ГруппаДоступа");
	//КонецЕсли;
	//
	//Если ИспользоватьСерии Тогда
	//	
	//	Если НастройкаИспользованияСерий <> Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоНомеруИСрокуГодности
	//		И НастройкаИспользованияСерий <> Перечисления.НастройкиИспользованияСерийНоменклатуры.ПартияТоваровПоСрокуГодности Тогда
	//		
	//		МассивНепроверяемыхРеквизитов.Добавить("ТочностьУказанияСрокаГодностиСерии");
	//		
	//	КонецЕсли;
	//	
	//	КлючевыеРеквизиты = Новый Массив;
	//	КлючевыеРеквизиты.Добавить("Склад");
	//	
	//	ОбщегоНазначенияУТ.ПроверитьНаличиеДублейСтрокТЧ(ЭтотОбъект, "ПолитикиУчетаСерий", КлючевыеРеквизиты, Отказ,,Ложь);
	//	Если Не НастройкиСерийБерутсяИзДругогоВидаНоменклатуры Тогда
	//		МассивНепроверяемыхРеквизитов.Добавить("ВладелецСерий");
	//	КонецЕсли;	
	//	
	//	ИспользоватьНесколькоСкладов = ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоСкладов");
	//	
	//	Если Не ИспользоватьНесколькоСкладов
	//		Или(ИспользоватьНесколькоСкладов
	//		И Не ЕдинаяНастройкаСерийДляСкладов) Тогда
	//		МассивНепроверяемыхРеквизитов.Добавить("ПолитикаУчетаСерийДляСкладов");
	//	КонецЕсли;
	//	
	//	Если Не ЕдинаяНастройкаСерийДляПодразделений Тогда
	//		МассивНепроверяемыхРеквизитов.Добавить("ПолитикаУчетаСерийДляПодразделений");
	//	КонецЕсли;	
	//	
	//Иначе
	//	
	//	МассивНепроверяемыхРеквизитов.Добавить("ТочностьУказанияСрокаГодностиСерии");
	//	МассивНепроверяемыхРеквизитов.Добавить("НастройкаИспользованияСерий");
	//	МассивНепроверяемыхРеквизитов.Добавить("ПолитикаУчетаСерийДляСкладов");
	//	МассивНепроверяемыхРеквизитов.Добавить("ПолитикаУчетаСерийДляПодразделений");
	//	МассивНепроверяемыхРеквизитов.Добавить("ВладелецСерий");
	//	
	//КонецЕсли;
	//
	//Если Не ИспользоватьХарактеристики Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ИспользованиеХарактеристик");
	//	МассивНепроверяемыхРеквизитов.Добавить("ВладелецХарактеристик");
	//ИначеЕсли ИспользованиеХарактеристик <> Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ВладелецХарактеристик");
	//КонецЕсли;
	//
	//Если Не ТоварныеКатегорииОбщиеСДругимВидомНоменклатуры Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ВладелецТоварныхКатегорий");
	//КонецЕсли;	
	//
	//Если Не Справочники.ГруппыДоступаНоменклатуры.ИспользуютсяГруппыДоступа() Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ГруппаДоступа");
	//КонецЕсли;
	//
	//Если Не ИспользоватьУпаковки Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("НаборУпаковок");
	//КонецЕсли;
	//
	//Если Не ПоставляетсяВМногооборотнойТаре Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("НоменклатураМногооборотнаяТара");
	//	МассивНепроверяемыхРеквизитов.Добавить("ХарактеристикаМногооборотнаяТара");
	//ИначеЕсли Не Справочники.Номенклатура.ХарактеристикиИспользуются(НоменклатураМногооборотнаяТара) Тогда
	//	МассивНепроверяемыхРеквизитов.Добавить("ХарактеристикаМногооборотнаяТара");
	//КонецЕсли;
	//
	//СтруктураШаблонов = Новый Структура;
	//СтруктураШаблонов.Вставить("ШаблонНаименованияДляПечатиНоменклатуры", ШаблонНаименованияДляПечатиНоменклатуры);
	//СтруктураШаблонов.Вставить("ШаблонНаименованияДляПечатиХарактеристики", ШаблонНаименованияДляПечатиХарактеристики);
	//СтруктураШаблонов.Вставить("ШаблонРабочегоНаименованияНоменклатуры", ШаблонРабочегоНаименованияНоменклатуры);
	//СтруктураШаблонов.Вставить("ШаблонРабочегоНаименованияХарактеристики", ШаблонРабочегоНаименованияХарактеристики);
	//
	//ШаблонТекстаОшибки = НСтр("ru='В формуле шаблона ""%ИмяШаблона%"" обнаружены ошибки'");
	//МетаданныеОбъекта = ЭтотОбъект.Метаданные();
	//
	//Для Каждого Элемент Из СтруктураШаблонов Цикл
	//	
	//	Шаблон = Элемент.Значение;
	//	
	//	Если ЗначениеЗаполнено(Шаблон) Тогда
	//		
	//		ТекстОшибки = СтрЗаменить(
	//		ШаблонТекстаОшибки,
	//		"%ИмяШаблона%",
	//		МетаданныеОбъекта.Реквизиты[Элемент.Ключ].Синоним);
	//		
	//		Если Не РаботаСФормуламиКлиентСервер.ПроверитьФормулу(
	//			Шаблон,
	//			РаботаСФормуламиКлиентСервер.ПолучитьМассивОперандовТекстовойФормулы(Шаблон),
	//			Элемент.Ключ,
	//			ТекстОшибки,
	//			Истина,
	//			"Объект") Тогда
	//			Отказ = Истина;
	//		КонецЕсли;
	//		
	//	КонецЕсли;
	//	
	//КонецЦикла;
	//
	//ПроверитьСовпадающиеРеквизитыДляОтбора(Отказ);
	//	
	//ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	//
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	//Если ДополнительныеСвойства.ЭтоНовый 
	//	И Не ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоВидовНоменклатуры") Тогда
	//	Запрос = Новый Запрос;
	//	Запрос.Текст =
	//	"ВЫБРАТЬ
	//	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВидыНоменклатуры.Ссылка) КАК КоличествоВидов
	//	|ИЗ
	//	|	Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
	//	|ГДЕ
	//	|	НЕ ВидыНоменклатуры.ЭтоГруппа";
	//	
	//	Выборка = Запрос.Выполнить().Выбрать();
	//	
	//	Если Выборка.Следующий() Тогда
	//		
	//		Если Выборка.КоличествоВидов > 2 Тогда
	//			УстановитьПривилегированныйРежим(Истина);
	//			
	//			Константы.ИспользоватьНесколькоВидовНоменклатуры.Установить(Истина);
	//			
	//			УстановитьПривилегированныйРежим(Ложь);
	//			
	//		КонецЕсли;
	//		
	//	КонецЕсли;
	//	
	//КонецЕсли;	
	//

	//
	//ОбновитьФлагиИспользованияСерийНаСкладахИВПроизводстве();
	//ОбновитьСвязанныеВидыНоменклатуры();
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если Не ЭтоГруппа Тогда
		ГруппаДоступа = Справочники.ГруппыДоступаНоменклатуры.ПолучитьГруппуДоступаПоУмолчанию(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбновитьФлагиИспользованияСерийНаСкладахИВПроизводстве()
	
	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьСерииНоменклатуры") Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.Свойство("ПропуститьОбновлениеФлагаИспользованияСерий")
		Или	ДополнительныеСвойства.Свойство("ПропуститьОбновлениеФлагаКонтроляОперативныхОстатков") Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПолитикиУчетаСерий.Склад,
	|	ИСТИНА КАК ИспользоватьСерии,
	|	МАКСИМУМ(ПолитикиУчетаСерий.ПолитикаУчетаСерий.УчитыватьСебестоимостьПоСериям) КАК УчитыватьСебестоимостьПоСериям,
	|	МАКСИМУМ(ПолитикиУчетаСерий.ПолитикаУчетаСерий.УказыватьПриПланированииОтбора) КАК УказыватьПриПланированииОтбора
	|ПОМЕСТИТЬ ВидыНоменклатуры
	|ИЗ
	|	Справочник.ВидыНоменклатуры.ПолитикиУчетаСерий КАК ПолитикиУчетаСерий
	|
	|СГРУППИРОВАТЬ ПО
	|	ПолитикиУчетаСерий.Склад
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Склады.Ссылка КАК Склад,
	|	ЕСТЬNULL(ВидыНоменклатуры.ИспользоватьСерии, ЛОЖЬ) КАК ИспользоватьСерииНоменклатуры,
	|	ЕСТЬNULL(ВидыНоменклатуры.УчитыватьСебестоимостьПоСериям, ЛОЖЬ) КАК УчитыватьСебестоимостьПоСериям,
	|	ЕСТЬNULL(ВидыНоменклатуры.УказыватьПриПланированииОтбора, ЛОЖЬ) КАК УказыватьПриПланированииОтбора
	|ИЗ
	|	Справочник.Склады КАК Склады
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВидыНоменклатуры КАК ВидыНоменклатуры
	|		ПО Склады.Ссылка = ВидыНоменклатуры.Склад
	|ГДЕ
	|	НЕ Склады.ЭтоГруппа
	|	И (ЕСТЬNULL(ВидыНоменклатуры.ИспользоватьСерии, ЛОЖЬ) <> Склады.ИспользоватьСерииНоменклатуры
	|			ИЛИ ЕСТЬNULL(ВидыНоменклатуры.УчитыватьСебестоимостьПоСериям, ЛОЖЬ) <> Склады.УчитыватьСебестоимостьПоСериям
	|			ИЛИ ЕСТЬNULL(ВидыНоменклатуры.УказыватьПриПланированииОтбора, ЛОЖЬ)
	|				И НЕ Склады.КонтролироватьОперативныеОстатки)";
	
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если ТипЗнч(Выборка.Склад) = Тип("СправочникСсылка.Склады") Тогда
			
			СкладОбъект = Выборка.Склад.ПолучитьОбъект();
			
			СкладОбъект.ИспользоватьСерииНоменклатуры  = Выборка.ИспользоватьСерииНоменклатуры;
			СкладОбъект.УчитыватьСебестоимостьПоСериям = Выборка.УчитыватьСебестоимостьПоСериям;
			
			Если Выборка.УказыватьПриПланированииОтбора Тогда
				
				СкладОбъект.КонтролироватьОперативныеОстатки = Истина;
				
			КонецЕсли;
			
			СкладОбъект.ДополнительныеСвойства.Вставить("ПропуститьОбновлениеФлагаИспользованияСерий");
			СкладОбъект.ДополнительныеСвойства.Вставить("ПропуститьОбновлениеФлагаКонтроляОперативныхОстатков");
			
			СкладОбъект.Записать();
			
		Иначе
			
			ПодразделениеОбъект = Выборка.Склад.ПолучитьОбъект();
			
			ПодразделениеОбъект.ИспользоватьСерииНоменклатуры  = Выборка.ИспользоватьСерииНоменклатуры;
			ПодразделениеОбъект.УчитыватьСебестоимостьПоСериям = Выборка.УчитыватьСебестоимостьПоСериям;
			
			ПодразделениеОбъект.ДополнительныеСвойства.Вставить("ПропуститьОбновлениеФлагаИспользованияСерий");
			ПодразделениеОбъект.Записать();
		
		КонецЕсли; 
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьТЧПолитикиУчетаСерийСкладамиИПодразделениями()
	//
	//Если Не ИспользоватьСерии Тогда
	//	Возврат;
	//КонецЕсли;
	//
	//Если ДополнительныеСвойства.Свойство("ПропуститьЗаполнениеТЧПолитикиУчетаСерий") Тогда
	//	Возврат;
	//КонецЕсли;
	//
	//УстановитьПривилегированныйРежим(Истина);
	//
	//ИспользоватьНесколькоСкладов = ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоСкладов");
	//
	//Если Не ИспользоватьНесколькоСкладов
	//	Или ЕдинаяНастройкаСерийДляСкладов Тогда
	//	
	//	СтрокиКУдалению = Новый Массив;
	//	Для каждого СтрТабл Из ПолитикиУчетаСерий Цикл
	//		Если ТипЗнч(СтрТабл.Склад) = Тип("СправочникСсылка.Склады") Тогда
	//			СтрокиКУдалению.Добавить(СтрТабл);
	//		КонецЕсли; 
	//	КонецЦикла;
	//	Для каждого СтрМас Из СтрокиКУдалению Цикл
	//		ПолитикиУчетаСерий.Удалить(СтрМас);
	//	КонецЦикла; 
	//	
	//	Если Не ИспользоватьНесколькоСкладов Тогда 
	//		ЕдинаяНастройкаСерийДляСкладов = Истина;
	//		Склад = ЗначениеНастроекПовтИсп.ПолучитьСкладПоУмолчанию(Склад);
	//		НоваяСтрока = ПолитикиУчетаСерий.Добавить();
	//		НоваяСтрока.Склад = Склад;
	//		НоваяСтрока.ПолитикаУчетаСерий = ПолитикаУчетаСерийДляСкладов;
	//	Иначе
	//		Запрос = Новый Запрос;
	//		Запрос.Текст =
	//		"ВЫБРАТЬ
	//		|	Склады.Ссылка КАК Склад
	//		|ИЗ
	//		|	Справочник.Склады КАК Склады
	//		|ГДЕ
	//		|	НЕ Склады.ЭтоГруппа";
	//		
	//		Выборка = Запрос.Выполнить().Выбрать();
	//		
	//		Пока Выборка.Следующий() Цикл
	//			
	//			НоваяСтрока = ПолитикиУчетаСерий.Добавить();
	//			НоваяСтрока.Склад = Выборка.Склад;
	//			НоваяСтрока.ПолитикаУчетаСерий = ПолитикаУчетаСерийДляСкладов;
	//			
	//		КонецЦикла;
	//		
	//	КонецЕсли;
	//		
	//КонецЕсли;
	//
	//Если ЕдинаяНастройкаСерийДляПодразделений Тогда
	//	
	//	СтрокиКУдалению = Новый Массив;
	//	Для каждого СтрТабл Из ПолитикиУчетаСерий Цикл
	//		Если ТипЗнч(СтрТабл.Склад) = Тип("СправочникСсылка.СтруктураПредприятия") Тогда
	//			СтрокиКУдалению.Добавить(СтрТабл);
	//		КонецЕсли; 
	//	КонецЦикла;
	//	Для каждого СтрМас Из СтрокиКУдалению Цикл
	//		ПолитикиУчетаСерий.Удалить(СтрМас);
	//	КонецЦикла; 
	//	
	//	Запрос = Новый Запрос;
	//	Запрос.Текст =
	//	"ВЫБРАТЬ
	//	|	СтруктураПредприятия.Ссылка КАК Подразделение
	//	|ИЗ
	//	|	Справочник.СтруктураПредприятия КАК СтруктураПредприятия
	//	|ГДЕ
	//	|	СтруктураПредприятия.ПроизводственноеПодразделение";
	//	
	//	Выборка = Запрос.Выполнить().Выбрать();
	//	
	//	Пока Выборка.Следующий() Цикл
	//		
	//		НоваяСтрока = ПолитикиУчетаСерий.Добавить();
	//		НоваяСтрока.Склад = Выборка.Подразделение;
	//		НоваяСтрока.ПолитикаУчетаСерий = ПолитикаУчетаСерийДляПодразделений;
	//		
	//	КонецЦикла;
	//		
	//КонецЕсли;
КонецПроцедуры

Процедура ОбновитьСвязанныеВидыНоменклатуры()
	//
	//Если ДополнительныеСвойства.ЭтоНовый 
	//	Или Не ДополнительныеСвойства.ИспользоватьСерии
	//	Или ДополнительныеСвойства.НастройкиСерийБерутсяИзДругогоВидаНоменклатуры Тогда
	//	Возврат;
	//КонецЕсли;
	//
	//Запрос = Новый Запрос;
	//Запрос.Текст =
	//"ВЫБРАТЬ
	//|	ВидыНоменклатуры.Ссылка КАК ВидНоменклатуры
	//|ИЗ
	//|	Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
	//|ГДЕ
	//|	ВидыНоменклатуры.ВладелецСерий = &ВладелецСерий";
	//
	//Запрос.УстановитьПараметр("ВладелецСерий", Ссылка);
	//
	//Выборка = Запрос.Выполнить().Выбрать();
	//
	//Пока Выборка.Следующий() Цикл
	//	
	//	ИзменяемыйОбъект = Выборка.ВидНоменклатуры.ПолучитьОбъект();
	//	
	//	ИзменяемыйОбъект.ИспользоватьСерии = ИспользоватьСерии;
	//	Если Не ИспользоватьСерии Тогда
	//		ИзменяемыйОбъект.НастройкиСерийБерутсяИзДругогоВидаНоменклатуры = Ложь;
	//		//Остальные поля очистятся при записи
	//		ИзменяемыйОбъект.Записать();
	//		Продолжить;
	//	КонецЕсли;
	//	                               
	//	ИзменяемыйОбъект.НастройкаИспользованияСерий        = НастройкаИспользованияСерий;
	//	ИзменяемыйОбъект.ТочностьУказанияСрокаГодностиСерии = ТочностьУказанияСрокаГодностиСерии;
	//	ИзменяемыйОбъект.ПолитикиУчетаСерий.Загрузить(ПолитикиУчетаСерий.Выгрузить());
	//	
	//	//Остальные поля заполнятся при записи
	//	ИзменяемыйОбъект.ДополнительныеСвойства.Вставить("ПропуститьЗаполнениеТЧПолитикиУчетаСерий");
	//	ИзменяемыйОбъект.ДополнительныеСвойства.Вставить("ПропуститьОбновлениеФлагаИспользованияСерий");
	//	ИзменяемыйОбъект.ДополнительныеСвойства.Вставить("ПропуститьОбновлениеФлагаКонтроляОперативныхОстатков");
	//	
	//	ИзменяемыйОбъект.Записать();
	//			
	//КонецЦикла;
	
КонецПроцедуры

// Проверяет, есть ли совпадающие реквизиты для быстрого отбора номенклатуры и характеристик.
// Если есть, то выводит сообщение пользователю, т.к. не допускается добавлять один и тот же 
// дополнительный реквизит в панель быстрого отбора и для номенклатуры и для характеристик. 
// Если требуется такая настройка, то следует создать два отдельных доп. реквизита 
// и соответственно указать их для номенклатуры и для характеристик.
//
// Например:
//	Марка (для номенклатуры) и Марка (для характеристик).
//
// Параметры:
//	Отказ - Булево, Неопределено - переменная в которую записывается флаг отказа.
//
Процедура ПроверитьСовпадающиеРеквизитыДляОтбора(Отказ)
	
	//Перем СовпадающиеРеквизиты;
	//
	//Если ЕстьСовпадающиеРеквизитыОтбораНоменклатурыХарактеристик(СовпадающиеРеквизиты) Тогда
	//	
	//	Отказ = Истина;
	//	
	//	Для каждого ПараметрыРеквизита Из СовпадающиеРеквизиты Цикл
	//		
	//		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
	//			НСтр("ru = 'Дополнительный реквизит для отбора номенклатуры в строке %1 совпадает с дополнительным реквизитом для отбора характеристик.'"), 
	//			ПараметрыРеквизита.НомерСтроки);
	//		
	//		Поле = "РеквизитыБыстрогоОтбораНоменклатуры[" + Формат(ПараметрыРеквизита.ИндексСтроки, "ЧЦ=10; ЧГ=0") + "].ПредставлениеРеквизита";
	//		
	//		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Поле, "Объект");
	//		
	//	КонецЦикла;
	//	
	//КонецЕсли;
	
КонецПроцедуры

// Проверяет, имеются ли в списке доп.реквизитов для быстрого отбора номенклатуры и характеристик
// совпадающие значения.
//
// Параметры:
//	СовпадающиеРеквизиты - Неопределено - переменная в которую записывается массив значений совпадающих реквизитов.
//
// Возвращаемое значение:
//	Булево - Истина - есть совпадающие реквизиты отбора номенклатуры характеристик.
//
Функция ЕстьСовпадающиеРеквизитыОтбораНоменклатурыХарактеристик(СовпадающиеРеквизиты)
	
	СовпадающиеРеквизиты = Новый Массив;
	
	Если Не ИспользоватьХарактеристики Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Отбор = Новый Структура("Свойство");
	
	Для каждого СтрокаТабл Из РеквизитыБыстрогоОтбораНоменклатуры Цикл
		
		Если Не СтрокаТабл.Используется Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Отбор, СтрокаТабл);
		
		МассивСтрок = РеквизитыБыстрогоОтбораХарактеристик.НайтиСтроки(Отбор);
		
		Если МассивСтрок.Количество() > 0 Тогда
			ПараметрыРеквизита = Новый Структура("Свойство, НомерСтроки, ИндексСтроки", 
				СтрокаТабл.Свойство, СтрокаТабл.НомерСтроки, РеквизитыБыстрогоОтбораНоменклатуры.Индекс(СтрокаТабл));
			
			СовпадающиеРеквизиты.Добавить(ПараметрыРеквизита);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат (СовпадающиеРеквизиты.Количество() > 0);
	
КонецФункции

#КонецОбласти

#КонецЕсли
