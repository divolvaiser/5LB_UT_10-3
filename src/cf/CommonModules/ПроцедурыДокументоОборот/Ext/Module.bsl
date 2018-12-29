﻿Процедура СформироватьДокументы () Экспорт
	
    ГлобалТрейд = Справочники.Организации.НайтиПоКоду("662");
	КонтрГлобалТрейд = Справочники.Контрагенты.НайтиПоКоду("000089596");
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Рег.Номенклатура,
	               |	Рег.КоличествоОстаток КАК Количество,
	               |	Цены.Цена КАК Цена,
	               |	Цены.ЕдиницаИзмерения КАК Ед
	               |ИЗ
	               |	РегистрНакопления.ТоварыОрганизаций.Остатки(, Организация = &Организация) КАК Рег
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&НачалоНедели, ТипЦен = &СЦЗ) КАК Цены
	               |		ПО Рег.Номенклатура = Цены.Номенклатура
	               |ГДЕ
	               |	Рег.КоличествоОстаток < 0";
	              
				   
	Запрос.УстановитьПараметр("Организация", ГлобалТрейд);
	Запрос.УстановитьПараметр("НачалоНедели",НачалоНедели(ТекущаяДата()));
	Запрос.УстановитьПараметр("СЦЗ",Справочники.ТипыЦенНоменклатуры.НайтиПоКоду("000000015"));
			
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Количество()=0 Тогда
		ОбработатьФитМилс();
		Возврат;
	КонецЕсли;
	
	
	Рел = СоздатьРелиз (КонтрГлобалТрейд);
	Если ТипЗнч(Рел)<>Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;
	
	Пост = СоздатьПоступление (ГлобалТрейд);
	Если ТипЗнч(Пост)<>Тип("ДокументОбъект.ПоступлениеТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;
		
	Пока Выб.Следующий() Цикл
						
		НовСт = Рел.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;
		
		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.Качество = Справочники.Качество.Новый;
		НовСт.СпособСписанияОстаткаТоваров = Перечисления.СпособыСписанияОстаткаТоваров.СоСклада;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Рел);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Рел);
		
				
		НовСт = Пост.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;

		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Пост);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Пост);
		НовСт.СуммаИзДокумента = НовСт.Сумма;

		
	КонецЦикла;
	
	Рел.Записать(РежимЗаписиДокумента.Проведение);
	Пост.Записать(РежимЗаписиДокумента.Проведение);
	
	
	/////03102018 Новая организация АКТИВ-ТРЕЙД ООО
	АктивТрейд = Справочники.Организации.НайтиПоКоду("677");
	КонтрАктивТрейд = Справочники.Контрагенты.НайтиПоКоду("000124139");
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Рег.Номенклатура,
	               |	Рег.КоличествоОстаток КАК Количество,
	               |	Цены.Цена КАК Цена,
	               |	Цены.ЕдиницаИзмерения КАК Ед
	               |ИЗ
	               |	РегистрНакопления.ТоварыОрганизаций.Остатки(, Организация = &Организация) КАК Рег
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&НачалоНедели, ТипЦен = &СЦЗ) КАК Цены
	               |		ПО Рег.Номенклатура = Цены.Номенклатура
	               |ГДЕ
	               |	Рег.КоличествоОстаток < 0";
	              
				   
	Запрос.УстановитьПараметр("Организация", АктивТрейд);
	Запрос.УстановитьПараметр("НачалоНедели",НачалоНедели(ТекущаяДата()));
	Запрос.УстановитьПараметр("СЦЗ",Справочники.ТипыЦенНоменклатуры.НайтиПоКоду("000000015"));
			
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Количество()=0 Тогда
		ОбработатьФитМилс();
		Возврат;
	КонецЕсли;
	
	
	Рел = СоздатьРелиз (КонтрАктивТрейд);
	Если ТипЗнч(Рел)<>Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;
	
	Пост = СоздатьПоступление (АктивТрейд);
	Если ТипЗнч(Пост)<>Тип("ДокументОбъект.ПоступлениеТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;
		
	Пока Выб.Следующий() Цикл
						
		НовСт = Рел.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;
		
		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.Качество = Справочники.Качество.Новый;
		НовСт.СпособСписанияОстаткаТоваров = Перечисления.СпособыСписанияОстаткаТоваров.СоСклада;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Рел);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Рел);
		
				
		НовСт = Пост.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;

		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Пост);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Пост);
		НовСт.СуммаИзДокумента = НовСт.Сумма;

		
	КонецЦикла;
	
	Рел.Записать(РежимЗаписиДокумента.Проведение);
	Пост.Записать(РежимЗаписиДокумента.Проведение);

	
	ОбработатьФитМилс();
КонецПроцедуры

Процедура ОбработатьФитМилс()
	
	ФитМил = Справочники.Организации.НайтиПоКоду("661");
	КонтрФитМил = Справочники.Контрагенты.НайтиПоКоду("000112064");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Рег.Номенклатура,
	               |	Рег.КоличествоОстаток КАК Количество,
	               |	Цены.Цена КАК Цена,
	               |	Цены.ЕдиницаИзмерения КАК Ед
	               |ИЗ
	               |	РегистрНакопления.ТоварыОрганизаций.Остатки(, Организация = &Организация) КАК Рег
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&НачалоНедели, ТипЦен = &СЦЗ) КАК Цены
	               |		ПО Рег.Номенклатура = Цены.Номенклатура
	               |ГДЕ
	               |	Рег.КоличествоОстаток < 0";
	              
				   
    Запрос.УстановитьПараметр("Организация", ФитМил);
	Запрос.УстановитьПараметр("НачалоНедели",НачалоНедели(ТекущаяДата()));
	Запрос.УстановитьПараметр("СЦЗ",Справочники.ТипыЦенНоменклатуры.НайтиПоКоду("000000015"));
		
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Количество()=0 Тогда
		Возврат;
	КонецЕсли;

	
	Рел = СоздатьРелиз (КонтрФитМил);
	Если ТипЗнч(Рел)<>Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;
	
	Пост = СоздатьПоступление (ФитМил);
	Если ТипЗнч(Пост)<>Тип("ДокументОбъект.ПоступлениеТоваровУслуг") Тогда
		Возврат;
	КонецЕсли;


	
	Выб = Запрос.Выполнить().Выбрать();
	Пока Выб.Следующий() Цикл
						
		НовСт = Рел.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;
		
		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.Качество = Справочники.Качество.Новый;
		НовСт.СпособСписанияОстаткаТоваров = Перечисления.СпособыСписанияОстаткаТоваров.СоСклада;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Рел);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Рел);
		
				
		НовСт = Пост.Товары.Добавить();
		НовСт.Номенклатура = Выб.Номенклатура;
		Если ЗначениеЗаполнено(Выб.Цена) Тогда
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = Выб.Цена/?(ЗначениеЗаполнено(Выб.Ед.Коэффициент),Выб.Ед.Коэффициент,1);
			Если НовСт.Цена = 0 Тогда 
				НовСт.Цена = 1;
			Иначе
				НовСт.Цена = (НовСт.Цена/100)+НовСт.Цена;
			КонецЕсли;
		Иначе
			НовСт.Количество = -Выб.Количество;
			НовСт.Цена = 1;
		КонецЕсли;

		НовСт.ЕдиницаИзмерения = Выб.Номенклатура.ЕдиницаХраненияОстатков;
		НовСт.Коэффициент = 1;
		НовСт.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НовСт, Пост);
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НовСт, Пост);
		НовСт.СуммаИзДокумента = НовСт.Сумма;

		
	КонецЦикла;
	
	Рел.Записать(РежимЗаписиДокумента.Проведение);
	Пост.Записать(РежимЗаписиДокумента.Проведение);

	
	
КонецПроцедуры

Функция СоздатьРелиз (Контр)
	
	Реал = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
	Реал.ВидОперации=Перечисления.ВидыОперацийРеализацияТоваров.ПродажаКомиссия;
	Реал.ВидПередачи=Перечисления.ВидыПередачиТоваров.СоСклада;
	Реал.Дата = НачалоНедели(ТекущаяДата());
	Реал.Организация = Справочники.Организации.НайтиПоКоду("000000001");//5лб
	Реал.Контрагент = Контр;
	Реал.ДоговорКонтрагента = Реал.Контрагент.ОсновнойДоговорКонтрагента;
	Реал.ОтражатьВУправленческомУчете=Истина;
	Реал.Склад = Справочники.Склады.НайтиПоКоду("000000005");
	Реал.ВалютаДокумента=Справочники.Валюты.НайтиПоКоду("643");
	Реал.КурсВзаиморасчетов=1;
	Реал.КратностьВзаиморасчетов=1;
	Реал.УчитыватьНДС=Истина;
	Реал.СуммаВключаетНДС=Истина;
		
	Возврат Реал;
	
КонецФункции

Функция СоздатьПоступление (Орг)
	
	Пост = Документы.ПоступлениеТоваровУслуг.СоздатьДокумент();
	Пост.ВидПоступления=Перечисления.ВидыПоступленияТоваров.НаСклад;
	Пост.Дата = НачалоНедели(ТекущаяДата())+60;
	Пост.ДатаС = Пост.Дата;
	Пост.ДатаПо = Пост.Дата;
	Пост.Организация = Орг;
	Пост.Контрагент = Справочники.Контрагенты.НайтиПоКоду("000112062");
	Если Орг=Справочники.Организации.НайтиПоКоду("662")  Тогда
		Пост.ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.НайтиПоНаименованию("СГлобалТрейд",Истина);
	//03102018 Новая организация АКТИВ-ТРЕЙД ООО	
	ИначеЕсли Орг=Справочники.Организации.НайтиПоКоду("677")  Тогда
		Пост.ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.НайтиПоНаименованию("САктивТрейд",Истина);
	Иначе
		Пост.ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.НайтиПоНаименованию("СФитМилс",Истина);
	КонецЕсли;
	Пост.ОтражатьВУправленческомУчете=Истина;
	Пост.СкладОрдер = Справочники.Склады.НайтиПоКоду("000000005");
	Пост.ВалютаДокумента=Справочники.Валюты.НайтиПоКоду("643");
	Пост.КурсВзаиморасчетов=1;
	Пост.КратностьВзаиморасчетов=1;
	Пост.УчитыватьНДС=Истина;
	Пост.СуммаВключаетНДС=Истина;
			
	Возврат Пост;

	
КонецФункции
