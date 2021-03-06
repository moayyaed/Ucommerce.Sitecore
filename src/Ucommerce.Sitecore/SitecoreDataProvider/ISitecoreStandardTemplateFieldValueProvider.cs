﻿using Sitecore.Data;
using Sitecore.Data.Items;

namespace Ucommerce.Sitecore.SitecoreDataProvider
{
	public interface ISitecoreStandardTemplateFieldValueProvider
	{
		void AddFieldValues(ID itemId, VersionUri version, FieldList fieldList);

		void SaveItem(ID id, ItemChanges changes);
	}
}
