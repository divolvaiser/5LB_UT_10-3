﻿
// Обработчик события ПередЗаписью .
//
Процедура ПередЗаписью(Отказ)

	Если НЕ ОбменДанными.Загрузка
	   И ТипЗнч(Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
		Если Владелец.ЕдиницаХраненияОстатков = Ссылка Тогда

			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);

			Запрос.Текст =
			"ВЫБРАТЬ
			|	ЕдиницыИзмерения.Ссылка КАК Элемент,
			|	ЕдиницыИзмерения.Коэффициент КАК Коэффициент
			|ИЗ
			|	Справочник.ЕдиницыИзмерения КАК ЕдиницыИзмерения
			|
			|ГДЕ
			|	ЕдиницыИзмерения.Ссылка = &ТекущийЭлемент";

			Выборка = Запрос.Выполнить().Выбрать();

			Если Выборка.Следующий() Тогда
				Если Выборка.Коэффициент <> Коэффициент Тогда
					Если ПолныеПрава.Номенклатура_СуществуютСсылки(Владелец, Неопределено) Тогда
						ОбщегоНазначения.СообщитьОбОшибке("Единица """ + СокрЛП(Наименование) + """ является единицей хранения остатков для """ + 
						                 СокрЛП(Владелец) + """ и уже участвует в товародвижении. Изменить коэффициент уже нельзя!", Отказ);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;

		КонецЕсли;
	КонецЕсли;

	//НМА 25.07.17 Проверка единиц измерения >>
	Если Не ОбменДанными.Загрузка И Не Отказ Тогда
		Если Не ЗначениеЗаполнено(ЕдиницаПоКлассификатору) Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Для """+СокрЛП(Владелец.Наименование)+""" у единицы измерения """+СокрЛП(ЕдиницаПоКлассификатору.Наименование)+""" не заполнено поле: По классификатору!");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	ВидНоменклатурыТовар=Ложь;
	Если ТипЗнч(Владелец)=Тип("СправочникСсылка.Номенклатура") Тогда
		Если Владелец.ВидНоменклатуры.Наименование = "Товар" Тогда
			ВидНоменклатурыТовар=Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ОбменДанными.Загрузка И Не Отказ  Тогда 
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕдиницыИзмерения.Владелец,
		|	ЕдиницыИзмерения.ЕдиницаПоКлассификатору КАК ЕдиницаПоКлассификатору
		|ИЗ
		|	Справочник.ЕдиницыИзмерения КАК ЕдиницыИзмерения
		|ГДЕ
		|	ЕдиницыИзмерения.Владелец = &Владелец
		|	И ЕдиницыИзмерения.ЕдиницаПоКлассификатору = &ЕдиницаПоКлассификатору
		|
		|СГРУППИРОВАТЬ ПО
		|	ЕдиницыИзмерения.Владелец,
		|	ЕдиницыИзмерения.ЕдиницаПоКлассификатору";
		
		Если ЭтоНовый() Тогда
			Запрос.УстановитьПараметр("Владелец", Владелец);
			Запрос.УстановитьПараметр("ЕдиницаПоКлассификатору", ЕдиницаПоКлассификатору);
			РезультатЗапроса = Запрос.Выполнить();
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
			Если ВыборкаДетальныеЗаписи.Количество()>0 Тогда
				ОбщегоНазначения.СообщитьОбОшибке("У владельца """+Владелец.Наименование+""" уже имеется единица измерения: """+ЕдиницаПоКлассификатору.Наименование+"""");
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
		Если ВидНоменклатурыТовар и ЕдиницаПоКлассификатору<>Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("796") Тогда
			Запрос.УстановитьПараметр("Владелец", Владелец);
			Запрос.УстановитьПараметр("ЕдиницаПоКлассификатору", Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("796"));  //штука
			РезультатЗапроса = Запрос.Выполнить();
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
			Если ВыборкаДетальныеЗаписи.Количество()=0 Тогда
				ОбщегоНазначения.СообщитьОбОшибке("У владельца """+Владелец.Наименование+""" отсутствует единица измерения ""шт""!");
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ОбменДанными.Загрузка И Не Отказ  Тогда //проверка коэффициента единицы измерения
		Если ВидНоменклатурыТовар Тогда
			Если ЕдиницаПоКлассификатору.Код = "796" Тогда //штука
				Если Коэффициент = 0 Тогда
					Сообщить("Для """+СокрЛП(Владелец.Наименование)+""" у единицы измерения """+СокрЛП(ЕдиницаПоКлассификатору.Наименование)+""" не задан коэффициент! Он будет установлен равным 1.");
					Коэффициент = 1;
				ИначеЕсли Коэффициент > 1 Тогда
					Сообщить("Для """+СокрЛП(Владелец.Наименование)+""" у единицы измерения """+СокрЛП(ЕдиницаПоКлассификатору.Наименование)+""" коэффициент указан не верный! Он будет установлен равным 1.");
					Коэффициент = 1;
				КонецЕсли;
			ИначеЕсли Коэффициент = 0 Тогда 
				ОбщегоНазначения.СообщитьОбОшибке("Для """+СокрЛП(Владелец.Наименование)+""" у единицы измерения """+СокрЛП(ЕдиницаПоКлассификатору.Наименование)+""" не задан коэффициент!");
				Отказ = Истина;
			ИначеЕсли Коэффициент = 1 Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Для """+СокрЛП(Владелец.Наименование)+""" уже имеется единица измерения: ""шт"" с коэффициентом 1. Укажите в поле Коэффициент количество штук в """+СокрЛП(ЕдиницаПоКлассификатору.Наименование)+"""");
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	//НМА 25.07.17 Проверка единиц измерения <<
	
	Если Не ОбменДанными.Загрузка
		И Не Отказ  Тогда
		Если (Ширина<>0) И (Высота<>0) И (Глубина<>0) Тогда
			Объем = Ширина*Высота*Глубина;
			Если ЕдиницаПоКлассификатору = Справочники.КлассификаторЕдиницИзмерения.НайтиПоНаименованию("кор",истина) Тогда
				Вл = Владелец.ПолучитьОбъект();
				Вл.Объем = Объем/Коэффициент;
				Попытка
					Вл.Записать();
					Сообщить ("Объём коробки и объём штуки из этой коробки успешно рассчитан");
				Исключение
					Сообщить (ОписаниеОшибки());
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;								
	КонецЕсли;
	

	G = 1;
	////Если ТипЗнч(НоменклатураСссылка) = Тип("СправочникСсылка.Номенклатура") Тогда
	//ОбщегоНазначения5LB.ЗаписатьИзменениеОбъекта(ЭтотОбъект);	
	////ЗаписатьИзменениеРегистраСведенийСОбъектом(НоменклатураСссылка,
	////				"ЕдиницыИзмерения", ТекСвойство.Штрихкод);
	////			Прервать;	// толкьо одно значение!
	////		КонецЦикла;		
	////КонецЕсли;

		
КонецПроцедуры // ПередЗаписью()


Процедура ПриЗаписи(Отказ)
	
	//Если (РольДоступна("НСИ_УТ11") ИЛИ РольДоступна("НСИ_УТ11_ПолныеПрава")) Тогда	

	//	// < 20.12.16 Вялов - ИНТЕГРАЦИЯ - обязательная проверка и создание Н+Х УТ-11
	//	Если НЕ (Ссылка.Владелец._5LB_НеУчаствуетВСинхронизации 
	//		ИЛИ  Ссылка.Владелец.Родитель._5LB_НеУчаствуетВСинхронизации)
	//		Тогда	// искл.н-ра
	
	НоменклатураСссылка = ЭтотОбъект.Владелец; 	
	//НоменклатураСссылка.ЭтоНовый()	
	Если ТипЗнч(НоменклатураСссылка)=Тип("СправочникСсылка.Номенклатура") Тогда //НМА 25.07.17
		Если НачалоМинуты(НоменклатураСссылка._5LB_ДатаСоздания) >= НачалоМинуты(ТекущаяДата() - 60) Тогда
			ОбщегоНазначения5LB.ЗаписатьИзменениеОбъекта(ЭтотОбъект);
		КонецЕсли;
	КонецЕсли; //НМА 25.07.17
	
	
// < 20.01.17 Вялов - ИНТЕГРАЦИЯ - обязательная проверка и создание Н+Х УТ-11
	Если НЕ Отказ Тогда	//  не отказ  	
	Если НЕ ЭтотОбъект.ОбменДанными.Загрузка Тогда	// в режиме обмене - нет	
			
		стрИзменение = ОбщегоНазначения5LB.ПолучитьИзмененияОбъектаСтрокой(Ссылка, Истина);
		// только если есть изменение		
		Если стрИзменение <> "" Тогда
			
			ОбрСоотв = Обработки._5LB_СоответствиеНоменклатуры_УТ11;     								
			НоменклатураСсылка = Ссылка.Владелец;
			бЕстьОбмен = ОбрСоотв.НоменклатураДоступнаДляОбмена(НоменклатураСсылка);				
			НоменклатураУТ11 = ОбрСоотв.ПолучитьНоменклатуру(НоменклатураСсылка);
			
			Если ЗначениеЗаполнено(НоменклатураУТ11) Тогда 	// только если есть номенклатура УТ-11
				
				//НоменклатураХарактеристика =ОбрСоотв.НайтиСоответствиеНоменклатуры(ЕдВладелец); 
				//НоменклатураУТ11 = НоменклатураХарактеристика.Номенклатура;
				
				//Если Не ЗначениеЗаполнено(НоменклатураУТ11) Тогда
				//		Отказ = Истина;
				//	Иначе
				//		//ОбрСоотв = Обработки._СоответствиеНоменклатуры_УТ11;
				//		бСообщать = Ложь;
				//		Рез = ОбрСоотв.НайтиСоздатьЕдиницыИзмерения(
				//			ЕдВладелец, НоменклатураУТ11, бСообщать); 							
				//		Если Рез = Неопределено Тогда
				//			Отказ = Истина; 
				//		КонецЕсли;
				//	КонецЕсли;
				//КонецЕсли; 
				
				НоменклатураХарактеристика =ОбрСоотв.НайтиСоответствиеНоменклатуры(НоменклатураСсылка); 
				СтруктураНоменклатураУТ11 = НоменклатураХарактеристика.Номенклатура;
				СтруктураХарактеристикаУТ11 = НоменклатураХарактеристика.Характеристика;	
				//Если НЕ ЗначениеЗаполнено(СтруктураНоменклатураУТ11) Тогда					
				//	РезОбновления = ОбрСоотв.ОбновитьЗаписьСоответствий(ЕдВладелец, НоменклатураУТ11, СтруктураХарактеристикаУТ11);  
				//		Если НЕ РезОбновления Тогда
				//		статусСообщ = СтатусСообщения.Важное;
				//			стрСообщ = "Не удалось создать запись связи номенклатуры УТ-10 и новой номенклатуры УТ-11!";
				//			Сообщить(стрСообщ, статусСообщ);
				//			Отказ = Истина;
				//		КонецЕсли;  
				//	КонецЕсли;
				
				стрИзменение =  Формат(ТекущаяДата(), "ДФ='dd.MM.yy HH:mm'") 
					+ "ед.изм. '" + Ссылка.Наименование + "' | "; 
				РезОбновления = ОбрСоотв.ОбновитьНоменклатуруСРеквизитами(
							НоменклатураСсылка, НоменклатураУТ11, СтруктураХарактеристикаУТ11, Истина,
							стрИзменение);										
					//Если РезОбновления Тогда
				бСообщать = Истина;	
				ОбрСоотв.НайтиСоздатьЕдиницыИзмерения(НоменклатураСсылка, НоменклатураУТ11, бСообщать);

				      
			
			КонецЕсли;  // только если есть номенклатура УТ-11
		КонецЕсли;		// только если есть изменени
		
	КонецЕсли;	// в режиме обмене - нет			
	КонецЕсли;		//  не отказ 
	// 20.12.16 Вялов - ИНТЕГРАЦИЯ - обязательная проверка и создание Н+Х УТ-11 >

КонецПроцедуры

