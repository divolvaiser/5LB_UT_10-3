﻿


Процедура _ЗаполнитьРеквизитыПоВидуНоменклатуры(Номенклатура) Экспорт
	
	Если Номенклатура.ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
		
	Если Не ЗначениеЗаполнено(Номенклатура.ВидНоменклатуры) Тогда
		Возврат;	
		
	Иначе
		
		ВидНом = Номенклатура.ВидНоменклатуры;
		
		Номенклатура.ТипНоменклатуры   				= ВидНом.ТипНоменклатуры;
		Номенклатура.ВариантОформленияПродажи       = ВидНом.ВариантОказанияУслуг;
//		Номенклатура.ГруппаДоступа					= ВидНом.;
		Номенклатура.ИспользованиеХарактеристик		= ВидНом.ИспользованиеХарактеристик;
		//Номенклатура.ВладелецХарактеристик		= ВидНом.;
		Номенклатура.ВладелецХарактеристик			= ВидНом.ВладелецХарактеристик;
		Номенклатура.ВладелецТоварныхКатегорий		= ВидНом.ВладелецТоварныхКатегорий;
//		Номенклатура.ИспользоватьУпаковки			= ВидНом.;

	КонецЕсли;
	

	
КонецПроцедуры


