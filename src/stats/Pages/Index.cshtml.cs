using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace stats.Pages
{
	public class IndexModel : PageModel
	{
		private readonly FnContext _context;
		public IndexModel(FnContext context)
		{
			_context = context;
		}

		public List<PhoneStatsModel> Stats { get; private set; }
		public void OnGet()
		{
			Stats = _context.Fn
						.GroupBy(f => f.Type)
						.Select(f => new PhoneStatsModel(f.Key, f.Count()))
						.ToList();
		}
	}

	public class PhoneStatsModel
	{
		public PhoneStatsModel(byte type, int count)
		{
			Type = type;
			Count = count;
		}

		public byte Type { get; }
		public string TypeName =>
			Type == 0
				? "iPhone"
				: Type == 1
					? "Android"
					: "Other";
		public int Count { get; }
	}
}
