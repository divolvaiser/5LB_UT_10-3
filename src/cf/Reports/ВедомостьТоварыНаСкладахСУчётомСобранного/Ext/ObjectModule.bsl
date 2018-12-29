﻿#Если Клиент Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ НАЧАЛЬНОЙ НАСТРОЙКИ ОТЧЕТА

// Процедура установки начальных настроек отчета по метаданным регистра накопления
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
	//УниверсальныйОтчет.ИмяРегистра = "ТоварыНаСкладах";
	
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
	
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ИсточникДанных.Склад КАК Склад,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.Склад) КАК СкладПредставление,
	|	ИсточникДанных.Номенклатура КАК Номенклатура,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.Номенклатура) КАК НоменклатураПредставление,
	|	ИсточникДанных.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.ХарактеристикаНоменклатуры) КАК ХарактеристикаНоменклатурыПредставление,
	|	ИсточникДанных.СерияНоменклатуры КАК СерияНоменклатуры,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.СерияНоменклатуры) КАК СерияНоменклатурыПредставление,
	|	ИсточникДанных.Качество КАК Качество,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.Качество) КАК КачествоПредставление,
	|	ИсточникДанных.Номенклатура.БазоваяЕдиницаИзмерения КАК БазоваяЕдиницаИзмерения,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.Номенклатура.БазоваяЕдиницаИзмерения) КАК БазоваяЕдиницаИзмеренияПредставление,
	|	ИсточникДанных.КоличествоНачальныйОстаток КАК КоличествоНачальныйОстаток,
	|	ИсточникДанных.КоличествоПриход КАК КоличествоПриход,
	|	ИсточникДанных.КоличествоРасход КАК КоличествоРасход,
	|	ИсточникДанных.КоличествоКонечныйОстаток КАК КоличествоКонечныйОстаток,
	|	ИсточникДанных.КоличествоОборот КАК КоличествоОборот,
	|	ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент КАК КоличествоЕдиницОтчетовНачальныйОстаток,
	|	ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент КАК КоличествоЕдиницОтчетовПриход,
	|	ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент КАК КоличествоЕдиницОтчетовРасход,
	|	ИсточникДанных.КоличествоКонечныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент КАК КоличествоЕдиницОтчетовКонечныйОстаток,
	|	ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент КАК КоличествоЕдиницОтчетовОборот,
	|	ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК КоличествоБазовыхЕдНачальныйОстаток,
	|	ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК КоличествоБазовыхЕдПриход,
	|	ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК КоличествоБазовыхЕдРасход,
	|	ИсточникДанных.КоличествоКонечныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК КоличествоБазовыхЕдКонечныйОстаток,
	|	ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК КоличествоБазовыхЕдОборот,
	|	ИсточникДанных.Регистратор КАК Регистратор,
	|	ПРЕДСТАВЛЕНИЕ(ИсточникДанных.Регистратор) КАК РегистраторПредставление,
	|	ИсточникДанных.Период КАК Период,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ДЕНЬ) КАК ПериодДень,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, НЕДЕЛЯ) КАК ПериодНеделя,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ДЕКАДА) КАК ПериодДекада,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, МЕСЯЦ) КАК ПериодМесяц,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, КВАРТАЛ) КАК ПериодКвартал,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ПОЛУГОДИЕ) КАК ПериодПолугодие,
	|	НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ГОД) КАК ПериодГод,
	|	ТоварыВРезервеНаСкладахОстатки.КоличествоОстаток КАК ОстатокРезерв,
	|	ТоварыНаПолкеОстатки.КоличествоСобраноОстаток КАК ОстатокНаПолке,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА ТоварыНаПолкеОстатки.КоличествоСобраноОстаток ЕСТЬ NULL 
	|					ИЛИ ТоварыНаПолкеОстатки.КоличествоСобраноОстаток = 0
	|				ТОГДА ИсточникДанных.КоличествоКонечныйОстаток
	|			ИНАЧЕ ИсточникДанных.КоличествоКонечныйОстаток - ТоварыНаПолкеОстатки.КоличествоСобраноОстаток
	|		КОНЕЦ КАК ЧИСЛО(15, 3)) КАК СвободныйОстаток
	|{ВЫБРАТЬ
	|	Склад.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	СерияНоменклатуры.*,
	|	Качество.*,
	|	БазоваяЕдиницаИзмерения.*,
	|	КоличествоНачальныйОстаток,
	|	КоличествоПриход,
	|	КоличествоРасход,
	|	КоличествоКонечныйОстаток,
	|	КоличествоОборот,
	|	КоличествоЕдиницОтчетовНачальныйОстаток,
	|	КоличествоЕдиницОтчетовПриход,
	|	КоличествоЕдиницОтчетовРасход,
	|	КоличествоЕдиницОтчетовКонечныйОстаток,
	|	КоличествоЕдиницОтчетовОборот,
	|	КоличествоБазовыхЕдНачальныйОстаток,
	|	КоличествоБазовыхЕдПриход,
	|	КоличествоБазовыхЕдРасход,
	|	КоличествоБазовыхЕдКонечныйОстаток,
	|	КоличествоБазовыхЕдОборот,
	|	Регистратор.* КАК Регистратор,
	|	Период КАК Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод,
	|	СвободныйОстаток,
	|	ОстатокНаПолке}
	|ИЗ
	|	РегистрНакопления.ТоварыНаСкладах.ОстаткиИОбороты(&ДатаНач, &ДатаКон, Регистратор {(&Периодичность)}, , {(Склад).* КАК Склад, (Номенклатура).* КАК Номенклатура, (ХарактеристикаНоменклатуры).* КАК ХарактеристикаНоменклатуры, (СерияНоменклатуры).* КАК СерияНоменклатуры, (Качество).* КАК Качество, (Номенклатура.БазоваяЕдиницаИзмерения).* КАК БазоваяЕдиницаИзмерения}) КАК ИсточникДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаКон, {(Склад).* КАК Склад, (Номенклатура).* КАК Номенклатура, (ХарактеристикаНоменклатуры).* КАК ХарактеристикаНоменклатуры, (СерияНоменклатуры).* КАК СерияНоменклатуры, (ДокументРезерва).* КАК ДокументОснование}) КАК ТоварыВРезервеНаСкладахОстатки
	|		ПО ИсточникДанных.Склад = ТоварыВРезервеНаСкладахОстатки.Склад
	|			И ИсточникДанных.Номенклатура = ТоварыВРезервеНаСкладахОстатки.Номенклатура
	|			И ИсточникДанных.ХарактеристикаНоменклатуры = ТоварыВРезервеНаСкладахОстатки.ХарактеристикаНоменклатуры
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаПолке.Остатки(&ДатаКон, {(Склад).* КАК Склад, (Номенклатура).* КАК Номенклатура, (ХарактеристикаНоменклатуры).* КАК ХарактеристикаНоменклатуры, (СерияНоменклатуры).* КАК СерияНоменклатуры, (ДокументРезерва).* КАК ДокументОснование}) КАК ТоварыНаПолкеОстатки
	|		ПО ИсточникДанных.Склад = ТоварыНаПолкеОстатки.Склад
	|			И ИсточникДанных.Номенклатура = ТоварыНаПолкеОстатки.Номенклатура
	|			И ИсточникДанных.ХарактеристикаНоменклатуры = ТоварыНаПолкеОстатки.ХарактеристикаНоменклатуры
	|{ГДЕ
	|	ИсточникДанных.КоличествоНачальныйОстаток КАК КоличествоНачальныйОстаток,
	|	ИсточникДанных.КоличествоПриход КАК КоличествоПриход,
	|	ИсточникДанных.КоличествоРасход КАК КоличествоРасход,
	|	ИсточникДанных.КоличествоКонечныйОстаток КАК КоличествоКонечныйОстаток,
	|	ИсточникДанных.КоличествоОборот КАК КоличествоОборот,
	|	(ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент) КАК КоличествоЕдиницОтчетовНачальныйОстаток,
	|	(ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент) КАК КоличествоЕдиницОтчетовПриход,
	|	(ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент) КАК КоличествоЕдиницОтчетовРасход,
	|	(ИсточникДанных.КоличествоКонечныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент) КАК КоличествоЕдиницОтчетовКонечныйОстаток,
	|	(ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / ИсточникДанных.Номенклатура.ЕдиницаДляОтчетов.Коэффициент) КАК КоличествоЕдиницОтчетовОборот,
	|	(ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК КоличествоБазовыхЕдНачальныйОстаток,
	|	(ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК КоличествоБазовыхЕдПриход,
	|	(ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК КоличествоБазовыхЕдРасход,
	|	(ИсточникДанных.КоличествоКонечныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК КоличествоБазовыхЕдКонечныйОстаток,
	|	(ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК КоличествоБазовыхЕдОборот,
	|	ИсточникДанных.Регистратор.* КАК Регистратор,
	|	ИсточникДанных.Период КАК Период,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ДЕНЬ)) КАК ПериодДень,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, НЕДЕЛЯ)) КАК ПериодНеделя,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ДЕКАДА)) КАК ПериодДекада,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, МЕСЯЦ)) КАК ПериодМесяц,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, КВАРТАЛ)) КАК ПериодКвартал,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ПОЛУГОДИЕ)) КАК ПериодПолугодие,
	|	(НАЧАЛОПЕРИОДА(ИсточникДанных.Период, ГОД)) КАК ПериодГод,
	|	ТоварыВРезервеНаСкладахОстатки.КоличествоОстаток КАК ОстатокРезерв,
	|	ТоварыВРезервеНаСкладахОстатки.ДокументРезерва КАК ДокументРезерва,
	|	ТоварыНаПолкеОстатки.КоличествоСобраноОстаток КАК ОстатокНаПолке,
	|	ТоварыНаПолкеОстатки.ДокументРезерва КАК ДокументРезерваНаПолке,
	|	(ВЫРАЗИТЬ(ВЫБОР
	|				КОГДА ТоварыНаПолкеОстатки.КоличествоСобраноОстаток ЕСТЬ NULL 
	|						ИЛИ ТоварыНаПолкеОстатки.КоличествоСобраноОстаток = 0
	|					ТОГДА ИсточникДанных.КоличествоКонечныйОстаток
	|				ИНАЧЕ ИсточникДанных.КоличествоКонечныйОстаток - ТоварыНаПолкеОстатки.КоличествоСобраноОстаток
	|			КОНЕЦ КАК ЧИСЛО(15, 3))) КАК СвободныйОстаток}
	|{УПОРЯДОЧИТЬ ПО
	|	Склад.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	СерияНоменклатуры.*,
	|	Качество.*,
	|	БазоваяЕдиницаИзмерения.*,
	|	КоличествоНачальныйОстаток,
	|	КоличествоПриход,
	|	КоличествоРасход,
	|	КоличествоКонечныйОстаток,
	|	КоличествоОборот,
	|	КоличествоЕдиницОтчетовНачальныйОстаток,
	|	КоличествоЕдиницОтчетовПриход,
	|	КоличествоЕдиницОтчетовРасход,
	|	КоличествоЕдиницОтчетовКонечныйОстаток,
	|	КоличествоЕдиницОтчетовОборот,
	|	КоличествоБазовыхЕдНачальныйОстаток,
	|	КоличествоБазовыхЕдПриход,
	|	КоличествоБазовыхЕдРасход,
	|	КоличествоБазовыхЕдКонечныйОстаток,
	|	КоличествоБазовыхЕдОборот,
	|	Регистратор.*,
	|	Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод,
	|	СвободныйОстаток,
	|	ОстатокНаПолке}
	|ИТОГИ
	|	СУММА(КоличествоНачальныйОстаток),
	|	СУММА(КоличествоПриход),
	|	СУММА(КоличествоРасход),
	|	СУММА(КоличествоКонечныйОстаток),
	|	СУММА(КоличествоОборот),
	|	СУММА(КоличествоЕдиницОтчетовНачальныйОстаток),
	|	СУММА(КоличествоЕдиницОтчетовПриход),
	|	СУММА(КоличествоЕдиницОтчетовРасход),
	|	СУММА(КоличествоЕдиницОтчетовКонечныйОстаток),
	|	СУММА(КоличествоЕдиницОтчетовОборот),
	|	СУММА(КоличествоБазовыхЕдНачальныйОстаток),
	|	СУММА(КоличествоБазовыхЕдПриход),
	|	СУММА(КоличествоБазовыхЕдРасход),
	|	СУММА(КоличествоБазовыхЕдКонечныйОстаток),
	|	СУММА(КоличествоБазовыхЕдОборот),
	|	СУММА(ОстатокНаПолке),
	|	СУММА(СвободныйОстаток)
	|ПО
	|	ОБЩИЕ
	|{ИТОГИ ПО
	|	Склад.*,
	|	Номенклатура.*,
	|	ХарактеристикаНоменклатуры.*,
	|	СерияНоменклатуры.*,
	|	Качество.*,
	|	БазоваяЕдиницаИзмерения.*,
	|	Регистратор.*,
	|	Период,
	|	ПериодДень,
	|	ПериодНеделя,
	|	ПериодДекада,
	|	ПериодМесяц,
	|	ПериодКвартал,
	|	ПериодПолугодие,
	|	ПериодГод}";
	
	// Инициализация текста запроса построителя отчета
	УниверсальныйОтчет.ПостроительОтчета.Текст = ТекстЗапроса;

	
	УниверсальныйОтчет.ДобавитьПолеГруппировка("БазоваяЕдиницаИзмерения", "Номенклатура", "БазоваяЕдиницаИзмерения", "Базовая единица измерения");
	
	//УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовНачальныйОстаток", "ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (нач. ост.)");
	//УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовПриход",           "ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (приход)");
	//УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовРасход",           "ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (расход)");
	//УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовКонечныйОстаток",  "ИсточникДанных.КоличествоКонечныйОстаток  * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (кон. ост.)");
	//УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовОборот",           "ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (оборот)");
	
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдНачальныйОстаток",     "ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (нач. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдПриход",               "ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (приход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдРасход",               "ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (расход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдКонечныйОстаток",      "ИсточникДанных.КоличествоКонечныйОстаток  * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (кон. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдОборот",               "ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (оборот)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("ОстатокНаПолке",            "ОстатокНаПолке", "Количество (в базовых единицах) (остатокНаполке)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("СвободныйОстаток",            "СвободныйОстаток", "Количество (в базовых единицах) (свободный)");
	
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдНачальныйОстаток", "Начальный остаток", Истина, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдПриход",           "Приход",            Истина, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдРасход",           "Расход",            Истина, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдКонечныйОстаток",  "Конечный остаток",  Истина, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдОборот",           "Оборот",              Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("ОстатокНаПолке",         "На Полке",              Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("СвободныйОстаток",         "Свободный",              Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	
	
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовНачальныйОстаток", "Начальный остаток", Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовПриход",           "Приход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовРасход",           "Расход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовКонечныйОстаток",  "Конечный остаток",  Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовОборот",           "Оборот",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	
			
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоНачальныйОстаток",, Ложь,, "Количество");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоПриход",,           Ложь,, "Количество");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоРасход",,           Ложь,, "Количество");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоКонечныйОстаток",,  Ложь,, "Количество");
	//УниверсальныйОтчет.ДобавитьПоказатель("КоличествоОборот",,           Ложь,, "Количество");
	
	// Добавление предопределенных группировок строк отчета.
	// Необходимо вызывать для каждой добавляемой группировки строки.
	// УниверсальныйОтчет.ДобавитьИзмерениеСтроки(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Склад");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Номенклатура");
	
	// Добавление предопределенных группировок колонок отчета.
	// Необходимо вызывать для каждой добавляемой группировки колонки.
	// УниверсальныйОтчет.ДобавитьИзмерениеКолонки(<ПутьКДанным>);
	
	// Добавление предопределенных отборов отчета.
	// Необходимо вызывать для каждого добавляемого отбора.
	// УниверсальныйОтчет.ДобавитьОтбор(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьОтбор("Склад");
	УниверсальныйОтчет.ДобавитьОтбор("Номенклатура");
	
	// Добавление предопределенных полей порядка отчета.
	// Необходимо вызывать для каждого добавляемого поля порядка.
	// УниверсальныйОтчет.ДобавитьПорядок(<ПутьКДанным>);
	
	// Установка связи подчиненных и родительских полей
	// УниверсальныйОтчет.УстановитьСвязьПолей(<ПутьКДанным>, <ПутьКДаннымРодитель>);
	
	// Установка связи полей и измерений
	// УниверсальныйОтчет.УстановитьСвязьПоляИИзмерения(<ИмяПоля>, <ИмяИзмерения>);
	
	// Добавление дополнительных полей
	// Необходимо вызывать для каждого добавляемого дополнительного поля.
	// УниверсальныйОтчет.ДобавитьДополнительноеПоле(<ПутьКДанным>, <Размещение>, <Положение>);
	УниверсальныйОтчет.ДобавитьДополнительноеПоле("БазоваяЕдиницаИзмерения");
	
	// Заполнение начальных настроек универсального отчета
	УниверсальныйОтчет.УстановитьНачальныеНастройки(Ложь);
	
КонецПроцедуры // УстановитьНачальныеНастройки()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМИРОВАНИЯ ОТЧЕТА 
	
// Процедура формирования отчета
//
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт
	
	// Перед формирование отчета можно установить необходимые параметры универсального отчета.
	Если РольДоступна (Метаданные.Роли.collector) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|Р.Склад
		|ИЗ РегистрСведений.СоставГруппДоступностиМагазинов КАК Р
		|ГДЕ Р.ГруппаДоступности = &Юзер";
		Запрос.УстановитьПараметр("Юзер", ПараметрыСеанса.ТекущийПользователь.Ссылка);
		
		Рез = Запрос.Выполнить();
		Если Рез.Пустой() Тогда
			Доступ=0;
			Сообщить ("Вы не прикреплены к магазину. Обратитесь к руководству");
			возврат;
		КонецЕсли;
		//
		Списка = Новый СписокЗначений;
		//Выб = Рез.Выбрать();
		//Пока Выб.Следующий() Цикл
		//	Списка.Добавить(Выб.Склад);
		//КонецЦикла;
		//
		//Ответ = Вопрос("Выбрать один магазин (Да) или отчёт по всем (Нет)?",РежимДиалогаВопрос.ДаНет);
		//Если Ответ=КодВозвратаДиалога.Да Тогда
		Списка.Очистить();
		Списка.Добавить(Справочники.Склады.ПолучитьФормуВыбора().ОткрытьМодально());
		//КонецЕсли;
		
		Ответ = Вопрос("Выбрать группу/бренд (Да) или отчёт по всем (Нет)?",РежимДиалогаВопрос.ДаНет);
		Если Ответ=КодВозвратаДиалога.Да Тогда
			Группа = Справочники.Номенклатура.ПолучитьФормуВыбораГруппы().ОткрытьМодально();
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Номенклатура.Использование=Истина;
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Номенклатура.ВидСравнения = ВидСравнения.ВИерархии;
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Номенклатура.Значение = Группа;
		Иначе
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Номенклатура.Использование=Ложь;
		КонецЕсли;

		
		Если Списка.Количество()>0 Тогда
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Склад.Использование=Истина;
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Склад.ВидСравнения = ВидСравнения.ВСписке;
			УниверсальныйОтчет.ПостроительОтчета.Отбор.Склад.Значение = Списка;
		Иначе
			возврат;
		КонецЕсли;
	КонецЕсли;

	
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