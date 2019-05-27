using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace stats
{
	public class FnContext : DbContext
	{
		public FnContext(DbContextOptions<FnContext> options)
			: base(options)
		{
		}

		public DbSet<Fn> Fn { get; set; }
	}

	[Table("fn")]
	public class Fn
	{
		[Key]
		public int Id { get; set; }
		public string UserAgent { get; set; }
		public byte Type { get; set; }
		public DateTime Date { get; set; }
	}
}