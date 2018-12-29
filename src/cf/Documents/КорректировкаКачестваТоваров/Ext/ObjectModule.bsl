﻿Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт

	Если ЭтоНовый() Тогда
		Предупреждение("Документ можно распечатать только после его записи");
		Возврат;
	ИначеЕсли Не УправлениеДопПравамиПользователей.РазрешитьПечатьНепроведенныхДокументов(Проведен) Тогда
		Предупреждение("Недостаточно полномочий для печати непроведенного документа!");
		Возврат;
	КонецЕсли;

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	Если ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Процедура выполняет заполнение табличной части по документу основанию.
// При заполнении копируется состав документа,
// количество - минимум из того, что есть в документе основании и свободного остатка на складе.
//
// Параметры:
//  ДокументОснование - ссылка на документ основание.
//
Процедура ЗаполнитьТоварыПоПоступлениюТоваровУпр(ДокументОснование) Экспорт

	ДокументОснованиеИмя = ДокументОснование.Метаданные().Имя;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Склад",             Склад);
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
	Запрос.УстановитьПараметр("Товар",             Перечисления.ТоварТара.Товар);
	Запрос.УстановитьПараметр("ДатаОстатков", 	   ОбщегоНазначения.ПолучитьДатуОстатков(ЭтотОбъект));
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	МИНИМУМ(Док.НомерСтроки)            КАК НомерСтроки,
	|	Док.Номенклатура                    КАК Номенклатура,
	|	Док.ЕдиницаИзмерения                КАК ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмеренияМест            КАК ЕдиницаИзмеренияМест,
	|	Док.Коэффициент                     КАК Коэффициент,
	|	СУММА(Док.Количество)               КАК КоличествоПоДокументу,
	|	МАКСИМУМ(Остатки.КоличествоОстаток) КАК КоличествоОстатокКомпании,
	|	Док.ХарактеристикаНоменклатуры      КАК ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры               КАК СерияНоменклатуры
	|ИЗ
	|	Документ." + ДокументОснованиеИмя + ".Товары КАК Док
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.%ИмяРегистраОстатки%.Остатки(&ДатаОстатков, Склад = &Склад) КАК Остатки
	|ПО
	|	Док.Номенклатура = Остатки.Номенклатура
	| И Док.ХарактеристикаНоменклатуры = Остатки.ХарактеристикаНоменклатуры
	|
	|ГДЕ
	|	Док.Ссылка = &ДокументОснование И
	|	Остатки.КоличествоОстаток > 0
	|	%УсловиеПоСкладу%
	|
	|СГРУППИРОВАТЬ ПО
	|	Док.Номенклатура,
	|	Док.ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмеренияМест,
	|	Док.Коэффициент,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";
	
	ТекстЗапроса = стрЗаменить(ТекстЗапроса,"%ИмяРегистраОстатки%", ?(Склад.ВидСклада=Перечисления.ВидыСкладов.Розничный,"ТоварыВРознице","ТоварыНаСкладах"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%УсловиеПоСкладу%",
		?(НЕ ЗначениеЗаполнено(Склад), "", "И Док.Склад = &Склад"));

	Запрос.Текст = ТекстЗапроса;
	РезультатЗапроса = Запрос.Выполнить();

	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл

		СтрокаТабличнойЧасти = Товары.Добавить();

		СтрокаТабличнойЧасти.Номенклатура         = Выборка.Номенклатура;
		СтрокаТабличнойЧасти.Количество           = Мин(Выборка.КоличествоПоДокументу, Выборка.КоличествоОстатокКомпании);
		СтрокаТабличнойЧасти.ЕдиницаИзмерения     = Выборка.ЕдиницаИзмерения;
		СтрокаТабличнойЧасти.ЕдиницаИзмеренияМест = Выборка.ЕдиницаИзмеренияМест;
		СтрокаТабличнойЧасти.Коэффициент          = Выборка.Коэффициент;

		ОбработкаТабличныхЧастей.РассчитатьКоличествоМестТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);

		СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
		СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;
		СтрокаТабличнойЧасти.Качество                   = Справочники.Качество.Новый;
		СтрокаТабличнойЧасти.КачествоНовое              = Справочники.Качество.Новый;
	КонецЦикла;

КонецПроцедуры // ЗаполнитьТоварыПоОснованиюУпр()

// Процедура выполняет заполнение табличной части по документу основанию.
// При заполнении копируется состав документа,
// количество - минимум из того, что есть в документе основании и свободного остатка на складе.
//
// Параметры:
//  ДокументОснование - ссылка на документ основание.
//
Процедура ЗаполнитьТоварыПоПриходномуОрдеруУпр(ДокументОснование) Экспорт

	ДокументОснованиеИмя = ДокументОснование.Метаданные().Имя;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Склад",             Склад);
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	МИНИМУМ(Док.НомерСтроки)            КАК НомерСтроки,
	|	Док.Номенклатура                    КАК Номенклатура,
	|	Док.ЕдиницаИзмерения                КАК ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмеренияМест            КАК ЕдиницаИзмеренияМест,
	|	Док.Коэффициент                     КАК Коэффициент,
	|	СУММА(Док.Количество)               КАК КоличествоПоДокументу,
	|	МАКСИМУМ(Остатки.КоличествоОстаток) КАК КоличествоОстатокКомпании,
	|	Док.ХарактеристикаНоменклатуры      КАК ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры               КАК СерияНоменклатуры
	|ИЗ
	|	Документ." + ДокументОснованиеИмя + ".Товары КАК Док
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыКПолучениюНаСклады.Остатки(, Склад = &Склад) КАК Остатки
	|ПО
	|	Док.Номенклатура = Остатки.Номенклатура
	| И Док.ХарактеристикаНоменклатуры = Остатки.ХарактеристикаНоменклатуры
	|
	|ГДЕ
	|	Док.Ссылка = &ДокументОснование И
	|	Остатки.КоличествоОстаток > 0
	|
	|СГРУППИРОВАТЬ ПО
	|	Док.Номенклатура,
	|	Док.ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмеренияМест,
	|	Док.Коэффициент,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";
	РезультатЗапроса = Запрос.Выполнить();

	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл

		СтрокаТабличнойЧасти = Товары.Добавить();

		СтрокаТабличнойЧасти.Номенклатура         = Выборка.Номенклатура;
		СтрокаТабличнойЧасти.Количество           = Мин(Выборка.КоличествоПоДокументу, Выборка.КоличествоОстатокКомпании);
		СтрокаТабличнойЧасти.ЕдиницаИзмерения     = Выборка.ЕдиницаИзмерения;
		СтрокаТабличнойЧасти.ЕдиницаИзмеренияМест = Выборка.ЕдиницаИзмеренияМест;
		СтрокаТабличнойЧасти.Коэффициент          = Выборка.Коэффициент;

		ОбработкаТабличныхЧастей.РассчитатьКоличествоМестТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);

		СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
		СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;
		СтрокаТабличнойЧасти.Качество                   = Справочники.Качество.Новый;
		СтрокаТабличнойЧасти.КачествоНовое              = Справочники.Качество.Новый;
	КонецЦикла;

КонецПроцедуры // ЗаполнитьТоварыПоПриходномуОрдеруУпр()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары",
//  СтруктураШапкиДокумента   - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблица значений.
//
Функция ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента)

	ТаблицаТоваров = РезультатЗапросаПоТоварам.Выгрузить();

	ПодготовитьТаблицуТоваровУпр(ТаблицаТоваров);

	Возврат ТаблицаТоваров;

КонецФункции // ПодготовитьТаблицуТоваров()

Процедура ПодготовитьТаблицуТоваровУпр(ТаблицаТоваров)

КонецПроцедуры // ПодготовитьТаблицуТоваров()

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация, Склад");

	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);

	// Вызовем общую процедуру для проверки проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

	Если СтруктураШапкиДокумента.ВидСклада = Перечисления.ВидыСкладов.НТТ Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Документ не может корректировать качество в НТТ!", Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
// Параметры: 
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Номенклатура, Количество");

	// Вызовем общую процедуру для проверки проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураОбязательныхПолей, Отказ, Заголовок);

	// Здесь услуг быть не должно.
	УправлениеЗапасами.ПроверитьЧтоНетУслуг(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);

	// Здесь наборов-пакетов быть не должно.
	УправлениеЗапасами.ПроверитьЧтоНетНаборов(ЭтотОбъект,"Товары", ТаблицаПоТоварам, Отказ, Заголовок);

	// Здесь наборов-комплектов быть не должно.
	УправлениеЗапасами.ПроверитьЧтоНетКомплектов(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);
	
	//Проверить на наличие строк, которые ничего не меняют
	ПроверитьНаличиеИзменяемыхРеквизитов(ТаблицаПоТоварам, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

Процедура ПроверитьНаличиеИзменяемыхРеквизитов(ТаблицаПоТоварам, Отказ, Заголовок)
	Для каждого Строка из ТаблицаПоТоварам цикл
		Если Строка.Качество = Строка.КачествоНовое Тогда
			ОбщегоНазначения.СообщитьОбОшибке("В строке № "+СокрЛП(Строка.НомерСтроки)+" не происходит изменение качества товара", Отказ, Заголовок);

		КонецЕсли
	КонецЦикла;
КонецПроцедуры

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры: 
//  РежимПроведения            - режим проведения документа (оперативный или неоперативный),
//  СтруктураШапкиДокумента    - выборка из результата запроса по шапке документа,
//  ТаблицаПоТоварам           - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  Отказ                      - флаг отказа в проведении,
//  Заголовок                  - строка, заголовок сообщения об ошибке проведения.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, Отказ, Заголовок)

	Перем ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая;

	ТаблицаПоТоварамСтарая = ТаблицаПоТоварам.Скопировать();

	ТаблицаПоТоварамНовая = ТаблицаПоТоварам.Скопировать();
	ТаблицаПоТоварамНовая.Колонки.Качество     .Имя = "КачествоСтарое";
	ТаблицаПоТоварамНовая.Колонки.КачествоНовое.Имя = "Качество";

	ДвиженияПоРегистрамУпр(РежимПроведения,       СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок);
	ДвиженияПоТоварамОрганизаций(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок);
	ДвиженияПоСписаннымТоварам(РежимПроведения,   СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок);

	УчетнаяПолитика = РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(Дата);

	ЗаписьРегистрации = ПринадлежностьПоследовательностям.ПартионныйУчет.Добавить();
	ЗаписьРегистрации.Период      = Дата;

	Если УчетнаяПолитика.СписыватьПартииПриПроведенииДокументов Тогда

		УправлениеЗапасамиПартионныйУчет.ДвижениеПартийТоваров(Ссылка, Движения.СписанныеТовары.Выгрузить());

	Иначе

		// В неоперативном режиме границы последовательностей сдвигаются назад, если они позже документа.
		Если РежимПроведения = РежимПроведенияДокумента.Неоперативный Тогда
			УправлениеЗапасамиПартионныйУчет.СдвигГраницыПоследовательностиПартионногоУчетаНазад(Дата, Ссылка, Организация);
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияПоРегистрамУпр(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок)

	Если СтруктураШапкиДокумента.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
		НаборДвижений = Движения.ТоварыВРознице;
	Иначе
		НаборДвижений = Движения.ТоварыНаСкладах;
	КонецЕсли;

	// Проверка остатков при оперативном проведении.
	Если РежимПроведения = РежимПроведенияДокумента.Оперативный Тогда
		НаборДвижений.КонтрольОстатков(ЭтотОбъект, "Товары", СтруктураШапкиДокумента, Отказ, Заголовок);
	КонецЕсли;

	ТаблицаПоТоварамСтарая = ТаблицаПоТоварам.Скопировать();

	// ТОВАРЫ ПО РЕГИСТРУ ТоварыНаСкладах ИЛИ ТоварыВРознице. Расход.
	Если Не Отказ Тогда

		СтруктТаблицДокумента = Новый Структура;
		СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоТоварам);

		ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);

		ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "Склад", Склад);

		Если СтруктураШапкиДокумента.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
			ТаблицаПоЦенам = УправлениеРозничнойТорговлей.СформироватьЗапросПоПродажнымЦенам(Дата, Склад, ТаблицыДанныхДокумента.ТаблицаПоТоварам.ВыгрузитьКолонку("Номенклатура")).Выгрузить();
			УправлениеРозничнойТорговлей.ЗаполнитьКолонкуСуммаПродажная(ТаблицыДанныхДокумента.ТаблицаПоТоварам, ТаблицаПоЦенам);
		КонецЕсли;

		ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Расход, ТаблицыДанныхДокумента, Дата);

		// ТОВАРЫ ПО РЕГИСТРУ ТоварыНаСкладах ИЛИ ТоварыВРознице. Приход.
		Если СтруктураШапкиДокумента.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
			НаборДвижений = Движения.ТоварыВРознице;
		Иначе
			НаборДвижений = Движения.ТоварыНаСкладах;
		КонецЕсли;

		ТаблицаПоТоварамНовая = ТаблицаПоТоварам.Скопировать();

		ТаблицаПоТоварамНовая.Колонки.Качество.Имя      = "КачествоСтарое";
		ТаблицаПоТоварамНовая.Колонки.КачествоНовое.Имя = "Качество";

		СтруктТаблицДокумента = Новый Структура;
		СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоТоварамНовая);

		ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);

		ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "Склад", Склад);

		Если СтруктураШапкиДокумента.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
			ТаблицаПоЦенам = УправлениеРозничнойТорговлей.СформироватьЗапросПоПродажнымЦенам(Дата, Склад, ТаблицыДанныхДокумента.ТаблицаПоТоварам.ВыгрузитьКолонку("Номенклатура")).Выгрузить();
			УправлениеРозничнойТорговлей.ЗаполнитьКолонкуСуммаПродажная(ТаблицыДанныхДокумента.ТаблицаПоТоварам, ТаблицаПоЦенам);
		КонецЕсли;

		ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Приход, ТаблицыДанныхДокумента, Дата);

	КонецЕсли;

КонецПроцедуры // ДвиженияПоРегистрамУпр()

Процедура ДвиженияПоТоварамОрганизаций(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок)

	Если НЕ СтруктураШапкиДокумента.ОтражатьВРегламентированномУчете 
	 Или Отказ Тогда
		Возврат;
	КонецЕсли;

	// ТОВАРЫ ПО РЕГИСТРУ ТоварыОрганизаций.

	НаборДвижений = Движения.ТоварыОрганизаций;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамСтарая, ТаблицаДвижений);

	// Недостающие поля.
	ТаблицаДвижений.ЗаполнитьЗначения(Организация, "Организация");
	ТаблицаДвижений.ЗаполнитьЗначения(Неопределено,"Комиссионер");

	Если Не СтруктураШапкиДокумента.ВестиУчетТоваровОрганизацийВРазрезеСкладов Тогда
		ТаблицаДвижений.ЗаполнитьЗначения(Неопределено, "Склад");
	КонецЕсли;

	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	// Проверка остатков при оперативном проведении.
	Если РежимПроведения = РежимПроведенияДокумента.Оперативный Тогда
		НаборДвижений.КонтрольОстатков(ЭтотОбъект, "Товары", СтруктураШапкиДокумента, Отказ, Заголовок);
	КонецЕсли;

	Если Не Отказ Тогда
		Движения.ТоварыОрганизаций.ВыполнитьРасход();
	КонецЕсли;

	// ТОВАРЫ ПО РЕГИСТРУ ТоварыОрганизаций.

	НаборДвижений = Движения.ТоварыОрганизаций;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамНовая, ТаблицаДвижений);

	// Недостающие поля.
	ТаблицаДвижений.ЗаполнитьЗначения(Организация, "Организация");
	ТаблицаДвижений.ЗаполнитьЗначения(Неопределено,"Комиссионер");

	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ТоварыОрганизаций.ВыполнитьПриход();
	КонецЕсли;

КонецПроцедуры // ДвиженияПоТоварамОрганизаций()

Процедура ЗаполнитьКолонкиРегистраСписанныеТоварыУпр(ТаблицаДвижений)

	ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.СтатусыПартийТоваров.Купленный,  "ДопустимыйСтатус1");
	ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.СтатусыПартийТоваров.НаКомиссию, "ДопустимыйСтатус2");
	ТаблицаДвижений.ЗаполнитьЗначения(Подразделение, "Подразделение");
	ТаблицаДвижений.ЗаполнитьЗначения(Истина, "ОтражатьВУправленческомУчете");

КонецПроцедуры

Процедура ДвиженияПоСписаннымТоварам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПоТоварамСтарая, ТаблицаПоТоварамНовая, Отказ, Заголовок)

	// ТОВАРЫ ПО РЕГИСТРУ СписанныеТовары.

	НаборДвижений = Движения.СписанныеТовары;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамСтарая, ТаблицаДвижений);

	// Недостающие поля.
	Инд = 0;
	Для каждого Строка Из ТаблицаДвижений Цикл
		СтрокаТаблицыПоТоварам = ТаблицаПоТоварамСтарая[Инд];
		Инд = Инд+1;
		Строка.НомерСтрокиДокумента = Инд;
	КонецЦикла;

	ТаблицаДвижений.ЗаполнитьЗначения(Склад,  "Склад");

	ТаблицаДвижений.ЗаполнитьЗначения(Дата,   "Период");
	ТаблицаДвижений.ЗаполнитьЗначения(Ссылка, "Регистратор");
	ТаблицаДвижений.ЗаполнитьЗначения(Истина, "Активность");

	ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.КодыОперацийПартииТоваров.КорректировкаКачества,"КодОперацииПартииТоваров");
	
	ЗаполнитьКолонкиРегистраСписанныеТоварыУпр(ТаблицаДвижений);

	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.СписанныеТовары.ВыполнитьДвижения();
	КонецЕсли;

	Если Движения.СписанныеТовары.Модифицированность() Тогда
	    Движения.СписанныеТовары.Записать(Истина);
	КонецЕсли;		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если (ТипЗнч(Основание) = Тип("ДокументСсылка.ПоступлениеТоваровУслуг")) Тогда

		// Заполним реквизиты из стандартного набора.
		ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);

		Если Основание.Проведен Тогда

			ЗаполнитьТоварыПоПоступлениюТоваровУпр(Основание);

		КонецЕсли;

	ИначеЕсли (ТипЗнч(Основание) = Тип("ДокументСсылка.ПриходныйОрдерНаТовары")) Тогда
		Если Основание.БезПраваПродажи Тогда
			Возврат;
		КонецЕсли;

		// Заполним реквизиты из стандартного набора.
		ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);

		Если Основание.Проведен Тогда

			ЗаполнитьТоварыПоПриходномуОрдеруУпр(Основание);

		КонецЕсли;
		
	ИначеЕсли (ТипЗнч(Основание) = Тип("ДокументСсылка.ПеремещениеТоваров")) Тогда

		// Заполним реквизиты из стандартного набора.
		ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);
		Склад = Основание.СкладПолучатель;
		Комментарий = "Создан на основании "+Основание;
		
		Если Основание.Проведен Тогда
			
			Для каждого Выборка из Основание.Товары Цикл
				СтрокаТабличнойЧасти = Товары.Добавить();
				
				СтрокаТабличнойЧасти.Номенклатура         = Выборка.Номенклатура;
				СтрокаТабличнойЧасти.Количество           = Выборка.Количество;
				СтрокаТабличнойЧасти.ЕдиницаИзмерения     = Выборка.ЕдиницаИзмерения;
				СтрокаТабличнойЧасти.Коэффициент          = Выборка.Коэффициент;
				
				СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
				СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;
				СтрокаТабличнойЧасти.Качество                   = Справочники.Качество.Новый;
				//СтрокаТабличнойЧасти.КачествоНовое              = Справочники.Качество.Новый;
				
			КонецЦикла;
			
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры // ОбработкаЗаполнения()

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	мУдалятьДвижения = НЕ ЭтоНовый();

	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

	// Проверка заполнения единицы измерения мест и количества мест
	ОбработкаТабличныхЧастей.ПриЗаписиПроверитьЕдиницуИзмеренияМест(Товары);
	
	//05092017 Доработка уценки. Рустам.
	Отказ = ЗаписьНевозможна();

КонецПроцедуры // ПередЗаписью

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	СтруктураШапкиДокумента.Вставить("СкладОтправитель", Склад);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке      = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Склад",           "ВидСклада",                        "ВидСклада");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Организации",     "ОтражатьВРегламентированномУчете", "ОтражатьВРегламентированномУчете");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика", "ВестиПартионныйУчетПоСкладам",     "ВестиПартионныйУчетПоСкладам");
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика", "ВестиУчетТоваровОрганизацийВРазрезеСкладов", "ВестиУчетТоваровОрганизацийВРазрезеСкладов");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);

	// Получим необходимые данные для проведения и проверки заполнения данных по табличной части "Товары".
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Номенклатура"                 , "Номенклатура");
	СтруктураПолей.Вставить("Количество"                   , "Количество * Коэффициент /Номенклатура.ЕдиницаХраненияОстатков.Коэффициент");
	СтруктураПолей.Вставить("ХарактеристикаНоменклатуры"   , "ХарактеристикаНоменклатуры");
	СтруктураПолей.Вставить("СерияНоменклатуры"            , "СерияНоменклатуры");
	СтруктураПолей.Вставить("Набор"                        , "Номенклатура.Набор");
	СтруктураПолей.Вставить("Комплект"                     , "Номенклатура.Комплект");
	СтруктураПолей.Вставить("Услуга"                       , "Номенклатура.Услуга");
	СтруктураПолей.Вставить("Качество"                     , "Качество");
	СтруктураПолей.Вставить("КачествоНовое"                , "КачествоНовое");
	СтруктураПолей.Вставить("Склад"                        , "Ссылка.Склад");

	РезультатЗапросаПоТоварам = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураПолей);

	// Подготовим таблицу товаров для проведения.
	ТаблицаПоТоварам = ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента);

	// Проверить заполнение ТЧ "Товары".
	ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок);

	// Движения по документу
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры// ОбработкаПроведения()

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);

КонецПроцедуры


Процедура ЗаполнитьПоСериям() Экспорт

	ТоварыТабличнойЧасти = Товары.Выгрузить();
	ТоварыТабличнойЧасти.Свернуть("Номенклатура"); 

	МассивНоменклатуры = ТоварыТабличнойЧасти.ВыгрузитьКолонку("Номенклатура");

	ЭтоНТТ = (Склад.ВидСклада = Перечисления.ВидыСкладов.НТТ);
	
	ТаблицаСерий = УправлениеЗапасами.ПолучитьТаблицуОстатковПоСериям(Склад, Организация, МассивНоменклатуры, , ЭтоНТТ, ,);

	СтрокаИндекса = "Номенклатура,ХарактеристикаНоменклатуры,Качество";
	Если ЭтоНТТ Тогда
		СтрокаИндекса = СтрокаИндекса+",Цена";
	КонецЕсли;
	ТаблицаСерий.Индексы.Добавить(СтрокаИндекса);

	ТоварыТабличнойЧасти=Товары.Выгрузить();
	
	Товары.Очистить();

	КолонкиТабЧасти = ТоварыТабличнойЧасти.Колонки;

	ИспользоватьУказаниеСерийНоменклатурыПриРезервировании = Константы.ИспользоватьУказаниеСерийНоменклатурыПриРезервировании.Получить();

	Для Каждого ИсходнаяСтрока ИЗ ТоварыТабличнойЧасти Цикл
		СтруктураПоиска   = Новый Структура;
		СтруктураПоиска.Вставить("Номенклатура",               ИсходнаяСтрока.Номенклатура);
		СтруктураПоиска.Вставить("ХарактеристикаНоменклатуры", ИсходнаяСтрока.ХарактеристикаНоменклатуры);
		СтруктураПоиска.Вставить("Качество",                   ИсходнаяСтрока.Качество);
		Если ЭтоНТТ Тогда
			СтруктураПоиска.Вставить("Цена"                  , ИсходнаяСтрока.Цена);
		КонецЕсли;

		ЗаполнятьИзРезервов = ложь;
		НайденныеСтроки = ТаблицаСерий.НайтиСтроки(СтруктураПоиска);
		
		СтрокаСПустойСерией = Неопределено;
		КоличествоОсталосьПогасить = ИсходнаяСтрока.Количество;

		Для Каждого Строка Из НайденныеСтроки Цикл

			Если КоличествоОсталосьПогасить<=0 Тогда
				Прервать;
			КонецЕсли;

			Если Строка.Остаток <= 0 Тогда
				Продолжить;
			КонецЕсли;

			ОстатокВЕдиницахДокумента = Строка.Остаток * ИсходнаяСтрока.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсходнаяСтрока.ЕдиницаИзмерения.Коэффициент;

			Если ОстатокВЕдиницахДокумента >= КоличествоОсталосьПогасить Тогда
				КоэффСписания = КоличествоОсталосьПогасить/ОстатокВЕдиницахДокумента;
			Иначе
				КоэффСписания = 1
			КонецЕсли;

			СписанноеКоличество = Окр(ОстатокВЕдиницахДокумента * КоэффСписания, 3, РежимОкругления.Окр15как20);

			Если СписанноеКоличество = 0 Тогда
				Продолжить;
			КонецЕсли;

			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Номенклатура               = ИсходнаяСтрока.Номенклатура;
			НоваяСтрока.ЕдиницаИзмерения           = ИсходнаяСтрока.ЕдиницаИзмерения;
			НоваяСтрока.Коэффициент                = ИсходнаяСтрока.Коэффициент;
			НоваяСтрока.ХарактеристикаНоменклатуры = ИсходнаяСтрока.ХарактеристикаНоменклатуры;
			НоваяСтрока.СерияНоменклатуры          = Строка.СерияНоменклатуры;
			НоваяСтрока.Качество                   = ИсходнаяСтрока.Качество;
			НоваяСтрока.КачествоНовое              = ИсходнаяСтрока.КачествоНовое;
			НоваяСтрока.Количество                 = СписанноеКоличество; 
			НоваяСтрока.КоличествоМест             = НоваяСтрока.Количество / НоваяСтрока.Коэффициент;
			
			Если НЕ ЗначениеЗаполнено(НоваяСтрока.СерияНоменклатуры) Тогда
				СтрокаСПустойСерией = НоваяСтрока;
			КонецЕсли;

			КоличествоОсталосьПогасить = КоличествоОсталосьПогасить-СписанноеКоличество;
			Строка.Остаток = Строка.Остаток - СписанноеКоличество* ИсходнаяСтрока.ЕдиницаИзмерения.Коэффициент / ИсходнаяСтрока.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;            

		КонецЦикла;

		Если КоличествоОсталосьПогасить>0 Тогда
			Если СтрокаСПустойСерией = Неопределено Тогда
				НоваяСтрока = Товары.Добавить();
				НоваяСтрока.Номенклатура               = ИсходнаяСтрока.Номенклатура;
				НоваяСтрока.ЕдиницаИзмерения           = ИсходнаяСтрока.ЕдиницаИзмерения;
				НоваяСтрока.Коэффициент                = ИсходнаяСтрока.Коэффициент;
				НоваяСтрока.ХарактеристикаНоменклатуры = ИсходнаяСтрока.ХарактеристикаНоменклатуры;
				НоваяСтрока.СерияНоменклатуры          = ИсходнаяСтрока.СерияНоменклатуры;
				НоваяСтрока.Качество                   = ИсходнаяСтрока.Качество;
				НоваяСтрока.КачествоНовое              = ИсходнаяСтрока.КачествоНовое;
				НоваяСтрока.Количество                 = КоличествоОсталосьПогасить;
				НоваяСтрока.КоличествоМест             = НоваяСтрока.Количество / НоваяСтрока.Коэффициент;
			Иначе
				СтрокаСПустойСерией.Количество = СтрокаСПустойСерией.Количество+КоличествоОсталосьПогасить;
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

//05092017 Доработка уценки. Рустам.
Функция ЗаписьНевозможна ()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Рег.Объект
	               |ИЗ
	               |	РегистрСведений.ЗначенияСвойствОбъектов КАК Рег
	               |ГДЕ
	               |	Рег.Объект В(&Товары)
	               |	И Рег.Свойство = &НеУценяется
	               |	И Рег.Значение = ИСТИНА";
	Запрос.УстановитьПараметр("Товары",Товары.ВыгрузитьКолонку("Номенклатура"));
	Запрос.УстановитьПараметр("НеУценяется",ПланыВидовХарактеристик.СвойстваОбъектов.НайтиПоНаименованию("НеУценяется",Истина));
	
	Рез = Запрос.Выполнить();
	
	Если Рез.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Сообщить ("Запрещено уценять следующие товары:",СтатусСообщения.Важное);
	Выб = Рез.Выбрать();
	Пока Выб.Следующий() Цикл
		Сообщить (Выб.Объект);
	КонецЦикла;
	
	Возврат Истина;
	
	
КонецФункции
мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");
