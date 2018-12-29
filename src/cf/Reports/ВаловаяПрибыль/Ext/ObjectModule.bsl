﻿#Если Клиент Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ НАЧАЛЬНОЙ НАСТРОЙКИ ОТЧЕТА

// Процедура установки начальных настроек отчета с использованием текста запроса
//
Процедура УстановитьНачальныеНастройки(ДополнительныеПараметры = Неопределено) Экспорт
	
	// Настройка общих параметров универсального отчета
	
	// Содержит название отчета, которое будет выводиться в шапке.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.мНазваниеОтчета = "Название отчета";
	УниверсальныйОтчет.мНазваниеОтчета = СокрЛП(ЭтотОбъект.Метаданные().Синоним);
	
	// Содержит признак необходимости отображения надписи и поля выбора раздела учета в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	
	// Содержит имя регистра, по метаданным которого будет выполняться заполнение настроек отчета.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.ИмяРегистра = "ТоварыНаСкладах";
	
	// Содержит признак необходимости вывода отрицательных значений показателей красным цветом.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	
	// Содержит признак необходимости вывода в отчет общих итогов.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.ВыводитьОбщиеИтоги = Ложь;
	
	// Содержит признак необходимости вывода детальных записей в отчет.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ВыводитьДетальныеЗаписи = Истина;
	
	// Содержит признак необходимости отображения флага использования свойств и категорий в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Ложь;
	//УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Истина;
	
	// Содержит признак использования свойств и категорий при заполнении настроек отчета.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ИспользоватьСвойстваИКатегории = Истина;
	
	// Содержит признак использования простой формы настроек отчета без группировок колонок.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.мРежимФормыНастройкиБезГруппировокКолонок = Истина;
	
	// Дополнительные параметры, переданные из отчета, вызвавшего расшифровку.
	// Информация, передаваемая в переменной ДополнительныеПараметры, может быть использована
	// для реализации специфичных для данного отчета параметрических настроек.
	
	// Описание исходного текста запроса.
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВложенныйЗапрос.Организация КАК Организация,
	|	ВложенныйЗапрос.Проект КАК Проект,
	|	ВложенныйЗапрос.Подразделение КАК Подразделение,
	|	ВложенныйЗапрос.Покупатель КАК Покупатель,
	|	ВложенныйЗапрос.ДоговорПокупателя КАК ДоговорПокупателя,
	|	ВложенныйЗапрос.Номенклатура КАК Номенклатура,
	|	ВложенныйЗапрос.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|	ВложенныйЗапрос.ЗаказПокупателя КАК ЗаказПокупателя,
	|	ВложенныйЗапрос.Регистратор КАК Регистратор,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Организация) КАК ОрганизацияПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Проект) КАК ПроектПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Подразделение) КАК ПодразделениеПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Покупатель) КАК ПокупательПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.ДоговорПокупателя) КАК ДоговорПокупателяПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Номенклатура) КАК НоменклатураПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.ХарактеристикаНоменклатуры) КАК ХарактеристикаНоменклатурыПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.ЗаказПокупателя) КАК ЗаказПокупателяПредставление,
	|	ПРЕДСТАВЛЕНИЕ(ВложенныйЗапрос.Регистратор) КАК РегистраторПредставление,
	|	ВложенныйЗапрос.Период КАК Период,
	|	ВложенныйЗапрос.ПериодДень КАК ПериодДень,
	|	ВложенныйЗапрос.ПериодНеделя КАК ПериодНеделя,
	|	ВложенныйЗапрос.ПериодДекада КАК ПериодДекада,
	|	ВложенныйЗапрос.ПериодМесяц КАК ПериодМесяц,
	|	ВложенныйЗапрос.ПериодКвартал КАК ПериодКвартал,
	|	ВложенныйЗапрос.ПериодПолугодие КАК ПериодПолугодие,
	|	ВложенныйЗапрос.ПериодГод КАК ПериодГод,
	|	ВложенныйЗапрос.Количество КАК Количество,
	|	ВложенныйЗапрос.КоличествоЕдиницОтчетов КАК КоличествоЕдиницОтчетов,
	|	ВложенныйЗапрос.КоличествоБазовыхЕдиниц КАК КоличествоБазовыхЕдиниц,
	|	ВложенныйЗапрос.СтоимостьБезНДС КАК СтоимостьБезНДС,
	|	ВложенныйЗапрос.НДС КАК НДС,
	|	ВложенныйЗапрос.Стоимость КАК Стоимость,
	|	ВложенныйЗапрос.Себестоимость КАК Себестоимость,
	|	ВложенныйЗапрос.ВаловаяПрибыль КАК ВаловаяПрибыль,
	|	ВложенныйЗапрос.Эффективность КАК Эффективность,
	|	ВложенныйЗапрос.Рентабельность КАК Рентабельность
	|	//ПОЛЯ_СВОЙСТВА
	|	//ПОЛЯ_КАТЕГОРИИ
	|{ВЫБРАТЬ
	|	Организация.*,
	|	Проект.*,
	|	Подразделение.*,
	|	Покупатель.*,
	|	ДоговорПокупателя.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	ЗаказПокупателя.*,
	|	Регистратор.*,
	|	Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод,
	|	Количество,
	|	КоличествоЕдиницОтчетов,
	|	КоличествоБазовыхЕдиниц,
	|	СтоимостьБезНДС,
	|	НДС,
	|	Стоимость,
	|	Себестоимость,
	|	ВаловаяПрибыль,
	|	Эффективность,
	|	Рентабельность
	|	//ПСЕВДОНИМЫ_СВОЙСТВА
	|	//ПСЕВДОНИМЫ_КАТЕГОРИИ
	|}
	|ИЗ
	|	(ВЫБРАТЬ
	|		ВложенныйЗапрос.Организация КАК Организация,
	|		ВложенныйЗапрос.Проект КАК Проект,
	|		ВложенныйЗапрос.Подразделение КАК Подразделение,
	|		ВложенныйЗапрос.Покупатель КАК Покупатель,
	|		ВложенныйЗапрос.ДоговорПокупателя КАК ДоговорПокупателя,
	|		ВложенныйЗапрос.Номенклатура КАК Номенклатура,
	|		ВложенныйЗапрос.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|		ВложенныйЗапрос.ЗаказПокупателя КАК ЗаказПокупателя,
	|		ВложенныйЗапрос.Регистратор КАК Регистратор,
	|		ВложенныйЗапрос.Период КАК Период,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, ДЕНЬ) КАК ПериодДень,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, НЕДЕЛЯ) КАК ПериодНеделя,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, ДЕКАДА) КАК ПериодДекада,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, МЕСЯЦ) КАК ПериодМесяц,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, КВАРТАЛ) КАК ПериодКвартал,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, ПОЛУГОДИЕ) КАК ПериодПолугодие,
	|		НАЧАЛОПЕРИОДА(ВложенныйЗапрос.Период, ГОД) КАК ПериодГод,
	|		СУММА(ВложенныйЗапрос.Количество) КАК Количество,
	|		СУММА(ВложенныйЗапрос.КоличествоЕдиницОтчетов) КАК КоличествоЕдиницОтчетов,
	|		СУММА(ВложенныйЗапрос.КоличествоБазовыхЕдиниц) КАК КоличествоБазовыхЕдиниц,
	|		СУММА(ВложенныйЗапрос.СтоимостьБезНДС) КАК СтоимостьБезНДС,
	|		СУММА(ВложенныйЗапрос.НДС) КАК НДС,
	|		СУММА(ВложенныйЗапрос.Стоимость) КАК Стоимость,
	|		СУММА(ВложенныйЗапрос.Себестоимость) КАК Себестоимость,
	|		ВЫБОР
	|			КОГДА &НеВключатьНДСВСтоимостьПартий
	|				ТОГДА СУММА(ВложенныйЗапрос.СтоимостьБезНДС)
	|			ИНАЧЕ СУММА(ВложенныйЗапрос.Стоимость)
	|		КОНЕЦ - СУММА(ВложенныйЗапрос.Себестоимость) КАК ВаловаяПрибыль,
	|		100 * ВЫБОР
	|			КОГДА &НеВключатьНДСВСтоимостьПартий
	|				ТОГДА ВЫБОР
	|						КОГДА СУММА(ВложенныйЗапрос.Себестоимость) <> 0
	|							ТОГДА (СУММА(ВложенныйЗапрос.СтоимостьБезНДС) - СУММА(ВложенныйЗапрос.Себестоимость)) / СУММА(ВложенныйЗапрос.Себестоимость)
	|						ИНАЧЕ 0
	|					КОНЕЦ
	|			ИНАЧЕ ВЫБОР
	|					КОГДА СУММА(ВложенныйЗапрос.Себестоимость) <> 0
	|						ТОГДА (СУММА(ВложенныйЗапрос.Стоимость) - СУММА(ВложенныйЗапрос.Себестоимость)) / СУММА(ВложенныйЗапрос.Себестоимость)
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		КОНЕЦ КАК Эффективность,
	|		100 * ВЫБОР
	|			КОГДА &НеВключатьНДСВСтоимостьПартий
	|				ТОГДА ВЫБОР
	|						КОГДА СУММА(ВложенныйЗапрос.СтоимостьБезНДС) <> 0
	|							ТОГДА (СУММА(ВложенныйЗапрос.СтоимостьБезНДС) - СУММА(ВложенныйЗапрос.Себестоимость)) / СУММА(ВложенныйЗапрос.СтоимостьБезНДС)
	|						ИНАЧЕ 0
	|					КОНЕЦ
	|			ИНАЧЕ ВЫБОР
	|					КОГДА СУММА(ВложенныйЗапрос.Стоимость) <> 0
	|						ТОГДА (СУММА(ВложенныйЗапрос.Стоимость) - СУММА(ВложенныйЗапрос.Себестоимость)) / СУММА(ВложенныйЗапрос.Стоимость)
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		КОНЕЦ КАК Рентабельность
	|	{ВЫБРАТЬ
	|		Организация,
	|		Проект,
	|		Подразделение,
	|		Покупатель,
	|		ДоговорПокупателя,
	|		Номенклатура,
	|		ХарактеристикаНоменклатуры,
	|		ЗаказПокупателя,
	|		Регистратор,
	|		Период,
	|		ПериодДень,
	|		ПериодНеделя,
	|		ПериодДекада,
	|		ПериодМесяц,
	|		ПериодКвартал,
	|		ПериодПолугодие,
	|		ПериодГод}
	|	ИЗ
	|		(ВЫБРАТЬ
	|			ПродажиОбороты.Проект КАК Проект,
	|			ПродажиОбороты.Подразделение КАК Подразделение,
	|			ПродажиОбороты.Контрагент КАК Покупатель,
	|			ПродажиОбороты.ДоговорКонтрагента КАК ДоговорПокупателя,
	|			ПродажиОбороты.Номенклатура КАК Номенклатура,
	|			ПродажиОбороты.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|			ПродажиОбороты.ЗаказПокупателя КАК ЗаказПокупателя,
	|			ПродажиОбороты.Организация КАК Организация,
	|			ПродажиОбороты.Регистратор КАК Регистратор,
	|			ПродажиОбороты.Период КАК Период,
	|			ПродажиОбороты.КоличествоОборот КАК Количество,
	|			ПродажиОбороты.КоличествоОборот * ЕСТЬNULL(ПродажиОбороты.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент, 1) / ЕСТЬNULL(ПродажиОбороты.Номенклатура.ЕдиницаДляОтчетов.Коэффициент, 1) КАК КоличествоЕдиницОтчетов,
	|			ПродажиОбороты.КоличествоОборот * ЕСТЬNULL(ПродажиОбороты.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент, 1) КАК КоличествоБазовыхЕдиниц,
	|			ПродажиОбороты.СтоимостьОборот - ПродажиОбороты.НДСОборот КАК СтоимостьБезНДС,
	|			ПродажиОбороты.НДСОборот КАК НДС,
	|			ПродажиОбороты.СтоимостьОборот КАК Стоимость,
	|			ЕСТЬNULL(ТаблицаРегистраПродажиСебестоимость.СтоимостьОборот, 0) КАК Себестоимость
	|		ИЗ
	|			РегистрНакопления.Продажи.Обороты(&ДатаНач, &ДатаКон, Регистратор, {Организация.* КАК Организация, Проект.* КАК Проект, Подразделение.* КАК Подразделение, Контрагент.* КАК Покупатель, ДоговорКонтрагента.* КАК ДоговорПокупателя, Номенклатура.* КАК Номенклатура, ХарактеристикаНоменклатуры.* КАК ХарактеристикаНоменклатуры, ЗаказПокупателя.* КАК ЗаказПокупателя}) КАК ПродажиОбороты
	|				ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|					ПродажиСебестоимость.Номенклатура КАК Номенклатура,
	|					ПродажиСебестоимость.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|					ПродажиСебестоимость.ЗаказПокупателя КАК ЗаказПокупателя,
	|					ВЫБОР
	|						КОГДА ПродажиСебестоимость.ДокументДвижения <> НЕОПРЕДЕЛЕНО
	|							ТОГДА ПродажиСебестоимость.ДокументДвижения
	|						ИНАЧЕ ПродажиСебестоимость.Регистратор
	|					КОНЕЦ КАК Регистратор,
	|					СУММА(ПродажиСебестоимость.Стоимость) КАК СтоимостьОборот
	|				ИЗ
	|					РегистрНакопления.ПродажиСебестоимость КАК ПродажиСебестоимость
	|				ГДЕ
	|					ПродажиСебестоимость.Период МЕЖДУ &ДатаНачала И &ДатаКонца
	|				{ГДЕ
	|					ПродажиСебестоимость.Проект.* КАК Проект,
	|					ПродажиСебестоимость.Подразделение.* КАК Подразделение,
	|					ПродажиСебестоимость.Номенклатура.* КАК Номенклатура,
	|					ПродажиСебестоимость.ХарактеристикаНоменклатуры.* КАК ХарактеристикаНоменклатуры,
	|					ПродажиСебестоимость.ЗаказПокупателя.* КАК ЗаказПокупателя}
	|				
	|				СГРУППИРОВАТЬ ПО
	|					ПродажиСебестоимость.Номенклатура,
	|					ПродажиСебестоимость.ХарактеристикаНоменклатуры,
	|					ПродажиСебестоимость.ЗаказПокупателя,
	|					ВЫБОР
	|						КОГДА ПродажиСебестоимость.ДокументДвижения <> НЕОПРЕДЕЛЕНО
	|							ТОГДА ПродажиСебестоимость.ДокументДвижения
	|						ИНАЧЕ ПродажиСебестоимость.Регистратор
	|					КОНЕЦ) КАК ТаблицаРегистраПродажиСебестоимость
	|				ПО ТаблицаРегистраПродажиСебестоимость.Номенклатура = ПродажиОбороты.Номенклатура
	|					И ТаблицаРегистраПродажиСебестоимость.ХарактеристикаНоменклатуры = ПродажиОбороты.ХарактеристикаНоменклатуры
	|					И ТаблицаРегистраПродажиСебестоимость.ЗаказПокупателя = ПродажиОбороты.ЗаказПокупателя
	|					И ТаблицаРегистраПродажиСебестоимость.Регистратор = ПродажиОбороты.Регистратор) КАК ВложенныйЗапрос
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ВложенныйЗапрос.Организация,
	|		ВложенныйЗапрос.Проект,
	|		ВложенныйЗапрос.Подразделение,
	|		ВложенныйЗапрос.Покупатель,
	|		ВложенныйЗапрос.ДоговорПокупателя,
	|		ВложенныйЗапрос.Номенклатура,
	|		ВложенныйЗапрос.ХарактеристикаНоменклатуры,
	|		ВложенныйЗапрос.ЗаказПокупателя,
	|		ВложенныйЗапрос.Регистратор,
	|		ВложенныйЗапрос.Период
	|	
	|	ИМЕЮЩИЕ
	|		(СУММА(ВложенныйЗапрос.Количество) <> 0
	|			ИЛИ СУММА(ВложенныйЗапрос.Стоимость) <> 0
	|			ИЛИ СУММА(ЕСТЬNULL(ВложенныйЗапрос.Себестоимость, 0)) <> 0)) КАК ВложенныйЗапрос
	|	//СОЕДИНЕНИЯ
	|{ГДЕ
	|	ВложенныйЗапрос.Регистратор.*,
	|	ВложенныйЗапрос.Период,
	|	ВложенныйЗапрос.ПериодДень,
	|	ВложенныйЗапрос.ПериодНеделя,
	|	ВложенныйЗапрос.ПериодДекада,
	|	ВложенныйЗапрос.ПериодМесяц,
	|	ВложенныйЗапрос.ПериодКвартал,
	|	ВложенныйЗапрос.ПериодПолугодие,
	|	ВложенныйЗапрос.ПериодГод,
	|	ВложенныйЗапрос.Количество,
	|	ВложенныйЗапрос.КоличествоЕдиницОтчетов,
	|	ВложенныйЗапрос.КоличествоБазовыхЕдиниц,
	|	ВложенныйЗапрос.СтоимостьБезНДС,
	|	ВложенныйЗапрос.НДС,
	|	ВложенныйЗапрос.Стоимость,
	|	ВложенныйЗапрос.Себестоимость,
	|	ВложенныйЗапрос.ВаловаяПрибыль,
	|	ВложенныйЗапрос.Эффективность,
	|	ВложенныйЗапрос.Рентабельность
	|	//УСЛОВИЯ_СВОЙСТВА
	|	//УСЛОВИЯ_КАТЕГОРИИ
	|}
	|{УПОРЯДОЧИТЬ ПО
	|	Организация.*,
	|	Проект.*,
	|	Подразделение.*,
	|	Покупатель.*,
	|	ДоговорПокупателя.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	ЗаказПокупателя.*,
	|	Регистратор.*,
	|	Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод,
	|	Количество,
	|	КоличествоЕдиницОтчетов,
	|	КоличествоБазовыхЕдиниц,
	|	СтоимостьБезНДС,
	|	НДС,
	|	Стоимость,
	|	Себестоимость,
	|	ВаловаяПрибыль,
	|	Эффективность,
	|	Рентабельность
	|	//ПСЕВДОНИМЫ_СВОЙСТВА
	|	//ПСЕВДОНИМЫ_КАТЕГОРИИ
	|}
	|ИТОГИ
	|	СУММА(Количество),
	|	СУММА(КоличествоЕдиницОтчетов),
	|	СУММА(КоличествоБазовыхЕдиниц),
	|	СУММА(СтоимостьБезНДС),
	|	СУММА(НДС),
	|	СУММА(Стоимость),
	|	СУММА(Себестоимость),
	|	ВЫБОР
	|		КОГДА &НеВключатьНДСВСтоимостьПартий
	|			ТОГДА СУММА(СтоимостьБезНДС)
	|		ИНАЧЕ СУММА(Стоимость)
	|	КОНЕЦ - СУММА(Себестоимость) КАК ВаловаяПрибыль,
	|	100 * ВЫБОР
	|		КОГДА &НеВключатьНДСВСтоимостьПартий
	|			ТОГДА ВЫБОР
	|					КОГДА СУММА(Себестоимость) <> 0
	|						ТОГДА (СУММА(СтоимостьБезНДС) - СУММА(Себестоимость)) / СУММА(Себестоимость)
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ ВЫБОР
	|				КОГДА СУММА(Себестоимость) <> 0
	|					ТОГДА (СУММА(Стоимость) - СУММА(Себестоимость)) / СУММА(Себестоимость)
	|				ИНАЧЕ 0
	|			КОНЕЦ
	|	КОНЕЦ КАК Эффективность,
	|	100 * ВЫБОР
	|		КОГДА &НеВключатьНДСВСтоимостьПартий
	|			ТОГДА ВЫБОР
	|					КОГДА СУММА(СтоимостьБезНДС) <> 0
	|						ТОГДА (СУММА(СтоимостьБезНДС) - СУММА(Себестоимость)) / СУММА(СтоимостьБезНДС)
	|					ИНАЧЕ 0
	|				КОНЕЦ
	|		ИНАЧЕ ВЫБОР
	|				КОГДА СУММА(Стоимость) <> 0
	|					ТОГДА (СУММА(Стоимость) - СУММА(Себестоимость)) / СУММА(Стоимость)
	|				ИНАЧЕ 0
	|			КОНЕЦ
	|	КОНЕЦ КАК Рентабельность
	|	//ИТОГИ_СВОЙСТВА
	|	//ИТОГИ_КАТЕГОРИИ
	|ПО
	|	ОБЩИЕ
	|{ИТОГИ ПО
	|	Организация.*,
	|	Проект.*,
	|	Подразделение.*,
	|	Покупатель.*,
	|	ДоговорПокупателя.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	ЗаказПокупателя.*,
	|	Регистратор.*,
	|	Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод
	|	//ПСЕВДОНИМЫ_СВОЙСТВА
	|	//ПСЕВДОНИМЫ_КАТЕГОРИИ
	|}";

	// В универсальном отчете включен флаг использования свойств и категорий.
	Если УниверсальныйОтчет.ИспользоватьСвойстваИКатегории Тогда
		
		// Добавление свойств и категорий поля запроса в таблицу полей.
		// Необходимо вызывать для каждого поля запроса, предоставляющего возможность использования свойств и категорий.
		// УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля(<ПсевдонимТаблицы>.<Поле> , <ПсевдонимПоля>, <Представление>, <Назначение>);
		
		УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.Организация", "Организация", "Организация", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_Организации);
		УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.Покупатель", "Покупатель", "Покупатель", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_Контрагенты);
		УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.ДоговорПокупателя", "ДоговорПокупателя", "Договор покупателя", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_ДоговорыКонтрагентов);
        УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.Номенклатура", "Номенклатура", "Номенклатура", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_Номенклатура);
        УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.ХарактеристикаНоменклатуры", "ХарактеристикаНоменклатуры", "Характеристика номенклатуры", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Справочник_ХарактеристикиНоменклатуры);
        УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.ЗаказПокупателя", "ЗаказПокупателя", "Заказ покупателя", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Документы);
		УниверсальныйОтчет.ДобавитьСвойстваИКатегорииДляПоля("ВложенныйЗапрос.ЗаказПокупателя", "ЗаказПокупателя", "Заказ покупателя", ПланыВидовХарактеристик.НазначенияСвойствКатегорийОбъектов.Документ_ЗаказПокупателя);
		
		// Добавление свойств и категорий в исходный текст запроса.
		УниверсальныйОтчет.ДобавитьВТекстЗапросаСвойстваИКатегории(ТекстЗапроса);
		
	КонецЕсли;
		
	// Инициализация текста запроса построителя отчета
	УниверсальныйОтчет.ПостроительОтчета.Текст = ТекстЗапроса;
	
	// Представления полей отчета.
	// Необходимо вызывать для каждого поля запроса.
	// УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить(<ИмяПоля>, <ПредставлениеПоля>);
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Организация", "Организация");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Проект", "Проект");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Подразделение", "Подразделение");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Покупатель", "Покупатель");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ДоговорПокупателя", "Договор покупателя");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Номенклатура", "Номенклатура");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ХарактеристикаНоменклатуры", "Характеристика номенклатуры");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ЗаказПокупателя", "Заказ покупателя");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Количество", "Количество (ед. хранения)");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоЕдиницОтчетов", "Количество (ед. отчетов)");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("КоличествоБазовыхЕдиниц", "Количество (базовых ед.)");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("СтоимостьБезНДС", "Стоимость продажи без НДС");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("НДС", "НДС продажи");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Стоимость", "Стоимость продажи с НДС");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Себестоимость", "Себестоимость");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ВаловаяПрибыль", "Валовая прибыль");
	
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Эффективность", "Эффективность, %");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Рентабельность", "Рентабельность, %");

	// Добавление показателей
	// Необходимо вызывать для каждого добавляемого показателя.
	ВалютаУпр = глЗначениеПеременной("ВалютаУправленческогоУчета");
	// УниверсальныйОтчет.ДобавитьПоказатель(<ИмяПоказателя>, <ПредставлениеПоказателя>, <ВключенПоУмолчанию>, <Формат>, <ИмяГруппы>, <ПредставлениеГруппы>);
	УниверсальныйОтчет.ДобавитьПоказатель("Количество", "Ед. хранения", Истина, "ЧЦ=15; ЧДЦ=3", "Количество", "Количество");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдиниц", "Базовых ед.", Ложь, "ЧЦ=15; ЧДЦ=3", "Количество", "Количество");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетов", "Ед. отчетов", Ложь, "ЧЦ=15; ЧДЦ=3", "Количество", "Количество");
	
	УниверсальныйОтчет.ДобавитьПоказатель("СтоимостьБезНДС", "Без НДС", Истина, "ЧЦ=15; ЧДЦ=2", "СтоимостьПродажи", "Стоимость продажи (" + ВалютаУпр + ")");
	УниверсальныйОтчет.ДобавитьПоказатель("НДС", "НДС", Ложь, "ЧЦ=15; ЧДЦ=2", "СтоимостьПродажи");
	УниверсальныйОтчет.ДобавитьПоказатель("Стоимость", "С НДС", Истина, "ЧЦ=15; ЧДЦ=2", "СтоимостьПродажи");
	
	УниверсальныйОтчет.ДобавитьПоказатель("Себестоимость", "Себестоимость  (" + ВалютаУпр + ")", Ложь, "ЧЦ=15; ЧДЦ=2");
	
	УниверсальныйОтчет.ДобавитьПоказатель("ВаловаяПрибыль", "Валовая прибыль (" + ВалютаУпр + ")", Истина, "ЧЦ=15; ЧДЦ=2");
	
	УниверсальныйОтчет.ДобавитьПоказатель("Эффективность", "Эффективность, %", Ложь, "ЧЦ=15; ЧДЦ=2");
	УниверсальныйОтчет.ДобавитьПоказатель("Рентабельность", "Рентабельность, %", Истина, "ЧЦ=15; ЧДЦ=2");

	// Добавление предопределенных группировок строк отчета.
	// Необходимо вызывать для каждой добавляемой группировки строки.
	// УниверсальныйОтчет.ДобавитьИзмерениеСтроки(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Покупатель");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Номенклатура");
	
	// Добавление предопределенных группировок колонок отчета.
	// Необходимо вызывать для каждой добавляемой группировки колонки.
	// УниверсальныйОтчет.ДобавитьИзмерениеКолонки(<ПутьКДанным>);
	
	// Добавление предопределенных отборов отчета.
	// Необходимо вызывать для каждого добавляемого отбора.
	// УниверсальныйОтчет.ДобавитьОтбор(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьОтбор("Организация");
	УниверсальныйОтчет.ДобавитьОтбор("Подразделение");
	УниверсальныйОтчет.ДобавитьОтбор("Покупатель");
	УниверсальныйОтчет.ДобавитьОтбор("Номенклатура");
	
	// Добавление предопределенных полей порядка отчета.
	// Необходимо вызывать для каждого добавляемого поля порядка.
	// УниверсальныйОтчет.ДобавитьПорядок(<ПутьКДанным>);
	
	// Установка связи подчиненных и родительских полей
	// УниверсальныйОтчет.УстановитьСвязьПолей(<ПутьКДанным>, <ПутьКДаннымРодитель>);
	
	// Установка связи полей и измерений
	// УниверсальныйОтчет.УстановитьСвязьПоляИИзмерения(<ИмяПоля>, <ИмяИзмерения>);
	
	// Установка представлений полей
	УниверсальныйОтчет.УстановитьПредставленияПолей(УниверсальныйОтчет.мСтруктураПредставлениеПолей, УниверсальныйОтчет.ПостроительОтчета);
	
	// Установка типов значений свойств в отборах отчета
	УниверсальныйОтчет.УстановитьТипыЗначенийСвойствДляОтбора();
	
	// Заполнение начальных настроек универсального отчета
	УниверсальныйОтчет.УстановитьНачальныеНастройки(Ложь);
	
	// Добавление дополнительных полей
	// Необходимо вызывать для каждого добавляемого дополнительного поля.
	// УниверсальныйОтчет.ДобавитьДополнительноеПоле(<ПутьКДанным>, <Размещение>, <Положение>);
	 
	
КонецПроцедуры // УстановитьНачальныеНастройки()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМИРОВАНИЯ ОТЧЕТА 
	
// Процедура формирования отчета
//
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт
	
	// Перед формирование отчета можно установить необходимые параметры универсального отчета.
	Отказ = Ложь;
	УчетнаяПолитика = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(Не ЗначениеЗаполнено(УниверсальныйОтчет.ДатаКон), ТекущаяДата(), УниверсальныйОтчет.ДатаКон), Отказ);
	УниверсальныйОтчет.ПостроительОтчета.Параметры.Вставить("НеВключатьНДСВСтоимостьПартий", ?(Отказ, Ложь, УчетнаяПолитика.НеВключатьНДСВСтоимостьПартий));
	
	УниверсальныйОтчет.СформироватьОтчет(ТабличныйДокумент);

КонецПроцедуры // СформироватьОтчет()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Процедура обработки расшифровки
//
Процедура ОбработкаРасшифровки(Расшифровка, Объект) Экспорт
	
	// Дополнительные параметры в расшифровывающий отчет можно передать
	// посредством инициализации переменной "ДополнительныеПараметры".
	
	ДополнительныеПараметры = Неопределено;
	УниверсальныйОтчет.ОбработкаРасшифровкиУниверсальногоОтчета(Расшифровка, Объект, ДополнительныеПараметры);
	
КонецПроцедуры // ОбработкаРасшифровки()

// Формирует структуру для сохранения настроек отчета
//
Процедура СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками) Экспорт
	
	УниверсальныйОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками);
	
КонецПроцедуры // СформироватьСтруктуруДляСохраненияНастроек()

// Заполняет настройки отчета из структуры сохраненных настроек
//
Функция ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт
	
	Возврат УниверсальныйОтчет.ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ЭтотОбъект);
	
КонецФункции // ВосстановитьНастройкиИзСтруктуры()

// Содержит значение используемого режима ввода периода.
// Тип: Число.
// Возможные значения: 0 - произвольный период, 1 - на дату, 2 - неделя, 3 - декада, 4 - месяц, 5 - квартал, 6 - полугодие, 7 - год
// Значение по умолчанию: 0
// Пример:
// УниверсальныйОтчет.мРежимВводаПериода = 1;




#КонецЕсли
