//
//  Types.h
//  GPSTracker
//
//  Created by YS on 2/6/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#ifndef GPSTracker_Types_h
#define GPSTracker_Types_h

typedef enum
{
	LanguageAutomatic = 0,
	LanguageBelarusian,
	LanguageGerman,
	LanguageEnglish,
	LanguageSpanish,
	LanguageFrench,
	LanguageRussian,
	LanguageChinese,
    LanguagePoland,
    LanguageItalian,
    LanguageTurkey
}Language;

typedef enum
{
	ActiveInBackgroundAlways = 0,
	ActiveInBackground30,
	ActiveInBackgroundHour,
	ActiveInBackground3Hours,
	ActiveInBackground12Hours
}ActiveInBackground;

typedef enum
{
	RequestsFrequencyAutomatically = 0,
	RequestsFrequencySeldom,
	RequestsFrequencyVerySeldom,
	RequestsFrequencyAverage,
	RequestsFrequencyOften,
	RequestsFrequencyVeryOften
}RequestsFrequency;

typedef enum
{
	Radius1 = 0,
	Radius1_5,
	Radius5_15,
	Radius15_70
}Radius;

typedef enum
{
	AttachmentTypeNone = 0,
	AttachmentTypeImage
}AttachmentType;

typedef enum
{
	UpdateTypeUsers,
	UpdateTypeMessages,
	UpdateTypePins
}UpdateType;

#endif
