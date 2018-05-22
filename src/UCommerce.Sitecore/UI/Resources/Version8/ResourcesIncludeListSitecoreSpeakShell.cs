﻿using System.Web.UI;
using ClientDependency.Core;
using UCommerce.Presentation.UI.Resources;

namespace UCommerce.Sitecore.UI.Resources.Version8
{
	[ClientDependency(ClientDependencyType.Css, "css/Speak/ucommerce-speak.css", "UCommerce", Priority = 20)]
	public class ResourcesIncludeListSitecoreSpeakShell : ResourcesIncludeListSitecoreShell, IResourcesIncludeList
	{
		public override Control GetControl()
		{
			return this;
		}
	}
}
