﻿/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Женя 13.06.2018
// Печать чека через фиск.регистратор
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ((
Процедура ПечататьЧекКоррекции (Источник,Отказ)  Экспорт
	//Элементарные проверки на реквизиты документа перенесены в процедуру "ЧекНажатие" формы документа "Реализация товаров и услуг" 
	
	Сдача = Ложь;
	Если Источник.ВидОплаты = Справочники.ВидыОплатЧекаККМ.Наличные Тогда
		ВидОплаты = "Нал";
		СуммаОпл = Источник.СуммаДокумента;
		Сдача = СуммаОпл<>Источник.Сумма;
		Если Сдача Тогда //25042018 если разница в пределах копеек, отменяем сдачу:) и сумма оплаты = сумме дока
			ТекРазница = СуммаОпл-Источник.Сумма;
			ТекРазница = Макс(-ТекРазница,ТекРазница);
			Если ТекРазница<1 Тогда
				Сдача=Ложь;
				СуммаОпл =  Источник.СуммаДокумента;
			КонецЕсли;
		КонецЕсли;
	Иначе
		ВидОплаты = "БезНал";
		СуммаОпл =  Источник.СуммаДокумента;
	КонецЕсли;
	
	Если РаботаСРеализациями.ПодготовитьФРКПродаже(Ложь)=Истина Тогда
		Отказ=Истина;
		Возврат;
	КонецЕсли;
	
	лОрганизация = Источник.Организация;
	
	РаботаСРеализациями.ПечатьСтроки(Символ(9)+"w"+Символ(9)+"w"+Символ(9)+"w"+"."+Символ(9)+"5"+Символ(9)+"l"+Символ(9)+"b"+"."+Символ(9)+"r"+Символ(9)+"u",1);
	
	Если лОрганизация = Неопределено Тогда
		//ПечатьСтроки(Символ(9)+"О"+Символ(9)+"О"+Символ(9)+"О"+" "+Символ(9)+"5"+Символ(9)+"Л"+Символ(9)+"Б",0);
		РаботаСРеализациями.ПечатьСтроки("ООО 5ЛБ",0);
		//ПечатьСтроки("ИНН 7715948131",0);
		РаботаСРеализациями.ПечатьСтроки("ИНН 7715431262",0);
	Иначе
		РаботаСРеализациями.ПечатьСтроки(лОрганизация.Наименование,0);
		РаботаСРеализациями.ПечатьСтроки("ИНН "+СокрЛП(лОрганизация.ИНН),0);
	КонецЕсли;
	
	РаботаСРеализациями.ПечатьСтроки(РаботаСРеализациями.ВернутьАдресГамаза(),0);
	РаботаСРеализациями.ПечатьСтроки("  ",0);
	
	Попытка
		флПечатьSP = (ПараметрыСеанса.НеВыгружатьВSailPlay=ЛОжь);
	Исключение
		флПечатьSP = Ложь;
	КонецПопытки; 
	
КонецПроцедуры

// )) 13.06.2018 Женя

